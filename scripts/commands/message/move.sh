#!/usr/bin/env bash
# shellcheck disable=SC2016
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/commands/_lib/common.sh
source "$SCRIPT_DIR/../_lib/common.sh"

[[ $# -eq 4 ]] || {
  echo "Usage: $(basename "$0") <account-name> <source-mailbox> <index> <target-mailbox>" >&2
  exit 1
}

account_name="$1"
source_mailbox="$2"
index="$3"
target_mailbox="$4"

account_exists_or_error "$account_name"
mailbox_exists_or_error "$account_name" "$source_mailbox"
mailbox_exists_or_error "$account_name" "$target_mailbox"
require_positive_int "index" "$index"

capture_osascript "$APPLETS_DIR/message/move.applescript" "$account_name" "$source_mailbox" "$index" "$target_mailbox" >/dev/null
ensure_jq
"$JQ_BIN" -nc \
  --arg account "$account_name" \
  --arg source_mailbox "$source_mailbox" \
  --arg target_mailbox "$target_mailbox" \
  --argjson index "$index" \
  '{moved: true, account: $account, source_mailbox: $source_mailbox, target_mailbox: $target_mailbox, index: $index}'
