# Command reference

All public entrypoints live under:

- `macos-mail/scripts/commands/**`

All commands print **JSON** to stdout on success and exit non-zero on failure.

## Setup / health

- `macos-mail/scripts/check-setup.sh`
  - Verifies `jq` + Mail Apple Events authorization.
  - Warns if `sqlite3`/Envelope Index access is missing (needed for `search-sqlite`).

## Accounts

```bash
macos-mail/scripts/commands/account/list.sh
macos-mail/scripts/commands/account/default.sh
macos-mail/scripts/commands/account/get.sh "<account>" [property]
macos-mail/scripts/commands/account/exists.sh "<account>"
macos-mail/scripts/commands/account/check-mail.sh ["<account>"]
```

## Mailboxes

```bash
macos-mail/scripts/commands/mailbox/list.sh ["<account>"]
macos-mail/scripts/commands/mailbox/get.sh "<account>" "<mailbox>" [property]
macos-mail/scripts/commands/mailbox/count.sh "<account>" "<mailbox>"
macos-mail/scripts/commands/mailbox/exists.sh "<account>" "<mailbox>"
```

## Messages

### Read

```bash
macos-mail/scripts/commands/message/list.sh "<account>" "<mailbox>" [limit]
macos-mail/scripts/commands/message/get.sh "<account>" "<mailbox>" <index> [property]
macos-mail/scripts/commands/message/show.sh "<account>" "<mailbox>" <index>
macos-mail/scripts/commands/message/source.sh "<account>" "<mailbox>" <index>
macos-mail/scripts/commands/message/get-by-id.sh "<rfc5322-message-id>" [property]
```

### Search

```bash
# Mail.app in-process search (can be slow on large mailboxes)
macos-mail/scripts/commands/message/search.sh "<account>" "<mailbox>" subject_contains "invoice" [limit]
macos-mail/scripts/commands/message/search.sh "<account>" "<mailbox>" sender_contains "@example.com" [limit]

# Fast metadata search (requires Full Disk Access)
macos-mail/scripts/commands/message/search-sqlite.sh "invoice" [limit]
```

### Draft-first composition

```bash
# Create a draft (does not send). Optional args are positional.
#   <toCsv> <subject> <body> [visible] [ccCsv] [bccCsv] [attachmentPath...]
macos-mail/scripts/commands/message/create.sh \
  "to@example.com" \
  "Subject" \
  "Body" \
  false \
  "cc1@example.com,cc2@example.com" \
  "" \
  /path/to/file.pdf

# List drafts across accounts (best-effort mailbox discovery).
macos-mail/scripts/commands/message/draft-list.sh [limit]

# Send a specific draft by its Mail internal id.
macos-mail/scripts/commands/message/draft-send.sh <draft-id>

# Reply/forward as drafts (do not send).
macos-mail/scripts/commands/message/reply-draft.sh "<account>" "<mailbox>" <index> "Reply body" [visible]
macos-mail/scripts/commands/message/forward-draft.sh "<account>" "<mailbox>" <index> [visible]
```

### Direct actions (use only with explicit approval)

```bash
macos-mail/scripts/commands/message/send.sh "to@example.com" "Subject" "Body"
macos-mail/scripts/commands/message/reply.sh "<account>" "<mailbox>" <index> "Body"
macos-mail/scripts/commands/message/move.sh "<account>" "<mailbox>" <index> "<destination-mailbox>"
macos-mail/scripts/commands/message/delete.sh "<account>" "<mailbox>" <index>
macos-mail/scripts/commands/message/mark-read.sh "<account>" "<mailbox>" <index>
macos-mail/scripts/commands/message/mark-unread.sh "<account>" "<mailbox>" <index>
macos-mail/scripts/commands/message/flag.sh "<account>" "<mailbox>" <index>
macos-mail/scripts/commands/message/unflag.sh "<account>" "<mailbox>" <index>
```

## Other

```bash
macos-mail/scripts/commands/signature/list.sh
macos-mail/scripts/commands/viewer/inbox.sh
macos-mail/scripts/commands/import/mailbox.sh "/path/to/Archive.mbox"
macos-mail/scripts/commands/url/mailto.sh "mailto:user@example.com?subject=Hello"
```

## JSON shapes

### Message summary

```json
{
  "id": "<message-id or fallback>",
  "account": "<account>",
  "mailbox": "<mailbox>",
  "index": 1,
  "subject": "...",
  "sender": "Name <addr@example.com>",
  "date_received": "2026-04-14T20:51:33Z",
  "message_id": "<rfc5322-message-id>",
  "read": false,
  "flagged": false
}
```

### Full message

Includes all summary fields plus:

- `date_sent` (ISO 8601 or `null`)
- `reply_to` (string or `null`)
- `message_size` (int or `null`)
- `junk` (bool)
- `flag_index` (int or `null`)
- `background_color` (string or `null`)
- `all_headers` (string or `null`)
- `content` (string)

### Draft summary

```json
{
  "draft_id": 12345,
  "account": "<account>",
  "mailbox": "Drafts",
  "subject": "...",
  "sender": "Name <addr@example.com>",
  "date_sent": null,
  "message_id": null,
  "read": true
}
```

### SQLite search rows (`search-sqlite`)

The SQLite search returns rows sourced from Mail's `Envelope Index` database, typically including:

- `rowid` (int)
- `message_id` (string or null; schema-dependent)
- `subject` (string)
- `sender` (string)
- `date_received` (ISO 8601 string)
- `read` / `flagged` (ints)
- `mailbox_url` (string)
