# Advanced search

## When to use SQLite search

Use `message/search-sqlite.sh` when:

- Mailboxes are very large and AppleScript enumeration/search is too slow.
- You only need **metadata** (subject/sender/date/mailbox) to identify candidates.

Avoid SQLite search when:

- You cannot or do not want to grant **Full Disk Access**.
- You need a strong compatibility story across future Mail schema changes.

## What SQLite search returns

`search-sqlite` queries Mail's `Envelope Index` database. On modern macOS this is commonly located at `~/Library/Mail/V10/MailData/Envelope Index` and returns metadata rows, typically including:

- `rowid`
- `message_id` (schema-dependent)
- `subject`
- `sender`
- `date_received` (UTC)
- `read`, `flagged`
- `mailbox_url`

This output is intended for **discovery**, not as a source of truth for destructive actions.

## Stability caveats

- Mail's database schema and file layout change across macOS releases.
- The presence of tables like `message_global_data` is version-dependent.
- The DB is a moving target while Mail is running and syncing.

For actions (move/delete/send/reply), always re-resolve the target message using Mail.app scripting.


## References

- Envelope Index location notes (SpamSieve docs): https://c-command.com/spamsieve/help/how-can-i-rebuild-apple
- Core Data / CFAbsoluteTime epoch offset (978307200 seconds): https://www.epochconverter.com/coredata
