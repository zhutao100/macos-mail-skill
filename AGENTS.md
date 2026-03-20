# Repo Guide

This repo stores a skill for macOS Mail.app integration.

## Goal

- Document AppleScript commands for Mail.app accurately.
- Keep the public `scripts/commands` interface accurate to the implemented behaviour.
- Prefer runnable examples over long prose.
- Treat email data as real user data. Never send messages without explicit user approval.

## Repo Layout

- `AGENTS.md`: this file; rules for coding agents.
- `SKILL.md`: the skill contract and usage instructions for agents.
- `README.md`: public project overview and installation notes.
- `Makefile`: targets `dictionary-mail`, `check`, `compile`, `test` (test-dictionary + test-smoke).
- `scripts/commands/`: public shell interface. All commands return JSON by default.
- `scripts/commands/_lib/common.sh`: shared shell helpers.
- `scripts/commands/account/`: `list.sh`, `get.sh`, `exists.sh`, `check-mail.sh`.
- `scripts/commands/mailbox/`: `list.sh`, `get.sh`, `count.sh`, `exists.sh`.
- `scripts/commands/message/`: `list.sh`, `get.sh`, `search.sh`, `exists.sh`, `create.sh`, `send.sh`, `reply.sh`, `forward.sh`, `move.sh`, `delete.sh`, `mark-read.sh`, `mark-unread.sh`, `flag.sh`, `unflag.sh`, `extract-name.sh`, `extract-address.sh`.
- `scripts/commands/signature/list.sh`, `scripts/commands/viewer/inbox.sh`, `scripts/commands/import/mailbox.sh`, `scripts/commands/url/mailto.sh`.
- `scripts/applescripts/account/`, `mailbox/`, `message/`, `signature/`, `viewer/`, `import/`, `url/`: internal AppleScript entrypoints.
- `tests/dictionary_contract.sh`: contract test against Mail.app scripting dictionary.
- `tests/smoke_mail.sh`: smoke test for the public command layer (skips when Mail.app is not available).
- `.github/workflows/ci-pr.yml`, `ci-main.yml`: CI on PR and push to main.

## Public Rule

- Run public commands from the repo root with `scripts/commands/...`.
- Do not call `scripts/applescripts` directly from the public contract.

## Validation

After making changes:

- run `make check` to ensure Mail.app and `jq` are available;
- run `make test` to run dictionary contract and smoke tests;
- run `make compile` to compile all AppleScript files (syntax check);
- update `SKILL.md` when command coverage changes.

## Editing Rules

- Keep docs in simple English.
- Do not claim support for a feature unless it is verified with AppleScript and Mail.app.
- Keep `SKILL.md` and `README.md` about the public `scripts/commands` interface, not the internal AppleScript backend.
- Treat email data as real user data. Never send messages without explicit user approval.
