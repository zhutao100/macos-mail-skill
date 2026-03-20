-- Count messages in a mailbox. argv: accountName mailboxName
on run argv
	if (count of argv) < 2 then
		return "Usage: count.applescript <account> <mailbox>"
	end if
	set accName to item 1 of argv
	set mbName to item 2 of argv

	tell application "Mail"
		set n to count of messages of mailbox mbName of account accName
		return n as text
	end tell
end run
