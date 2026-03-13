-- List recent messages in a mailbox. argv: accountName mailboxName [N]
-- Output: subject | sender | date (one per line). Default N=10.
on run argv
	if (count of argv) < 2 then
		return "Usage: list.applescript <account> <mailbox> [N]"
	end if
	set accName to item 1 of argv
	set mbName to item 2 of argv
	set limit to 10
	if (count of argv) ≥ 3 then set limit to (item 3 of argv) as integer

	tell application "Mail"
		set mb to mailbox mbName of account accName
		set msgList to messages 1 thru limit of mb
		set output to ""
		repeat with m in msgList
			set output to output & (subject of m) & " | " & (sender of m) & " | " & (date received of m) & linefeed
		end repeat
		return output
	end tell
end run
