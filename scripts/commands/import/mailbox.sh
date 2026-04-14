#!/usr/bin/env bash
# shellcheck disable=SC2016
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/commands/_lib/common.sh
source "$SCRIPT_DIR/../_lib/common.sh"

[[ $# -eq 1 ]] || {
  echo "Usage: $(basename "$0") <path>" >&2
  exit 1
}

path_value="$1"
capture_osascript "$APPLETS_DIR/import/mailbox.applescript" "$path_value" >/dev/null
ensure_jq
"$JQ_BIN" -nc --arg path "$path_value" '{imported: true, path: $path}'
