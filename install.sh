#!/usr/bin/env bash
# Sync the tracked /peter skill and its agents with ~/.claude.
# ~/.claude/skills/build is a generated alias of peter (only name: differs);
# it is rebuilt on install and never pulled.
#
#   ./install.sh            repo -> ~/.claude   (default)
#   ./install.sh pull       ~/.claude -> repo
#   ./install.sh check      diff both ways, non-zero on drift
#
# ~/.claude is not version-controlled; this repo is the tracked copy.
set -euo pipefail

repo="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
dest="${CLAUDE_HOME:-$HOME/.claude}"

case "${1:-install}" in
install)
	mkdir -p "$dest/skills" "$dest/agents"
	rm -rf "${dest:?}/skills/peter" "${dest:?}/skills/build"
	cp -R "$repo/skills/peter" "$dest/skills/peter"
	cp -R "$repo/skills/peter" "$dest/skills/build"
	sed 's/^name: peter$/name: build/' "$repo/skills/peter/SKILL.md" > "$dest/skills/build/SKILL.md"
	cp "$repo"/agents/*.md "$dest/agents/"
	echo "installed -> $dest"
	;;
pull)
	rm -rf "${repo:?}/skills/peter"
	cp -R "$dest/skills/peter" "$repo/skills/peter"
	cp "$dest"/agents/{backend-builder,frontend-builder,security-auditor,ui-auditor}.md "$repo/agents/"
	echo "pulled <- $dest"
	;;
check)
	diff -r "$repo/skills/peter" "$dest/skills/peter"
	diff -r --exclude=SKILL.md "$repo/skills/peter" "$dest/skills/build"
	diff <(sed 's/^name: peter$/name: build/' "$repo/skills/peter/SKILL.md") "$dest/skills/build/SKILL.md"
	for f in "$repo"/agents/*.md; do
		diff "$f" "$dest/agents/$(basename "$f")"
	done
	echo "in sync"
	;;
*)
	echo "usage: ${0##*/} [install|pull|check]" >&2
	exit 2
	;;
esac
