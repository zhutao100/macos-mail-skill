#!/usr/bin/env bash
# shellcheck disable=SC2016
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/commands/_lib/common.sh
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

capture_osascript "$APPLETS_DIR/message/forward.applescript" "$account_name" "$mailbox_name" "$index" >/dev/null
ensure_jq
"$JQ_BIN" -nc \
  --arg account "$account_name" \
  --arg mailbox "$mailbox_name" \
  --argjson index "$index" \
  '{opened: true, action: "forward", account: $account, mailbox: $mailbox, index: $index}'
