#!/usr/bin/env bash
# shellcheck disable=SC2016
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=macos-mail/scripts/commands/_lib/common.sh
source "$SCRIPT_DIR/../_lib/common.sh"

[[ $# -ge 1 && $# -le 2 ]] || {
  echo "Usage: $(basename "$0") <account-name> [id|name]" >&2
  exit 1
}

account_name="$1"
property="${2:-}"

account_exists_or_error "$account_name"
ensure_jq

account_json="$("$JQ_BIN" -nc --arg id "$account_name" --arg name "$account_name" '{id: $id, name: $name}')"

if [[ -z "$property" ]]; then
  printf '%s' "$account_json"
  exit 0
fi

case "$property" in
  id | name) ;;
  *)
    echo "Unsupported account property: $property" >&2
    exit 1
    ;;
esac

printf '%s' "$account_json" | "$JQ_BIN" -c --arg property "$property" '
  {
    id: .id,
    name: .name,
    property: $property,
    value: .[$property]
  }
'
