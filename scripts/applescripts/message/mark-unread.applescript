-- Mark message as unread. argv: account mailbox index
on run argv
	if (count of argv) < 3 then
		return "Usage: mark-unread.applescript <account> <mailbox> <index>"
	end if
	set accName to item 1 of argv
	set mbName to item 2 of argv
	set idx to item 3 of argv as integer

	tell application "Mail"
		set read status of message idx of mailbox mbName of account accName to false
	end tell
	return "marked unread"
end run
