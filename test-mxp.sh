#!/usr/bin/env bash

# Test suite for mxp
# Copyright (c) 2025 Ag Ibragimov <agzam.ibragimov@gmail.com>
# Licensed under the MIT License. See LICENSE file for details.

set -euo pipefail

# Trap errors and show which line failed
trap 'echo "Error on line $LINENO"' ERR

SCRIPT="./mxp"
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

passed=0
failed=0

echo "================================"
echo "mxp Test Suite"
echo "================================"
echo ""

# Helper functions
pass() {
  printf "${GREEN}✓${NC} %s\n" "$1"
  passed=$((passed + 1))
}

fail() {
  printf "${RED}✗${NC} %s\n" "$1"
  failed=$((failed + 1))
}

info() {
  printf "${YELLOW}ℹ${NC} %s\n" "$1"
}

section() {
  echo ""
  echo "--- $1 ---"
}

cleanup_buffer() {
  local buffer="$1"
  emacsclient --eval "(when (get-buffer \"$buffer\") (kill-buffer \"$buffer\"))" &>/dev/null || true
}

buffer_exists() {
  local buffer="$1"
  # Use printf to avoid shell interpretation of angle brackets
  local cmd
  cmd=$(printf '(buffer-live-p (get-buffer "%s"))' "$buffer")
  emacsclient --eval "$cmd" 2>/dev/null | grep -q 't'
}

buffer_content() {
  local buffer="$1"
  # Use mxp's own read mode instead of parsing elisp strings
  ./mxp --from "$buffer" 2>/dev/null
}

# Pre-test cleanup
section "Pre-test Cleanup"
cleanup_buffer "*test-buffer*"
cleanup_buffer "*test-append*"
cleanup_buffer "*test-conflict*"
cleanup_buffer "*test-conflict<2>*"
cleanup_buffer "*Piper 1*"
cleanup_buffer "*Piper 2*"
info "Cleaned up test buffers"

# Test 1: Basic help
section "Test 1: Help and Version"
if $SCRIPT --help | grep -q "mxp"; then
  pass "Help message displays"
else
  fail "Help message missing"
fi

if $SCRIPT --version | grep -q "mxp v"; then
  pass "Version displays"
else
  fail "Version missing"
fi

# Test 2: Write mode - pipe to new buffer
section "Test 2: Write Mode - Create Buffer"
cleanup_buffer "*test-buffer*"
echo "test content" | $SCRIPT "*test-buffer*" &>/dev/null

if buffer_exists "*test-buffer*"; then
  pass "Buffer created from pipe"
  content=$(buffer_content "*test-buffer*")
  if [[ "$content" == *"test content"* ]]; then
    pass "Buffer contains correct content"
  else
    fail "Buffer content incorrect: got '$content'"
  fi
else
  fail "Buffer not created"
fi

# Test 3: Write mode - auto-generated buffer name
section "Test 3: Auto-generated Buffer Name"
cleanup_buffer "*Piper 1*"
echo "auto content" | $SCRIPT &>/dev/null

if buffer_exists "*Piper 1*"; then
  pass "Auto-generated buffer created"
  content=$(buffer_content "*Piper 1*")
  if [[ "$content" == *"auto content"* ]]; then
    pass "Auto-generated buffer has correct content"
  else
    fail "Auto-generated buffer content incorrect"
  fi
else
  fail "Auto-generated buffer not created"
fi

# Test 4: Write mode - second auto-generated buffer
echo "auto content 2" | $SCRIPT &>/dev/null
if buffer_exists "*Piper 2*"; then
  pass "Second auto-generated buffer created with incremented number"
else
  fail "Second auto-generated buffer not created"
fi

# Test 5: Read mode - output buffer content
section "Test 4: Read Mode - Output Buffer"
cleanup_buffer "*test-read*"
echo "readable content" | $SCRIPT "*test-read*" &>/dev/null
output=$($SCRIPT --from "*test-read*" 2>/dev/null)

if [[ "$output" == *"readable content"* ]]; then
  pass "Read mode outputs buffer content"
else
  fail "Read mode failed: got '$output'"
fi

# Test 6: Read mode with short flag
output=$($SCRIPT -f "*test-read*" 2>/dev/null)
if [[ "$output" == *"readable content"* ]]; then
  pass "Read mode works with -f short flag"
else
  fail "Short flag -f failed"
fi

# Test 7: Append mode
section "Test 5: Append Mode"
cleanup_buffer "*test-append*"
echo "first line" | $SCRIPT "*test-append*" &>/dev/null
echo "second line" | $SCRIPT --append "*test-append*" &>/dev/null

content=$(buffer_content "*test-append*")
if [[ "$content" == *"first line"* ]] && [[ "$content" == *"second line"* ]]; then
  pass "Append mode preserves existing content"
else
  fail "Append mode failed: got '$content'"
fi

# Test 8: Append with short flag
echo "third line" | $SCRIPT -a "*test-append*" &>/dev/null
content=$(buffer_content "*test-append*")
if [[ "$content" == *"third line"* ]]; then
  pass "Append works with -a short flag"
else
  fail "Short flag -a failed"
fi

# Test 9: Conflict resolution (without force)
section "Test 6: Buffer Conflict Resolution"
if [ -n "${CI:-}" ]; then
  info "Skipped in CI (shell-specific edge case)"
else
  cleanup_buffer "*test-conflict*"
  cleanup_buffer "*test-conflict<2>*"
  echo "first" | $SCRIPT "*test-conflict*" &>/dev/null
  echo "second" | $SCRIPT "*test-conflict*" &>/dev/null

  if buffer_exists "*test-conflict<2>*"; then
    pass "Conflict creates new buffer with <2> suffix"
    content=$(buffer_content "*test-conflict<2>*")
    if [[ "$content" == *"second"* ]]; then
      pass "Conflicted buffer has correct content"
    else
      fail "Conflicted buffer content incorrect"
    fi
  else
    fail "Conflict resolution failed"
  fi
