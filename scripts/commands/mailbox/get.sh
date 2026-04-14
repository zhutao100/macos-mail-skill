#!/usr/bin/env bash
# shellcheck disable=SC2016
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/commands/_lib/common.sh
source "$SCRIPT_DIR/../_lib/common.sh"

[[ $# -ge 2 && $# -le 3 ]] || {
  echo "Usage: $(basename "$0") <account-name> <mailbox-name> [id|name|account|message_count]" >&2
  exit 1
}

account_name="$1"
mailbox_name="$2"
property="${3:-}"

account_exists_or_error "$account_name"
mailbox_exists_or_error "$account_name" "$mailbox_name"
ensure_jq

count_raw="$(capture_osascript "$APPLETS_DIR/mailbox/count.applescript" "$account_name" "$mailbox_name")"
mailbox_json="$("$JQ_BIN" -nc \
  --arg id "${account_name}/${mailbox_name}" \
  --arg name "$mailbox_name" \
  --arg account "$account_name" \
  --argjson count "$count_raw" \
  '{id: $id, name: $name, account: $account, message_count: $count}')"

if [[ -z "$property" ]]; then
  printf '%s' "$mailbox_json"
  exit 0
fi

case "$property" in
  id | name | account | message_count) ;;
  *)
    echo "Unsupported mailbox property: $property" >&2
    exit 1
    ;;
esac

printf '%s' "$mailbox_json" | "$JQ_BIN" -c --arg property "$property" '
  {
    id: .id,
    name: .name,
    account: .account,
    property: $property,
    value: .[$property]
  }
'
