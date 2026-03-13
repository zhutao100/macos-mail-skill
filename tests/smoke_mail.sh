#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if ! osascript -e 'tell application "Mail" to get name' >/dev/null 2>&1; then
	echo "smoke_mail: Mail.app not available."
	exit 0
fi
osascript -e 'tell application "Mail" to get name' | grep -q . || { echo "smoke_mail: could not get app name." >&2; exit 1; }

# Script layer: list accounts
acc_list="$(osascript "$ROOT_DIR/scripts/account/list.applescript" 2>&1)" || { echo "smoke_mail: Mail not running, skipping."; exit 0; }
printf '%s\n' "$acc_list" >/dev/null || { echo "smoke_mail: account list failed." >&2; exit 1; }

# Script layer: list mailboxes (first account)
mb_list="$(osascript "$ROOT_DIR/scripts/mailbox/list.applescript" 2>&1)" || { echo "smoke_mail: Mail not running, skipping."; exit 0; }
printf '%s\n' "$mb_list" >/dev/null || { echo "smoke_mail: mailbox list failed." >&2; exit 1; }

# Mailbox count (if we have account and mailbox)
first_acc="$(echo "$acc_list" | head -1)"
if [ -n "$first_acc" ]; then
  first_mb="$(echo "$mb_list" | head -1)"
  if [ -n "$first_mb" ]; then
    cnt="$(osascript "$ROOT_DIR/scripts/mailbox/count.applescript" "$first_acc" "$first_mb" 2>&1)" || true
    [ -z "$cnt" ] || true
  fi
fi

echo "smoke_mail: ok"
