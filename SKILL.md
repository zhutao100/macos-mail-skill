---
name: macos-mail
description: Read, compose, search, and organise emails in Apple Mail.app on macOS through the public scripts/commands interface.
---

# macOS Mail

Use this skill when the task is about Apple Mail.app on macOS.

## Main Rule

Use only `scripts/commands`.
Do not call `scripts/applescripts` directly.

## Requirements

- macOS with Mail.app configured
- Automation access for your terminal app
- `jq`

Check access with:

```bash
make check
```

## Public Interface

Run commands from `scripts/commands`:

- `scripts/commands/account/*`
- `scripts/commands/mailbox/*`
- `scripts/commands/message/*`
- `scripts/commands/signature/list.sh`
- `scripts/commands/viewer/inbox.sh`
- `scripts/commands/import/mailbox.sh`
- `scripts/commands/url/mailto.sh`

All public commands return JSON by default.

## Accounts

```bash
scripts/commands/account/list.sh
scripts/commands/account/get.sh "iCloud"
scripts/commands/account/get.sh "iCloud" name
scripts/commands/account/exists.sh "iCloud"
scripts/commands/account/check-mail.sh
scripts/commands/account/check-mail.sh "iCloud"
```

## Mailboxes

```bash
scripts/commands/mailbox/list.sh
scripts/commands/mailbox/list.sh "iCloud"
scripts/commands/mailbox/get.sh "iCloud" "INBOX"
scripts/commands/mailbox/get.sh "iCloud" "INBOX" message_count
scripts/commands/mailbox/count.sh "iCloud" "INBOX"
scripts/commands/mailbox/exists.sh "iCloud" "INBOX"
```

## Messages

Read and search:

```bash
scripts/commands/message/list.sh "iCloud" "INBOX" 5
scripts/commands/message/get.sh "iCloud" "INBOX" 1
scripts/commands/message/get.sh "iCloud" "INBOX" 1 subject
scripts/commands/message/search.sh "iCloud" "INBOX" subject_contains "invoice"
scripts/commands/message/search.sh "iCloud" "INBOX" sender_contains "john@example.com"
scripts/commands/message/exists.sh "iCloud" "INBOX" 1
```

Create, send, and reply:

```bash
scripts/commands/message/create.sh "person@example.com" "Hello" "Draft body" false
scripts/commands/message/send.sh "person@example.com" "Hello" "Ready to send"
scripts/commands/message/reply.sh "iCloud" "INBOX" 1 "Thanks for your message."
scripts/commands/message/forward.sh "iCloud" "INBOX" 1
```

Organise:

```bash
scripts/commands/message/move.sh "iCloud" "INBOX" 1 "Archive"
scripts/commands/message/delete.sh "iCloud" "INBOX" 1
scripts/commands/message/mark-read.sh "iCloud" "INBOX" 1
scripts/commands/message/mark-unread.sh "iCloud" "INBOX" 1
scripts/commands/message/flag.sh "iCloud" "INBOX" 1
scripts/commands/message/unflag.sh "iCloud" "INBOX" 1
```

Address parsing:

```bash
scripts/commands/message/extract-name.sh "Jane Doe <jane@example.com>"
scripts/commands/message/extract-address.sh "Jane Doe <jane@example.com>"
```

## Other Commands

```bash
scripts/commands/signature/list.sh
scripts/commands/viewer/inbox.sh
scripts/commands/import/mailbox.sh "/Users/Dmytro/Downloads/Archive.mbox"
scripts/commands/url/mailto.sh "mailto:user@example.com?subject=Hello"
```

## JSON Contract

Account object:

- `id`
- `name`

Mailbox object:

- `id`
- `name`
- `account`
- `message_count`

Message summary object:

- `id`
- `account`
- `mailbox`
- `index`
- `subject`
- `sender`
- `date_received`
- `read`
- `flagged`

Full message object:

- all summary fields
- `date_sent`
- `message_id`
- `reply_to`
- `message_size`
- `junk`
- `flag_index`
- `background_color`
- `all_headers`
- `content`

Scalar envelopes:

- `count`: `{"count": N, "account": "...", "mailbox": "..."}`
- `exists`: `{"exists": true, ...}` or `{"exists": false, "id": null, ...}`
- `deleted`: `{"deleted": true, ...}`
- property read: `{"id": "...", "property": "...", "value": ...}`
- status actions: `checking`, `created`, `sent`, `moved`, `updated`, `opened`, `imported`

## Safety

- Treat email content as private user data.
- Prefer drafts over direct send.
- Never send or reply without explicit user approval.
