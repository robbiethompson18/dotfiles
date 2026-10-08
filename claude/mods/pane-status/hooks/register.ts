import type { Register } from 'claude-code'

// Claude Code's own /color names; the matching tab colors live in bin/cc-state.
const PRIORITY_COLORS = { p0: 'red', p1: 'orange', p2: 'yellow', p3: 'blue', pnone: 'default' } as const
type Priority = keyof typeof PRIORITY_COLORS
const PRIORITIES = Object.keys(PRIORITY_COLORS) as Priority[]
const CC_STATE = 'repos/dotfiles/bin/cc-state'

export const register: Register = on => {
  on('session.start', async ($, e, next) => {
    for (const name of PRIORITIES) {
      await $.command.register({
        name,
        description:
          name === 'pnone' ? 'Clear the priority color' : `Mark this session ${name}: ${PRIORITY_COLORS[name]} tab and prompt bar`,
        immediate: true,
      })
    }
    await $.command.register({
      name: 'state',
      description: 'Set the workflow state shown in the iTerm2 status',
      argumentHint: 'ideating | implementing | review | overnight | blocked [reason] | clear',
      immediate: true,
    })

    return next(e)
  })

  for (const name of PRIORITIES) {
    on('command.run', { command: name }, async $ => {
      const home = await $.env.get('HOME')
      const ran = await $.process.run([`${home}/${CC_STATE}`, 'priority', name === 'pnone' ? 'none' : name])
      // Queued behind this command, so it can't be awaited from inside it.
      void $.command
        .run({ command: 'color', args: PRIORITY_COLORS[name] })
        .catch(error => $.ui.log(`pane-status: /color failed: ${error}`, { to: 'debug' }))

      return { text: ran.exitCode === 0 ? `Priority: ${name === 'pnone' ? 'none' : name}` : ran.stderr.trim() }
    })
  }

  on('command.run', { command: 'state' }, async ($, e) => {
    const [state = '', ...reason] = e.args.trim().split(/\s+/)
    const home = await $.env.get('HOME')
    const ran = await $.process.run([`${home}/${CC_STATE}`, state, ...(reason.length > 0 ? [reason.join(' ')] : [])])

    return { text: ran.exitCode === 0 ? `State: ${state}` : ran.stderr.trim() }
  })
}
