-- Import Mail mailbox from path. argv: path (to .mbox or folder of mailboxes)
on run argv
	if (count of argv) < 1 then
		return "Usage: mailbox.applescript <path>"
	end if
	set pathStr to item 1 of argv
	-- AppleScript file type: use POSIX file
	set pathFile to POSIX file pathStr

	tell application "Mail"
		import Mail mailbox at pathFile
	end tell
	return "imported"
end run
