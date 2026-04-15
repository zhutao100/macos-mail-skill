#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=macos-mail/scripts/commands/_lib/common.sh
source "$SCRIPT_DIR/../_lib/common.sh"

[[ $# -le 1 ]] || {
  echo "Usage: $(basename "$0") [limit]" >&2
  exit 1
}

limit="${1:-20}"
require_positive_int "limit" "$limit"

raw="$(capture_osascript "$APPLETS_DIR/message/draft-list.applescript" "$limit")"

if [[ -z "$raw" ]]; then
  echo '[]'
  exit 0
fi

printf '%s\n' "$raw" | json_lines_to_array
