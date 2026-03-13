---
name: macos-mail
description: Read, compose, search, and organize emails in Apple Mail.app on macOS. Use for checking inbox, drafting messages, managing mailboxes, or automating email workflows. Triggers on queries about email, mail, inbox, drafts, or contacting someone via email.
---

# macOS Mail Integration

Read, compose, search, and organize emails using AppleScript and Apple Mail.app on macOS.

## Setup

### 1. Grant Permissions

Required macOS permissions (System Settings > Privacy & Security):

| Permission | Location | Required For |
|------------|----------|--------------|
| Automation | Privacy & Security > Automation | Controlling Mail.app via AppleScript |
| Full Disk Access | Privacy & Security > Full Disk Access | Accessing mail data (optional, for SQLite search) |

### 2. Configure Mail.app

- Open Mail.app and sign in to at least one email account.
- Ensure mailboxes are synced and visible.

## Commands

All commands use `osascript -e` to execute AppleScript one-liners, or `osascript` with a heredoc for multi-line scripts.

### List Accounts

```bash
osascript -e 'tell application "Mail" to get name of every account'
```

### List Mailboxes for an Account

```bash
osascript -e 'tell application "Mail" to get name of every mailbox of account "iCloud"'
```

### Count Messages in a Mailbox

```bash
osascript -e 'tell application "Mail" to get count of messages of mailbox "INBOX" of account "iCloud"'
```

### Read Recent Messages

```bash
# Get subject and sender of the 10 most recent messages in INBOX
osascript <<'EOF'
tell application "Mail"
    set msgs to messages 1 thru 10 of mailbox "INBOX" of account "iCloud"
    set output to ""
    repeat with m in msgs
        set output to output & subject of m & " | " & sender of m & " | " & date received of m & linefeed
    end repeat
    return output
end tell
EOF
```

### Read a Specific Message

```bash
# Read the full content of message 1 in INBOX
osascript <<'EOF'
tell application "Mail"
    set m to message 1 of mailbox "INBOX" of account "iCloud"
    set subj to subject of m
    set sndr to sender of m
    set dt to date received of m
    set body to content of m
    return "Subject: " & subj & linefeed & "From: " & sndr & linefeed & "Date: " & dt & linefeed & linefeed & body
end tell
EOF
```

### Create and Send a Message

```bash
osascript <<'EOF'
tell application "Mail"
    set newMsg to make new outgoing message with properties {subject:"Meeting Tomorrow", content:"Hi,\n\nJust confirming our meeting tomorrow at 10am.\n\nBest regards", visible:true}
    tell newMsg
        make new to recipient at end of to recipients with properties {address:"recipient@example.com"}
    end tell
    send newMsg
end tell
EOF
```

### Save a Draft (Without Sending)

```bash
osascript <<'EOF'
tell application "Mail"
    set newMsg to make new outgoing message with properties {subject:"Draft: Project Update", content:"Here is the latest update...", visible:true}
    tell newMsg
        make new to recipient at end of to recipients with properties {address:"recipient@example.com"}
    end tell
    -- Do not call "send" -- the message stays as a draft in the Drafts mailbox
end tell
EOF
```

### Reply to a Message

```bash
osascript <<'EOF'
tell application "Mail"
    set m to message 1 of mailbox "INBOX" of account "iCloud"
    set replyMsg to reply m with properties {content:"Thanks for your message! I'll get back to you shortly."}
    send replyMsg
end tell
EOF
```

### Add Attachments

```bash
osascript <<'EOF'
tell application "Mail"
    set newMsg to make new outgoing message with properties {subject:"Report Attached", content:"Please find the report attached.", visible:true}
    tell newMsg
        make new to recipient at end of to recipients with properties {address:"recipient@example.com"}
        make new attachment with properties {file name:POSIX file "/Users/Dmytro/Documents/report.pdf"} at after last paragraph
    end tell
    send newMsg
end tell
EOF
```

### Search Messages

```bash
# Search by subject in INBOX
osascript <<'EOF'
tell application "Mail"
    set found to (messages of mailbox "INBOX" of account "iCloud" whose subject contains "invoice")
    set output to ""
    repeat with m in found
        set output to output & subject of m & " | " & sender of m & " | " & date received of m & linefeed
    end repeat
    return output
end tell
EOF
```

```bash
# Search by sender
osascript <<'EOF'
tell application "Mail"
    set found to (messages of mailbox "INBOX" of account "iCloud" whose sender contains "john@example.com")
    set output to ""
    repeat with m in found
        set output to output & subject of m & " | " & date received of m & linefeed
    end repeat
    return output
end tell
EOF
```

### Move a Message to Another Mailbox

```bash
osascript <<'EOF'
tell application "Mail"
    set m to message 1 of mailbox "INBOX" of account "iCloud"
    move m to mailbox "Archive" of account "iCloud"
end tell
EOF
```

### Delete a Message

```bash
osascript <<'EOF'
tell application "Mail"
    set m to message 1 of mailbox "INBOX" of account "iCloud"
    delete m
end tell
EOF
```

### Mark as Read / Unread

```bash
# Mark as read
osascript -e 'tell application "Mail" to set read status of message 1 of mailbox "INBOX" of account "iCloud" to true'

# Mark as unread
osascript -e 'tell application "Mail" to set read status of message 1 of mailbox "INBOX" of account "iCloud" to false'
```

### Flag / Unflag a Message

```bash
# Flag a message
osascript -e 'tell application "Mail" to set flagged status of message 1 of mailbox "INBOX" of account "iCloud" to true'

# Unflag a message
osascript -e 'tell application "Mail" to set flagged status of message 1 of mailbox "INBOX" of account "iCloud" to false'
```

## Best Practices

### Account and Mailbox Names
- Always specify the correct account name (e.g. "iCloud", "Gmail", "Exchange").
- Use `get name of every account` to discover available accounts first.
- Mailbox names are case-sensitive and locale-dependent.

### Drafts Over Direct Send
- **Prefer saving drafts** over sending directly — let the user review before sending.
- Omit the `send` command to leave the message as a visible draft.

### Performance
- AppleScript message searches can be slow on large mailboxes.
- Limit result sets with `messages 1 thru N` when possible.
- For fast searching across all mailboxes, consider using the `apple-mail-search` skill (direct SQLite queries).

### Email Etiquette for Agents
- **Never send without approval** — always save as draft first.
- **Use proper formatting** — include greeting, body, and sign-off.
- **Be concise** — keep emails clear and to the point.
- **Respect privacy** — treat email content as confidential user data.

## Troubleshooting

| Issue | Solution |
|-------|----------|
| "not authorized" error | Grant Automation permission to terminal in System Settings |
| Mail.app not responding | Ensure Mail.app is running; launch with `open -a Mail` |
| Account not found | Check account name with `get name of every account` |
| Mailbox not found | Check mailbox name with `get name of every mailbox of account "..."` |
| Slow searches | Limit result count or use SQLite-based `apple-mail-search` skill |
| Attachments not attaching | Use `POSIX file` path format with absolute paths |

## Technical Notes

- Uses AppleScript via `osascript` for all operations (no private APIs).
- Mail.app must be running for AppleScript commands to work.
- Works with any account type configured in Mail.app (iCloud, Gmail, Exchange, IMAP, etc.).
- Requires macOS 12+ with Mail.app configured.
