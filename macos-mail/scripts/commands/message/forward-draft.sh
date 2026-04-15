#!/usr/bin/env bash
# shellcheck disable=SC2016
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=macos-mail/scripts/commands/_lib/common.sh
source "$SCRIPT_DIR/../_lib/common.sh"

[[ $# -ge 3 && $# -le 4 ]] || {
  echo "Usage: $(basename "$0") <account-name> <mailbox-name> <index> [visible]" >&2
  exit 1
}

account_name="$1"
mailbox_name="$2"
index="$3"
visible="${4:-true}"

account_exists_or_error "$account_name"
mailbox_exists_or_error "$account_name" "$mailbox_name"
require_positive_int "index" "$index"

case "$visible" in
  true | false | 1 | 0) ;;
  *)
    echo "Visible must be true, false, 1, or 0" >&2
    exit 1
    ;;
esac

ensure_jq

json="$(capture_osascript "$APPLETS_DIR/message/forward-draft.applescript" "$account_name" "$mailbox_name" "$index" "$visible")"
printf '%s' "$json" | normalize_json_input
