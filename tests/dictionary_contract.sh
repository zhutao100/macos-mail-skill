#!/usr/bin/env bash
set -euo pipefail

tmp="$(mktemp)"
trap 'rm -f "$tmp"' EXIT

make --no-print-directory dictionary-mail >"$tmp"

has_pattern() {
  local pattern="$1"
  if command -v rg-x >/dev/null 2>&1; then
    rg-x -q "$pattern" "$tmp"
  elif command -v rg >/dev/null 2>&1; then
    rg -q "$pattern" "$tmp"
  else
    grep -q -- "$pattern" "$tmp"
  fi
}

has_pattern '<class name="account"'
has_pattern '<class name="message"'
has_pattern '<class name="mailbox"'

printf 'dictionary_contract: ok\n'
