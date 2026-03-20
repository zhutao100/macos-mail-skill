-- Move a message to another mailbox. argv: account sourceMailbox index targetMailbox
on run argv
	if (count of argv) < 4 then
		return "Usage: move.applescript <account> <sourceMailbox> <index> <targetMailbox>"
	end if
	set accName to item 1 of argv
	set srcMb to item 2 of argv
	set idx to item 3 of argv as integer
	set tgtMb to item 4 of argv

	tell application "Mail"
		set m to message idx of mailbox srcMb of account accName
		move m to mailbox tgtMb of account accName
	end tell
	return "moved"
end run
