-- List mailbox names for an account. argv: [accountName] (default: first account)
on run argv
	tell application "Mail"
		set accs to every account
		if (count of accs) is 0 then
			return ""
		end if
		if (count of argv) ≥ 1 then
			set targetAccount to account (item 1 of argv)
		else
			set targetAccount to item 1 of accs
		end if
		set mbList to name of every mailbox of targetAccount
		set output to ""
		repeat with mbName in mbList
			set output to output & mbName & linefeed
		end repeat
		return output
	end tell
end run
