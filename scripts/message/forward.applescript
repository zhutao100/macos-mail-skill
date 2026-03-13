-- Forward a message. argv: account mailbox index
-- Creates forwarded message; does not send (user can edit and send).
on run argv
	if (count of argv) < 3 then
		return "Usage: forward.applescript <account> <mailbox> <index>"
	end if
	set accName to item 1 of argv
	set mbName to item 2 of argv
	set idx to item 3 of argv as integer

	tell application "Mail"
		set m to message idx of mailbox mbName of account accName
		forward m
	end tell
	return "forward window opened"
end run
