-- Create a draft message (do not send). argv: toCsv subject body [visible] [ccCsv] [bccCsv] [attachmentPath...]
-- Output: one JSON object.
on run argv
	if (count of argv) < 3 then error "Usage: create.applescript <toCsv> <subject> <body> [visible] [ccCsv] [bccCsv] [attachmentPath...]"

	set toCsv to item 1 of argv
	set subj to item 2 of argv
	set bodyText to item 3 of argv
	set showWin to true
	if (count of argv) ≥ 4 then
		set visibleRaw to item 4 of argv as text
		if (visibleRaw is "false") or (visibleRaw is "0") then set showWin to false
	end if
	set ccCsv to ""
	if (count of argv) ≥ 5 then set ccCsv to item 5 of argv as text
	set bccCsv to ""
	if (count of argv) ≥ 6 then set bccCsv to item 6 of argv as text

	set attachments to {}
	if (count of argv) ≥ 7 then set attachments to items 7 thru -1 of argv

	tell application "Mail"
		set newMsg to make new outgoing message with properties {subject:subj, content:bodyText, visible:showWin}
		my addToRecipients(newMsg, toCsv)
		my addCcRecipients(newMsg, ccCsv)
		my addBccRecipients(newMsg, bccCsv)
		my addAttachments(newMsg, attachments)
		save newMsg
		set draftId to ""
		try
			set draftId to (id of newMsg) as text
		end try
		return "{" & "\"created\":true," & "\"draft_id\":" & my jsonNullable(draftId) & "," & "\"to\":" & my jsonString(toCsv) & "," & "\"cc\":" & my jsonString(ccCsv) & "," & "\"bcc\":" & my jsonString(bccCsv) & "," & "\"subject\":" & my jsonString(subj) & "," & "\"body\":" & my jsonString(bodyText) & "," & "\"visible\":" & my jsonBoolean(showWin) & "}"
	end tell
end run

on addToRecipients(newMsg, csv)
	using terms from application "Mail"
		set listItems to my splitCsv(csv)
		repeat with addr in listItems
			set trimmed to my trimWhitespace(addr)
			if trimmed is not "" then
				tell newMsg
					make new to recipient at end of to recipients with properties {address:trimmed}
				end tell
			end if
		end repeat
	end using terms from
end addToRecipients

on addCcRecipients(newMsg, csv)
	using terms from application "Mail"
		set listItems to my splitCsv(csv)
		repeat with addr in listItems
			set trimmed to my trimWhitespace(addr)
			if trimmed is not "" then
				tell newMsg
					make new cc recipient at end of cc recipients with properties {address:trimmed}
				end tell
			end if
		end repeat
	end using terms from
end addCcRecipients

on addBccRecipients(newMsg, csv)
	using terms from application "Mail"
		set listItems to my splitCsv(csv)
		repeat with addr in listItems
			set trimmed to my trimWhitespace(addr)
			if trimmed is not "" then
				tell newMsg
					make new bcc recipient at end of bcc recipients with properties {address:trimmed}
				end tell
			end if
		end repeat
	end using terms from
end addBccRecipients

on addAttachments(newMsg, attachments)
	using terms from application "Mail"
		if (count of attachments) is 0 then return
		tell content of newMsg
			repeat with p in attachments
				set posixPath to p as text
				if posixPath is not "" then
					set f to POSIX file posixPath as alias
					make new attachment with properties {file name:f} at after the last paragraph
				end if
			end repeat
		end tell
		delay 0.2
	end using terms from
end addAttachments

on splitCsv(csv)
	set csvText to my trimWhitespace(csv as text)
	if csvText is "" then return {}
	set AppleScript's text item delimiters to ","
	set parts to text items of csvText
	set AppleScript's text item delimiters to ""
	return parts
end splitCsv

on trimWhitespace(s)
	set s to s as text
	repeat while s is not "" and my isWhitespace(character 1 of s)
		if (length of s) = 1 then return ""
		set s to text 2 thru -1 of s
	end repeat
	repeat while s is not "" and my isWhitespace(character -1 of s)
		if (length of s) = 1 then return ""
		set s to text 1 thru -2 of s
	end repeat
	return s
end trimWhitespace

on isWhitespace(ch)
	return ch is " " or ch is tab or ch is return or ch is linefeed
end isWhitespace

on jsonNullable(textValue)
	set t to textValue as text
	if t is "" then return "null"
	return my jsonString(t)
end jsonNullable

on jsonBoolean(booleanValue)
	if booleanValue then return "true"
	return "false"
end jsonBoolean

on jsonString(textValue)
	return "\"" & my jsonEscape(textValue as text) & "\""
end jsonString

on jsonEscape(textValue)
	set escapedValue to textValue
	set escapedValue to my replaceText("\\", "\\\\", escapedValue)
	set escapedValue to my replaceText("\"", "\\\"", escapedValue)
	set escapedValue to my replaceText(return, "\\n", escapedValue)
	set escapedValue to my replaceText(linefeed, "\\n", escapedValue)
	set escapedValue to my replaceText(tab, "\\t", escapedValue)
	return escapedValue
end jsonEscape

on replaceText(findText, replaceTextValue, sourceText)
	set AppleScript's text item delimiters to findText
	set textItems to text items of sourceText
	set AppleScript's text item delimiters to replaceTextValue
	set replacedText to textItems as text
	set AppleScript's text item delimiters to ""
	return replacedText
end replaceText
