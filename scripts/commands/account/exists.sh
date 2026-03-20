#!/usr/bin/env bash
# shellcheck disable=SC2016
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/commands/_lib/common.sh
source "$SCRIPT_DIR/../_lib/common.sh"

[[ $# -eq 1 ]] || { echo "Usage: $(basename "$0") <account-name>" >&2; exit 1; }

account_name="$1"
accounts_raw="$(account_names_raw)"
ensure_jq

if printf '%s\n' "$accounts_raw" | grep -Fqx -- "$account_name"; then
  "$JQ_BIN" -nc --arg id "$account_name" --arg name "$account_name" '{exists: true, id: $id, name: $name}'
else
  "$JQ_BIN" -nc --arg name "$account_name" '{exists: false, id: null, name: $name}'
fi
