# Permissions and privacy

Apple Mail automation touches macOS privacy controls. The most common failures are:

- **Automation (Apple Events)** not granted
- **Full Disk Access** not granted (only required for SQLite-backed search)

## Automation: “Not authorized to send Apple events to Mail”

Symptoms:

- `osascript` fails with an error mentioning it is *not authorized to send Apple events*

Fix:

1) Open **System Settings** → **Privacy & Security** → **Automation**.
2) Find your terminal app (Terminal, iTerm, etc.).
3) Enable automation access to **Mail**.

Resetting Automation permissions (when the UI is stuck):

```bash
/usr/bin/tccutil reset AppleEvents <bundle-id>
```

Examples (common terminal bundle IDs):

- Terminal: `com.apple.Terminal`
- iTerm2: `com.googlecode.iterm2`

After reset, rerun `macos-mail/scripts/check-setup.sh` to trigger the prompt again.

## Full Disk Access (for `search-sqlite`)

`macos-mail/scripts/commands/message/search-sqlite.sh` reads Mail's `Envelope Index` SQLite DB under `~/Library/Mail/**`.

On modern macOS, this typically requires granting your terminal app **Full Disk Access**:

- System Settings → Privacy & Security → Full Disk Access

If you do not want to grant Full Disk Access, avoid `search-sqlite` and use `message/search.sh` (slower, but in-process).

## Remote Apple Events (rare)

If you are scripting Mail **from another machine**, enable Remote Apple Events:

- System Settings → General → Sharing → Remote Apple Events

Then configure “Allow access for …” appropriately.


## References

- Apple Support: https://support.apple.com/en-ge/guide/mac-help/mchlp1398/mac
- Apple Stack Exchange: https://apple.stackexchange.com/questions/468354/macos-ventura-cannot-reset-automation-preferences-for-a-single-app
