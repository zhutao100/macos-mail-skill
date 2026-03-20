-- Check for new mail. argv: [accountName] (optional; if omitted checks all)
on run argv
	tell application "Mail"
		if (count of argv) ≥ 1 then
			check for new mail for account (item 1 of argv)
		else
			check for new mail
		end if
	end tell
	return "checking"
end run
