# AppleScript patterns

This skill is implemented as small AppleScript entrypoints invoked via `osascript`.

## Mail search with `whose`

Prefer Mail-side filtering instead of enumerating every message in a mailbox:

```applescript
tell application "Mail"
  set mb to mailbox "INBOX" of account "iCloud"
  set found to (messages of mb whose subject contains "invoice")
end tell
```

This is the core pattern used by `message/search.applescript`.

## Attachments for outgoing messages

The most reliable pattern for attaching files is:

```applescript
tell application "Mail"
  set newMessage to make new outgoing message with properties {subject:"Subject", content:"Body", visible:false}
  tell newMessage
    make new to recipient at end of to recipients with properties {address:"to@example.com"}
    tell content
      make new attachment with properties {file name:(POSIX file "/path/to/file.pdf" as alias)} at after the last paragraph
    end tell
  end tell
  save newMessage
end tell
```

This skill's `message/create.applescript` uses the same approach and supports multiple attachments.

## Message-ID lookup

When you only have the RFC 5322 Message-ID, you can locate the message by scanning mailboxes:

```applescript
tell application "Mail"
  set targetId to "<some-id@example.com>"
  repeat with acc in every account
    repeat with mb in every mailbox of acc
      try
        set hits to (messages of mb whose message id contains targetId)
        if (count of hits) > 0 then return item 1 of hits
      end try
    end repeat
  end repeat
end tell
```

This is the core of `message/get-by-id.applescript`.


## References

- Apple Technical Q&A QA1018 (mirror): https://leopard-adc.pepas.com/qa/qa2001/qa1018.html
- MacScripter: multiple attachments loop examples: https://www.macscripter.net/t/multiple-attachments-in-mail/46792
