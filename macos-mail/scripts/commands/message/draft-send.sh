#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=macos-mail/scripts/commands/_lib/common.sh
source "$SCRIPT_DIR/../_lib/common.sh"

[[ $# -eq 1 ]] || {
  echo "Usage: $(basename "$0") <draft-id>" >&2
  exit 1
}

draft_id="$1"
require_positive_int "draft-id" "$draft_id"

ensure_jq

json="$(capture_osascript "$APPLETS_DIR/message/draft-send.applescript" "$draft_id")"
printf '%s' "$json" | normalize_json_input
