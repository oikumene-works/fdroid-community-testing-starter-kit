#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
cd -- "$repo_root"

echo "Guarded F-Droid community testing bootstrap"
bootstrap_status=0
if ! git status --short --branch 2>/dev/null; then
    echo "Git status: unavailable (Git is missing, failed, or this is not a worktree)"
    bootstrap_status=1
fi
if remotes="$(git remote -v 2>/dev/null)"; then
    if [[ -n "$remotes" ]]; then
        echo "Git remote: configured; no external action is implied"
    else
        echo "Git remote: none"
    fi
else
    echo "Git remote: unknown (Git inspection failed)" >&2
    bootstrap_status=1
fi
echo "This bootstrap did not start ADB or an emulator."

handoff="docs/next-session.md"
[[ -s "$handoff" ]] || {
    echo "Missing or empty next-session handoff: $handoff" >&2
    exit 1
}
echo
echo "--- Next Session ---"
cat -- "$handoff"

if [[ -s cases/active-case ]]; then
    IFS= read -r active_case < cases/active-case
    [[ "$active_case" =~ ^[a-z0-9][a-z0-9-]*$ ]] || {
        echo "Invalid active-case pointer" >&2
        exit 1
    }
    echo "Active case: $active_case"
    sed -n '1,120p' "cases/$active_case/case.md"
else
    echo "Active case: none"
fi

echo "Read AGENTS.md, docs/next-session.md, docs/session-continuity.md,"
echo "docs/protocol.md, and the complete active case records before acting."

exit "$bootstrap_status"
