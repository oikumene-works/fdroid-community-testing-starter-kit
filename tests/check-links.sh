#!/usr/bin/env bash
set -euo pipefail
# shellcheck source-path=SCRIPTDIR

repo_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
cd -- "$repo_root"
# shellcheck source=scripts/lib/common.sh
source "$repo_root/scripts/lib/common.sh"
require_tools rg find dirname

documents="$(find . -path './.git' -prune -o -path './.local' -prune -o \
    -type f -name '*.md' -print)" || die "Markdown enumeration failed"
failed=false
while IFS= read -r document; do
    [[ -n "$document" ]] || continue
    if links="$(rg -o '\]\([^ )#]+(?:#[^ )]+)?\)' "$document")"; then
        :
    else
        search_status=$?
        [[ "$search_status" == 1 ]] || \
            die "Link extraction failed for $document (ripgrep exit $search_status)"
    fi
    while IFS= read -r raw; do
        [[ -n "$raw" ]] || continue
        target="${raw#](}"
        target="${target%)}"
        target="${target%%#*}"
        case "$target" in
            "" | http://* | https://* | mailto:*) continue ;;
        esac
        if [[ ! -e "$(dirname -- "$document")/$target" ]]; then
            echo "Broken local link: $document -> $target" >&2
            failed=true
        fi
    done <<< "$links"
done <<< "$documents"
$failed && exit 1
echo "Local Markdown links passed."
