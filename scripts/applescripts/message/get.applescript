-- Get full message details. argv: accountName mailboxName index
-- Output: one JSON object.
on run argv
	if (count of argv) < 3 then error "Usage: get.applescript <account> <mailbox> <index>"
	set accName to item 1 of argv
	set mbName to item 2 of argv
	set idx to item 3 of argv as integer

	tell application "Mail"
		set msgRecord to contents of message idx of mailbox mbName of account accName
		return my messageJson(msgRecord, accName, mbName, idx)
	end tell
end run

on messageJson(msgRecord, accName, mbName, messageIndex)
	set identityValue to my messageIdentity(msgRecord, accName, mbName, messageIndex)
	using terms from application "Mail"
		set rawMessageIdValue to (message id of msgRecord)
		set rawDateReceivedValue to (date received of msgRecord)
		set rawDateSentValue to (date sent of msgRecord)
		set rawReplyToValue to (reply to of msgRecord)
		set rawReadValue to (read status of msgRecord)
		set rawFlaggedValue to (flagged status of msgRecord)
		set rawJunkValue to (junk mail status of msgRecord)
		set rawBackgroundColorValue to (background color of msgRecord)
		set rawAllHeadersValue to (all headers of msgRecord)
		set subjectValue to subject of msgRecord as text
		set senderValue to sender of msgRecord as text
		set messageSizeValue to message size of msgRecord as text
		set flagIndexValue to flag index of msgRecord as text
		set contentValue to content of msgRecord as text
	end using terms from
	set messageIdValue to my safeText(rawMessageIdValue)
	set dateReceivedValue to my jsonNullable(rawDateReceivedValue)
	set dateSentValue to my jsonNullable(rawDateSentValue)
	set replyToValue to my jsonNullable(rawReplyToValue)
	set readValue to my jsonBoolean(rawReadValue)
	set flaggedValue to my jsonBoolean(rawFlaggedValue)
	set junkValue to my jsonBoolean(rawJunkValue)
	set backgroundColorValue to my jsonNullable(rawBackgroundColorValue)
	set allHeadersValue to my jsonNullable(rawAllHeadersValue)

	return "{" & "\"id\":" & my jsonString(identityValue) & "," & "\"account\":" & my jsonString(accName) & "," & "\"mailbox\":" & my jsonString(mbName) & "," & "\"index\":" & (messageIndex as text) & "," & "\"subject\":" & my jsonString(subjectValue) & "," & "\"sender\":" & my jsonString(senderValue) & "," & "\"date_received\":" & dateReceivedValue & "," & "\"date_sent\":" & dateSentValue & "," & "\"message_id\":" & my jsonNullable(messageIdValue) & "," & "\"reply_to\":" & replyToValue & "," & "\"message_size\":" & messageSizeValue & "," & "\"read\":" & readValue & "," & "\"flagged\":" & flaggedValue & "," & "\"junk\":" & junkValue & "," & "\"flag_index\":" & flagIndexValue & "," & "\"background_color\":" & backgroundColorValue & "," & "\"all_headers\":" & allHeadersValue & "," & "\"content\":" & my jsonString(contentValue) & "}"
end messageJson

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
