#!/usr/bin/env bash
set -euo pipefail

repo="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
test_root="$(mktemp -d)"
trap 'rm -rf -- "$test_root"' EXIT

fail() {
	echo "FAIL: $*" >&2
	exit 1
}

assert_exists() {
	[ -e "$1" ] || fail "expected $1"
}

assert_missing() {
	[ ! -e "$1" ] || fail "expected $1 to be absent"
}

fresh_dest="$test_root/fresh"
CLAUDE_CONFIG_DIR="$fresh_dest" "$repo/install.sh" --dry-run >/dev/null
assert_missing "$fresh_dest"

CLAUDE_CONFIG_DIR="$fresh_dest" "$repo/install.sh" >/dev/null
CLAUDE_CONFIG_DIR="$fresh_dest" "$repo/install.sh" >/dev/null
CLAUDE_CONFIG_DIR="$fresh_dest" "$repo/install.sh" check >/dev/null
assert_exists "$fresh_dest/skills/peter/SKILL.md"
grep -Fqx 'name: build' "$fresh_dest/skills/build/SKILL.md"
assert_exists "$fresh_dest/.peter-install/version"

CLAUDE_CONFIG_DIR="$fresh_dest" "$repo/install.sh" uninstall >/dev/null
assert_missing "$fresh_dest/skills/peter"
assert_missing "$fresh_dest/skills/build"
assert_missing "$fresh_dest/agents/backend-builder.md"
assert_missing "$fresh_dest/.peter-install"

collision_dest="$test_root/collision"
mkdir -p "$collision_dest/skills/peter" "$collision_dest/agents"
printf 'original skill\n' >"$collision_dest/skills/peter/SKILL.md"
mkdir -p "$collision_dest/skills/build"
printf 'original build\n' >"$collision_dest/skills/build/SKILL.md"
printf 'original agent\n' >"$collision_dest/agents/backend-builder.md"

if CLAUDE_CONFIG_DIR="$collision_dest" "$repo/install.sh" >/dev/null 2>&1; then
	fail "install accepted collisions without --force"
fi
CLAUDE_CONFIG_DIR="$collision_dest" "$repo/install.sh" --force >/dev/null
grep -Fqx 'original skill' "$collision_dest/.peter-install/original/skills/peter/SKILL.md"
grep -Fqx 'original build' "$collision_dest/.peter-install/original/skills/build/SKILL.md"
grep -Fqx 'original agent' "$collision_dest/.peter-install/original/agents/backend-builder.md"

printf 'user modification\n' >"$collision_dest/agents/backend-builder.md"
if CLAUDE_CONFIG_DIR="$collision_dest" "$repo/install.sh" uninstall >/dev/null 2>&1; then
	fail "uninstall discarded a local change without --force"
fi
CLAUDE_CONFIG_DIR="$collision_dest" "$repo/install.sh" uninstall --force >/dev/null
grep -Fqx 'original skill' "$collision_dest/skills/peter/SKILL.md"
grep -Fqx 'original build' "$collision_dest/skills/build/SKILL.md"
grep -Fqx 'original agent' "$collision_dest/agents/backend-builder.md"
assert_missing "$collision_dest/agents/frontend-builder.md"
assert_missing "$collision_dest/.peter-install"
assert_exists "$(find "$collision_dest/peter-backups" -type f -name backend-builder.md -print -quit)"

symlink_dest="$test_root/symlink"
outside_agents="$test_root/outside-agents"
mkdir -p "$symlink_dest" "$outside_agents"
ln -s "$outside_agents" "$symlink_dest/agents"
if CLAUDE_CONFIG_DIR="$symlink_dest" "$repo/install.sh" --force >/dev/null 2>&1; then
	fail "install wrote through a configuration symlink"
fi
assert_missing "$outside_agents/backend-builder.md"

echo "install tests passed"
