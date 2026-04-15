#!/usr/bin/env bash
# shellcheck disable=SC2016
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=macos-mail/scripts/commands/_lib/common.sh
source "$SCRIPT_DIR/../_lib/common.sh"

[[ $# -eq 3 ]] || {
  echo "Usage: $(basename "$0") <to> <subject> <body>" >&2
  exit 1
}

to_address="$1"
subject="$2"
body="$3"

capture_osascript "$APPLETS_DIR/message/send.applescript" "$to_address" "$subject" "$body" >/dev/null
ensure_jq
"$JQ_BIN" -nc --arg to "$to_address" --arg subject "$subject" --arg body "$body" '
  {
    sent: true,
    to: $to,
    subject: $subject,
    body: $body
  }
'
