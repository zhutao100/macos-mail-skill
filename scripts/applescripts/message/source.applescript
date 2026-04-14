-- Get raw RFC 822 source for a message. argv: accountName mailboxName index
-- Output: one JSON object.
on run argv
	if (count of argv) < 3 then error "Usage: source.applescript <account> <mailbox> <index>"
	set accName to item 1 of argv
	set mbName to item 2 of argv
	set idx to item 3 of argv as integer

	tell application "Mail"
		set msgRecord to message idx of mailbox mbName of account accName
		return my messageSourceJson(msgRecord, accName, mbName, idx)
	end tell
end run

on messageSourceJson(msgRecord, accName, mbName, messageIndex)
	set identityValue to my messageIdentity(msgRecord, accName, mbName, messageIndex)
	using terms from application "Mail"
		set subjectValue to subject of msgRecord as text
		set senderValue to sender of msgRecord as text
		set rawDateReceivedValue to (date received of msgRecord)
		set sourceValue to source of msgRecord as text
	end using terms from
	set dateReceivedValue to my jsonNullable(rawDateReceivedValue)

	return "{" & "\"id\":" & my jsonString(identityValue) & "," & "\"account\":" & my jsonString(accName) & "," & "\"mailbox\":" & my jsonString(mbName) & "," & "\"index\":" & (messageIndex as text) & "," & "\"subject\":" & my jsonString(subjectValue) & "," & "\"sender\":" & my jsonString(senderValue) & "," & "\"date_received\":" & dateReceivedValue & "," & "\"source\":" & my jsonString(sourceValue) & "}"
end messageSourceJson

on messageIdentity(msgRecord, accName, mbName, messageIndex)
	using terms from application "Mail"
		set rawMessageIdValue to (message id of msgRecord)
	end using terms from
	set messageIdValue to my safeText(rawMessageIdValue)
	if messageIdValue is "" then
		return accName & "/" & mbName & "/" & messageIndex
	end if
	return messageIdValue
end messageIdentity

on safeText(valueValue)
	if valueValue is missing value then return ""
	return valueValue as text
end safeText

on jsonNullable(valueValue)
	if valueValue is missing value then return "null"
	set textValue to valueValue as text
	if textValue is "" then return "null"
	return my jsonString(textValue)
end jsonNullable

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
