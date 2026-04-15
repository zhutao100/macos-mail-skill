# Workflows

This document focuses on **repeatable**, low-flake workflows for agents.

## Inbox triage

1) Identify the target mailbox:

```bash
acc="$(macos-mail/scripts/commands/account/default.sh | jq -r '.name')"
macos-mail/scripts/commands/mailbox/list.sh "$acc"
```

2) List recent messages (limit aggressively):

```bash
macos-mail/scripts/commands/message/list.sh "$acc" "INBOX" 20
```

3) Read the target message:

```bash
macos-mail/scripts/commands/message/get.sh "$acc" "INBOX" 1
```

4) Optional: show in UI for user verification:

```bash
macos-mail/scripts/commands/message/show.sh "$acc" "INBOX" 1
```

## Reply (draft-first)

1) Read the message first.
2) Create a reply draft:

```bash
macos-mail/scripts/commands/message/reply-draft.sh "$acc" "INBOX" 1 "<reply text>" false
```

3) List drafts and confirm the right one:

```bash
macos-mail/scripts/commands/message/draft-list.sh 20
```

4) Send the draft only after explicit approval:

```bash
macos-mail/scripts/commands/message/draft-send.sh <draft-id>
```

## Compose with attachments (draft-first)

```bash
macos-mail/scripts/commands/message/create.sh \
  "to@example.com" \
  "Quarterly update" \
  "Here is the report." \
  false \
  "cc@example.com" \
  "" \
  /path/to/report.pdf

macos-mail/scripts/commands/message/draft-list.sh 20
# confirm the correct draft_id
macos-mail/scripts/commands/message/draft-send.sh <draft-id>
```

## Search then act (safe)

Search is for discovery; act on **fresh listings**.

1) Search candidates:

```bash
macos-mail/scripts/commands/message/search.sh "$acc" "INBOX" subject_contains "invoice" 25
```

2) Re-list, then act based on explicit user confirmation.

## Bulk move/delete

Principle: **re-list immediately before mutating**.

1) List mailbox:

```bash
macos-mail/scripts/commands/message/list.sh "$acc" "INBOX" 200
```

2) Filter with `jq` to produce a candidate set.
3) Present a human-readable summary for confirmation.
4) Apply one-by-one (Mail AppleScript is not reliably batch-oriented):

```bash
macos-mail/scripts/commands/message/move.sh "$acc" "INBOX" <index> "Archive"
```

If message ordering may change between steps, prefer `get-by-id` based workflows (Message-ID header).
