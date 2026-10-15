# shellcheck shell=bash
# Called by Home Manager through DRY_RUN_CMD; never run against a real profile
# from tests. settings.json remains runtime-owned and writable.
settings="$1"

if [[ -L $settings ]]; then
    printf 'pi theme: %s is a symlink; leaving it untouched\n' "$settings" >&2
    exit 0
fi

mode=600
if [[ -e $settings ]]; then
    if ! jq -e 'type == "object"' "$settings" >/dev/null 2>&1; then
        printf 'pi theme: %s is not a JSON object; leaving it untouched\n' "$settings" >&2
        exit 0
    fi
    # Any explicit value belongs to the user/runtime, including null. Do not
    # rewrite an existing choice, even when it names a theme other than ours.
    if jq -e 'has("theme")' "$settings" >/dev/null; then
        exit 0
    fi
    mode="$(stat -c '%a' "$settings")"
fi

mkdir -p "$(dirname "$settings")"
tmp="$(mktemp "$settings.XXXXXX")"
trap 'rm -f "$tmp"' EXIT

if [[ -f $settings ]]; then
    jq '. + {theme: "aytordev"}' "$settings" >"$tmp"
else
    printf '{"theme":"aytordev"}\n' >"$tmp"
fi
chmod "$mode" "$tmp"
mv "$tmp" "$settings"
