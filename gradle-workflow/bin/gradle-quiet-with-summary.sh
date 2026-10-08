#!/usr/bin/env bash
# Runs ./gradlew with the same arguments, but keeps console output small.
#
# - Full output  -> build/logs/gradle-<timestamp>.log
# - Milestones   -> build/logs/latest.progress (fixed path, truncated each run; starts with a `START <epoch>` line and ends with a `DONE (exit N)` line)
# - stdout       -> the same milestone lines as they happen (so a backgrounded run's shell output shows live progress), then a short summary (result, duration, failed tasks, failing tests, compile errors, log path)
# - The gradle run is wrapped in `caffeinate -i` (when available) so the machine can't sleep mid-run.
#
# Usage: gradle-quiet-with-summary.sh :e2e:jvmTest [other gradlew args...]   (on PATH via the gradle-workflow plugin's bin/)
# Runs from the project root: $CLAUDE_PROJECT_DIR, else the nearest directory at or above the cwd that holds ./gradlew.
# GRADLE_WORKFLOW_MILESTONES overrides the milestone regex below. Exit code is gradle's own exit code.

set -u
root="${CLAUDE_PROJECT_DIR:-$PWD}"
while [ ! -x "$root/gradlew" ] && [ "$root" != "/" ]; do root=$(dirname "$root"); done
[ -x "$root/gradlew" ] || { echo "gradle-quiet-with-summary.sh: no ./gradlew found at or above ${CLAUDE_PROJECT_DIR:-$PWD}" >&2; exit 2; }
cd "$root"

mkdir -p build/logs
stamp=$(date +%Y%m%d-%H%M%S)
log="build/logs/gradle-$stamp.log"
progress="build/logs/latest.progress"
: > "$progress"
echo "START $(date +%s)" >> "$progress"
echo "$log" > build/logs/latest.path

start=$(date +%s)
marker="build/logs/.run-start.marker"
touch "$marker"

# Milestones: only the phases worth a status line — Supabase start/reset/stop, the test tasks, packaging, spec coverage — plus
# failures (a failing test shows up the moment it fails), compile errors and the final build result. Compile and
# resource-check tasks are left out on purpose: they flood the stream without telling you how far along the run is. The
# status line (the gradle-workflow plugin) shows the latest of them as the current phase.
default_milestone_re='^> Task :[^ ]+:(jvmTest|wasmJsBrowserTest|supabaseStart|supabaseStop|supabaseReset[^ ]*|wasmJsBrowserProductionWebpack|wasmJsBrowserDistribution|wasmJsBrowserDevelopmentRun|verifySpecCoverage)( FAILED)?$|FAILED|^BUILD |^e: |^test-history: '
milestone_re="${GRADLE_WORKFLOW_MILESTONES:-$default_milestone_re}"

# Keep the Mac awake for the whole run (macOS `caffeinate -i`): a sleep mid-run freezes Docker's clock and Karma, and shows up as a hung
# `supabase start` or a "no message in 180000 ms" browser disconnect that has nothing to do with the code. Skipped where it doesn't exist.
keep_awake=()
command -v caffeinate >/dev/null 2>&1 && keep_awake=(caffeinate -i)

${keep_awake[@]+"${keep_awake[@]}"} ./gradlew --console=plain "$@" 2>&1 | tee "$log" | grep --line-buffered -E "$milestone_re" | tee -a "$progress"
status=${PIPESTATUS[0]}
# Terminator for the gradle-workflow plugin — written even when gradle died before printing its own BUILD line.
echo "DONE (exit $status)" >> "$progress"

end=$(date +%s)
dur=$((end - start))
mins=$((dur / 60)); secs=$((dur % 60))

if [ "$status" -eq 0 ]; then result="SUCCESS"; else result="FAILED (exit $status)"; fi
echo "gradle $* -> $result in ${mins}m${secs}s"
echo "log: $log"

