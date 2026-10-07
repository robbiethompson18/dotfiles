export type Summary = { doing: string; why: string; at: number }

declare module 'claude-code' {
  interface PluginState {
    'now-doing': { summary: Summary | null; links: string[]; isHidden: boolean }
  }
}
