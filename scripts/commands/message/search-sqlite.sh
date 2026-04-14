#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/commands/_lib/common.sh
source "$SCRIPT_DIR/../_lib/common.sh"

[[ $# -ge 1 && $# -le 2 ]] || { echo "Usage: $(basename "$0") <query> [limit]" >&2; exit 1; }

query="$1"
limit="${2:-20}"

require_positive_int "limit" "$limit"
ensure_jq

command -v sqlite3 >/dev/null 2>&1 || { echo "sqlite3 is required" >&2; exit 1; }

find_envelope_index() {
  local base_dir="$HOME/Library/Mail"
  [[ -d "$base_dir" ]] || return 1
  find "$base_dir" -maxdepth 4 -type f -name 'Envelope Index' -print -quit 2>/dev/null
}

db_path="$(find_envelope_index || true)"
[[ -n "$db_path" ]] || { echo "Envelope Index database not found under $HOME/Library/Mail" >&2; exit 1; }
[[ -r "$db_path" ]] || { echo "No read permission for $db_path. Grant Full Disk Access to your terminal app." >&2; exit 1; }

query_one_line="${query//$'\n'/ }"
query_sql="${query_one_line//\'/\'\'}"

sql_with_message_id="
SELECT
  m.ROWID AS rowid,
  mgd.message_id_header AS message_id,
  s.subject AS subject,
  a.address AS sender,
  datetime(m.date_received + 978307200, 'unixepoch') AS date_received,
  m.read AS read,
  m.flagged AS flagged,
  mb.url AS mailbox_url
FROM messages m
JOIN addresses a ON m.sender = a.ROWID
JOIN subjects s ON m.subject = s.ROWID
JOIN mailboxes mb ON m.mailbox = mb.ROWID
LEFT JOIN message_global_data mgd ON m.message_id = mgd.message_id
WHERE s.subject LIKE '%' || '${query_sql}' || '%'
   OR a.address LIKE '%' || '${query_sql}' || '%'
ORDER BY m.date_received DESC
LIMIT ${limit};
"

sql_without_message_id="
SELECT
  m.ROWID AS rowid,
  NULL AS message_id,
  s.subject AS subject,
  a.address AS sender,
  datetime(m.date_received + 978307200, 'unixepoch') AS date_received,
  m.read AS read,
  m.flagged AS flagged,
  mb.url AS mailbox_url
FROM messages m
JOIN addresses a ON m.sender = a.ROWID
JOIN subjects s ON m.subject = s.ROWID
JOIN mailboxes mb ON m.mailbox = mb.ROWID
WHERE s.subject LIKE '%' || '${query_sql}' || '%'
   OR a.address LIKE '%' || '${query_sql}' || '%'
ORDER BY m.date_received DESC
LIMIT ${limit};
"

run_query() {
  local sql="$1"
  sqlite3 -batch "$db_path" 2>&1 <<SQL
.headers on
.mode json
${sql}
SQL
}

if ! raw_output="$(run_query "$sql_with_message_id")"; then
  if printf '%s' "$raw_output" | grep -qF "no such table: message_global_data"; then
    raw_output="$(run_query "$sql_without_message_id")" || { echo "$raw_output" >&2; exit 1; }
  else
    echo "$raw_output" >&2
    exit 1
  fi
fi

if [[ -z "$raw_output" ]]; then
  echo '[]'
  exit 0
fi

printf '%s' "$raw_output" | "$JQ_BIN" -c '.'
