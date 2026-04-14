-- Get full message details by message-id header. argv: messageId
-- Output: one JSON object.
on run argv
	if (count of argv) < 1 then error "Usage: get-by-id.applescript <message-id>"
	set targetIdRaw to item 1 of argv as text
	set targetId to my stripAngles(targetIdRaw)
	
	tell application "Mail"
		set allAccounts to every account
		repeat with acc in allAccounts
			set accName to name of acc as text
			set allMailboxes to every mailbox of acc
			repeat with mb in allMailboxes
				set mbName to name of mb as text
				try
					set foundMsgs to (every message of mb whose message id contains targetId)
					if (count of foundMsgs) > 0 then
						set msgRecord to item 1 of foundMsgs
						set idxJson to "null"
						try
							set idxJson to (index of msgRecord) as text
						end try
						return my messageJson(msgRecord, accName, mbName, idxJson)
					end if
				end try
			end repeat
		end repeat
	end tell
	
	error "Message not found with id: " & targetIdRaw
end run

on stripAngles(rawId)
	set textValue to rawId as text
	if (textValue starts with "<") and (textValue ends with ">") then
		return text 2 thru -2 of textValue
	end if
	return textValue
end stripAngles

on messageJson(msgRecord, accName, mbName, idxJson)
	set identityValue to my messageIdentity(msgRecord, accName, mbName, idxJson)
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
	
	return "{" & "\"id\":" & my jsonString(identityValue) & "," & "\"account\":" & my jsonString(accName) & "," & "\"mailbox\":" & my jsonString(mbName) & "," & "\"index\":" & idxJson & "," & "\"subject\":" & my jsonString(subjectValue) & "," & "\"sender\":" & my jsonString(senderValue) & "," & "\"date_received\":" & dateReceivedValue & "," & "\"date_sent\":" & dateSentValue & "," & "\"message_id\":" & my jsonNullable(messageIdValue) & "," & "\"reply_to\":" & replyToValue & "," & "\"message_size\":" & messageSizeValue & "," & "\"read\":" & readValue & "," & "\"flagged\":" & flaggedValue & "," & "\"junk\":" & junkValue & "," & "\"flag_index\":" & flagIndexValue & "," & "\"background_color\":" & backgroundColorValue & "," & "\"all_headers\":" & allHeadersValue & "," & "\"content\":" & my jsonString(contentValue) & "}"
end messageJson

on messageIdentity(msgRecord, accName, mbName, idxJson)
	using terms from application "Mail"
		set rawMessageIdValue to (message id of msgRecord)
	end using terms from
	set messageIdValue to my safeText(rawMessageIdValue)
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
