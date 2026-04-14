-- Get the default Mail account name.
-- Output: plain text account name (or empty string if none).
tell application "Mail"
	if (count of accounts) is 0 then return ""
	set defaultAccount to first account
	return name of defaultAccount as text
end tell
