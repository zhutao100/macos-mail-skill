#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

if ! command -v git >/dev/null 2>&1; then
  echo "install-git-hooks: git not found" >&2
  exit 1
fi

# Optional: prek (pre-commit runner).
if command -v prek >/dev/null 2>&1; then
  prek install --prepare-hooks
else
  echo "install-git-hooks: prek not found; skipping 'prek install'." >&2
  echo "install-git-hooks: install prek, or use pre-commit directly, if you want automatic formatting/lints." >&2
fi

# Point git at the repo's hook shims.
git config core.hooksPath .githooks

echo "install-git-hooks: ok"
