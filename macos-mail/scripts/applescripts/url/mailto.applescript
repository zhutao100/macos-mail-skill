-- Open a mailto URL. argv: mailtoURL (e.g. mailto:user@example.com?subject=Hello)
on run argv
	if (count of argv) < 1 then
		return "Usage: mailto.applescript <mailto:...>"
	end if
	set urlStr to item 1 of argv

	tell application "Mail"
		mailto urlStr
	end tell
	return "opened"
end run
