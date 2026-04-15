#!/usr/bin/env bash
# shellcheck disable=SC2016
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=macos-mail/scripts/commands/_lib/common.sh
source "$SCRIPT_DIR/../_lib/common.sh"

[[ $# -eq 0 ]] || {
  echo "Usage: $(basename "$0")" >&2
  exit 1
}

mailbox_name="$(capture_osascript "$APPLETS_DIR/viewer/inbox.applescript")"
ensure_jq
"$JQ_BIN" -nc --arg mailbox "$mailbox_name" '{mailbox: $mailbox}'
