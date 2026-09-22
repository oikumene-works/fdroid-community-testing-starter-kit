#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
mkdir -p -- "$repo_root/.local/runtime"
test_root="$(mktemp -d "$repo_root/.local/runtime/missing-tool-test.XXXXXX")"
cleanup() {
    [[ "$test_root" == "$repo_root"/.local/runtime/missing-tool-test.* ]] || exit 1
    rm -rf -- "$test_root"
}
trap cleanup EXIT
fixture="$test_root/repo"
no_rg="$test_root/no-rg"
with_rg="$test_root/with-rg"
error_bin="$test_root/error-bin"
passed=0
output=""

run_status() {
    local expected="$1" actual=0
    shift
    output="$("$@" 2>&1)" || actual=$?
    [[ "$actual" == "$expected" ]] || {
        printf 'Expected exit %s, got %s: %s\n%s\n' "$expected" "$actual" "$*" "$output" >&2
        exit 1
    }
    passed=$((passed + 1))
}
contains() {
    [[ "$output" == *"$1"* ]] || {
        printf 'Missing expected output: %s\n%s\n' "$1" "$output" >&2
        exit 1
    }
}
excludes() {
    [[ "$output" != *"$1"* ]] || {
        printf 'Unexpected output: %s\n%s\n' "$1" "$output" >&2
        exit 1
    }
}

mkdir -p "$fixture/scripts/lib" "$fixture/tests" "$fixture/docs" \
    "$fixture/config" "$fixture/cases" "$fixture/templates" "$no_rg" "$with_rg" "$error_bin"
cp "$repo_root/scripts/lib/common.sh" "$fixture/scripts/lib/"
for script in session-bootstrap.sh doctor.sh check-all.sh check-case-records.sh; do
    cp "$repo_root/scripts/$script" "$fixture/scripts/"
done
cp "$repo_root/tests/check-links.sh" "$fixture/tests/"
cp "$repo_root/config/android.env.example" "$fixture/config/"
if [[ -f "$repo_root/seed" ]]; then cp "$repo_root/seed" "$fixture/seed"; fi
printf '%s\n' 'Synthetic handoff.' >"$fixture/docs/next-session.md"
printf '%s\n' 'Synthetic instructions.' >"$fixture/AGENTS.md"
printf '%s\n' 'No links in this document.' >"$fixture/README.md"
git -C "$fixture" init -q
git -C "$fixture" remote add origin https://example.invalid/test.git

# This is a genuinely missing command, not just a stub returning an error.
for tool in bash git dirname cat sed find sort awk shellcheck; do
    ln -s "$(command -v "$tool")" "$no_rg/$tool"
done
cp -a "$no_rg/." "$with_rg/"
real_rg="$(command -v rg)"
ln -s "$real_rg" "$with_rg/rg"

run_status 0 env PATH="$no_rg" "$fixture/scripts/session-bootstrap.sh"
contains 'Git remote: configured'
excludes 'Git remote: none'
run_status 1 env PATH="$no_rg" ANDROID_SDK_ROOT="$test_root/no-sdk" "$fixture/scripts/doctor.sh"
contains 'rg is missing'
contains 'WARNING  Git remote is configured'
contains 'DOCTOR_STATUS=BLOCKED'
excludes 'READY    no Git remote is configured'
# The same missing-tool host must still distinguish a genuinely absent remote.
git -C "$fixture" remote remove origin
run_status 0 env PATH="$no_rg" "$fixture/scripts/session-bootstrap.sh"
contains 'Git remote: none'
run_status 1 env PATH="$no_rg" ANDROID_SDK_ROOT="$test_root/no-sdk" "$fixture/scripts/doctor.sh"
contains 'READY    no Git remote is configured'
git -C "$fixture" remote add origin https://example.invalid/test.git

for script in tests/check-links.sh scripts/check-case-records.sh scripts/check-all.sh; do
    run_status 1 env PATH="$no_rg" "$fixture/$script"
    contains 'Missing required tool: rg'
    excludes 'checks passed'
    excludes 'links passed'
done
run_status 1 env PATH="$no_rg" REQUIRE_NO_REMOTE=1 "$fixture/scripts/check-all.sh"
contains 'Missing required tool: rg'
run_status 1 env PATH="$with_rg" REQUIRE_NO_REMOTE=1 "$fixture/scripts/check-all.sh"
contains 'A Git remote is configured but REQUIRE_NO_REMOTE=1.'

