import { atom, read, update } from 'claude-code'
import type { Register } from 'claude-code'

import { buildDigest, extractLinks, hrefFor, parseReply, SYSTEM } from './digest'

const summary = atom({ plugin: 'now-doing', key: 'summary' } as const, null)
const links = atom({ plugin: 'now-doing', key: 'links' } as const, [])
const isHidden = atom({ plugin: 'now-doing', key: 'isHidden' } as const, false)

const MODEL = 'haiku'
const TICK_MS = 5_000
const MIN_GAP_MS = 45_000

export const register: Register = on => {
  let hasNewActivity = false
  let isUrgent = false
  let isRunning = false
  let lastRunAt = 0

  on('session.start', async ($, e, next) => {
    await $.command.register({
      name: 'now-doing',
      description: 'Refresh the "what is Claude doing" line now; `off` hides it, `on` shows it',
    })
    // The only place the model is called. While work happens it refreshes at most once per MIN_GAP_MS; the end of a main-thread turn or `/now-doing` asks for one straight away.
    $.clock.every(TICK_MS, async () => {
      if (isRunning || !hasNewActivity) {
        return
      }
      const now = await $.clock.now()
      if (!isUrgent && now - lastRunAt < MIN_GAP_MS) {
        return
      }
      if (await read($, isHidden)) {
        return
      }
      isRunning = true
      hasNewActivity = false
      isUrgent = false
      lastRunAt = now
      try {
        const messages = await $.session.messages()
        if (messages.length === 0) {
          return
        }
        await update($, links, () => extractLinks(messages))
        const reply = await $.model.complete({
          model: MODEL,
          system: SYSTEM,
          prompt: buildDigest(messages, await read($, summary)),
          maxTokens: 200,
          effort: 'low',
          timeoutMs: 20_000,
        })
        if (!reply.isAnswered) {
          await $.ui.log(`now-doing: no summary (${reply.reason})`, { to: 'debug' })
          return
        }
        const fresh = parseReply(reply.text, await $.clock.now())
        if (fresh) {
          await update($, summary, () => fresh)
        }
      } finally {
        isRunning = false
      }
    })

    return next(e)
  })

  on('turn.start', ($, e, next) => {
    hasNewActivity = true

    return next(e)
  })

  on('tool.call', ($, e, next) => {
    hasNewActivity = true

    return next(e)
  })

  on('turn.complete', ($, e, next) => {
    if (e.agentId === undefined) {
      hasNewActivity = true
      isUrgent = true
    }

    return next(e)
  })

  on('command.run', { command: 'now-doing' }, async ($, e) => {
    const arg = e.args.trim().toLowerCase()
    if (arg === 'off' || arg === 'hide') {
      await update($, isHidden, () => true)
      return { text: 'Now-doing line hidden. `/now-doing on` brings it back.' }
    }
    await update($, isHidden, () => false)
    hasNewActivity = true
    isUrgent = true

    return { text: 'Refreshing the now-doing line; it updates above the prompt in a few seconds.' }
  })

  on('ui.render', { component: 'AbovePrompt' }, async ($, e, next) => {
    const current = await read($, summary)
    if (e.props.hasSurvey || current === null || (await read($, isHidden))) {
      return next(e)
    }
    const { Box, Link, Text } = $.ui.resolve(e)
    const currentLinks = await read($, links)

    return (
      <Box flexDirection="column">
        <Text key="doing" wrap="truncate-end">
          <Text bold>Doing:</Text> {current.doing}
        </Text>
        {current.why && (
          <Text key="why" dimColor wrap="truncate-end">
            <Text bold>Why:</Text> {current.why}
          </Text>
        )}
        {currentLinks.map((link, i) => (
          <Text key={link} wrap="truncate-end">
            <Text bold>{i === 0 ? 'Links:' : '      '}</Text> <Link href={hrefFor(link)}>{link}</Link>
          </Text>
        ))}
      </Box>
    )
  })
}
