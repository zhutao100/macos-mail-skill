.PHONY: dictionary-mail compile check test test-dictionary test-unit test-smoke lint

dictionary-mail:
	@set -euo pipefail; \
	app="/System/Applications/Mail.app"; \
	[ -d "$$app" ] || app="/Applications/Mail.app"; \
	sdef "$$app"

compile:
	@set -euo pipefail; \
	out_dir="build/applescripts"; \
	rm -rf "$$out_dir"; \
	mkdir -p "$$out_dir"; \
	find scripts -type f -name '*.applescript' -print0 | while IFS= read -r -d '' file; do \
		rel="$${file#scripts/}"; \
		out_path="$$out_dir/$${rel%.applescript}.scpt"; \
		mkdir -p "$$(dirname "$$out_path")"; \
		/usr/bin/osacompile -l AppleScript -o "$$out_path" "$$file" >/dev/null; \
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

test: test-dictionary test-unit test-smoke lint

test-dictionary:
	@bash tests/dictionary_contract.sh

test-unit:
	@bash tests/unit_parsing.sh

test-smoke:
	@bash tests/smoke_mail.sh
