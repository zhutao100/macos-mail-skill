#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/commands/_lib/common.sh
source "$SCRIPT_DIR/../_lib/common.sh"

[[ $# -ge 2 && $# -le 3 ]] || { echo "Usage: $(basename "$0") <account-name> <mailbox-name> [limit]" >&2; exit 1; }

account_name="$1"
mailbox_name="$2"
limit="${3:-10}"

account_exists_or_error "$account_name"
mailbox_exists_or_error "$account_name" "$mailbox_name"
require_positive_int "limit" "$limit"

messages_raw="$(capture_osascript "$APPLETS_DIR/message/list.applescript" "$account_name" "$mailbox_name" "$limit")"

if [[ -z "$messages_raw" ]]; then
  echo '[]'
  exit 0
fi

printf '%s\n' "$messages_raw" | json_lines_to_array
