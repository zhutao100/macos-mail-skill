-- Create a draft message (do not send). argv: toAddress subject body [visible]
on run argv
	if (count of argv) < 3 then
		return "Usage: create.applescript <to> <subject> <body> [visible]"
	end if
	set toAddr to item 1 of argv
	set subj to item 2 of argv
	set body to item 3 of argv
	set showWin to true
	if (count of argv) ≥ 4 and (item 4 of argv is "false" or item 4 of argv is "0") then set showWin to false

	tell application "Mail"
		set newMsg to make new outgoing message with properties {subject:subj, content:body, visible:showWin}
		tell newMsg
			make new to recipient at end of to recipients with properties {address:toAddr}
		end tell
	end tell
	return "draft created"
end run
