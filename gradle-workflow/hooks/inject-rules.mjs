#!/usr/bin/env node
// SessionStart hook: prints the plugin's rules/*.md to stdout, which Claude Code adds to the session context (plugins can't ship
// .claude/rules files). Never blocks session start.
import { readdirSync, readFileSync } from 'fs'
import path from 'path'

try {
  const dir = path.join(process.env.CLAUDE_PLUGIN_ROOT, 'rules')
  const files = readdirSync(dir).filter((f) => f.endsWith('.md')).sort()
  const out = files.map((f) => readFileSync(path.join(dir, f), 'utf8').trim())
  if (out.length) process.stdout.write(`Rules from the gradle-workflow plugin:\n\n${out.join('\n\n')}\n`)
} catch {}
process.exit(0)
