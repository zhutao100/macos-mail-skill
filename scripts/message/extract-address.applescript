-- Extract email address from full address string. argv: "Full Name <email@example.com>"
on run argv
	if (count of argv) < 1 then
		return "Usage: extract-address.applescript <full-email-address>"
	end if
	set fullAddr to item 1 of argv

	tell application "Mail"
		return extract address from fullAddr
	end tell
end run
