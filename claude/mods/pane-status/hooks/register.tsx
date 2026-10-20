import type { Register } from 'claude-code'

const CC_STATE = 'repos/dotfiles/bin/cc-state'
const POLL_MS = 1_000
// Keyed by the state bin/cc-state writes to the label file.
const BANNERS: Record<string, { text: string; backgroundColor: string }> = {
  coding: { text: 'CODING', backgroundColor: 'warning' },
  'review-bots': { text: 'REVIEW (CI/bots)', backgroundColor: 'success' },
  'review-robbie': { text: 'REVIEW (robbie)', backgroundColor: 'cyan' },
  results: { text: 'RESULTS', backgroundColor: 'blue' },
  quiz: { text: 'QUIZ', backgroundColor: '#ff5fd7' },
  questions: { text: 'QUESTIONS', backgroundColor: 'claude' },
  blocked: { text: 'BLOCKED', backgroundColor: 'error' },
}

export const register: Register = on => {
  let banner: string | undefined

  on('session.start', async ($, e, next) => {
    await $.command.register({
      name: 'state',
      description: 'Set the workflow state shown in the banner above the prompt',
      argumentHint: 'coding | review-bots | review-robbie | results | quiz | questions | blocked | clear',
      immediate: true,
    })

    const pane = (await $.env.get('ITERM_SESSION_ID'))?.split(':')[1]
    if (pane === undefined) {
      return next(e)
    }
    const labelFile = `${await $.env.get('HOME')}/.cache/cc-state/${pane}.label`
    $.clock.every(POLL_MS, async () => {
      const label = (await $.fs.read(labelFile).catch(() => '')).trim()
      const wantedBanner = label in BANNERS ? label : undefined
      if (banner !== wantedBanner) {
        banner = wantedBanner
        $.ui.invalidate('ui.render')
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
