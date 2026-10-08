#!/usr/bin/env node
// SessionStart hook: copies statusline.sh into the plugin's data directory (a path that survives plugin updates) and points
// settings.json's statusLine at it, unless statusLine is already set to something else. Never blocks session start.
import { chmodSync, copyFileSync, existsSync, mkdirSync, readFileSync, realpathSync, writeFileSync } from 'fs'
import { homedir } from 'os'
import path from 'path'

export function syncScript(pluginRoot, pluginData) {
  const source = path.join(pluginRoot, 'statusline.sh')
  if (!existsSync(source)) return null
  const dest = path.join(pluginData, 'statusline.sh')
  if (!existsSync(dest) || readFileSync(dest, 'utf8') !== readFileSync(source, 'utf8')) {
    mkdirSync(pluginData, { recursive: true })
    copyFileSync(source, dest)
    chmodSync(dest, 0o755)
  }
  return dest
}

export function installStatusLine(settingsPath, scriptPath) {
  const command = `bash ${JSON.stringify(scriptPath)}`
  let raw = '{}'
  if (existsSync(settingsPath)) {
    try { raw = readFileSync(settingsPath, 'utf8') } catch { return 'unreadable' }
  }
  let settings
  try { settings = JSON.parse(raw) } catch { return 'unparsable' }
  const current = settings.statusLine?.command
  if (current === command) return 'unchanged'
  if (typeof current === 'string' && !/gradle-(status|workflow)/.test(current)) return 'skipped'
  const target = existsSync(settingsPath) ? realpathSync(settingsPath) : settingsPath
  if (existsSync(target) && !existsSync(`${target}.bak`)) writeFileSync(`${target}.bak`, raw)
  settings.statusLine = { type: 'command', command }
  writeFileSync(target, `${JSON.stringify(settings, null, 2)}\n`)
  return 'installed'
}

try {
  const root = process.env.CLAUDE_PLUGIN_ROOT
  const data = process.env.CLAUDE_PLUGIN_DATA
  if (root && data) {
    const script = syncScript(root, data)
    if (script) installStatusLine(path.join(process.env.CLAUDE_CONFIG_DIR || path.join(homedir(), '.claude'), 'settings.json'), script)
  }
} catch {}
process.exit(0)
