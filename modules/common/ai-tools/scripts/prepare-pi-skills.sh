#!/usr/bin/env bash
# One-time, explicitly invoked preactivation step. Not installed or activated.
set -euo pipefail

refuse() {
    printf 'Pi skills transition refused: %s\n' "$*" >&2
    exit 1
}

[[ $# == 0 ]] || refuse "no arguments accepted; uses HOME"
[[ ${HOME:-} == /* && -d $HOME && ! -L $HOME ]] || refuse "HOME must be an absolute real directory"
for parent in "$HOME/.pi" "$HOME/.pi/agent"; do
    [[ -d $parent && ! -L $parent ]] || refuse "not a real directory: $parent"
done

target="$HOME/.pi/agent/skills"
backup="$HOME/.pi/agent/skills.hm-before-native"
[[ -L $target ]] || refuse "skills is not the old whole-directory symlink"
old_entry="$(readlink "$target")"
# Match the precise old HM entry, not an arbitrary store or foreign symlink.
[[ $old_entry =~ ^/nix/store/[0-9a-z]{32}-home-manager-files/\.pi/agent/skills$ ]] || refuse "skills does not link to the old HM entry"
[[ -L $old_entry && -d $old_entry ]] || refuse "old HM entry is not a whole-directory source link"
for name in dotfiles-coder nix skill-creator skill-registry; do
    [[ -f $old_entry/$name/SKILL.md ]] || refuse "old source lacks $name/SKILL.md"
done
[[ ! -e $backup && ! -L $backup ]] || refuse "backup already exists: $backup"

# Reserve a private backup directory exclusively. No trailing slash on target:
# mv moves the link itself, never the immutable tree or anything below it.
mkdir -m 700 "$backup"
mv -n "$target" "$backup/skills"
[[ ! -L $target && ! -e $target && -L $backup/skills ]] || refuse "move incomplete; inspect both paths before continuing"
[[ $(readlink "$backup/skills") == "$old_entry" ]] || refuse "backup target changed; inspect before continuing"
printf 'Preserved old HM link at %s/skills; ready for reviewed activation.\n' "$backup"
