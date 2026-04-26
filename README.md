# MacOS Mail Skill

> an enhanced fork of [vinitu/macos-mail-skill](https://github.com/vinitu/macos-mail-skill).

This repo stores a skill for Apple Mail.app integration on macOS via AppleScript.

## Scope

- List accounts and mailboxes configured in Mail.app.
- Read messages with structured JSON output.
- Show a message in the Mail.app window.
- Create drafts, send messages, and reply to messages.
- Search messages by subject or sender.
- Move, delete, flag, and mark messages.

## Prerequisites

- macOS 15+ (and future releases) with Mail.app configured and signed in
- Automation permission granted to your terminal app
- `jq`
- Full Xcode for development targets that compile AppleScript or inspect the Mail scripting dictionary
- (Optional) Full Disk Access for `macos-mail/scripts/commands/message/search-sqlite.sh`

## How To Use

Run the public command wrappers from the repo root or from the installed skill path.
Do not call `macos-mail/scripts/applescripts` directly.

```bash
# List all Mail accounts
macos-mail/scripts/commands/account/list.sh
# Get default account
macos-mail/scripts/commands/account/default.sh
# List mailboxes in account "iCloud"
macos-mail/scripts/commands/mailbox/list.sh "iCloud"
# Count messages in INBOX
macos-mail/scripts/commands/mailbox/count.sh "iCloud" "INBOX"
# List recent messages
macos-mail/scripts/commands/message/list.sh "iCloud" "INBOX" 5
# Read one message
macos-mail/scripts/commands/message/get.sh "iCloud" "INBOX" 1
# Show one message in Mail.app
macos-mail/scripts/commands/message/show.sh "iCloud" "INBOX" 1
# Get raw RFC 822 message source
macos-mail/scripts/commands/message/source.sh "iCloud" "INBOX" 1
# SQLite search (requires Full Disk Access)
macos-mail/scripts/commands/message/search-sqlite.sh "invoice" 20
# Get a message by Message-ID header
macos-mail/scripts/commands/message/get-by-id.sh "<message-id@example.com>"
# Create draft (does not send)
macos-mail/scripts/commands/message/create.sh "someone@example.com" "Hello" "Draft body here" false
```

All public commands return JSON by default.
For the full command set and examples, see `macos-mail/SKILL.md`.

## Public Interface

- `macos-mail/scripts/commands/account/*`
- `macos-mail/scripts/commands/mailbox/*`
- `macos-mail/scripts/commands/message/*`
- `macos-mail/scripts/commands/signature/list.sh`
- `macos-mail/scripts/commands/viewer/inbox.sh`
- `macos-mail/scripts/commands/import/mailbox.sh`
- `macos-mail/scripts/commands/url/mailto.sh`

## Troubleshooting

| Issue | Solution |
|-------|----------|
| "not authorized" error | Grant Automation permission to terminal in System Settings |
| Mail.app not responding | Ensure Mail.app is running; launch with `open -a Mail` |
| Account not found | Check account name with `macos-mail/scripts/commands/account/list.sh` |
| Mailbox not found | Check mailbox name with `macos-mail/scripts/commands/mailbox/list.sh "ACCOUNT"` |
| `jq is required` | Install `jq` and ensure it is in `PATH` |
| Slow searches | Use `macos-mail/scripts/commands/message/search-sqlite.sh` (requires Full Disk Access) |

## Development

- Run checks: `make compile && make test && make lint`
  - The Makefile uses `/Applications/Xcode.app/Contents/Developer` when `DEVELOPER_DIR` is unset, so VMs with Command Line Tools selected can still run `sdef`/`osacompile`.
- Disposable VM-only end-to-end check: `MACOS_MAIL_VM_E2E=1 tests/vm_mail_e2e.sh`
  - Run this only through a safe VM workflow. It creates draft messages and opens Mail UI views, but does not send, move, or delete mail.
- Pre-commit (prek): `prek install --prepare-hooks` (optional self-healing hook: `git config core.hooksPath .githooks`)

## Acknowledgements

This project is an enhanced fork of the original [vinitu/macos-mail-skill](https://github.com/vinitu/macos-mail-skill).
