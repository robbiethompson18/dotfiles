import type { Register } from 'claude-code'

const CC_STATE = 'repos/dotfiles/bin/cc-state'
const IT2 = '/Applications/iTerm 2.app/Contents/Resources/utilities/it2'
const DEFAULT_TITLE = 'Claude Code'
const LABEL_PREFIX =/^(IDEA|IMPL|REVIEW|NIGHT|COMPUTE|BLOCK): /
const POLL_MS = 1_000
// Labels that also get a colored banner above the prompt bar. IDEA and NIGHT only prefix the title.
const BANNERS: Record<string, { text: string; backgroundColor: string }> = {
  BLOCK: { text: 'BLOCKED: waiting on you', backgroundColor: 'error' },
  REVIEW: { text: 'REVIEW: waiting on bot reviews', backgroundColor: 'success' },
  IMPL: { text: 'CODING', backgroundColor: 'warning' },
  COMPUTE: { text: 'BABYSITTING COMPUTE', backgroundColor: 'blue' },
}

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
  let banner: string | undefined

  on('session.start', async ($, e, next) => {
    await $.command.register({
      name: 'state',
      description: 'Set the workflow state shown before the session title',
      argumentHint: 'ideating | implementing | review | overnight | babysitting | blocked | clear',
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
        const wantedBanner = label in BANNERS ? label : undefined
        if (banner !== wantedBanner) {
          banner = wantedBanner
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
        let base = title.replace(LABEL_PREFIX, '')
        // An untitled session's pane is just "Claude Code"; name it after the project instead.
        if (base === DEFAULT_TITLE) {
          base = (await $.session.root()).split('/').pop() ?? base
        }
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
    if (banner === undefined || e.props.hasSurvey) {
      return below
    }
    const { Box, Text } = $.ui.resolve(e)
    const { text, backgroundColor } = BANNERS[banner]
    const row = ` ${text}`.padEnd(e.props.bodyColumns)

    return (
      <Box flexDirection="column">
        {below}
        <Text key="banner" bold color="inverseText" backgroundColor={backgroundColor} wrap="truncate-end">
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
