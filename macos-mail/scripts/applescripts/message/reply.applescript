-- Reply to a message. argv: account mailbox index replyBody
on run argv
	if (count of argv) < 4 then
		return "Usage: reply.applescript <account> <mailbox> <index> <replyBody>"
	end if
	set accName to item 1 of argv
	set mbName to item 2 of argv
	set idx to item 3 of argv as integer
	set replyBody to item 4 of argv

	tell application "Mail"
		set m to message idx of mailbox mbName of account accName
		set replyMsg to reply m
		set content of replyMsg to replyBody
		send replyMsg
	end tell
	return "sent"
end run
