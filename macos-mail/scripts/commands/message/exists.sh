#!/usr/bin/env bash
# shellcheck disable=SC2016
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=macos-mail/scripts/commands/_lib/common.sh
source "$SCRIPT_DIR/../_lib/common.sh"

[[ $# -eq 3 ]] || {
  echo "Usage: $(basename "$0") <account-name> <mailbox-name> <index>" >&2
  exit 1
}

account_name="$1"
mailbox_name="$2"
index="$3"

account_exists_or_error "$account_name"
mailbox_exists_or_error "$account_name" "$mailbox_name"
require_positive_int "index" "$index"
ensure_jq

if message_json="$(try_capture_osascript "$APPLETS_DIR/message/get.applescript" "$account_name" "$mailbox_name" "$index" 2>/dev/null)"; then
  printf '%s' "$message_json" | "$JQ_BIN" -c '{exists: true, id: .id, account: .account, mailbox: .mailbox, index: .index}'
else
  "$JQ_BIN" -nc \
    --arg account "$account_name" \
    --arg mailbox "$mailbox_name" \
    --argjson index "$index" \
    '{exists: false, id: null, account: $account, mailbox: $mailbox, index: $index}'
fi
