# macOS Mail Skill

This repo stores a skill for Apple Mail.app integration on macOS via AppleScript.

## Installation

Install with `skills.sh`:

```bash
skills.sh add vinitu/macos-mail-skill
```

If you use the npm installer instead:

```bash
npx skills add vinitu/macos-mail-skill
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

```bash
# List all accounts
osascript -e 'tell application "Mail" to get name of every account'

# List mailboxes
osascript -e 'tell application "Mail" to get name of every mailbox of account "iCloud"'

# Read recent messages
osascript -e 'tell application "Mail" to get subject of messages 1 thru 5 of mailbox "INBOX" of account "iCloud"'

# Save a draft
osascript <<'EOF'
tell application "Mail"
    set newMsg to make new outgoing message with properties {subject:"Hello", content:"Draft body here", visible:true}
    tell newMsg
        make new to recipient at end of to recipients with properties {address:"someone@example.com"}
    end tell
end tell
EOF
```

For the full command set and examples, see `SKILL.md`.

## Troubleshooting

| Issue | Solution |
|-------|----------|
| "not authorized" error | Grant Automation permission to terminal in System Settings |
| Mail.app not responding | Ensure Mail.app is running; launch with `open -a Mail` |
| Account not found | Check account name with `get name of every account` |
| Mailbox not found | Check mailbox name with `get name of every mailbox of account "..."` |
| Slow searches | Limit result count or use SQLite-based `apple-mail-search` skill |
