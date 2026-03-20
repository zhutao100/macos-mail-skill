-- Search messages in mailbox. argv: account mailbox subject_contains|sender_contains value
on run argv
	if (count of argv) < 4 then error "Usage: search.applescript <account> <mailbox> <subject_contains|sender_contains> <value>"
	set accName to item 1 of argv
	set mbName to item 2 of argv
	set searchType to item 3 of argv
	set searchVal to item 4 of argv

	tell application "Mail"
		set mb to mailbox mbName of account accName
		set msgList to every message of mb
		set output to ""
		set firstMatch to true
		repeat with messageIndex from 1 to count of msgList
			set msgRecord to contents of item messageIndex of msgList
			if my matchesSearch(msgRecord, searchType, searchVal) then
				if firstMatch is false then set output to output & linefeed
				set output to output & my messageSummaryJson(msgRecord, accName, mbName, messageIndex)
				set firstMatch to false
			end if
		end repeat
		return output
	end tell
end run

on matchesSearch(msgRecord, searchType, searchVal)
	if searchType is "subject_contains" then
		return subject of msgRecord contains searchVal
	else if searchType is "sender_contains" then
		return sender of msgRecord contains searchVal
	end if

	error "Unknown search type: " & searchType
end matchesSearch

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
