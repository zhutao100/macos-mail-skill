#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/commands/_lib/common.sh
source "$SCRIPT_DIR/../_lib/common.sh"

[[ $# -eq 4 ]] || { echo "Usage: $(basename "$0") <account-name> <mailbox-name> <subject_contains|sender_contains> <value>" >&2; exit 1; }

account_name="$1"
mailbox_name="$2"
mode="$3"
value="$4"

account_exists_or_error "$account_name"
mailbox_exists_or_error "$account_name" "$mailbox_name"

case "$mode" in
  subject_contains|sender_contains)
    ;;
  *)
    echo "Unsupported search mode: $mode" >&2
    exit 1
    ;;
esac

messages_raw="$(capture_osascript "$APPLETS_DIR/message/search.applescript" "$account_name" "$mailbox_name" "$mode" "$value")"

if [[ -z "$messages_raw" ]]; then
  echo '[]'
  exit 0
fi

printf '%s\n' "$messages_raw" | json_lines_to_array
