#!/usr/bin/env bash
set -euo pipefail

fail() {
  echo "check-setup: $*" >&2
  exit 1
}

warn() {
  echo "check-setup: warning: $*" >&2
}

command -v /usr/bin/osascript >/dev/null 2>&1 || fail "osascript not found at /usr/bin/osascript"

JQ_BIN="${JQ_BIN:-}"
if [[ -z "$JQ_BIN" ]]; then
  JQ_BIN="$(command -v jq 2>/dev/null || true)"
fi
[[ -n "$JQ_BIN" ]] || fail "jq is required (install jq and ensure it is in PATH)"

# Basic Mail.app automation check.
set +e
out="$(/usr/bin/osascript -e 'tell application "Mail" to get name' 2>&1)"
st=$?
set -e
if [[ $st -ne 0 ]]; then
  if echo "$out" | grep -qi "not authorized to send apple events"; then
    cat >&2 <<'EOF'
check-setup: Mail.app automation is not authorized for this app.

Fix:
  System Settings → Privacy & Security → Automation
  Enable your terminal app (Terminal/iTerm/etc.) to control "Mail".

If the entry is missing or stuck, you can reset AppleEvents permissions:
  /usr/bin/tccutil reset AppleEvents <terminal-bundle-id>
EOF
    exit 1
  fi
  fail "Mail.app is not responding to Apple Events: $out"
fi

# Optional: Envelope Index access check (for search-sqlite).
if command -v sqlite3 >/dev/null 2>&1; then
  base_dir="$HOME/Library/Mail"
  if [[ -d "$base_dir" ]]; then
    db_path="$(find "$base_dir" -maxdepth 4 -type f -name 'Envelope Index' -print -quit 2>/dev/null || true)"
    if [[ -n "$db_path" ]]; then
      if [[ -r "$db_path" ]]; then
        :
      else
        warn "Envelope Index exists but is not readable. search-sqlite requires Full Disk Access for your terminal app. (db: $db_path)"
      fi
    else
      warn "Envelope Index not found under $base_dir (search-sqlite will be unavailable)."
    fi
  else
    warn "Mail data directory not found at $base_dir (Mail may not be configured)."
  fi
else
  warn "sqlite3 not found (search-sqlite will be unavailable)."
fi

echo "check-setup: ok"
