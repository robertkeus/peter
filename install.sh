#!/usr/bin/env bash
# Install, update, verify, or remove Peter's Claude Code files.
# The /build skill is generated from /peter during installation.
set -euo pipefail

repo="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
dest="${CLAUDE_CONFIG_DIR:-${CLAUDE_HOME:-$HOME/.claude}}"
dest="${dest%/}"
state="$dest/.peter-install"
backup_root="$dest/peter-backups"
targets=(
	"skills/peter"
	"agents/backend-builder.md"
	"agents/frontend-builder.md"
	"agents/security-auditor.md"
	"agents/ui-auditor.md"
)
managed_targets=("${targets[@]}" "skills/build")

action=install
action_set=0
dry_run=0
force=0

usage() {
	cat <<'EOF'
usage: ./install.sh [install|pull|check|uninstall] [--dry-run] [--force]

  install     copy this repository into ~/.claude (default)
  pull        copy the installed files back into this repository
  check       report drift without changing files
  uninstall   remove Peter and restore files backed up during first install

  --dry-run   print changes without making them
  --force     back up and replace conflicting files
EOF
}

for arg in "$@"; do
	case "$arg" in
	install | pull | check | uninstall)
		if [ "$action_set" -eq 1 ]; then
			echo "choose one action" >&2
			usage >&2
			exit 2
		fi
		action="$arg"
		action_set=1
		;;
	--dry-run) dry_run=1 ;;
	--force) force=1 ;;
	-h | --help)
		usage
		exit 0
		;;
	*)
		echo "unknown argument: $arg" >&2
		usage >&2
		exit 2
		;;
	esac
done

case "$dest" in
"" | "/")
	echo "refusing unsafe configuration directory: ${dest:-<empty>}" >&2
	exit 2
	;;
esac

exists() {
	[ -e "$1" ] || [ -L "$1" ]
}

validate_write_layout() {
	for path in "$dest/skills" "$dest/agents" "$state"; do
		if [ -L "$path" ]; then
			echo "refusing to write through symlink: $path" >&2
			echo "set CLAUDE_CONFIG_DIR to the real configuration directory" >&2
			exit 1
		fi
	done
}

same_path() {
	left=$1
	right=$2
	exists "$left" && exists "$right" || return 1
	if [ -L "$left" ] || [ -L "$right" ]; then
		[ -L "$left" ] && [ -L "$right" ] &&
			[ "$(readlink "$left")" = "$(readlink "$right")" ]
	elif [ -d "$left" ] && [ -d "$right" ]; then
		diff -qr "$left" "$right" >/dev/null
	elif [ -f "$left" ] && [ -f "$right" ]; then
		cmp -s "$left" "$right"
	else
		return 1
	fi
}

remove_path() {
	path=$1
	exists "$path" || return 0
	if [ "$dry_run" -eq 1 ]; then
		printf 'would remove %s\n' "$path"
	elif [ -d "$path" ] && [ ! -L "$path" ]; then
		rm -rf -- "$path"
	else
		rm -f -- "$path"
	fi
}

copy_path() {
	source_path=$1
	target_path=$2
	if [ "$dry_run" -eq 1 ]; then
		printf 'would copy %s -> %s\n' "$source_path" "$target_path"
		return
	fi
	mkdir -p "$(dirname "$target_path")"
	remove_path "$target_path"
	if [ -d "$source_path" ] && [ ! -L "$source_path" ]; then
		cp -R "$source_path" "$target_path"
	else
		cp -P "$source_path" "$target_path"
	fi
}

validate_sources() {
	root=$1
	for rel in "${targets[@]}"; do
		if ! exists "$root/$rel"; then
			echo "missing required path: $root/$rel" >&2
			exit 1
		fi
	done
}

validate_state() {
	if [ ! -f "$state/version" ] || [ "$(cat "$state/version")" != "1" ]; then
		echo "invalid install state: $state" >&2
		exit 1
	fi
	for rel in "${managed_targets[@]}"; do
		if ! exists "$state/original/$rel" && ! grep -Fqx "$rel" "$state/original-absent"; then
			echo "incomplete install state for $rel" >&2
			exit 1
		fi
	done
}

find_initial_collisions() {
	collisions=()
	for rel in "${managed_targets[@]}"; do
		exists "$dest/$rel" && collisions+=("$rel")
	done
	return 0
}

find_modified_targets() {
	collisions=()
	for rel in "${managed_targets[@]}"; do
		if exists "$dest/$rel" && ! same_path "$dest/$rel" "$state/installed/$rel"; then
			collisions+=("$rel")
		fi
	done
	return 0
}

