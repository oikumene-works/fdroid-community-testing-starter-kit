#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
test_root="$(mktemp -d)"
trap 'rm -rf -- "$test_root"' EXIT
fixture="$test_root/repo"
mkdir -p "$fixture/scripts" "$fixture/templates" "$fixture/cases"
mkdir -p "$fixture/scripts/lib"
cp "$repo_root/scripts/lib/common.sh" "$fixture/scripts/lib/"
cp "$repo_root/scripts/create-case.sh" "$repo_root/scripts/check-case-records.sh" \
    "$fixture/scripts/"
cp "$repo_root/templates/"* "$fixture/templates/"
chmod +x "$fixture/scripts/"*.sh

"$fixture/scripts/create-case.sh" pending-app-12345 >/dev/null
output="$("$fixture/scripts/check-case-records.sh")"
rg -Fq 'Inactive pending case checkpoint: pending-app-12345' <<<"$output"
printf '%s\n' pending-app-12345 >"$fixture/cases/active-case"
if "$fixture/scripts/check-case-records.sh" >/dev/null 2>&1; then
    echo "Unresolved inactive case unexpectedly passed as active" >&2
    exit 1
fi

echo "Inactive pending checkpoint and active-case denial tests passed: 2"
