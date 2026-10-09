import type { Register } from 'claude-code'

// Claude Code's own /color names.
const PRIORITY_COLORS = { p0: 'red', p1: 'orange', p2: 'yellow', p3: 'blue', pnone: 'default' } as const
type Priority = keyof typeof PRIORITY_COLORS
const PRIORITIES = Object.keys(PRIORITY_COLORS) as Priority[]

const CC_STATE = 'repos/dotfiles/bin/cc-state'
const IT2 = '/Applications/iTerm 2.app/Contents/Resources/utilities/it2'
const LABEL_PREFIX = /^(IDEA|IMPL|REVIEW|NIGHT|BLOCK): /
const POLL_MS = 1_000

// The mod API has no getter for the session's name, so read it off the pane title, which iTerm2
// reports as `"✳ my title (claude)"`: quoted, behind Claude Code's status glyph, with the job name.
function paneTitle(paneName: string): string {
  return paneName
    .trim()
    .replace(/^"|"$/g, '')
    .replace(/^[^\p{L}\p{N}]+/u, '')
    .replace(/ \(claude\)$/, '')
}

export const register: Register = on => {
  // A command.run hook can't run another command, so /p0 leaves the color here for the next tick.
  let pendingColor: string | undefined

  on('session.start', async ($, e, next) => {
    for (const name of PRIORITIES) {
      await $.command.register({
        name,
        description:
          name === 'pnone' ? 'Clear the priority color' : `Mark this session ${name}: ${PRIORITY_COLORS[name]} prompt bar`,
        immediate: true,
      })
    }
    await $.command.register({
      name: 'state',
      description: 'Set the workflow state shown before the session title',
      argumentHint: 'ideating | implementing | review | overnight | blocked | clear',
      immediate: true,
    })

    const pane = (await $.env.get('ITERM_SESSION_ID'))?.split(':')[1]
    const labelFile = `${await $.env.get('HOME')}/.cache/cc-state/${pane}.label`
    let applied: string | undefined
    let isBusy = false
    // Both commands are queued by the engine until the session is idle, so a change made mid-turn lands when the turn ends.
    $.clock.every(POLL_MS, async () => {
      if (isBusy) {
        return
      }
      isBusy = true
      try {
        if (pendingColor !== undefined) {
          const color = pendingColor
          pendingColor = undefined
          await $.command.run({ command: 'color', args: color })
        }
        // bin/cc-state writes the label; this mirrors it into the title as `LABEL: title`.
        if (pane === undefined) {
          return
        }
        const label = (await $.fs.read(labelFile).catch(() => '')).trim()
        if (label === applied) {
          return
        }
        const paneName = await $.process.run([IT2, 'session', 'get-var', 'name', '--session', pane])
        if (paneName.exitCode !== 0) {
          return
        }
        const title = paneTitle(paneName.stdout)
        const base = title.replace(LABEL_PREFIX, '')
        const wanted = label === '' ? base : `${label}: ${base}`
        if (title !== wanted) {
          await $.command.run({ command: 'rename', args: wanted })
        }
        applied = label
      } finally {
        isBusy = false
      }
    })

    return next(e)
  })

  for (const name of PRIORITIES) {
    on('command.run', { command: name }, () => {
      pendingColor = PRIORITY_COLORS[name]

      return { text: `Priority: ${name === 'pnone' ? 'none' : name}` }
    })
  }

  on('command.run', { command: 'state' }, async ($, e) => {
    const state = e.args.trim()
    const ran = await $.process.run([`${await $.env.get('HOME')}/${CC_STATE}`, state])

    return { text: ran.exitCode === 0 ? `State: ${state}` : ran.stderr.trim() }
  })
}
