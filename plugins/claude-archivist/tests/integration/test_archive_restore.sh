#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
TEST_DIR=$(mktemp -d)
ORIGINAL_HOME="$HOME"

cleanup() {
    rm -rf "$TEST_DIR"
    export HOME="$ORIGINAL_HOME"
}
trap cleanup EXIT

setup_test_env() {
    export HOME="$TEST_DIR/home"
    rm -rf "$HOME/.claude" "$HOME/.claude-archive"
    mkdir -p "$HOME/.claude/projects/-test-project"
    mkdir -p "$HOME/.claude-archive"
}

create_mock_session() {
    local session_id="$1"
    local content="$2"
    local session_file="$HOME/.claude/projects/-test-project/${session_id}.jsonl"
    echo "$content" > "$session_file"
}

assert_file_exists() {
    local file="$1"
    local msg="$2"
    if [ ! -f "$file" ]; then
        echo "FAIL: $msg - File not found: $file"
        exit 1
    fi
    echo "PASS: $msg"
}

assert_file_not_exists() {
    local file="$1"
    local msg="$2"
    if [ -f "$file" ]; then
        echo "FAIL: $msg - File should not exist: $file"
        exit 1
    fi
    echo "PASS: $msg"
}

assert_file_content() {
    local file="$1"
    local expected="$2"
    local msg="$3"
    local actual=$(cat "$file")
    if [ "$actual" != "$expected" ]; then
        echo "FAIL: $msg - Content mismatch"
        echo "  Expected: $expected"
        echo "  Actual: $actual"
        exit 1
    fi
    echo "PASS: $msg"
}

test_basic_archive() {
    echo "=== Test: Basic Archive ==="
    setup_test_env

    create_mock_session "session-001" '{"message": "test1"}'
    create_mock_session "session-002" '{"message": "test2"}'

    "$PLUGIN_ROOT/scripts/archive.sh"

    assert_file_exists "$HOME/.claude-archive/-test-project/session-001.jsonl.gz" "session-001 archived"
    assert_file_exists "$HOME/.claude-archive/-test-project/session-002.jsonl.gz" "session-002 archived"
    assert_file_exists "$HOME/.claude-archive/.last-backup-timestamp" "timestamp file created"

    local content=$(gunzip -c "$HOME/.claude-archive/-test-project/session-001.jsonl.gz")
    assert_file_content <(echo "$content") '{"message": "test1"}' "archived content matches"
}

test_incremental_backup() {
    echo "=== Test: Incremental Backup ==="
    setup_test_env

    create_mock_session "session-001" '{"message": "original"}'
    "$PLUGIN_ROOT/scripts/archive.sh"

    local first_mtime=$(stat -c %Y "$HOME/.claude-archive/-test-project/session-001.jsonl.gz" 2>/dev/null || stat -f %m "$HOME/.claude-archive/-test-project/session-001.jsonl.gz")

    sleep 1
    "$PLUGIN_ROOT/scripts/archive.sh"

    local second_mtime=$(stat -c %Y "$HOME/.claude-archive/-test-project/session-001.jsonl.gz" 2>/dev/null || stat -f %m "$HOME/.claude-archive/-test-project/session-001.jsonl.gz")

    if [ "$first_mtime" -ne "$second_mtime" ]; then
        echo "FAIL: Archive should not be updated when source unchanged"
        exit 1
    fi
    echo "PASS: Unchanged file not re-archived"

    sleep 1
    create_mock_session "session-001" '{"message": "updated"}'
    "$PLUGIN_ROOT/scripts/archive.sh"

    local content=$(gunzip -c "$HOME/.claude-archive/-test-project/session-001.jsonl.gz")
    assert_file_content <(echo "$content") '{"message": "updated"}' "updated content archived"
}

test_restore() {
    echo "=== Test: Restore ==="
    setup_test_env

    create_mock_session "session-001" '{"message": "restore-test"}'
    "$PLUGIN_ROOT/scripts/archive.sh"

    rm "$HOME/.claude/projects/-test-project/session-001.jsonl"
    assert_file_not_exists "$HOME/.claude/projects/-test-project/session-001.jsonl" "source file deleted"

    "$PLUGIN_ROOT/scripts/restore.sh"

    assert_file_exists "$HOME/.claude/projects/-test-project/session-001.jsonl" "session restored"
    assert_file_content "$HOME/.claude/projects/-test-project/session-001.jsonl" '{"message": "restore-test"}' "restored content matches"
}

test_restore_no_overwrite() {
    echo "=== Test: Restore Does Not Overwrite ==="
    setup_test_env

    create_mock_session "session-001" '{"message": "original"}'
    "$PLUGIN_ROOT/scripts/archive.sh"

    create_mock_session "session-001" '{"message": "newer-content"}'
    "$PLUGIN_ROOT/scripts/restore.sh"

    assert_file_content "$HOME/.claude/projects/-test-project/session-001.jsonl" '{"message": "newer-content"}' "existing file not overwritten"
}

test_periodic_mode() {
    echo "=== Test: Periodic Mode ==="
    setup_test_env

    create_mock_session "session-001" '{"message": "periodic-test"}'
    "$PLUGIN_ROOT/scripts/archive.sh"

    local first_timestamp=$(cat "$HOME/.claude-archive/.last-backup-timestamp")

    sleep 1
    "$PLUGIN_ROOT/scripts/archive.sh" --periodic

    local second_timestamp=$(cat "$HOME/.claude-archive/.last-backup-timestamp")

    if [ "$first_timestamp" -ne "$second_timestamp" ]; then
        echo "FAIL: Periodic backup should not run before interval"
        exit 1
    fi
    echo "PASS: Periodic backup skipped (interval not reached)"
}

test_list_restorable() {
    echo "=== Test: List Restorable ==="
    setup_test_env

    create_mock_session "session-001" '{"message": "list-test"}'
    "$PLUGIN_ROOT/scripts/archive.sh"

    rm "$HOME/.claude/projects/-test-project/session-001.jsonl"

    local output=$("$PLUGIN_ROOT/scripts/restore.sh" --list)
    if [[ "$output" != *"session-001"* ]]; then
        echo "FAIL: session-001 should be listed as restorable"
        exit 1
    fi
    echo "PASS: Restorable session listed"
}

echo "Running integration tests for claude-archivist"
echo "=============================================="
echo ""

test_basic_archive
echo ""
test_incremental_backup
echo ""
test_restore
echo ""
test_restore_no_overwrite
echo ""
test_periodic_mode
echo ""
test_list_restorable

echo ""
echo "=============================================="
echo "All tests passed!"
