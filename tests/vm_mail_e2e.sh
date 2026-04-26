#!/usr/bin/env bash
# shellcheck disable=SC2016
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
JQ_BIN="${JQ_BIN:-$(command -v jq || true)}"

fail() {
  echo "vm_mail_e2e: $*" >&2
  exit 1
}

json_ok() {
  local json="$1"
  local filter="$2"
  local label="$3"
  printf '%s\n' "$json" | "$JQ_BIN" -e "$filter" >/dev/null || fail "$label"
}

cmd() {
  local command_path="$1"
  shift
  "$ROOT_DIR/macos-mail/scripts/commands/$command_path" "$@"
}

[[ "${MACOS_MAIL_VM_E2E:-}" == "1" ]] || fail "refusing to run unless MACOS_MAIL_VM_E2E=1 is set in a disposable VM"
[ -n "$JQ_BIN" ] || fail "jq is required"

if ! osascript -e 'tell application "Mail" to get name' >/dev/null 2>&1; then
  fail "Mail.app is not available or Automation is not authorized"
fi

accounts_json="$(cmd account/list.sh)"
json_ok "$accounts_json" 'type == "array" and length > 0' "account list should be a non-empty array"
account_name="$(printf '%s\n' "$accounts_json" | "$JQ_BIN" -r '.[0].name')"

default_json="$(cmd account/default.sh)"
json_ok "$default_json" '. == null or type == "object"' "default account should be object or null"

account_json="$(cmd account/get.sh "$account_name")"
printf '%s\n' "$account_json" | "$JQ_BIN" -e --arg name "$account_name" 'type == "object" and .name == $name' >/dev/null || fail "account get contract mismatch"

account_exists_json="$(cmd account/exists.sh "$account_name")"
json_ok "$account_exists_json" '.exists == true' "account exists contract mismatch"

mailboxes_json="$(cmd mailbox/list.sh "$account_name")"
json_ok "$mailboxes_json" 'type == "array" and length > 0' "mailbox list should be a non-empty array"

mailbox_name=""
message_count=0
while IFS= read -r candidate; do
  [ -n "$candidate" ] || continue
  count_json="$(cmd mailbox/count.sh "$account_name" "$candidate")" || continue
  count="$(printf '%s\n' "$count_json" | "$JQ_BIN" -r '.count // 0')"
  if [[ "$count" =~ ^[0-9]+$ ]] && [ "$count" -gt 0 ]; then
    mailbox_name="$candidate"
    message_count="$count"
    break
  fi
done < <(printf '%s\n' "$mailboxes_json" | "$JQ_BIN" -r '.[].name')

[ -n "$mailbox_name" ] || fail "no mailbox with messages was found in the disposable VM test account"

mailbox_json="$(cmd mailbox/get.sh "$account_name" "$mailbox_name")"
printf '%s\n' "$mailbox_json" | "$JQ_BIN" -e --arg name "$mailbox_name" 'type == "object" and .name == $name and (.message_count | type == "number")' >/dev/null || fail "mailbox get contract mismatch"

mailbox_exists_json="$(cmd mailbox/exists.sh "$account_name" "$mailbox_name")"
json_ok "$mailbox_exists_json" '.exists == true' "mailbox exists contract mismatch"

messages_json="$(cmd message/list.sh "$account_name" "$mailbox_name" 3)"
json_ok "$messages_json" 'type == "array" and length > 0' "message list should be a non-empty array"
message_index="$(printf '%s\n' "$messages_json" | "$JQ_BIN" -r '.[0].index')"

message_json="$(cmd message/get.sh "$account_name" "$mailbox_name" "$message_index")"
json_ok "$message_json" 'has("id") and has("subject") and has("sender") and has("content")' "message get contract mismatch"

message_subject_json="$(cmd message/get.sh "$account_name" "$mailbox_name" "$message_index" subject)"
json_ok "$message_subject_json" '.property == "subject" and has("value")' "message property get contract mismatch"

