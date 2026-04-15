#!/usr/bin/env bash
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

message_json="$(capture_osascript "$APPLETS_DIR/message/source.applescript" "$account_name" "$mailbox_name" "$index")"
printf '%s' "$message_json" | normalize_json_input
