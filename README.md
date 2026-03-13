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
- Read messages (subject, sender, date, content).
- Create, send, and save draft messages.
- Search messages by subject, sender, or content.
- Add attachments to outgoing messages.
- Move messages between mailboxes.
- Mark messages as read/unread/flagged.

## Prerequisites

- macOS 12+ with Mail.app configured and signed in
- Automation permission granted to your terminal app
- (Optional) Full Disk Access for SQLite-based search

## How To Use

From the skill directory (or path where scripts are installed):

```bash
# List all Mail accounts
osascript scripts/account/list.applescript
# List mailboxes in account "iCloud"
osascript scripts/mailbox/list.applescript "iCloud"
# List recent messages (account, mailbox, limit); subject | sender | date
osascript scripts/message/list.applescript "iCloud" "INBOX" 5
# Create draft (to, subject, body); does not send
osascript scripts/message/create.applescript "someone@example.com" "Hello" "Draft body here"
```

For the full command set and examples, see `SKILL.md` and scripts under `scripts/`.

## Troubleshooting

| Issue | Solution |
|-------|----------|
| "not authorized" error | Grant Automation permission to terminal in System Settings |
| Mail.app not responding | Ensure Mail.app is running; launch with `open -a Mail` |
| Account not found | Check account name with `get name of every account` |
| Mailbox not found | Check mailbox name with `get name of every mailbox of account "..."` |
| Slow searches | Limit result count or use SQLite-based `apple-mail-search` skill |
