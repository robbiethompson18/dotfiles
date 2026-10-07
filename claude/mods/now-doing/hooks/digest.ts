import type { SessionMessage, ToolUseSummary } from 'claude-code'

import type { Summary } from '../types'

const USER_PROMPTS = 3
const ASSISTANT_NOTES = 4
const TOOL_USES = 15
const DIGEST_LIMIT = 7000
const LINKS = 3
// A local dev-server URL, or an absolute file path. The lookbehind keeps the path half from matching inside a URL or a relative path.
const LINK = /https?:\/\/(?:localhost|127\.0\.0\.1|0\.0\.0\.0|[\w.-]+\.localhost)(?::\d+)?[^\s`'"()<>[\]]*|(?<![\w/.~-])(?:file:\/\/)?\/(?:Users|tmp|private)\/[^\s`'"()<>[\]]+/g

export const SYSTEM = `You write a one-glance status for someone supervising an AI coding agent. They are not following the details. From the session excerpt, say what the agent is working on right now and why, at a bird's-eye level, in plain everyday language.

Rules:
- "doing": what it is working on now, at most 15 words. Name the goal, not the individual commands or files.
- "why": the reason, tied to what the user asked for, at most 15 words.
- No jargon, internal names, file paths, IDs or tool names unless the user would know them.
- If the agent is waiting on the user or has finished, say so.
- Reply with JSON only: {"doing": "...", "why": "..."}`

function clip(text: string, limit: number): string {
  const flat = text.replace(/\s+/g, ' ').trim()
  return flat.length <= limit ? flat : `${flat.slice(0, limit - 1)}…`
}

function stripInjected(text: string): string {
  return text
    .replace(/<system-reminder>[\s\S]*?<\/system-reminder>/g, '')
    .replace(/<(local-command-[a-z]+|command-[a-z]+)>[\s\S]*?<\/\1>/g, '')
    .trim()
}

function describeToolUse(use: ToolUseSummary): string {
  const input = use.input
  const hint = ['description', 'prompt', 'command', 'file_path', 'pattern', 'url', 'query']
    .map(key => input[key])
    .find((value): value is string => typeof value === 'string' && value.length > 0)
  const status = use.text === undefined ? ' (running)' : use.isError ? ' (failed)' : ''
  return `- ${use.tool}${hint ? `: ${clip(hint, 140)}` : ''}${status}`
}

/** Builds the excerpt the model reads: the user's recent asks, the agent's recent notes, and its latest actions. */
export function buildDigest(messages: readonly SessionMessage[], previous: Summary | null): string {
  const asks = messages
    .filter(m => m.role === 'user' && !m.toolResults?.length)
    .map(m => stripInjected(m.text))
    .filter(text => text.length > 0)
    .slice(-USER_PROMPTS)
  const notes = messages
    .filter(m => m.role === 'assistant')
    .map(m => m.text.trim())
    .filter(text => text.length > 0)
    .slice(-ASSISTANT_NOTES)
  const actions = messages
    .filter(m => m.role === 'assistant')
    .flatMap(m => m.toolUses)
    .slice(-TOOL_USES)
  const lastIsUser = messages.at(-1)?.role === 'user' && !messages.at(-1)?.toolResults?.length

  const parts = [
    `## What the user asked (oldest first)\n${asks.map(a => `- ${clip(a, 700)}`).join('\n') || '- (nothing yet)'}`,
    `## What the agent said recently (oldest first)\n${notes.map(n => `- ${clip(n, 400)}`).join('\n') || '- (nothing yet)'}`,
    `## The agent's latest actions (oldest first)\n${actions.map(describeToolUse).join('\n') || '- (none)'}`,
  ]
  if (lastIsUser) {
    parts.push('The user has just sent a new message; the agent is starting on it.')
  }
  if (previous) {
    parts.push(`## Previous status (update it if things moved on)\nDoing: ${previous.doing}\nWhy: ${previous.why}`)
  }
  const digest = parts.join('\n\n')
  return digest.length <= DIGEST_LIMIT ? digest : digest.slice(-DIGEST_LIMIT)
}

/** The dev-server URLs and absolute file paths the agent most recently wrote to the user, newest first. Taken verbatim from its prose, never from the model, so they are always exact. */
export function extractLinks(messages: readonly SessionMessage[]): string[] {
  const found = messages
    .filter(m => m.role === 'assistant')
    .flatMap(m => m.text.match(LINK) ?? [])
    .map(link => link.replace(/^file:\/\//, '').replace(/[.,;:!?*]+$/, ''))
  return [...new Set(found.reverse())].slice(0, LINKS)
}

/** What a click on a link opens: the URL itself, or the file without its \`:line\` suffix. */
export function hrefFor(link: string): string {
  return link.startsWith('/') ? `file://${link.replace(/(:\d+)+$/, '')}` : link
}

/** Reads the model's reply as `{ doing, why }`, accepting a bare sentence when it skipped the JSON. */
export function parseReply(text: string, at: number): Summary | null {
  const match = text.match(/\{[\s\S]*\}/)
  if (match) {
    try {
      const value: unknown = JSON.parse(match[0])
      if (typeof value === 'object' && value !== null) {
        const { doing, why } = value as Record<string, unknown>
        if (typeof doing === 'string' && doing.trim()) {
          return { doing: clip(doing, 160), why: typeof why === 'string' ? clip(why, 160) : '', at }
        }
      }
    } catch {
      // Not JSON after all; fall through to the plain-text reading.
    }
  }
  const plain = clip(text, 200)
  return plain ? { doing: plain, why: '', at } : null
}
