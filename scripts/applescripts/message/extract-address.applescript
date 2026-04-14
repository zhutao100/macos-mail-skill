-- Extract email address from full address string. argv: "Full Name <email@example.com>"
on run argv
	if (count of argv) < 1 then error "Usage: extract-address.applescript <full-email-address>"
	set fullAddr to item 1 of argv as text
	return my extractAddress(fullAddr)
end run

on extractAddress(fullAddr)
	set s to my trimWhitespace(fullAddr as text)
	if s is "" then return ""

	-- If input contains multiple comma-separated addresses, take the first.
	if s contains "," then
		set s to my firstItem(s, ",")
		set s to my trimWhitespace(s)
	end if

	-- Common form: Name <addr>
	if s contains "<" then
		try
			set AppleScript's text item delimiters to "<"
			set afterLt to text item 2 of s
			set AppleScript's text item delimiters to ">"
			set inside to text item 1 of afterLt
			set AppleScript's text item delimiters to ""
			set inside to my trimWhitespace(inside)
			if inside is not "" then return inside
		end try
		set AppleScript's text item delimiters to ""
	end if

	-- Alternate: addr (Name)
	if s contains "(" then
		set s to my firstItem(s, "(")
		set s to my trimWhitespace(s)
	end if

	-- Optional: strip mailto:
	if s starts with "mailto:" then
		if (length of s) > 7 then
			set s to text 8 thru -1 of s
		else
			set s to ""
		end if
		set s to my trimWhitespace(s)
	end if

	return s
end extractAddress

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