# Task outcome counts, plus which test tasks were skipped (their results are from an earlier run, not this one).
executed=$(grep -cE '^> Task [^ ]+$' "$log")
up_to_date=$(grep -cE '^> Task [^ ]+ UP-TO-DATE$' "$log")
from_cache=$(grep -cE '^> Task [^ ]+ FROM-CACHE$' "$log")
echo "tasks: $executed executed, $up_to_date up-to-date, $from_cache from-cache"
skipped_tests=$(grep -E '^> Task [^ ]*[Tt]est (UP-TO-DATE|FROM-CACHE)$' "$log" | sed 's/^> Task //' | head -10)
if [ -n "$skipped_tests" ]; then
  echo "test tasks not re-run (--rerun-tasks to force):"; echo "$skipped_tests" | sed 's/^/  /'
fi

# Tests actually run in this build: sum the <testsuite> counts from JUnit XML written since the run started.
test_totals=$(find . -path '*/build/test-results/*' -name 'TEST-*.xml' -newer "$marker" 2>/dev/null \
  | xargs grep -h -o '<testsuite [^>]*' 2>/dev/null \
  | awk '{ for (i = 1; i <= NF; i++) {
             if ($i ~ /^tests=/)    { gsub(/[^0-9]/, "", $i); t += $i }
             if ($i ~ /^skipped=/)  { gsub(/[^0-9]/, "", $i); s += $i }
             if ($i ~ /^failures=/) { gsub(/[^0-9]/, "", $i); f += $i }
             if ($i ~ /^errors=/)   { gsub(/[^0-9]/, "", $i); f += $i } } }
         END { if (NR > 0) printf "%d run, %d failed, %d skipped", t, f, s }')
[ -n "$test_totals" ] && echo "tests: $test_totals"

# The test-history plugin (../gradle-plugins) logs, per test task, the expected-vs-actual test count and duration, and for each failed
# test when it last passed and which files changed since (see the "Test history" section of .claude/rules/testing.md).
grep -E '^test-history: ' "$log" | cut -c1-300 | head -60

if [ "$status" -ne 0 ]; then
  failed_tasks=$(grep -E '^> Task .* FAILED$' "$log" | sed 's/^> Task //; s/ FAILED$//' | sort -u | head -10)
  if [ -n "$failed_tasks" ]; then
    echo "failed tasks:"; echo "$failed_tasks" | sed 's/^/  /'
  fi

  compile_errors=$(grep -E '^e: ' "$log" | sort -u | head -10)
  if [ -n "$compile_errors" ]; then
    echo "compile errors (first 10):"; echo "$compile_errors" | sed 's/^/  /'
  fi

  # Test failures: read this run's JUnit XML (full assertion message). Only files written since the run started.
  test_failures=$(find . -path '*/build/test-results/*' -name 'TEST-*.xml' -newer "$marker" 2>/dev/null \
    | xargs awk '
        /<testcase / { match($0, /classname="[^"]*"/); cls = substr($0, RSTART + 11, RLENGTH - 12)
                       match($0, / name="[^"]*"/);     tc  = substr($0, RSTART + 7,  RLENGTH - 8) }
        /<(failure|error) / { match($0, /message="[^"]*"/); msg = substr($0, RSTART + 9, RLENGTH - 10)
                              gsub(/&lt;/, "<", msg); gsub(/&gt;/, ">", msg); gsub(/&quot;/, "\"", msg)
                              gsub(/&#10;/, " ", msg); gsub(/&amp;/, "\\&", msg)
                              print cls "." tc "\n      " substr(msg, 1, 300) }' 2>/dev/null | head -20)
  if [ -n "$test_failures" ]; then
    echo "failing tests (first 10, with message):"; echo "$test_failures" | sed 's/^/  /'
  else
    # Fallback: console "<Class> > <test> FAILED" plus the following exception line.
    test_failures=$(grep -A1 -E ' > .* FAILED$' "$log" | grep -v '^--$' | head -20)
    if [ -n "$test_failures" ]; then
      echo "failing tests (first 10, console detail):"; echo "$test_failures" | sed 's/^/  /'
    fi
  fi

  if [ -z "$failed_tasks$compile_errors$test_failures" ]; then
    echo "last lines of log:"; tail -n 10 "$log" | sed 's/^/  /'
  fi
fi

exit "$status"
