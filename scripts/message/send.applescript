-- Send a new message. argv: toAddress subject body
on run argv
	if (count of argv) < 3 then
		return "Usage: send.applescript <to> <subject> <body>"
	end if
	set toAddr to item 1 of argv
	set subj to item 2 of argv
	set body to item 3 of argv

	tell application "Mail"
		set newMsg to make new outgoing message with properties {subject:subj, content:body, visible:false}
		tell newMsg
			make new to recipient at end of to recipients with properties {address:toAddr}
		end tell
		send newMsg
	end tell
	return "sent"
end run
