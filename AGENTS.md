# Repo Guide

This repo stores a skill for macOS Mail.app integration.

## Goal

- Document AppleScript commands for Mail.app accurately.
- Keep the public `macos-mail/scripts/commands` interface accurate to the implemented behaviour.
- Prefer runnable examples over long prose.
- Treat email data as real user data. Never send messages without explicit user approval.

## Repo Layout

- `AGENTS.md`: this file; rules for coding agents.
- `macos-mail/SKILL.md`: the skill contract and usage instructions for agents.
- `README.md`: public project overview and installation notes.
- `Makefile`: targets `dictionary-mail`, `check`, `compile`, `test` (test-dictionary + test-unit + test-smoke).
- `.pre-commit-config.yaml`: prek/pre-commit hooks (format + checks).
- `.githooks/pre-commit`: agent-friendly self-healing prek hook shim (optional).
- `macos-mail/scripts/commands/`: public shell interface. All commands return JSON by default.
- `macos-mail/scripts/commands/_lib/common.sh`: shared shell helpers.
- `macos-mail/scripts/commands/account/`: `list.sh`, `get.sh`, `exists.sh`, `check-mail.sh`.
- `macos-mail/scripts/commands/mailbox/`: `list.sh`, `get.sh`, `count.sh`, `exists.sh`.
- `macos-mail/scripts/commands/message/`: `list.sh`, `get.sh`, `search.sh`, `search-sqlite.sh`, `get-by-id.sh`, `exists.sh`, `create.sh`, `draft-list.sh`, `draft-send.sh`, `reply-draft.sh`, `forward-draft.sh`, `send.sh`, `reply.sh`, `forward.sh`, `move.sh`, `delete.sh`, `mark-read.sh`, `mark-unread.sh`, `flag.sh`, `unflag.sh`, `extract-name.sh`, `extract-address.sh`.
- `macos-mail/scripts/commands/signature/list.sh`, `macos-mail/scripts/commands/viewer/inbox.sh`, `macos-mail/scripts/commands/import/mailbox.sh`, `macos-mail/scripts/commands/url/mailto.sh`.
- `macos-mail/scripts/applescripts/account/`, `mailbox/`, `message/`, `signature/`, `viewer/`, `import/`, `url/`: internal AppleScript entrypoints.
- `tests/dictionary_contract.sh`: contract test against Mail.app scripting dictionary.
- `tests/unit_parsing.sh`: unit-ish tests for pure parsing AppleScripts (no Mail.app required).
- `tests/smoke_mail.sh`: smoke test for the public command layer (skips when Mail.app is not available).
- `.github/workflows/ci-pr.yml`, `ci-main.yml`: CI on PR and push to main.

## Public Rule

- Run public commands from the repo root with `macos-mail/scripts/commands/...`.
- Do not call `macos-mail/scripts/applescripts` directly from the public contract.

## Validation

After making changes:

- run `make check` to ensure Mail.app and `jq` are available;
- run `make test` to run dictionary contract + unit + smoke tests;
- run `make compile` to compile all AppleScript files (syntax check);
- run `prek run --all-files` to verify pre-commit checks (or rely on `.githooks/pre-commit`);
- update `macos-mail/SKILL.md` when command coverage changes.

## Editing Rules

- Keep docs in simple English.
- Do not claim support for a feature unless it is verified with AppleScript and Mail.app.
- Keep `macos-mail/SKILL.md` and `README.md` about the public `macos-mail/scripts/commands` interface, not the internal AppleScript backend.
- Treat email data as real user data. Never send messages without explicit user approval.
