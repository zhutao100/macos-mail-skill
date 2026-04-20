#!/usr/bin/env bash
# shellcheck disable=SC2016
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=macos-mail/scripts/commands/_lib/common.sh
source "$SCRIPT_DIR/../_lib/common.sh"

[[ $# -ge 3 ]] || {
  echo "Usage: $(basename "$0") <toCsv> <subject> <body> [visible] [ccCsv] [bccCsv] [attachmentPath...]" >&2
  exit 1
}

to_csv="$1"
subject="$2"
body="$3"
visible="${4:-true}"
cc_csv="${5:-}"
bcc_csv="${6:-}"
attachments=("${@:7}")

case "$visible" in
  true | false | 1 | 0) ;;
  *)
    echo "Visible must be true, false, 1, or 0" >&2
    exit 1
    ;;
esac

ensure_jq

if ((${#attachments[@]} > 0)); then
  message_json="$(capture_osascript "$APPLETS_DIR/message/create.applescript" "$to_csv" "$subject" "$body" "$visible" "$cc_csv" "$bcc_csv" "${attachments[@]}")"
  attachments_json="$($JQ_BIN -nc '$ARGS.positional' --args "${attachments[@]}")"
else
  message_json="$(capture_osascript "$APPLETS_DIR/message/create.applescript" "$to_csv" "$subject" "$body" "$visible" "$cc_csv" "$bcc_csv")"
  attachments_json="$($JQ_BIN -nc '[]')"
fi

printf '%s' "$message_json" | "$JQ_BIN" -c --argjson attachments "$attachments_json" '. + {attachments: $attachments}'
