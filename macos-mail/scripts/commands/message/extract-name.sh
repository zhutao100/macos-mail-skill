#!/usr/bin/env bash
# shellcheck disable=SC2016
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=macos-mail/scripts/commands/_lib/common.sh
source "$SCRIPT_DIR/../_lib/common.sh"

[[ $# -eq 1 ]] || {
  echo "Usage: $(basename "$0") <full-email-address>" >&2
  exit 1
}

full_address="$1"
name_value="$(capture_osascript "$APPLETS_DIR/message/extract-name.applescript" "$full_address")"
ensure_jq
"$JQ_BIN" -nc --arg input "$full_address" --arg name "$name_value" '{input: $input, name: $name}'
