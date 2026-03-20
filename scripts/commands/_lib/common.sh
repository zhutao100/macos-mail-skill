#!/usr/bin/env bash

COMMON_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
COMMANDS_DIR="$(cd "$COMMON_DIR/.." && pwd)"
REPO_ROOT="$(cd "$COMMANDS_DIR/../.." && pwd)"
APPLETS_DIR="$REPO_ROOT/scripts/applescripts"

if [[ -z "${JQ_BIN:-}" ]]; then
  if JQ_BIN="$(command -v jq 2>/dev/null)"; then
    :
  elif [[ -x "/opt/homebrew/bin/jq" ]]; then
    JQ_BIN="/opt/homebrew/bin/jq"
  else
    JQ_BIN=""
  fi
fi

ensure_jq() {
  [[ -n "$JQ_BIN" ]] || {
    echo "jq is required" >&2
    exit 1
  }
}

capture_osascript() {
  local script_path="$1"
  shift

  local output
  if ! output=$(/usr/bin/osascript "$script_path" "$@" 2>&1); then
    printf '%s\n' "$output" >&2
    exit 1
  fi

  printf '%s' "$output"
}

try_capture_osascript() {
  local script_path="$1"
  shift

  /usr/bin/osascript "$script_path" "$@"
}

normalize_json_input() {
  ensure_jq
  "$JQ_BIN" -c '.'
}

json_lines_to_array() {
  ensure_jq
  "$JQ_BIN" -Rsc 'split("\n") | map(select(length > 0) | fromjson)'
}

require_positive_int() {
  local label="$1"
  local value="$2"

  [[ "$value" =~ ^[0-9]+$ ]] && [[ "$value" -ge 1 ]] || {
    echo "Invalid ${label}: ${value}" >&2
    exit 1
  }
}

account_names_raw() {
  capture_osascript "$APPLETS_DIR/account/list.applescript"
}

account_exists_or_error() {
  local account_name="$1"
  local accounts_raw

  accounts_raw="$(account_names_raw)"
  printf '%s\n' "$accounts_raw" | grep -Fqx -- "$account_name" || {
    echo "Account not found: $account_name" >&2
    exit 1
  }
}

mailbox_names_raw() {
  local account_name="${1:-}"

  if [[ -n "$account_name" ]]; then
    capture_osascript "$APPLETS_DIR/mailbox/list.applescript" "$account_name"
  else
    capture_osascript "$APPLETS_DIR/mailbox/list.applescript"
  fi
}

mailbox_exists_or_error() {
  local account_name="$1"
  local mailbox_name="$2"
  local mailboxes_raw

  mailboxes_raw="$(mailbox_names_raw "$account_name")"
  printf '%s\n' "$mailboxes_raw" | grep -Fqx -- "$mailbox_name" || {
    echo "Mailbox not found: $mailbox_name" >&2
    exit 1
  }
}
