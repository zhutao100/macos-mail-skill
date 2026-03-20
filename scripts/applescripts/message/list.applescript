-- List recent messages in a mailbox. argv: accountName mailboxName [N]
-- Output: one JSON object per line.
on run argv
	if (count of argv) < 2 then error "Usage: list.applescript <account> <mailbox> [N]"

	set accName to item 1 of argv
	set mbName to item 2 of argv
	set limitValue to 10
	if (count of argv) ≥ 3 then set limitValue to (item 3 of argv) as integer

	tell application "Mail"
		set mb to mailbox mbName of account accName
		set totalMessages to count of messages of mb
		if totalMessages is 0 then return ""
		if limitValue > totalMessages then set limitValue to totalMessages

		set msgList to messages 1 thru limitValue of mb
		set output to ""
		set messageIndex to 1
		repeat with msgRef in msgList
			set msgRecord to contents of msgRef
			set output to output & my messageSummaryJson(msgRecord, accName, mbName, messageIndex)
			if messageIndex < limitValue then set output to output & linefeed
			set messageIndex to messageIndex + 1
		end repeat
		return output
	end tell
end run

on messageSummaryJson(msgRecord, accName, mbName, messageIndex)
	set identityValue to my messageIdentity(msgRecord, accName, mbName, messageIndex)
	using terms from application "Mail"
		set subjectValue to subject of msgRecord as text
		set senderValue to sender of msgRecord as text
		set rawDateReceivedValue to (date received of msgRecord)
		set rawReadValue to (read status of msgRecord)
		set rawFlaggedValue to (flagged status of msgRecord)
	end using terms from
	set dateReceivedValue to my jsonNullable(rawDateReceivedValue)
	set readValue to my jsonBoolean(rawReadValue)
	set flaggedValue to my jsonBoolean(rawFlaggedValue)

	return "{" & "\"id\":" & my jsonString(identityValue) & "," & "\"account\":" & my jsonString(accName) & "," & "\"mailbox\":" & my jsonString(mbName) & "," & "\"index\":" & (messageIndex as text) & "," & "\"subject\":" & my jsonString(subjectValue) & "," & "\"sender\":" & my jsonString(senderValue) & "," & "\"date_received\":" & dateReceivedValue & "," & "\"read\":" & readValue & "," & "\"flagged\":" & flaggedValue & "}"
end messageSummaryJson

on messageIdentity(msgRecord, accName, mbName, messageIndex)
	set messageIdValue to ""
	using terms from application "Mail"
		try
			set messageIdValue to message id of msgRecord as text
		end try
	end using terms from

	if messageIdValue is "" then
		return accName & "/" & mbName & "/" & messageIndex
	end if

	return messageIdValue
end messageIdentity

on jsonNullable(valueValue)
	if valueValue is missing value then return "null"
	set textValue to valueValue as text
	if textValue is "" then return "null"
	return my jsonString(textValue)
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
