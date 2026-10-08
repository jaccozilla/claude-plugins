#!/usr/bin/env bash
# Claude Code status line (settings `statusLine`, installed by hooks/ensure-statusline.mjs) showing the state of a run started with gradle-quiet-with-summary.sh.
# Its output is drawn in the Claude Code console for the user only — it is never sent to the model, so unlike
# a Monitor it costs no tokens however often it refreshes.
#
#   gradle ▸ :e2e:wasmJsBrowserTest · 163 tests · 2:10     while a run is active (latest gradle phase, finished tests, elapsed)
#   gradle ▸ :e2e:wasmJsBrowserTest · 140 tests · 2:10 · 2 failed
#   gradle ✓ BUILD SUCCESSFUL in 4m 10s                     for two minutes after a run ends
#   gradle ✗ BUILD FAILED in 6m 0s · 5 failed
#
# Also appends the running docker stacks (compose project, or the container name when it has none), e.g. `docker ▸ knb · knb-e2e`.
# Prints nothing when no run is active or recent and no stack is up, so the status line stays empty. Reads build/logs/latest.progress,
# latest.path and the gradle log; per-test counts need the testLogging in e2e/build.gradle.kts.
#
# Claude Code passes session JSON on stdin; only workspace.current_dir (falling back to cwd) is read, to find the project's build/logs.
# Set GRADLE_STATUS_DIR to read another logs directory (tests).

input=$(cat 2>/dev/null)
dir=$(printf '%s' "$input" | sed -n 's/.*"current_dir" *: *"\([^"]*\)".*/\1/p' | head -1)
cd "${dir:-.}" 2>/dev/null || exit 0

gradle_line() {
  dir=${GRADLE_STATUS_DIR:-build/logs}
  f="$dir/latest.progress"
  [ -f "$f" ] || return 0
  start=$(grep -m1 '^START ' "$f" | cut -d' ' -f2)
  [ -n "$start" ] || return 0

  now=$(date +%s)
  mtime=$(stat -f %m "$f" 2>/dev/null || stat -c %Y "$f" 2>/dev/null || echo "$now")
  age=$((now - mtime))
  failed=$(grep -E 'FAILED$' "$f" | grep -vc '^> Task')

  if grep -q '^DONE ' "$f"; then
    [ "$age" -le 120 ] || return 0
    code=$(grep -m1 '^DONE ' "$f" | sed -E 's/.*exit ([0-9]+).*/\1/')
    build=$(grep -m1 '^BUILD ' "$f")
    if [ "$code" = 0 ]; then
      echo "gradle ✓ ${build:-done}"
    else
      out="gradle ✗ ${build:-failed (exit $code)}"
      [ "$failed" -gt 0 ] && out="$out · $failed failed"
      echo "$out"
    fi
    return 0
  fi

  # No DONE line means the run was killed (the wrapper never got to write it): treat it as live only while the wrapper is still running.
  pgrep -f gradle-quiet-with-summary > /dev/null 2>&1 || return 0

  log=$(cat "$dir/latest.path" 2>/dev/null)
  tests=0
  [ -n "$log" ] && [ -f "$log" ] && tests=$(grep -vE '^> Task ' "$log" | grep -cE ' (PASSED|FAILED|SKIPPED)$')
  phase=$(grep -E '^> Task ' "$f" | tail -1 | sed 's/^> Task //')
  el=$((now - start))

  out="gradle ▸ ${phase:-starting}"
  [ "$tests" -gt 0 ] && out="$out · $tests tests"
  out="$out · $((el / 60)):$(printf '%02d' $((el % 60)))"
  [ "$failed" -gt 0 ] && out="$out · $failed failed"
  echo "$out"
}

docker_line() {
  local out
  out=$(docker ps --format '{{if .Label "com.docker.compose.project"}}{{.Label "com.docker.compose.project"}}{{else}}{{.Names}}{{end}}' 2>/dev/null \
    | sort -u | paste -sd'|' - | sed 's/|/ · /g') || return 0
  [ -n "$out" ] && echo "docker ▸ $out"
  return 0
}

g=$(gradle_line)
d=$(docker_line)
echo "${d}${d:+${g:+  |  }}${g}" | sed '/^$/d'
