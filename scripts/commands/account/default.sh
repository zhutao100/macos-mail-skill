#!/usr/bin/env bash
# shellcheck disable=SC2016
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/commands/_lib/common.sh
source "$SCRIPT_DIR/../_lib/common.sh"

[[ $# -eq 0 ]] || { echo "Usage: $(basename "$0")" >&2; exit 1; }

default_name="$(capture_osascript "$APPLETS_DIR/account/default.applescript")"

if [[ -z "$default_name" ]]; then
  echo 'null'
  exit 0
fi

ensure_jq
"$JQ_BIN" -nc --arg name "$default_name" '{id: $name, name: $name}'
