#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

assert_eq() {
  local label="$1"
  local expected="$2"
  local actual="$3"

  if [[ "$expected" != "$actual" ]]; then
    printf 'unit_parsing: %s: expected %q, got %q\n' "$label" "$expected" "$actual" >&2
    exit 1
  fi
}

run_osascript() {
  local script_path="$1"
  shift
  /usr/bin/osascript "$script_path" "$@"
}

name_script="$ROOT_DIR/scripts/applescripts/message/extract-name.applescript"
addr_script="$ROOT_DIR/scripts/applescripts/message/extract-address.applescript"

assert_eq "name angle" "Jane Doe" "$(run_osascript "$name_script" 'Jane Doe <jane@example.com>')"
assert_eq "addr angle" "jane@example.com" "$(run_osascript "$addr_script" 'Jane Doe <jane@example.com>')"

assert_eq "name quoted" "Jane Doe" "$(run_osascript "$name_script" "\"Jane Doe\" <jane@example.com>")"
assert_eq "addr quoted" "jane@example.com" "$(run_osascript "$addr_script" "\"Jane Doe\" <jane@example.com>")"

assert_eq "name bare" "" "$(run_osascript "$name_script" 'jane@example.com')"
assert_eq "addr bare" "jane@example.com" "$(run_osascript "$addr_script" 'jane@example.com')"

assert_eq "name comment" "Jane Doe" "$(run_osascript "$name_script" 'jane@example.com (Jane Doe)')"
assert_eq "addr comment" "jane@example.com" "$(run_osascript "$addr_script" 'jane@example.com (Jane Doe)')"

assert_eq "name multi" "Jane Doe" "$(run_osascript "$name_script" 'Jane Doe <jane@example.com>, John <john@example.com>')"
assert_eq "addr multi" "jane@example.com" "$(run_osascript "$addr_script" 'Jane Doe <jane@example.com>, John <john@example.com>')"

if run_osascript "$name_script" >/dev/null 2>&1; then
  echo "unit_parsing: expected extract-name.applescript to fail without args" >&2
  exit 1
fi
if run_osascript "$addr_script" >/dev/null 2>&1; then
  echo "unit_parsing: expected extract-address.applescript to fail without args" >&2
  exit 1
fi

echo "unit_parsing: ok"
