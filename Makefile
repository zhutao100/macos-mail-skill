.PHONY: dictionary-mail compile check test test-dictionary test-smoke lint

dictionary-mail:
	@sdef /System/Applications/Mail.app

compile:
	@set -euo pipefail; \
	find scripts -name '*.applescript' -print | while IFS= read -r file; do \
		osacompile -o /tmp/$$(echo "$$file" | tr '/' '_' | sed 's/\.applescript$$/.scpt/') "$$file"; \
	done

lint:
	@if command -v shellcheck >/dev/null 2>&1; then \
		find scripts tests -name '*.sh' -exec shellcheck {} +; \
	else \
		echo "lint: shellcheck not available, skipping"; \
	fi

check:
	@command -v jq >/dev/null || { echo "check: jq is required"; exit 1; }
	@osascript -e 'tell application "Mail" to get name' >/dev/null || { echo "check: Mail.app not available"; exit 1; }
	@echo "Mail.app and jq are available"

test: test-dictionary test-smoke lint

test-dictionary:
	@bash tests/dictionary_contract.sh

test-smoke:
	@bash tests/smoke_mail.sh
