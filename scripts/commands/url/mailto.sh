#!/usr/bin/env bash
# shellcheck disable=SC2016
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/commands/_lib/common.sh
source "$SCRIPT_DIR/../_lib/common.sh"

[[ $# -eq 1 ]] || { echo "Usage: $(basename "$0") <mailto-url>" >&2; exit 1; }

mailto_url="$1"
capture_osascript "$APPLETS_DIR/url/mailto.applescript" "$mailto_url" >/dev/null
ensure_jq
"$JQ_BIN" -nc --arg url "$mailto_url" '{opened: true, url: $url}'
