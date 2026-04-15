#!/usr/bin/env bash
# shellcheck disable=SC2016
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=macos-mail/scripts/commands/_lib/common.sh
source "$SCRIPT_DIR/../_lib/common.sh"

[[ $# -eq 2 ]] || {
  echo "Usage: $(basename "$0") <account-name> <mailbox-name>" >&2
  exit 1
}

account_name="$1"
mailbox_name="$2"

account_exists_or_error "$account_name"
mailbox_exists_or_error "$account_name" "$mailbox_name"
ensure_jq

count_raw="$(capture_osascript "$APPLETS_DIR/mailbox/count.applescript" "$account_name" "$mailbox_name")"
"$JQ_BIN" -nc \
  --arg account "$account_name" \
  --arg mailbox "$mailbox_name" \
  --argjson count "$count_raw" \
  '{count: $count, account: $account, mailbox: $mailbox}'
