-- List mailbox names for an account. argv: [accountName] (default: first account)
-- Output: one mailbox full name per line (e.g. "[Gmail]/All Mail").
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
		set mbList to every mailbox of targetAccount
		set output to ""
		repeat with mbRef in mbList
			set mbName to my mailboxFullName(contents of mbRef)
			set output to output & mbName & linefeed
		end repeat
		return output
	end tell
end run

on mailboxFullName(mbRef)
	using terms from application "Mail"
		set parts to {name of mbRef as text}
		try
			set parentRef to container of mbRef
			repeat while ((class of parentRef is mailbox) or (class of parentRef is container))
				set parts to {(name of parentRef as text)} & parts
				set parentRef to container of parentRef
			end repeat
		end try
	end using terms from

	set AppleScript's text item delimiters to "/"
	set fullName to parts as text
	set AppleScript's text item delimiters to ""
	return fullName
end mailboxFullName
