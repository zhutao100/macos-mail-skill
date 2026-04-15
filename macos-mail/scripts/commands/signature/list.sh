#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=macos-mail/scripts/commands/_lib/common.sh
source "$SCRIPT_DIR/../_lib/common.sh"

[[ $# -eq 0 ]] || {
  echo "Usage: $(basename "$0")" >&2
  exit 1
}

signatures_raw="$(capture_osascript "$APPLETS_DIR/signature/list.applescript")"
ensure_jq

printf '%s\n' "$signatures_raw" | "$JQ_BIN" -Rsc '
  split("\n")
  | map(select(length > 0))
  | map({id: ., name: .})
'
