-- Flag a message. argv: account mailbox index
on run argv
	if (count of argv) < 3 then
		return "Usage: flag.applescript <account> <mailbox> <index>"
	end if
	set accName to item 1 of argv
	set mbName to item 2 of argv
	set idx to item 3 of argv as integer

	tell application "Mail"
		set flagged status of message idx of mailbox mbName of account accName to true
	end tell
	return "flagged"
end run
