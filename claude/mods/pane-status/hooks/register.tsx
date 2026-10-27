import type { Register } from 'claude-code'

const CC_STATE = 'repos/dotfiles/bin/cc-state'
const POLL_MS = 1_000
// Keyed by the state bin/cc-state writes to the label file.
const BANNERS: Record<string, { text: string; backgroundColor: string }> = {
  coding: { text: 'CODING', backgroundColor: 'warning' },
  experiment: { text: 'MID EXPERIMENT', backgroundColor: '#af87ff' },
  'review-bots': { text: 'REVIEW (CI/bots)', backgroundColor: 'success' },
  'review-robbie': { text: 'REVIEW (robbie)', backgroundColor: 'cyan' },
  'intermediate-results': { text: 'INTERMEDIATE RESULTS', backgroundColor: '#87d7ff' },
  results: { text: 'FINAL RESULTS', backgroundColor: 'blue' },
  quiz: { text: 'QUIZ', backgroundColor: '#ff5fd7' },
  questions: { text: 'QUESTIONS', backgroundColor: 'claude' },
  blocked: { text: 'BLOCKED', backgroundColor: 'error' },
}
const QUESTION_COLOR = '#ffaf5f'
const SUBAGENT_COLOR = '#6c6c6c'
const MAX_SUBAGENT_ROWS = 5

// Greedy word wrap, so each banner row can be padded to the full width and the background stays solid.
function wrapRows(text: string, width: number): string[] {
  const rows: string[] = []
  let row = ''
  for (const word of text.split(' ')) {
    if (row !== '' && row.length + 1 + word.length > width) {
      rows.push(row)
      row = word
    } else {
      row = row === '' ? word : `${row} ${word}`
    }
  }
  return [...rows, row].map(r => ` ${r}`.padEnd(width + 1))
}

export const register: Register = on => {
  let banner: string | undefined
  let questions: string[] = []
  let subagents: string[] = []

  on('session.start', async ($, e, next) => {
    await $.command.register({
      name: 'state',
      description: 'Set the workflow state shown in the banner above the prompt',
      argumentHint:
        'coding | experiment | review-bots | review-robbie | intermediate-results | results | quiz | questions | blocked | clear',
      immediate: true,
    })

    const pane = (await $.env.get('ITERM_SESSION_ID'))?.split(':')[1]
    if (pane === undefined) {
      return next(e)
    }
    const labelFile = `${await $.env.get('HOME')}/.cache/cc-state/${pane}.label`
    const questionFile = labelFile.replace(/\.label$/, '.question')
    $.clock.every(POLL_MS, async () => {
      const label = (await $.fs.read(labelFile).catch(() => '')).trim()
      const wantedBanner = label in BANNERS ? label : undefined
      if (banner !== wantedBanner) {
        banner = wantedBanner
        $.ui.invalidate('ui.render')
      }
      const wantedQuestions = (await $.fs.read(questionFile).catch(() => ''))
        .split('\n')
        .map(q => q.trim())
        .filter(q => q !== '')
      if (wantedQuestions.join('\n') !== questions.join('\n')) {
        questions = wantedQuestions
        $.ui.invalidate('ui.render')
      }
      // Live subagents, one gray row each. Finished ones linger in the list for a while, hence the filter.
      const wantedSubagents = (await $.agent.list().catch(() => []))
        .filter(a => a.status === 'pending' || a.status === 'running' || a.status === 'waiting')
        .map(a => (a.type === 'general-purpose' || a.type === 'claude' ? a.description : `${a.description} (${a.type})`))
      if (wantedSubagents.join('\n') !== subagents.join('\n')) {
        subagents = wantedSubagents
        $.ui.invalidate('ui.render')
      }
    })

    return next(e)
  })

  // The prompt bar's own color can only change through /color, which prints to the transcript, so the banner is a row of its own right above the bar.
  on('ui.render', { component: 'AbovePrompt' }, async ($, e, next) => {
    const below = await next(e)
    const state = banner === undefined ? undefined : BANNERS[banner]
    if ((state === undefined && questions.length === 0 && subagents.length === 0) || e.props.hasSurvey) {
      return below
    }
    const { Box, Text } = $.ui.resolve(e)
    const width = e.props.bodyColumns
    const questionRows = questions.flatMap(q => wrapRows(`NON-BLOCKING QUESTION: ${q}`, width - 1))
    const subagentRows = subagents.length <= MAX_SUBAGENT_ROWS
      ? subagents
      : [...subagents.slice(0, MAX_SUBAGENT_ROWS - 1), `+${subagents.length - MAX_SUBAGENT_ROWS + 1} more`]

    return (
      <Box flexDirection="column">
        {below}
        {questionRows.map((row, i) => (
          <Text key={`question-${i}`} bold color="inverseText" backgroundColor={QUESTION_COLOR} wrap="truncate-end">
            {row}
          </Text>
        ))}
        {subagentRows.map((row, i) => (
          <Text key={`subagent-${i}`} bold color="inverseText" backgroundColor={SUBAGENT_COLOR} wrap="truncate-end">
            {` SUB: ${row}`.padEnd(width)}
          </Text>
        ))}
        {state !== undefined && (
          <Text key="banner" bold color="inverseText" backgroundColor={state.backgroundColor} wrap="truncate-end">
            {` ${state.text}`.padEnd(width)}
          </Text>
        )}
      </Box>
    )
  })

  // The hint line under the prompt carries the engine's background-task pills (`3 shells`, `2 agents`,
  // `↓ to manage`). The gray rows above the prompt replace them, so drop those segments.
  on('ui.render', { component: 'PromptHint' }, async ($, e, next) => {
    const kept = e.props.hint
      .split(' · ')
      .filter(segment => !/^\d+ [a-z]+$/.test(segment) && segment !== '↓ to manage')
    return next({ ...e, props: { ...e.props, hint: kept.join(' · ') } })
  })

  on('command.run', { command: 'state' }, async ($, e) => {
    const state = e.args.trim()
    const ran = await $.process.run([`${await $.env.get('HOME')}/${CC_STATE}`, state])

    return { text: ran.exitCode === 0 ? `State: ${state}` : ran.stderr.trim() }
  })
}
