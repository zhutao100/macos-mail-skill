#!/usr/bin/env bash
# shellcheck disable=SC2016
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/commands/_lib/common.sh
source "$SCRIPT_DIR/../_lib/common.sh"

[[ $# -ge 1 && $# -le 2 ]] || {
  echo "Usage: $(basename "$0") <message-id> [property]" >&2
  exit 1
}

message_id="$1"
property="${2:-}"

message_json="$(capture_osascript "$APPLETS_DIR/message/get-by-id.applescript" "$message_id")"
ensure_jq

if [[ -z "$property" ]]; then
  printf '%s' "$message_json" | normalize_json_input
  exit 0
fi

case "$property" in
  id | account | mailbox | index | subject | sender | date_received | date_sent | message_id | reply_to | message_size | read | flagged | junk | flag_index | background_color | all_headers | content) ;;
  *)
    echo "Unsupported message property: $property" >&2
    exit 1
    ;;
esac

printf '%s' "$message_json" | "$JQ_BIN" -c --arg property "$property" '
  {
    id: .id,
    account: .account,
    mailbox: .mailbox,
    index: .index,
    property: $property,
    value: .[$property]
  }
'
