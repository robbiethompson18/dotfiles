import type { ModelCompleteInput, On, RenderElement, SessionMessage } from 'claude-code'
import { expect, mock, test } from 'claude-code/testing'

const TRANSCRIPT: SessionMessage[] = [
  { role: 'user', text: 'Make the login page remember the user between visits <system-reminder>secret</system-reminder>', toolUses: [] },
  {
    role: 'assistant',
    text: 'I will add a remember-me cookie.',
    toolUses: [{ tool_use_id: 't1', tool: 'Bash', input: { command: 'pytest', description: 'Run the login tests' }, text: 'ok' }],
  },
]

const BAND = {
  plugin: 'now-doing',
  component: 'AbovePrompt',
  props: { hasSurvey: false, isWorking: false, maxRows: 10, bodyColumns: 100, scroll: { offset: 0, bodyRows: 10 }, view: {} },
} as const

function stubEngine(on: On): void {
  on('session.start', (_$, e) => ({ cwd: e.cwd }))
  on('command.register', (_$, e) => ({ value: { command: e.name } }))
  on('ui.render', { component: 'AbovePrompt' }, ($, e) => {
    const { Text } = $.ui.resolve(e)
    return h(Text, null, 'engine band') as RenderElement
  })
  on('turn.complete', (_$, e) => ({ text: e.answer }))
}

const USAGE = { input_tokens: 1, output_tokens: 1, cache_read_input_tokens: 0, cache_creation_input_tokens: 0 }

test('the end of a turn puts a plain-language summary above the prompt', async ($, on) => {
  const clock = mock.clock(on, { now: 1_000_000 })
  stubEngine(on)
  const asked: ModelCompleteInput[] = []
  on('session.messages', () => ({ value: TRANSCRIPT }))
  on('model.complete', (_$, e) => {
    asked.push(e)
    return { value: { isAnswered: true as const, text: '{"doing": "Adding a remember-me option to login", "why": "You asked for logins to persist"}', usage: USAGE } }
  })

  await $.session.start({ cwd: '/', surface: 'terminal', isInteractive: true })
  const before = await $.ui.mount({ ...BAND, surface: 'terminal' })
  expect(await before.find({ text: /Doing/ })).toBeUndefined()
  await before.unmount()

  await $.turn.complete({ answer: 'Done', durationMs: 10, isAborted: false, turnId: 'a', reason: 'answer' })
  await clock.advance(5_000)

  expect(asked).toHaveLength(1)
  expect(asked[0]?.model).toBe('haiku')
  expect(asked[0]?.prompt).toContain('remember the user between visits')
  expect(asked[0]?.prompt).toContain('Run the login tests')
  expect(asked[0]?.prompt).not.toContain('secret')

  const after = await $.ui.mount({ ...BAND, surface: 'terminal' })
  expect(await after.find({ type: 'Text', text: 'Doing: Adding a remember-me option to login' })).toBeDefined()
  expect(await after.find({ type: 'Text', text: 'Why: You asked for logins to persist' })).toBeDefined()
  await after.unmount()
})

test('tool calls refresh at most once per 45 seconds, and not at all with no new activity', async ($, on) => {
  const clock = mock.clock(on, { now: 1_000_000 })
  stubEngine(on)
  let calls = 0
  on('session.messages', () => ({ value: TRANSCRIPT }))
  on('model.complete', () => {
    calls += 1
    return { value: { isAnswered: true as const, text: '{"doing": "Working", "why": "Asked"}', usage: USAGE } }
  })
  on('tool.call', () => ({ result: 'ok' }))

  await $.session.start({ cwd: '/', surface: 'terminal', isInteractive: true })
  await clock.advance(60_000)
  expect(calls).toBe(0)

  await $.tool.call({ tool: 'Read', tool_use_id: 'r1', file_path: '/a' })
  await clock.advance(5_000)
  expect(calls).toBe(1)

  await $.tool.call({ tool: 'Read', tool_use_id: 'r2', file_path: '/b' })
  await clock.advance(20_000)
  expect(calls).toBe(1)
  await clock.advance(25_000)
  expect(calls).toBe(2)
})

test('/now-doing off hides the line and stops model calls', async ($, on) => {
  const clock = mock.clock(on, { now: 1_000_000 })
  stubEngine(on)
  let calls = 0
  on('session.messages', () => ({ value: TRANSCRIPT }))
  on('model.complete', () => {
    calls += 1
    return { value: { isAnswered: true as const, text: '{"doing": "Working", "why": "Asked"}', usage: USAGE } }
  })

  await $.session.start({ cwd: '/', surface: 'terminal', isInteractive: true })
  await $.turn.complete({ answer: '', durationMs: 1, isAborted: false, turnId: 'a', reason: 'answer' })
  await clock.advance(5_000)
  expect(calls).toBe(1)

  await $.command.run({ command: 'now-doing', args: 'off', origin: { kind: 'composer' }, presentation: { isFullscreen: false, columns: 100 } })
  const band = await $.ui.mount({ ...BAND, surface: 'terminal' })
  expect(await band.find({ text: /Doing:/ })).toBeUndefined()
  expect(await band.find({ text: 'engine band' })).toBeDefined()
  await band.unmount()

  await $.turn.complete({ answer: '', durationMs: 1, isAborted: false, turnId: 'b', reason: 'answer' })
  await clock.advance(60_000)
  expect(calls).toBe(1)
})

test('links the agent gave show under the summary, newest first, and are never sent through the model', async ($, on) => {
  const clock = mock.clock(on, { now: 1_000_000 })
  stubEngine(on)
  const transcript: SessionMessage[] = [
    ...TRANSCRIPT,
    { role: 'assistant', text: 'Old one: http://localhost:3000/old. See `src/login.ts:12` and /api/users too.', toolUses: [] },
    { role: 'assistant', text: 'Dev server is at http://app.localhost/login, notes in **/Users/robbie/repos/app/docs/login.md:40**.', toolUses: [] },
    { role: 'assistant', text: 'Also /tmp/report.html and https://example.com/x.', toolUses: [] },
  ]
  on('session.messages', () => ({ value: transcript }))
  on('model.complete', () => ({ value: { isAnswered: true as const, text: '{"doing": "Working", "why": "Asked"}', usage: USAGE } }))

  await $.session.start({ cwd: '/', surface: 'terminal', isInteractive: true })
  await $.turn.complete({ answer: 'Done', durationMs: 10, isAborted: false, turnId: 'a', reason: 'answer' })
  await clock.advance(5_000)

  const band = await $.ui.mount({ ...BAND, surface: 'terminal' })
  expect(await band.find({ type: 'Link', text: '/tmp/report.html' })).toBeDefined()
  expect(await band.find({ type: 'Link', text: '/Users/robbie/repos/app/docs/login.md:40' })).toBeDefined()
  expect(await band.find({ type: 'Link', text: 'http://app.localhost/login' })).toBeDefined()
  expect(await band.find({ text: /old|example\.com|api\/users|src\/login/ })).toBeUndefined()
  await band.unmount()
})
