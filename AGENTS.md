# Repo Guide

This repo stores a skill for macOS Mail.app integration.

## Goal

- Document AppleScript commands for Mail.app accurately.
- Prefer runnable examples over long prose.
- Treat email data as real user data — never send messages without explicit user approval.

## Repo Layout

- `AGENTS.md`: this file; rules for coding agents.
- `SKILL.md`: the skill contract and usage instructions for agents.
- `README.md`: public project overview and installation notes.
- `Makefile`: targets `dictionary-mail`, `check`, `compile`, `test` (test-dictionary + test-smoke).
- `scripts/account/list.applescript`: list Mail account names.
- `scripts/account/check-mail.applescript`: check for new mail [for account].
- `scripts/mailbox/list.applescript`: list mailbox names [for account].
- `scripts/mailbox/count.applescript`: message count for account/mailbox.
- `scripts/message/list.applescript`, `get.applescript`, `search.applescript`, `create.applescript`, `send.applescript`.
- `scripts/message/reply.applescript`, `forward.applescript`, `move.applescript`, `delete.applescript`.
- `scripts/message/mark-read.applescript`, `mark-unread.applescript`, `flag.applescript`, `unflag.applescript`.
- `scripts/message/extract-name.applescript`, `extract-address.applescript`.
- `scripts/url/mailto.applescript`; `scripts/viewer/inbox.applescript`; `scripts/signature/list.applescript`; `scripts/import/mailbox.applescript`.
- `tests/dictionary_contract.sh`: contract test against Mail.app scripting dictionary.
- `tests/smoke_mail.sh`: smoke test for script layer (skips when Mail.app not available).
- `.github/workflows/ci-pr.yml`, `ci-main.yml`: CI on PR and push to main.

## Validation

After making changes:
- run `make check` to ensure Mail.app is available;
- run `make test` to run dictionary contract and smoke tests;
- run `make compile` to compile all AppleScript files (syntax check);
- update `SKILL.md` when command coverage changes.

## Editing Rules

- Keep docs in simple English.
- Do not claim support for a feature unless it is verified with AppleScript and Mail.app.
- Treat email data as real user data; never send messages without explicit user approval.
