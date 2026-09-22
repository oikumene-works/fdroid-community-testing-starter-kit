# Troubleshooting

## `doctor.sh` reports a missing SDK tool

Install the Android command-line tools explicitly and put `sdkmanager`,
`avdmanager`, `emulator`, `adb`, `aapt`, `apksigner`, and `zipalign` on `PATH`,
or set `ANDROID_SDK_ROOT`. Review SDK licenses yourself.

`BLOCKED` means the supported reference workflow cannot proceed. `WARNING`
means review is needed but the doctor found no hard blocker. The doctor checks
the configured platform, build-tools version, system image, KVM, and display;
command availability alone is insufficient.

## A check reports a missing or failed ripgrep

The bootstrap and doctor's Git-remote inspection do not require ripgrep. They
can report the existing remote while the doctor separately reports `rg` missing
for later verification. `check-all.sh`, `check-case-records.sh` and the standalone
link check require `rg` before any success is reported. Stop at that prerequisite
and choose any installation separately; the scripts do not install it for you.

A search with no matches is a normal result; a search error is not. Failed link
extraction or enumeration and failed negative guard searches return nonzero.
Keep the first error rather than treating empty output as a successful check.
For entry-command exit statuses, see [Start here](start-here.md).

## KVM is unavailable

Confirm virtualization is enabled, `/dev/kvm` exists, and the current user has
the required group access. Software rendering is outside the supported
reference execution profile; do not silently continue with another environment.

## The AVD helper refuses to create an image

The configured system image must already exist. Check
`.local/config/android.env`, install that exact image explicitly, and rerun the
read-only doctor before creating the AVD.

## An emulator or port is already in use

Stop. Do not reuse an unknown device or choose a random serial. Inspect the
configured ports and unrelated emulator processes read-only, then resolve the
conflict before requesting a new execution window.

## A claim or pin changed

Close the gate and repeat exact preflight. Do not edit a digest or status merely
to make a guard pass. A changed head needs a new claim review and qualification.

## An inactive case contains unresolved values

That is permitted at a selection or source-preflight checkpoint. Keep it out of
`cases/active-case`; `check-all.sh` should label it `Inactive pending`. Replace
values only from exact public sources. Activation must reject every unresolved
field and every `PENDING_APK_QUALIFICATION` built-surface value.

## An action says the repository is not clean

Qualification, execution download, emulator start, activation, and posting need
a committed clean HEAD. Review `git status --short`, run `check-all.sh`, and
commit only the focused durable records. Do not hide changes or delete evidence
just to satisfy the guard. A normal clone `origin` is accepted but never
authorizes a push or post.

## An approval token was rejected

Tokens such as `qualify-apk:CASE_ID` prevent accidental command execution. They
do not record or replace human authorization. Verify the requested case and
action, obtain a fresh exact approval if required, and pass the displayed token
verbatim. Never reuse one action's token for another gate.

## `gh` or `glab` authentication fails

Use the client's normal interactive authentication, verify the selected account
read-only, and keep tokens out of tracked files, command arguments, reports, and
chat. Authentication is capability, not approval. Re-run the exact live recheck
after restoring access because provider state may have changed.

## The live recheck fails

Do not download, start Android tooling, or post. Read the first mismatch, update
the inactive case only after a new exact source/claim review, and repeat any
qualification invalidated by changed candidate bytes or built surface.

## Posting returned an error or omitted `web_url`

Do not retry. A successful response is accepted without `web_url`; the helper
derives the stable URL from the returned note ID. On an ambiguous response it
stores `.local/runtime/CASE_ID-posting-ambiguity.json`. Keep that receipt and
run `./scripts/recover-posted-comment.sh --case CASE_ID`; recovery is read-only
and succeeds only for exactly one matching body by the approved account.

## A custom GitLab reply request fails

First distinguish an authentication failure from an invalid request or a lost
response. A successful read-only account lookup verifies the current identity;
it does not prove write permissions. Retain the returned HTTP status and error
before deciding whether credentials, scopes or the request need changing.
Recommend an authentication change only when the observed failure supports it.
Never include credentials or authorization headers in diagnostics.

For a separately approved follow-up reply, keep its canonical body, digest and
receipt distinct from the original report; do not clear a posted-note receipt
to reuse the original posting helper. Use the same clean-checkpoint, exact-text,
account and duplicate checks. Save response/error output in restricted ignored
local files before parsing it, bound the request time, and preserve an attempt
marker if interrupted. A timeout does not prove the server rejected a write.
Read all note pages and verify the exact body and author before deciding what
happened; never automatically repeat an ambiguous POST. Record the verified
receipt, then remove the temporary diagnostics during closeout.

Codex reproduced a request-construction pitfall in glab 1.107.0 using a local
HTTP receiver and a dummy token: `--input` passed JSON bytes without setting
Content-Type. For JSON input, set `--header 'Content-Type: application/json'`
explicitly. The corrected request supplied the header and the subsequently
approved GitLab reply succeeded. The first reply attempt's lost response means
its original failure cause remains unproven; this was not evidence of a GitLab
outage or an authentication defect. See the versioned
[request implementation](https://gitlab.com/gitlab-org/cli/-/blob/v1.107.0/internal/commands/api/http.go).

## Cleanup failed

Do not continue testing or delete broad directories. Record the exact local
state, verify the one emulator target again, and perform only the separately
authorized recovery or cleanup operation.

## `check-all.sh` fails

Fix the reported shell, documentation, executable-bit, secret-pattern, link,
or guard-test issue. The check is offline and must not be bypassed for
publication.

The suite may create and remove bounded ignored-local fixtures. A leftover
fixture is a failure; the suite is externally read-only, not a promise of zero
temporary local writes.
