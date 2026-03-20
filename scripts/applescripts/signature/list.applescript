-- List signature names. One per line.
on run argv
	tell application "Mail"
		set sigList to every signature
		set output to ""
		repeat with s in sigList
			set output to output & (name of s) & linefeed
		end repeat
		return output
	end tell
end run
