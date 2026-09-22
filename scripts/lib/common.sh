#!/usr/bin/env bash
# shellcheck disable=SC2034,SC2153

repo_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd)"

die() {
    echo "ERROR: $*" >&2
    exit 1
}

require_tools() {
    local tool
    for tool in "$@"; do
        command -v "$tool" >/dev/null 2>&1 || die "Missing required tool: $tool"
    done
}

# A negative search is a guard only if "no match" is distinguished from failure.
reject_rg_matches() {
    local message="$1"
    local search_status=0
    shift
    rg "$@" || search_status=$?
    case "$search_status" in
        0) die "$message" ;;
        1) return 0 ;;
        *) die "ripgrep search failed (exit $search_status); check did not complete" ;;
    esac
}

require_clean_repository_checkpoint() {
    local worktree_state

    require_tools git
    worktree_state="$(git status --porcelain=v1 --untracked-files=all)"
    if [[ -n "$worktree_state" ]]; then
        echo "Repository changes at an approval-dependent action boundary:" >&2
        printf '%s\n' "$worktree_state" >&2
        die "Commit the focused checkpoint and leave a clean worktree first"
    fi
    checkpoint_head="$(git rev-parse --verify HEAD)" || \
        die "A committed Git checkpoint is required before this action"
    checkpoint_remotes="$(git remote -v)"
    if [[ -n "$checkpoint_remotes" ]]; then
        checkpoint_remote_state=CONFIGURED
    else
        checkpoint_remote_state=NONE
    fi
}

require_value() {
    local name="$1"
    [[ -n "${!name:-}" ]] || die "Case configuration is missing: $name"
}

resolve_case() {
    local requested_case=""

    while (($#)); do
        case "$1" in
            --case)
                (($# >= 2)) || die "--case requires a case ID"
                requested_case="$2"
                shift 2
                ;;
            *) die "Unknown argument: $1" ;;
        esac
    done

    if [[ -z "$requested_case" ]]; then
        [[ -s "$repo_root/cases/active-case" ]] || die "No active case; use --case CASE_ID"
        IFS= read -r requested_case < "$repo_root/cases/active-case"
    fi

    [[ "$requested_case" =~ ^[a-z0-9][a-z0-9-]*$ ]] || die "Invalid case ID: $requested_case"
    case_id="$requested_case"
    case_dir="$repo_root/cases/$case_id"
    case_env="$case_dir/case.env"
    [[ -d "$case_dir" && -f "$case_env" ]] || die "Missing case: cases/$case_id"
}

load_case() {
    # case.env is trusted operator configuration, never copied third-party text.
    # shellcheck source=/dev/null
    source "$case_env"
    require_value CASE_ID
    [[ "$CASE_ID" == "$case_id" ]] || die "CASE_ID does not match cases/$case_id"
}

require_real_case() {
    [[ "${EXAMPLE_ONLY:-false}" == "false" ]] || die "Fictional examples cannot perform this action"
}

csv_lines() {
    tr ',' '\n' <<<"$1" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' -e '/^$/d'
}

permission_lines() {
    if [[ "$1" != "NONE" && "$1" != "PENDING_APK_QUALIFICATION" ]]; then
        csv_lines "$1"
    fi
}

verify_digest_bound_file() {
    local filename="$1"
    local expected="$2"
    local label="$3"
    local path actual
    [[ "$filename" =~ ^[A-Za-z0-9._-]+$ ]] || die "Invalid $label filename"
    path="$case_dir/$filename"
    [[ -f "$path" ]] || die "Missing $label: $path"
    actual="$(sha256sum "$path" | cut -d' ' -f1)"
    [[ "$actual" == "$expected" ]] || die "$label digest changed: $actual"
}

require_claim_gate() {
    require_tools sha256sum
    for name in CLAIM_REVIEW_FILE EXPECTED_CLAIM_REVIEW_SHA256 CLAIM_REVIEW_STATUS; do
        require_value "$name"
    done
    [[ "$CLAIM_REVIEW_STATUS" == "PASS" ]] || \
        die "Public-claim review is not PASS: $CLAIM_REVIEW_STATUS"
    verify_digest_bound_file "$CLAIM_REVIEW_FILE" "$EXPECTED_CLAIM_REVIEW_SHA256" \
        "public claim review"
}

require_qualification_gate() {
    require_tools sha256sum
    for name in APK_QUALIFICATION_FILE EXPECTED_APK_QUALIFICATION_SHA256 \
        APK_QUALIFICATION_STATUS; do
        require_value "$name"
    done
    [[ "$APK_QUALIFICATION_STATUS" == "PASS" ]] || \
        die "APK qualification is not PASS: $APK_QUALIFICATION_STATUS"
    for name in EXPECTED_APK_PERMISSIONS EXPECTED_APK_FEATURES \
        EXPECTED_APK_NATIVE_CODE EXPECTED_APK_MANIFEST_XMLTREE_SHA256; do
        require_value "$name"
        [[ "${!name}" != "PENDING_APK_QUALIFICATION" ]] || \
            die "APK qualification is not reconciled: $name"
    done
    verify_digest_bound_file "$APK_QUALIFICATION_FILE" \
        "$EXPECTED_APK_QUALIFICATION_SHA256" "APK qualification"
}

require_approval_token() {
    local action="$1"
    local supplied="${2:-}"
    local expected="${action}:${CASE_ID}"
    [[ "$supplied" == "$expected" ]] || \
        die "Explicit approval token required: --approval '$expected'"
}
