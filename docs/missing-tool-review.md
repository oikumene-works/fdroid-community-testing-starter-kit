# Missing-tool feedback: bounded local correction

## Current gate

Local implementation and reply preparation only. No new push, issue comment,
issue closure or MR reply is authorized by this correction task. Keep the
Battleship MR quiet; continue any later approved conversation in the repository
issues. The operator requested thanks for the fresh perspective and an explicit
lack of obligation to reciprocate the Battleship testing.

Canonical proposed reply: [missing-tool-reply.md](missing-tool-reply.md).
SHA-256 including final newline:
d541ead712cd8cfe5b7bbcb431b46b1fc45fd25942ba317d4f27d37ceffddc3e.
The same proposed body is retained in both repositories. Review exact text,
repository publication and the established account before posting it; verify
the linked public review notes after publishing the fixes and before commenting; the prior
Battleship publication approval does not cover these new issue comments.

## Source of the report

- [Starter-kit issue #1](https://github.com/oikumene-works/fdroid-community-testing-starter-kit/issues/1)
- [Adaptive-seed issue #1](https://github.com/oikumene-works/fdroid-community-testing-adaptive-seed/issues/1)
- Reporter @cocodedk describes Linux without ripgrep, running the starter-kit
  first exercise at 4575d121656a20420cf770bfb3c24b02cd757bff.
- The reporter did not claim to have run adaptive discovery. Its affected
  shared scripts were inspected here; Codex tested each repository separately.
- These local fixes start from starter-kit 0360408ebe7df7f430173c35e815c5909fa44e94.

Codex read the MR and issues, reproduced the reported behavior, implemented the
corrections, wrote the tests and documentation, and drafted the proposed reply.
The operator selected the scope and communication approach. No independent
human reproduction or reporter validation of the patch is yet recorded.

## Reproduction and interpretation

Codex used isolated local fixture repositories and a PATH with no ripgrep;
no host package was uninstalled. Original starter-kit scripts were read from
commit 4575d12. With an origin present, bootstrap returned 0 and reported no
remote; doctor reported no remote alongside its missing-tool blockers. The
standalone link check returned 0 even with a deliberately broken local link.
These reproduce the two principal errors without network or Android actions.

The doctor itself returned 1 with BLOCKED, matching its existing explicit exit.
The report's zero exit for that command was not reproduced. Do not describe this
as a fixed doctor-exit bug. The documentation now states the actual contract;
a precise invocation and immediately captured status could clarify a difference.

The other negative search guards were fragile, but the reporter did not reach
all of them. Tests now inject parser errors directly into each relevant guard;
this does not retroactively claim an observed end-to-end safety bypass.
Removing only `|| true` inside a process substitution would not reliably expose
the child search's exit status, so the link check captures and checks it directly.

## Changes

- Bootstrap and doctor inspect captured Git output without ripgrep; an inspection
  failure is unknown/nonzero, never "no remote". Missing ripgrep remains a doctor
  blocker for the later workflow, without preventing the entry diagnosis.
- The standalone link checker and both verification entry points check for their
  required search tool before processing, including when there are no cases.
- Negative repository/active-case searches accept only ripgrep's no-match status
  as absence; operational errors stop the check. A configured remote or failed
  inspection stops REQUIRE_NO_REMOTE before the rest of the suite.
- Link extraction and Markdown/case enumeration errors propagate. Valid links
  and link-free documents still pass; broken links fail.
- Guides separate entry dependencies, later prerequisites and exit contracts.
  No installation, permission, candidate, profile-growth or posting gate expands.

## Validation

The new offline suite exercises absent ripgrep with/without a remote; blocked
and failing Git inspections; all three standalone verification entries; optional
no-remote enforcement; valid/broken/link-free documents; extraction errors; each
negative repository scan; active pending-field and placeholder guards; and file
enumeration failures. The same shared suite is used in the adaptive repository.

Targeted cases passed: 24. The full check-all suite passed in both repositories; the final
documentation/draft update is checked again before the local commits. These are synthetic PATH/error-injection tests on this
Linux host, not a new operator trial, cross-platform validation or APK execution.
Fixtures are bounded under ignored .local and deleted by the tests. No browser,
Android session, download, external mutation or authentication change occurred.

## Retrospective and next step

The fresh report exposed a missing-dependency gap that successful checks on the
development host did not cover. Codex added behavior tests at the affected
entry points rather than relying on the installed environment. The operator
kept the conversation in the issues and requested that optional feedback not
become a perceived repayment obligation. No broad scanner rewrite, new framework
or general environment installation is included. Stop at checked local commits
and the exact reply draft; review publication separately in a fresh session.
