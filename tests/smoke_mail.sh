#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
JQ_BIN="${JQ_BIN:-$(command -v jq || true)}"

[ -n "$JQ_BIN" ] || {
  echo "smoke_mail: jq is required." >&2
  exit 1
}

if ! osascript -e 'tell application "Mail" to get name' >/dev/null 2>&1; then
  echo "smoke_mail: Mail.app not available."
  exit 0
fi
osascript -e 'tell application "Mail" to get name' | grep -q . || {
  echo "smoke_mail: could not get app name." >&2
  exit 1
}

# Public command layer: list accounts
acc_json="$("$ROOT_DIR/macos-mail/scripts/commands/account/list.sh" 2>&1)" || {
  echo "smoke_mail: Mail not running, skipping."
  exit 0
}
printf '%s\n' "$acc_json" | "$JQ_BIN" -e 'type == "array"' >/dev/null || {
  echo "smoke_mail: account list is not JSON array." >&2
  exit 1
}

first_acc="$(printf '%s\n' "$acc_json" | "$JQ_BIN" -r '.[0].name // empty')"
mb_json="$("$ROOT_DIR/macos-mail/scripts/commands/mailbox/list.sh" "${first_acc:-}" 2>&1)" || mb_json=""

first_mb=""
if printf '%s\n' "$mb_json" | "$JQ_BIN" -e 'type == "array"' >/dev/null 2>&1; then
  first_mb="$(printf '%s\n' "$mb_json" | "$JQ_BIN" -r '.[0].name // empty')"
elif [ -n "$first_acc" ]; then
  first_mb="INBOX"
else
  echo "smoke_mail: mailbox list failed and no INBOX fallback was found." >&2
  exit 1
fi

if [ -n "$first_acc" ]; then
  if [ -n "$first_mb" ]; then
    count_json="$("$ROOT_DIR/macos-mail/scripts/commands/mailbox/count.sh" "$first_acc" "$first_mb" 2>&1)" || {
      echo "smoke_mail: mailbox count failed." >&2
      exit 1
    }
    printf '%s\n' "$count_json" | "$JQ_BIN" -e 'has("count") and has("account") and has("mailbox")' >/dev/null || {
      echo "smoke_mail: mailbox count contract mismatch." >&2
      exit 1
    }

    message_list_json="$("$ROOT_DIR/macos-mail/scripts/commands/message/list.sh" "$first_acc" "$first_mb" 1 2>&1)" || {
      echo "smoke_mail: message list failed." >&2
      exit 1
    }
    printf '%s\n' "$message_list_json" | "$JQ_BIN" -e 'type == "array"' >/dev/null || {
      echo "smoke_mail: message list is not JSON array." >&2
      exit 1
    }

    first_index="$(printf '%s\n' "$message_list_json" | "$JQ_BIN" -r '.[0].index // empty')"
    if [ -n "$first_index" ]; then
      message_json="$("$ROOT_DIR/macos-mail/scripts/commands/message/get.sh" "$first_acc" "$first_mb" "$first_index" 2>&1)" || {
        echo "smoke_mail: message get failed." >&2
        exit 1
      }
      printf '%s\n' "$message_json" | "$JQ_BIN" -e 'has("id") and has("subject") and has("content")' >/dev/null || {
        echo "smoke_mail: message get contract mismatch." >&2
        exit 1
      }

      show_json="$("$ROOT_DIR/macos-mail/scripts/commands/message/show.sh" "$first_acc" "$first_mb" "$first_index" 2>&1)" || {
        echo "smoke_mail: message show failed." >&2
        exit 1
      }
      printf '%s\n' "$show_json" | "$JQ_BIN" -e '.shown == true and has("subject") and has("mailbox")' >/dev/null || {
        echo "smoke_mail: message show contract mismatch." >&2
        exit 1
      }
    fi
  fi
fi

echo "smoke_mail: ok"
