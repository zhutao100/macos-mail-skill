-- Search messages in mailbox. argv: account mailbox subject_contains|sender_contains value [limit]
-- Output: one JSON object per line.
on run argv
	if (count of argv) < 4 then error "Usage: search.applescript <account> <mailbox> <subject_contains|sender_contains> <value> [limit]"
	set accName to item 1 of argv
	set mbName to item 2 of argv
	set searchType to item 3 of argv
	set searchVal to item 4 of argv
	set limitValue to 50
	if (count of argv) ≥ 5 then set limitValue to (item 5 of argv) as integer

	tell application "Mail"
		set mb to mailbox mbName of account accName
		set msgList to {}
		if searchType is "subject_contains" then
			set msgList to (messages of mb whose subject contains searchVal)
		else if searchType is "sender_contains" then
			set msgList to (messages of mb whose sender contains searchVal)
		else
			error "Unknown search type: " & searchType
		end if

		set totalMatches to count of msgList
		if totalMatches is 0 then return ""
		if limitValue > totalMatches then set limitValue to totalMatches

		set output to ""
		repeat with i from 1 to limitValue
			set msgRecord to contents of item i of msgList
			set output to output & my messageSummaryJson(msgRecord, accName, mbName)
			if i < limitValue then set output to output & linefeed
		end repeat
		return output
	end tell
end run

on messageSummaryJson(msgRecord, accName, mbName)
	set idxJson to "null"
	try
		set idxJson to (index of msgRecord) as text
	end try
	set identityValue to my messageIdentity(msgRecord, accName, mbName, idxJson)
	using terms from application "Mail"
		set rawMessageIdValue to (message id of msgRecord)
		set subjectValue to subject of msgRecord as text
		set senderValue to sender of msgRecord as text
		set rawDateReceivedValue to (date received of msgRecord)
		set rawReadValue to (read status of msgRecord)
		set rawFlaggedValue to (flagged status of msgRecord)
	end using terms from
	set messageIdValue to my safeText(rawMessageIdValue)
	set dateReceivedValue to my jsonDateIso(rawDateReceivedValue)
	set readValue to my jsonBoolean(rawReadValue)
	set flaggedValue to my jsonBoolean(rawFlaggedValue)

	return "{" & "\"id\":" & my jsonString(identityValue) & "," & "\"account\":" & my jsonString(accName) & "," & "\"mailbox\":" & my jsonString(mbName) & "," & "\"index\":" & idxJson & "," & "\"subject\":" & my jsonString(subjectValue) & "," & "\"sender\":" & my jsonString(senderValue) & "," & "\"date_received\":" & dateReceivedValue & "," & "\"message_id\":" & my jsonNullable(messageIdValue) & "," & "\"read\":" & readValue & "," & "\"flagged\":" & flaggedValue & "}"
end messageSummaryJson

on messageIdentity(msgRecord, accName, mbName, idxJson)
	set messageIdValue to ""
	using terms from application "Mail"
		try
			set messageIdValue to message id of msgRecord as text
		end try
	end using terms from

	if messageIdValue is "" then
		return accName & "/" & mbName & "/" & idxJson
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

on jsonDateIso(dateValue)
	if dateValue is missing value then return "null"
	try
		set unixSeconds to (dateValue as integer) - 2082844800
		set isoText to do shell script "/bin/date -u -r " & unixSeconds & " +%Y-%m-%dT%H:%M:%SZ"
		return my jsonString(isoText)
	on error
		return my jsonString(dateValue as text)
	end try
end jsonDateIso

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
