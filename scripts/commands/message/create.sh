#!/usr/bin/env bash
# shellcheck disable=SC2016
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/commands/_lib/common.sh
source "$SCRIPT_DIR/../_lib/common.sh"

[[ $# -ge 3 && $# -le 4 ]] || {
  echo "Usage: $(basename "$0") <to> <subject> <body> [visible]" >&2
  exit 1
}

to_address="$1"
subject="$2"
body="$3"
visible="${4:-true}"

case "$visible" in
  true | false | 1 | 0) ;;
  *)
    echo "Visible must be true, false, 1, or 0" >&2
    exit 1
    ;;
esac

capture_osascript "$APPLETS_DIR/message/create.applescript" "$to_address" "$subject" "$body" "$visible" >/dev/null
ensure_jq
"$JQ_BIN" -nc \
  --arg to "$to_address" \
  --arg subject "$subject" \
  --arg body "$body" \
  --arg visible "$visible" '
  {
    created: true,
    to: $to,
    subject: $subject,
    body: $body,
    visible: ($visible == "true" or $visible == "1")
  }
'
