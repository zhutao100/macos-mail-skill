# macOS Mail Skill

This repo stores a skill for Apple Mail.app integration on macOS via AppleScript.

## Installation

```bash
npx skills add vinitu/macos-mail-skill
```

Or with [skills.sh](https://skills.sh):

```bash
skills.sh add vinitu/macos-mail-skill
```

## Scope

- List accounts and mailboxes configured in Mail.app.
- Read messages with structured JSON output.
- Show a message in the Mail.app window.
- Create drafts, send messages, and reply to messages.
- Search messages by subject or sender.
- Move, delete, flag, and mark messages.

## Prerequisites

- macOS 12+ with Mail.app configured and signed in
- Automation permission granted to your terminal app
- `jq`
- (Optional) Full Disk Access for SQLite-based search

## How To Use

Run the public command wrappers from the repo root or from the installed skill path.
Do not call `scripts/applescripts` directly.

```bash
# List all Mail accounts
scripts/commands/account/list.sh
# List mailboxes in account "iCloud"
scripts/commands/mailbox/list.sh "iCloud"
# Count messages in INBOX
scripts/commands/mailbox/count.sh "iCloud" "INBOX"
# List recent messages
scripts/commands/message/list.sh "iCloud" "INBOX" 5
# Read one message
scripts/commands/message/get.sh "iCloud" "INBOX" 1
# Show one message in Mail.app
scripts/commands/message/show.sh "iCloud" "INBOX" 1
# Create draft (does not send)
scripts/commands/message/create.sh "someone@example.com" "Hello" "Draft body here" false
```

All public commands return JSON by default.
For the full command set and examples, see `SKILL.md`.

## Public Interface

- `scripts/commands/account/*`
- `scripts/commands/mailbox/*`
- `scripts/commands/message/*`
- `scripts/commands/signature/list.sh`
- `scripts/commands/viewer/inbox.sh`
- `scripts/commands/import/mailbox.sh`
- `scripts/commands/url/mailto.sh`

## Troubleshooting

| Issue | Solution |
|-------|----------|
| "not authorized" error | Grant Automation permission to terminal in System Settings |
| Mail.app not responding | Ensure Mail.app is running; launch with `open -a Mail` |
| Account not found | Check account name with `scripts/commands/account/list.sh` |
| Mailbox not found | Check mailbox name with `scripts/commands/mailbox/list.sh "ACCOUNT"` |
| `jq is required` | Install `jq` and ensure it is in `PATH` |
| Slow searches | Limit result count or use SQLite-based `apple-mail-search` skill |
