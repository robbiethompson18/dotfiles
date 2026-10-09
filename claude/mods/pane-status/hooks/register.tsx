import type { Register } from 'claude-code'

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
  let isBlocked = false

  on('session.start', async ($, e, next) => {
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
    // /rename is queued by the engine until the session is idle, so a change made mid-turn lands when the turn ends.
    $.clock.every(POLL_MS, async () => {
      if (isBusy) {
        return
      }
      isBusy = true
      try {
        // bin/cc-state writes the label; this mirrors it into the title as `LABEL: title`.
        if (pane === undefined) {
          return
        }
        const label = (await $.fs.read(labelFile).catch(() => '')).trim()
        if (isBlocked !== (label === 'BLOCK')) {
          isBlocked = label === 'BLOCK'
          $.ui.invalidate('ui.render')
        }
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

  // The prompt bar's own color can only change through /color, which prints to the transcript, so the banner is a row of its own right above the bar.
  on('ui.render', { component: 'AbovePrompt' }, async ($, e, next) => {
    const below = await next(e)
    if (!isBlocked || e.props.hasSurvey) {
      return below
    }
    const { Box, Text } = $.ui.resolve(e)
    const row = ' BLOCKED: waiting on you'.padEnd(e.props.bodyColumns)

    return (
      <Box flexDirection="column">
        {below}
        <Text key="blocked" bold color="inverseText" backgroundColor="error" wrap="truncate-end">
          {row}
        </Text>
      </Box>
    )
  })

  on('command.run', { command: 'state' }, async ($, e) => {
    const state = e.args.trim()
    const ran = await $.process.run([`${await $.env.get('HOME')}/${CC_STATE}`, state])

    return { text: ran.exitCode === 0 ? `State: ${state}` : ran.stderr.trim() }
  })
}
