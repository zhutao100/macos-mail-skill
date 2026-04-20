#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
JQ_BIN="${JQ_BIN:-$(command -v jq || true)}"

[ -n "$JQ_BIN" ] || {
  echo "unit_commands: jq is required." >&2
  exit 1
}

fail() {
  echo "unit_commands: $*" >&2
  exit 1
}

tmp_dir="$(mktemp -d)"
trap 'rm -rf "$tmp_dir"' EXIT

stub_log="$tmp_dir/osascript.calls"
stub_bin="$tmp_dir/osascript_stub.sh"

cat >"$stub_bin" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

log="${OSASCRIPT_STUB_LOG:-}"
if [[ -n "$log" ]]; then
  {
    printf '%s' "$1"
    shift || true
    printf '\targc=%s' "$#"
    for a in "$@"; do
      printf '\t%s' "$a"
    done
    printf '\n'
  } >>"$log"
fi

printf '%s\n' '{"created":true}'
EOF

chmod +x "$stub_bin"

export OSASCRIPT_BIN="$stub_bin"
export OSASCRIPT_STUB_LOG="$stub_log"

create_cmd="$ROOT_DIR/macos-mail/scripts/commands/message/create.sh"

out="$("/bin/bash" "$create_cmd" "to@example.com" "Subject" "Body" false)"
printf '%s\n' "$out" | "$JQ_BIN" -e '.created == true and (.attachments | type == "array" and length == 0)' >/dev/null || {
  fail "create.sh without attachments did not return expected JSON (attachments should be empty array)"
}

last_line="$(sed -n '$p' "$stub_log" 2>/dev/null || true)"
[[ -n "$last_line" ]] || fail "osascript stub was not called"
[[ "$last_line" == *$'\targc=6'* ]] || fail "expected create.sh to call osascript with 6 args when no attachments: $last_line"

out="$("/bin/bash" "$create_cmd" "to@example.com" "Subject" "Body" false "" "" "a.txt" "b.pdf")"
printf '%s\n' "$out" | "$JQ_BIN" -e '.attachments == ["a.txt", "b.pdf"]' >/dev/null || {
  fail "create.sh with attachments did not preserve attachment args"
}

last_line="$(sed -n '$p' "$stub_log" 2>/dev/null || true)"
[[ "$last_line" == *$'\targc=8'*$'\ta.txt\tb.pdf' ]] || fail "expected create.sh to pass attachment args through to osascript: $last_line"

echo "unit_commands: ok"
