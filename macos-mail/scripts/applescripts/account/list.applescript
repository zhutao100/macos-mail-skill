-- List names of all Mail accounts. Returns one name per line.
with timeout of 300 seconds
	tell application "Mail"
		set accList to name of every account
		set output to ""
		repeat with accName in accList
			set output to output & accName & linefeed
		end repeat
		return output
	end tell
end timeout