print_collisions() {
	message=$1
	printf '%s\n' "$message" >&2
	for rel in "${collisions[@]}"; do
		printf '  %s\n' "$dest/$rel" >&2
	done
	printf 'rerun with --force to back them up and continue\n' >&2
}

backup_conflicts() {
	[ "${#collisions[@]}" -gt 0 ] || return 0
	conflict_backup="$backup_root/$(date -u +%Y%m%dT%H%M%SZ)-$$"
	for rel in "${collisions[@]}"; do
		copy_path "$dest/$rel" "$conflict_backup/$rel"
	done
	printf '%s\n' "conflicts backed up -> $conflict_backup"
}

install_build_alias() {
	target_path=$1
	copy_path "$repo/skills/peter" "$target_path"
	if [ "$dry_run" -eq 1 ]; then
		printf 'would set skill name to build in %s/SKILL.md\n' "$target_path"
	else
		sed 's/^name: peter$/name: build/' "$repo/skills/peter/SKILL.md" >"$target_path/SKILL.md"
	fi
}

same_build_alias() {
	target_path=$1
	exists "$target_path" || return 1
	diff -qr --exclude=SKILL.md "$repo/skills/peter" "$target_path" >/dev/null &&
		diff <(sed 's/^name: peter$/name: build/' "$repo/skills/peter/SKILL.md") "$target_path/SKILL.md" >/dev/null
}

install_files() {
	validate_sources "$repo"

	if exists "$state"; then
		validate_state
		find_modified_targets
		if [ "${#collisions[@]}" -gt 0 ] && [ "$force" -eq 0 ]; then
			print_collisions "installed files contain local changes:"
			exit 1
		fi
		[ "$force" -eq 1 ] && backup_conflicts
	else
		find_initial_collisions
		if [ "${#collisions[@]}" -gt 0 ] && [ "$force" -eq 0 ]; then
			print_collisions "installation would replace existing files:"
			exit 1
		fi

		if [ "$dry_run" -eq 0 ]; then
			mkdir -p "$state/original" "$state/installed"
			: >"$state/original-absent"
			for rel in "${managed_targets[@]}"; do
				if exists "$dest/$rel"; then
					copy_path "$dest/$rel" "$state/original/$rel"
				else
					printf '%s\n' "$rel" >>"$state/original-absent"
				fi
			done
			printf '1\n' >"$state/version"
			if [ "${#collisions[@]}" -gt 0 ]; then
				printf 'original files saved for uninstall -> %s\n' "$state/original"
			fi
		else
			printf 'would create restore state in %s\n' "$state"
		fi
	fi

	for rel in "${targets[@]}"; do
		copy_path "$repo/$rel" "$dest/$rel"
		copy_path "$repo/$rel" "$state/installed/$rel"
	done
	install_build_alias "$dest/skills/build"
	copy_path "$dest/skills/build" "$state/installed/skills/build"
	printf '%s\n' "installed -> $dest"
}

pull_files() {
	validate_sources "$dest"
	if [ "$force" -eq 0 ] && [ -n "$(git -C "$repo" status --porcelain -- skills/peter agents)" ]; then
		echo "repository copies contain local changes; rerun with --force to replace them" >&2
		exit 1
	fi
	for rel in "${targets[@]}"; do
		copy_path "$dest/$rel" "$repo/$rel"
	done
	printf '%s\n' "pulled <- $dest"
}

check_files() {
	validate_sources "$repo"
	validate_sources "$dest"
	drift=0
	for rel in "${targets[@]}"; do
		if ! same_path "$repo/$rel" "$dest/$rel"; then
			printf 'drift: %s\n' "$rel" >&2
			drift=1
		fi
	done
	if ! same_build_alias "$dest/skills/build"; then
		printf 'drift: %s\n' "skills/build" >&2
		drift=1
	fi
	[ "$drift" -eq 0 ] || exit 1
	printf '%s\n' "in sync"
}

uninstall_files() {
	if ! exists "$state"; then
		echo "Peter is not installed by this installer: $state not found" >&2
		exit 1
	fi
	validate_state
	find_modified_targets
	if [ "${#collisions[@]}" -gt 0 ] && [ "$force" -eq 0 ]; then
		print_collisions "installed files contain local changes:"
		exit 1
	fi
	[ "$force" -eq 1 ] && backup_conflicts

	for rel in "${managed_targets[@]}"; do
		remove_path "$dest/$rel"
		if exists "$state/original/$rel"; then
			copy_path "$state/original/$rel" "$dest/$rel"
		fi
	done
	remove_path "$state"
	printf '%s\n' "uninstalled -> $dest"
}

case "$action" in
install)
	validate_write_layout
	install_files
	;;
pull) pull_files ;;
check) check_files ;;
uninstall)
	validate_write_layout
	uninstall_files
	;;
esac
