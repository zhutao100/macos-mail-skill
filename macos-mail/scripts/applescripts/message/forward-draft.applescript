-- Forward a message as a draft (do not send). argv: account mailbox index [visible]
-- Output: one JSON object.
on run argv
	if (count of argv) < 3 then error "Usage: forward-draft.applescript <account> <mailbox> <index> [visible]"
	set accName to item 1 of argv
	set mbName to item 2 of argv
	set idx to item 3 of argv as integer
	set showWin to true
	if (count of argv) ≥ 4 then
		set visibleRaw to item 4 of argv as text
		if (visibleRaw is "false") or (visibleRaw is "0") then set showWin to false
	end if

	tell application "Mail"
		set m to message idx of mailbox mbName of account accName
		set fwdMsg to forward m
		try
			set visible of fwdMsg to showWin
		end try
		save fwdMsg
		set draftId to ""
		try
			set draftId to (id of fwdMsg) as text
		end try
		set subjectValue to ""
		try
			set subjectValue to subject of fwdMsg as text
		end try
		return "{" & "\"created\":true," & "\"draft_id\":" & my jsonNullable(draftId) & "," & "\"account\":" & my jsonString(accName) & "," & "\"mailbox\":" & my jsonString(mbName) & "," & "\"index\":" & (idx as text) & "," & "\"subject\":" & my jsonString(subjectValue) & "," & "\"visible\":" & my jsonBoolean(showWin) & "}"
	end tell
end run

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
