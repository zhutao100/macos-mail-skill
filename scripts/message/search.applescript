-- Search messages in mailbox. argv: account mailbox subject_contains|sender_contains value
on run argv
	if (count of argv) < 4 then
		return "Usage: search.applescript <account> <mailbox> <subject_contains|sender_contains> <value>"
	end if
	set accName to item 1 of argv
	set mbName to item 2 of argv
	set searchType to item 3 of argv
	set searchVal to item 4 of argv

	tell application "Mail"
		set mb to mailbox mbName of account accName
		if searchType is "subject_contains" then
			set found to (messages of mb whose subject contains searchVal)
		else if searchType is "sender_contains" then
			set found to (messages of mb whose sender contains searchVal)
		else
			return "Unknown search type: " & searchType
		end if
		set output to ""
		repeat with m in found
			set output to output & (subject of m) & " | " & (sender of m) & " | " & (date received of m) & linefeed
		end repeat
		return output
	end tell
end run
