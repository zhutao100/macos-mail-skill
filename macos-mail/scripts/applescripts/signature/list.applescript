-- List signature names. One per line.
on run argv
	tell application "Mail"
		set sigList to every signature
		if sigList is missing value then return ""
		set output to ""
		repeat with s in sigList
			try
				set output to output & (name of s as text) & linefeed
			end try
		end repeat
		return output
	end tell
end run
