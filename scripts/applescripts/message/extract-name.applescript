-- Extract display name from full email address. argv: "Full Name <email@example.com>"
on run argv
	if (count of argv) < 1 then error "Usage: extract-name.applescript <full-email-address>"
	set fullAddr to item 1 of argv as text
	return my extractName(fullAddr)
end run

on extractName(fullAddr)
	set s to my trimWhitespace(fullAddr as text)
	if s is "" then return ""

	-- If input contains multiple comma-separated addresses, take the first.
	if s contains "," then
		set s to my firstItem(s, ",")
	end if

	-- Common form: Name <addr>
	if s contains "<" then
		set namePart to my firstItem(s, "<")
		set namePart to my stripWrappingQuotes(my trimWhitespace(namePart))
		return my trimWhitespace(namePart)
	end if

	-- Alternate: addr (Name)
	if (s contains "(") and (s ends with ")") then
		try
			set AppleScript's text item delimiters to "("
			set afterParen to text item 2 of s
			set AppleScript's text item delimiters to ")"
			set insideParen to text item 1 of afterParen
			set AppleScript's text item delimiters to ""
			set insideParen to my trimWhitespace(insideParen)
			if insideParen is not "" then return insideParen
		end try
		set AppleScript's text item delimiters to ""
	end if

	return ""
end extractName

on stripWrappingQuotes(s)
	set s to s as text
	if (length of s) ≥ 2 and (character 1 of s is "\"") and (character -1 of s is "\"") then
		return text 2 thru -2 of s
	end if
	return s
end stripWrappingQuotes

on firstItem(s, delimiterValue)
	set AppleScript's text item delimiters to delimiterValue
	set itemValue to text item 1 of s
	set AppleScript's text item delimiters to ""
	return itemValue
end firstItem

on trimWhitespace(s)
	set s to s as text
	repeat while s is not "" and my isWhitespace(character 1 of s)
		if (length of s) = 1 then return ""
		set s to text 2 thru -1 of s
	end repeat
	repeat while s is not "" and my isWhitespace(character -1 of s)
		if (length of s) = 1 then return ""
		set s to text 1 thru -2 of s
	end repeat
	return s
end trimWhitespace

on isWhitespace(ch)
	return ch is " " or ch is tab or ch is return or ch is linefeed
end isWhitespace