message_exists_json="$(cmd message/exists.sh "$account_name" "$mailbox_name" "$message_index")"
json_ok "$message_exists_json" '.exists == true' "message exists contract mismatch"

source_json="$(cmd message/source.sh "$account_name" "$mailbox_name" "$message_index")"
json_ok "$source_json" 'has("source") and (.source | type == "string")' "message source contract mismatch"

show_json="$(cmd message/show.sh "$account_name" "$mailbox_name" "$message_index")"
json_ok "$show_json" '.shown == true and has("subject") and has("mailbox")' "message show contract mismatch"

message_id="$(printf '%s\n' "$message_json" | "$JQ_BIN" -r '.message_id // empty')"
if [ -n "$message_id" ]; then
  by_id_json="$(cmd message/get-by-id.sh "$message_id")"
  printf '%s\n' "$by_id_json" | "$JQ_BIN" -e --arg message_id "$message_id" '.message_id == $message_id' >/dev/null || fail "message get-by-id contract mismatch"
else
  echo "vm_mail_e2e: get-by-id skipped because the selected message has no Message-ID"
fi

search_value="$(printf '%s\n' "$message_json" | "$JQ_BIN" -r '.subject // empty' | tr '\n' ' ' | cut -c 1-40)"
if [ -n "$search_value" ]; then
  search_json="$(cmd message/search.sh "$account_name" "$mailbox_name" subject_contains "$search_value" 2)"
  json_ok "$search_json" 'type == "array"' "message search should return an array"

  if sqlite_json="$(cmd message/search-sqlite.sh "$search_value" 2 2>/dev/null)"; then
    json_ok "$sqlite_json" 'type == "array"' "message search-sqlite should return an array"
  else
    echo "vm_mail_e2e: search-sqlite skipped because Full Disk Access or Envelope Index access is unavailable"
  fi
else
  echo "vm_mail_e2e: search skipped because the selected message has no subject"
fi

extract_name_json="$(cmd message/extract-name.sh 'Agent Test <agent-test@example.invalid>')"
json_ok "$extract_name_json" '.name == "Agent Test"' "extract-name contract mismatch"

extract_address_json="$(cmd message/extract-address.sh 'Agent Test <agent-test@example.invalid>')"
json_ok "$extract_address_json" '.address == "agent-test@example.invalid"' "extract-address contract mismatch"

signature_json="$(cmd signature/list.sh)"
json_ok "$signature_json" 'type == "array"' "signature list should return an array"

viewer_json="$(cmd viewer/inbox.sh)"
json_ok "$viewer_json" 'has("mailbox")' "viewer inbox contract mismatch"

draft_subject="macos-mail VM E2E draft $(date -u +%Y%m%dT%H%M%SZ)-$$"
draft_json="$(cmd message/create.sh "agent-test@example.invalid" "$draft_subject" "Disposable VM draft body." false)"
printf '%s\n' "$draft_json" | "$JQ_BIN" -e --arg subject "$draft_subject" '.created == true and .visible == false and .subject == $subject' >/dev/null || fail "draft create contract mismatch"

reply_json="$(cmd message/reply-draft.sh "$account_name" "$mailbox_name" "$message_index" "Disposable VM reply draft body." false)"
json_ok "$reply_json" '.created == true and .visible == false' "reply-draft contract mismatch"

forward_json="$(cmd message/forward-draft.sh "$account_name" "$mailbox_name" "$message_index" false)"
json_ok "$forward_json" '.created == true and .visible == false' "forward-draft contract mismatch"

drafts_json="$(cmd message/draft-list.sh 20)"
printf '%s\n' "$drafts_json" | "$JQ_BIN" -e --arg subject "$draft_subject" 'type == "array" and any(.subject == $subject)' >/dev/null || fail "draft-list did not include the created draft"

echo "vm_mail_e2e: ok (selected mailbox had $message_count messages)"