# No matches is legitimate; a missing target or failed parser is not.
run_status 0 env PATH="$with_rg" "$fixture/tests/check-links.sh"
contains 'Local Markdown links passed.'
printf '%s\n' '[missing](missing.md)' >"$fixture/README.md"
run_status 1 env PATH="$with_rg" "$fixture/tests/check-links.sh"
contains 'Broken local link:'
excludes 'Local Markdown links passed.'
printf '%s\n' 'Synthetic target.' >"$fixture/missing.md"
run_status 0 env PATH="$with_rg" "$fixture/tests/check-links.sh"
contains 'Local Markdown links passed.'

cp -a "$with_rg/." "$error_bin/"
rm "$error_bin/rg"
cat >"$error_bin/rg" <<'STUB'
#!/usr/bin/env bash
if [[ "${RG_ERROR_CONTAINS:-all}" == all || "$*" == *"$RG_ERROR_CONTAINS"* ]]; then
    echo 'Synthetic ripgrep failure' >&2
    exit 2
fi
exec "$REAL_RG" "$@"
STUB
chmod +x "$error_bin/rg"
run_status 1 env PATH="$error_bin" "$fixture/tests/check-links.sh"
contains 'Link extraction failed'
contains 'ripgrep exit 2'
excludes 'Local Markdown links passed.'
# Exercise each negative repository scan through check-all's real entry point.
for pattern in 'CHANGE''ME' 'Users' 'AKIA'; do
    run_status 1 env PATH="$error_bin" REAL_RG="$real_rg" RG_ERROR_CONTAINS="$pattern" \
        "$fixture/scripts/check-all.sh"
    contains 'ripgrep search failed (exit 2)'
    excludes 'Offline repository and guard checks passed.'
done

mkdir -p "$fixture/cases/test-case"
printf '%s\n' test-case >"$fixture/cases/active-case"
cat >"$fixture/cases/test-case/case.env" <<'CASE'
CASE_ID=test-case
CLAIM_REVIEW_STATUS=PASS
TEST_SAFETY_STATUS=PASS
APK_QUALIFICATION_STATUS=PASS
EXPECTED_APK_PERMISSIONS=PENDING_APK_QUALIFICATION
CASE
for file in case.md claims.md qualification.md report.md public-comment.md; do
    printf '%s\n' 'Synthetic record.' >"$fixture/cases/test-case/$file"
done
run_status 1 env PATH="$with_rg" "$fixture/scripts/check-case-records.sh"
contains 'Active case still has a pending built-APK surface'
for pattern in 'CHANGE''ME' '=PENDING_APK_QUALIFICATION$'; do
    run_status 1 env PATH="$error_bin" REAL_RG="$real_rg" RG_ERROR_CONTAINS="$pattern" \
        "$fixture/scripts/check-case-records.sh"
    contains 'ripgrep search failed (exit 2)'
    excludes 'Active case record:'
done

# Git inspection failure must not be represented as "no remote".
broken_git="$test_root/broken-git"
mkdir -p "$broken_git"
cp -a "$with_rg/." "$broken_git/"
rm "$broken_git/git"
printf '%s\n' '#!/usr/bin/env bash' 'exit 2' >"$broken_git/git"
chmod +x "$broken_git/git"
run_status 1 env PATH="$broken_git" "$fixture/scripts/session-bootstrap.sh"
contains 'Git remote: unknown'
excludes 'Git remote: none'
run_status 1 env PATH="$broken_git" ANDROID_SDK_ROOT="$test_root/no-sdk" "$fixture/scripts/doctor.sh"
contains 'Git remote state is unknown'
excludes 'READY    no Git remote is configured'
run_status 1 env PATH="$broken_git" REQUIRE_NO_REMOTE=1 "$fixture/scripts/check-all.sh"
contains 'Git remote state is unknown'

# Enumeration failure must not silently validate an empty set of records/links.
broken_find="$test_root/broken-find"
mkdir -p "$broken_find"
cp -a "$with_rg/." "$broken_find/"
rm "$broken_find/find"
printf '%s\n' '#!/usr/bin/env bash' 'exit 2' >"$broken_find/find"
chmod +x "$broken_find/find"
run_status 1 env PATH="$broken_find" "$fixture/tests/check-links.sh"
contains 'Markdown enumeration failed'
run_status 1 env PATH="$broken_find" "$fixture/scripts/check-case-records.sh"
contains 'Case directory enumeration failed'

# Adaptive discovery remains usable without the later verification dependencies.
if [[ -f "$fixture/seed" ]]; then
    run_status 0 env PATH="$no_rg" "$fixture/seed" grow
    contains 'ADAPTIVE SEED DISCOVERY'
    contains 'PROPOSED_STEP='
fi
[[ ! -e "$fixture/.local" ]] || {
    echo 'Read-only entry/check fixtures unexpectedly created local state' >&2
    exit 1
}
echo "Missing-tool and failed-inspection checks passed: $passed (no network or Android action)."
