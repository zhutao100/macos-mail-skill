-- List draft messages across accounts. argv: [limit]
-- Output: one JSON object per line.
on run argv
	set limitValue to 20
	if (count of argv) ≥ 1 then set limitValue to (item 1 of argv) as integer
	if limitValue < 1 then set limitValue to 1

	tell application "Mail"
		set output to ""
		set remaining to limitValue
		set firstLine to true
		set seenKeys to {}

		repeat with acc in every account
			set accName to name of acc as text
			set draftBoxes to my draftMailboxes(acc)
			repeat with mb in draftBoxes
				if remaining ≤ 0 then exit repeat
				set mbName to ""
				try
					set mbName to name of mb as text
				end try
				set key to accName & "/" & mbName
				if key is in seenKeys then
					-- skip duplicates
				else
					set end of seenKeys to key
					set msgCount to 0
					try
						set msgCount to count of messages of mb
					end try
					if msgCount > 0 then
						set takeCount to msgCount
						if takeCount > remaining then set takeCount to remaining
						set msgList to messages 1 thru takeCount of mb
						repeat with i from 1 to count of msgList
							set msgRecord to contents of item i of msgList
							if firstLine is false then set output to output & linefeed
							set output to output & my draftSummaryJson(msgRecord, accName, mbName)
							set firstLine to false
						end repeat
						set remaining to remaining - takeCount
					end if
				end if
			end repeat
			if remaining ≤ 0 then exit repeat
		end repeat

		return output
	end tell
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

on draftSummaryJson(msgRecord, accName, mbName)
	using terms from application "Mail"
		set rawIdValue to id of msgRecord
		set rawMessageIdValue to (message id of msgRecord)
		set subjectValue to subject of msgRecord as text
		set senderValue to sender of msgRecord as text
		set rawDateSentValue to (date sent of msgRecord)
		set rawReadValue to (read status of msgRecord)
	end using terms from
	set draftIdValue to my jsonIntNullable(rawIdValue)
	set messageIdValue to my safeText(rawMessageIdValue)
	set dateSentValue to my jsonDateIso(rawDateSentValue)
	set readValue to my jsonBoolean(rawReadValue)

	return "{" & "\"draft_id\":" & draftIdValue & "," & "\"account\":" & my jsonString(accName) & "," & "\"mailbox\":" & my jsonString(mbName) & "," & "\"subject\":" & my jsonString(subjectValue) & "," & "\"sender\":" & my jsonString(senderValue) & "," & "\"date_sent\":" & dateSentValue & "," & "\"message_id\":" & my jsonNullable(messageIdValue) & "," & "\"read\":" & readValue & "}"
end draftSummaryJson

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

on jsonIntNullable(valueValue)
	if valueValue is missing value then return "null"
	try
		set intValue to valueValue as integer
		return intValue as text
	on error
		return "null"
	end try
end jsonIntNullable

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
