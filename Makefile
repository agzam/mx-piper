.PHONY: help test test-fast test-ci install-shellspec clean

# Default target
help:
	@echo "mxp - Makefile targets"
	@echo ""
	@echo "Testing:"
	@echo "  make test           - Run all tests"
	@echo "  make test-fast      - Run fast tests only (skip slow/problematic ones)"
	@echo "  make test-ci        - Run CI-safe tests"
	@echo ""
	@echo "ShellSpec (future):"
	@echo "  make install-shellspec - Install ShellSpec testing framework"
	@echo "  make spec              - Run ShellSpec tests"
	@echo ""
	@echo "Utilities:"
	@echo "  make clean          - Clean up test artifacts"
	@echo "  make version        - Show mxp version"

# Run all tests
test:
	@echo "Running all tests..."
	./test-mxp.sh

# Run fast tests (skip slow/CI-problematic tests)
test-fast:
	@echo "Running fast tests..."
	./test-mxp.sh --fast

# CI-safe tests (same as fast for now)
test-ci: test-fast

# Install ShellSpec (for future use)
install-shellspec:
	@echo "Installing ShellSpec..."
	@if [ ! -d "shellspec" ]; then \
		git clone --depth 1 https://github.com/shellspec/shellspec.git; \
		echo "ShellSpec installed to ./shellspec/"; \
	else \
		echo "ShellSpec already installed"; \
	fi

# Run ShellSpec tests (future)
spec:
	@if [ -d "shellspec" ]; then \
		./shellspec/shellspec; \
	else \
		echo "ShellSpec not installed. Run: make install-shellspec"; \
		exit 1; \
	fi

# Clean up test artifacts
clean:
	@echo "Cleaning up test artifacts..."
	@rm -f /tmp/mxp-* /tmp/tmp.* 2>/dev/null || true
	@echo "Done"

# Show version
version:
	@./mxp --version
