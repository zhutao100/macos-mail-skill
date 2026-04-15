#!/usr/bin/env bash
# shellcheck disable=SC2016
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=macos-mail/scripts/commands/_lib/common.sh
source "$SCRIPT_DIR/../_lib/common.sh"

[[ $# -eq 4 ]] || {
  echo "Usage: $(basename "$0") <account-name> <mailbox-name> <index> <reply-body>" >&2
  exit 1
}

account_name="$1"
mailbox_name="$2"
index="$3"
reply_body="$4"

account_exists_or_error "$account_name"
mailbox_exists_or_error "$account_name" "$mailbox_name"
require_positive_int "index" "$index"

capture_osascript "$APPLETS_DIR/message/reply.applescript" "$account_name" "$mailbox_name" "$index" "$reply_body" >/dev/null
ensure_jq
"$JQ_BIN" -nc \
  --arg account "$account_name" \
  --arg mailbox "$mailbox_name" \
  --argjson index "$index" \
  --arg body "$reply_body" \
  '{sent: true, account: $account, mailbox: $mailbox, index: $index, body: $body}'
