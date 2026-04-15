---
name: macos-mail
description: Automate Apple Mail.app on macOS via AppleScript-backed CLI commands (read, search, draft, and organise email).
---

# macOS Mail

Use this skill when the user needs to **read, search, draft, or organise** email in **Apple Mail.app** on macOS.

## Non-negotiables

1. **Use only** `macos-mail/scripts/commands/**`.
   - Do not call `macos-mail/scripts/applescripts/**` directly.
2. Treat mailbox contents as **private user data**.
3. **Draft-first by default**.
   - Never send, reply, forward, move, or delete messages without explicit user approval.

## Quick start

```bash
# Verify dependencies + Automation permission.
macos-mail/scripts/check-setup.sh

# Discover accounts and mailboxes.
macos-mail/scripts/commands/account/list.sh
macos-mail/scripts/commands/mailbox/list.sh "<account>"

# List and read messages.
macos-mail/scripts/commands/message/list.sh "<account>" "<mailbox>" 10
macos-mail/scripts/commands/message/get.sh "<account>" "<mailbox>" 1

# Create a draft (supports optional cc/bcc + attachments).
macos-mail/scripts/commands/message/create.sh "to@example.com" "Subject" "Body" false "cc@example.com" "" /path/to/file.pdf

# List drafts and send a specific draft by id.
macos-mail/scripts/commands/message/draft-list.sh 20
macos-mail/scripts/commands/message/draft-send.sh <draft-id>

# Reply/forward as draft (do not send).
macos-mail/scripts/commands/message/reply-draft.sh "<account>" "<mailbox>" 1 "Reply body" false
macos-mail/scripts/commands/message/forward-draft.sh "<account>" "<mailbox>" 1 true
```

## What to read next

- `macos-mail/references/commands.md` — command inventory + JSON shapes.
- `macos-mail/references/workflows.md` — reliable end-to-end workflows (triage, reply, bulk move).
- `macos-mail/references/permissions.md` — Automation + Full Disk Access (for `search-sqlite`).
- `macos-mail/references/advanced-search.md` — when to use SQLite search and how to interpret results.
- `macos-mail/references/applescript-patterns.md` — concrete AppleScript snippets used by the skill.

## Safety rules

- Prefer **stable identifiers** when available:
  - `message/get-by-id.sh` accepts an RFC 5322 **Message-ID** header.
- Destructive actions (`delete`, `move`, sending mail) require an explicit confirmation step in the conversation.
- For bulk actions, always **re-list** immediately before acting.