fi

# Test 10: Force overwrite
section "Test 7: Force Overwrite"
cleanup_buffer "*test-force*"
echo "original" | $SCRIPT "*test-force*" &>/dev/null
echo "overwritten" | $SCRIPT --force "*test-force*" &>/dev/null

content=$(buffer_content "*test-force*")
if [[ "$content" == *"overwritten"* ]] && [[ "$content" != *"original"* ]]; then
  pass "Force flag overwrites existing buffer"
else
  fail "Force overwrite failed: got '$content'"
fi

# Test 11: Force with short flag
echo "original2" | $SCRIPT "*test-force*" &>/dev/null
echo "overwritten2" | $SCRIPT -F "*test-force*" &>/dev/null
content=$(buffer_content "*test-force*")
if [[ "$content" == *"overwritten2"* ]]; then
  pass "Force works with -F short flag"
else
  fail "Short flag -F failed"
fi

# Test 12: Regex buffer matching (write mode)
section "Test 8: Regex Buffer Matching"
cleanup_buffer "*regex-test-123*"
echo "regex content" | $SCRIPT "*regex-test-123*" &>/dev/null

# Try to match with regex
echo "matched content" | $SCRIPT --force ".*regex-test.*" &>/dev/null
content=$(buffer_content "*regex-test-123*")
if [[ "$content" == *"matched content"* ]]; then
  pass "Regex matching works in write mode"
else
  fail "Regex matching failed in write mode"
fi

# Test 13: Regex buffer matching (read mode)
output=$($SCRIPT --from ".*regex-test.*" 2>/dev/null)
if [[ "$output" == *"matched content"* ]]; then
  pass "Regex matching works in read mode"
else
  fail "Regex matching failed in read mode: got '$output'"
fi

# Test 14: Pass-through behavior
section "Test 9: Pass-through (tee behavior)"
cleanup_buffer "*test-passthrough*"
output=$(echo "passthrough test" | $SCRIPT "*test-passthrough*" 2>/dev/null)

if [[ "$output" == *"passthrough test"* ]]; then
  pass "Content passes through to stdout"
  if buffer_exists "*test-passthrough*"; then
    pass "Content also written to buffer"
  else
    fail "Buffer not created during pass-through"
  fi
else
  fail "Pass-through failed: got '$output'"
fi

# Test 15: Multi-line content
section "Test 10: Multi-line Content"
cleanup_buffer "*test-multiline*"
printf "line 1\nline 2\nline 3\n" | $SCRIPT "*test-multiline*" &>/dev/null
content=$(buffer_content "*test-multiline*")

if [[ "$content" == *"line 1"* ]] && [[ "$content" == *"line 2"* ]] && [[ "$content" == *"line 3"* ]]; then
  pass "Multi-line content preserved"
else
  fail "Multi-line content failed"
fi

# Test 16: Special characters handling
section "Test 11: Special Characters"
cleanup_buffer "*test-special*"
echo 'special: "quotes" $vars \backslash' | $SCRIPT "*test-special*" &>/dev/null
content=$(buffer_content "*test-special*")

if [[ "$content" == *'special: "quotes" $vars \backslash'* ]]; then
  pass "Special characters preserved"
else
  fail "Special characters mangled: got '$content'"
fi

# Test 17: Empty input
section "Test 12: Empty Input"
cleanup_buffer "*test-empty*"
echo -n "" | $SCRIPT "*test-empty*" &>/dev/null

if buffer_exists "*test-empty*"; then
  pass "Empty input creates buffer"
else
  fail "Empty input failed to create buffer"
fi

# Test 18: Large content (chunking test)
section "Test 13: Large Content (Chunking)"
cleanup_buffer "*test-large*"
seq 1 500 | $SCRIPT "*test-large*" &>/dev/null
content=$(buffer_content "*test-large*")

if [[ "$content" == *"1"* ]] && [[ "$content" == *"500"* ]]; then
  pass "Large content (500 lines) handled correctly"
else
  fail "Large content failed"
fi

# Test 19: Non-existent buffer read
section "Test 14: Error Handling"
output=$($SCRIPT --from "*non-existent-buffer*" 2>&1 || true)
if [[ "$output" == *"No buffer matching"* ]]; then
  pass "Reading non-existent buffer shows error"
else
  fail "Error message missing for non-existent buffer"
fi

# Test 20: Read mode without stdin (auto-detect)
section "Test 15: Auto-detect Read Mode"
if [ -n "${CI:-}" ]; then
  info "Skipped in CI (command substitution stdin edge case)"
else
  cleanup_buffer "*test-autoread*"
  echo "auto read test" | $SCRIPT "*test-autoread*" &>/dev/null

  # Call without --from but redirect from /dev/null to simulate no stdin
  # This simulates terminal usage where stdin is not a pipe
  output=$($SCRIPT "*test-autoread*" </dev/null 2>/dev/null)
  if [[ "$output" == *"auto read test"* ]]; then
    pass "Auto-detects read mode when no stdin"
  else
    fail "Auto-detect read mode failed: got '$output'"
  fi
fi

# Summary
section "Test Summary"
echo ""
echo "Passed: $passed"
echo "Failed: $failed"
echo ""

if [ $failed -eq 0 ]; then
  printf "${GREEN}All tests passed!${NC}\n"
  exit 0
else
  printf "${RED}Some tests failed.${NC}\n"
  exit 1
fi
