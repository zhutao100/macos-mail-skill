-- Extract display name from full email address. argv: "Full Name <email@example.com>"
on run argv
	if (count of argv) < 1 then
		return "Usage: extract-name.applescript <full-email-address>"
	end if
	set fullAddr to item 1 of argv

	tell application "Mail"
		return extract name from fullAddr
	end tell
end run
