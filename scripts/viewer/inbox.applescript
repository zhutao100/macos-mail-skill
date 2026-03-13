-- Get the inbox mailbox name for first account (for use with message viewer).
on run argv
	tell application "Mail"
		set vw to first message viewer
		return name of inbox of vw
	end tell
end run
