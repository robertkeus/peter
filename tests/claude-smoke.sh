#!/usr/bin/env bash
set -euo pipefail

repo="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
test_root="$(mktemp -d)"
trap 'rm -rf -- "$test_root"' EXIT

version="$(npx --yes @anthropic-ai/claude-code@2.1.228 --version)"
case "$version" in
2.1.228*) ;;
*)
	echo "unexpected Claude Code version: $version" >&2
	exit 1
	;;
esac

config="$test_root/claude"
CLAUDE_CONFIG_DIR="$config" "$repo/install.sh" >/dev/null
CLAUDE_CONFIG_DIR="$config" "$repo/install.sh" check >/dev/null
CLAUDE_CONFIG_DIR="$config" "$repo/install.sh" uninstall >/dev/null

[ ! -e "$config/.peter-install" ] || {
	echo "uninstall left Peter state behind" >&2
	exit 1
}

echo "Claude Code $version smoke test passed"
