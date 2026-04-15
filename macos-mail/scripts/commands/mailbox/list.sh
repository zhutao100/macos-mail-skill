#!/usr/bin/env bash
# shellcheck disable=SC2016
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=macos-mail/scripts/commands/_lib/common.sh
source "$SCRIPT_DIR/../_lib/common.sh"

[[ $# -le 1 ]] || {
  echo "Usage: $(basename "$0") [account-name]" >&2
  exit 1
}

account_name="${1:-}"
if [[ -n "$account_name" ]]; then
  account_exists_or_error "$account_name"
else
  account_name="$(account_names_raw | head -n 1)"
fi

if [[ -z "$account_name" ]]; then
  echo '[]'
  exit 0
fi

mailboxes_raw="$(mailbox_names_raw "$account_name")"
ensure_jq

out='[]'
while IFS= read -r mailbox_name; do
  [[ -n "$mailbox_name" ]] || continue
  count_raw="0"
  if count_candidate="$(try_capture_osascript "$APPLETS_DIR/mailbox/count.applescript" "$account_name" "$mailbox_name" 2>/dev/null)"; then
    if [[ "$count_candidate" =~ ^[0-9]+$ ]]; then
      count_raw="$count_candidate"
    fi
  fi
  mailbox_json="$("$JQ_BIN" -nc \
    --arg id "${account_name}/${mailbox_name}" \
    --arg name "$mailbox_name" \
    --arg account "$account_name" \
    --argjson count "$count_raw" \
    '{id: $id, name: $name, account: $account, message_count: $count}')"
  out="$(printf '%s' "$out" | "$JQ_BIN" -c --argjson item "$mailbox_json" '. + [$item]')"
done <<<"$mailboxes_raw"

printf '%s\n' "$out"
