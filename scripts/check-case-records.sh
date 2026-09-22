#!/usr/bin/env bash
set -euo pipefail
# shellcheck source-path=SCRIPTDIR

repo_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
cd -- "$repo_root"
# shellcheck source=scripts/lib/common.sh
source "$repo_root/scripts/lib/common.sh"
require_tools rg find sort

active_case=""
if [[ -e cases/active-case ]]; then
    [[ -s cases/active-case ]] || {
        echo "cases/active-case is empty" >&2
        exit 1
    }
    IFS= read -r active_case < cases/active-case
    [[ "$active_case" =~ ^[a-z0-9][a-z0-9-]*$ ]] || {
        echo "Invalid active-case pointer" >&2
        exit 1
    }
    [[ -d "cases/$active_case" ]] || {
        echo "Active case directory is missing" >&2
        exit 1
    }
fi

case_directories="$(find cases -mindepth 1 -maxdepth 1 -type d -print | LC_ALL=C sort)" || \
    die "Case directory enumeration failed"
checked=0
while IFS= read -r case_dir; do
    [[ -n "$case_dir" ]] || continue
    case_id="${case_dir##*/}"
    [[ "$case_id" =~ ^[a-z0-9][a-z0-9-]*$ ]] || {
        echo "Invalid case directory: $case_dir" >&2
        exit 1
    }
    for name in case.env case.md claims.md qualification.md report.md public-comment.md; do
        [[ -f "$case_dir/$name" ]] || {
            echo "Missing $case_dir/$name" >&2
            exit 1
        }
    done
    rg -Fxq "CASE_ID=$case_id" "$case_dir/case.env" || {
        echo "CASE_ID does not match $case_dir" >&2
        exit 1
    }
    if [[ "$case_id" == "$active_case" ]]; then
        reject_rg_matches "Active case contains unresolved values" \
            -n -F 'CHANGE''ME' "$case_dir"
        rg -Fxq 'CLAIM_REVIEW_STATUS=PASS' "$case_dir/case.env" || {
            echo "Active case claim review is not PASS" >&2
            exit 1
        }
        rg -Fxq 'APK_QUALIFICATION_STATUS=PASS' "$case_dir/case.env" || {
            echo "Active case APK qualification is not PASS" >&2
            exit 1
        }
        reject_rg_matches "Active case still has a pending built-APK surface" \
            -q '=PENDING_APK_QUALIFICATION$' "$case_dir/case.env"
        echo "Active case record: $case_id (activation gates complete)"
    else
        echo "Inactive pending case checkpoint: $case_id"
    fi
    checked=$((checked + 1))
done <<< "$case_directories"

echo "Case record checks passed: $checked case directories; active=${active_case:-none}."
