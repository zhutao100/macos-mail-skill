-- Get full message details. argv: accountName mailboxName index
-- Includes: subject, sender, date, content, all headers, message id, source, reply to, message size, read/flagged/junk status
on run argv
	if (count of argv) < 3 then
		return "Usage: get.applescript <account> <mailbox> <index>"
	end if
	set accName to item 1 of argv
	set mbName to item 2 of argv
	set idx to item 3 of argv as integer

	tell application "Mail"
		set m to message idx of mailbox mbName of account accName
		set output to "Subject: " & (subject of m) & linefeed
		set output to output & "From: " & (sender of m) & linefeed
		set output to output & "Date received: " & (date received of m) & linefeed
		set output to output & "Date sent: " & (date sent of m) & linefeed
		set output to output & "Message ID: " & (message id of m) & linefeed
		set output to output & "Reply-To: " & (reply to of m) & linefeed
		set output to output & "Message size: " & (message size of m) & linefeed
		set output to output & "Read: " & (read status of m) & linefeed
		set output to output & "Flagged: " & (flagged status of m) & linefeed
		set output to output & "Junk: " & (junk mail status of m) & linefeed
		set output to output & "Flag index: " & (flag index of m) & linefeed
		set output to output & "Background color: " & (background color of m) & linefeed
		set output to output & "All headers: " & (all headers of m) & linefeed
		set output to output & "Content: " & (content of m)
		return output
	end tell
end run
