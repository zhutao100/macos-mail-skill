-- Show a message in Mail.app UI. argv: accountName mailboxName index
-- Output: one JSON object.
on run argv
	if (count of argv) < 3 then error "Usage: show.applescript <account> <mailbox> <index>"
	set accName to item 1 of argv
	set mbName to item 2 of argv
	set idx to item 3 of argv as integer

	tell application "Mail"
		set targetMailbox to mailbox mbName of account accName
		set targetMessage to message idx of targetMailbox
		set subjectValue to subject of targetMessage as text
		set identityValue to my messageIdentity(targetMessage, accName, mbName, idx)

		activate
		set viewerWindow to my ensureMessageViewer(targetMailbox)
		set selected mailboxes of viewerWindow to {targetMailbox}
		set selected messages of viewerWindow to {targetMessage}

		return "{" & "\"shown\":true," & "\"id\":" & my jsonString(identityValue) & "," & "\"account\":" & my jsonString(accName) & "," & "\"mailbox\":" & my jsonString(mbName) & "," & "\"index\":" & (idx as text) & "," & "\"subject\":" & my jsonString(subjectValue) & "}"
	end tell
end run

on ensureMessageViewer(targetMailbox)
	tell application "Mail"
		if (count of message viewers) is 0 then
			set viewerWindow to make new message viewer
			set selected mailboxes of viewerWindow to {targetMailbox}
			return viewerWindow
		end if

		return first message viewer
	end tell
end ensureMessageViewer

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
