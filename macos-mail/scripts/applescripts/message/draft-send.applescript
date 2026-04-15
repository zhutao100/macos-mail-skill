-- Send a draft message by its Mail internal id. argv: draftId
-- Output: one JSON object.
on run argv
	if (count of argv) < 1 then error "Usage: draft-send.applescript <draft-id>"
	set targetId to (item 1 of argv) as integer

	tell application "Mail"
		repeat with acc in every account
			set accName to name of acc as text
			set draftBoxes to my draftMailboxes(acc)
			repeat with mb in draftBoxes
				set mbName to ""
				try
					set mbName to name of mb as text
				end try
				try
					set foundMsgs to (messages of mb whose id is targetId)
					if (count of foundMsgs) > 0 then
						set draftMsg to item 1 of foundMsgs
						send draftMsg
						return "{" & "\"sent\":true," & "\"draft_id\":" & (targetId as text) & "," & "\"account\":" & my jsonString(accName) & "," & "\"mailbox\":" & my jsonString(mbName) & "}"
					end if
				end try
			end repeat
		end repeat
	end tell

	error "Draft not found: " & (targetId as text)
end run

on draftMailboxes(acc)
	set resultBoxes to {}
	using terms from application "Mail"
		try
			set end of resultBoxes to mailbox "Drafts" of acc
		end try
		try
			set end of resultBoxes to mailbox "Draft" of acc
		end try
		try
			repeat with mb in (every mailbox of acc)
				set mbName to ""
				try
					set mbName to name of mb as text
				end try
				ignoring case
					if mbName contains "draft" then set end of resultBoxes to mb
				end ignoring
			end repeat
		end try
	end using terms from
	return resultBoxes
end draftMailboxes

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
