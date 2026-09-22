# Start here — Guarded starter kit

This is an experimental, repository-based workflow for independent community
testing, with scripts, checklists and examples. It is not an F-Droid service or
an unattended test runner. The work has been developed and exercised with Codex;
an operator selects the goal, reviews findings and authorizes effects. Reports
must identify who actually supplied inputs, interpreted evidence and wrote them.
Human usability or broad effectiveness has not been established by agent runs.

## First useful outcome: understand your next step

Use your own clone in a separate working directory. Installing software or
accepting licenses is not part of this first exercise. Git and Bash are needed
for these entry commands; if unavailable, read the files on GitHub first.

```sh
git clone https://github.com/oikumene-works/fdroid-community-testing-starter-kit.git
cd fdroid-community-testing-starter-kit
./scripts/session-bootstrap.sh
./scripts/doctor.sh
```

These entry commands inspect local state; they do not download an APK, start
Android or publish anything. Read the root instructions and printed handoff.
The kit checks a documented reference environment and reports READY, WARNING
or BLOCKED. Review the named prerequisites; a missing tool is not permission
to install it. It does not choose or adapt a new platform automatically.

If working with a repository-aware agent, this is a sufficient first request:

> Read the project instructions and start with the read-only entry procedure.
> Explain what is available, what is missing or unsupported, and one bounded
> next step. Do not install tools, change configuration, download a candidate,
> start Android or publish anything. Stop after that explanation.

You are done with the first exercise when you can identify the proposed next
step, its effects and what would make it complete. A truthful blocker is a
useful result. Historical reports/case records describe their original runs;
a fresh clone does not inherit that machine's setup, approvals or active case.
Do not resume a distributed historical case as if its pins were still current.

## Before a real app

The implemented execution lane requires Linux, GNU tools, Bubblewrap, the
Android SDK, usable KVM and a graphical display. It uses a disposable AOSP
Android 14/API 34 x86_64 emulator. See [environment setup](environment-setup.md)
for tools, SDK packages and CLI authentication, and [platform limits](platform-limits.md)
for exclusions. macOS/Windows and WSL Android execution are not verified lanes.
GitHub upstream and GitLab MR access are implemented; network-capable apps,
sensitive permissions, personal data/accounts and special hardware are excluded.
No external-service login is needed just to read this guide or inspect the host.

When you choose to continue, follow the [first-case runbook](first-case-runbook.md)
from the beginning. It supplies the authoritative commands, field sources and
gates; this page is only the entrance. Local setup and the fictional offline
exercise come before a real candidate. The fictional example cannot be run as
an Android case. Passing local checks does not prove an app works.

This kit stops before APK download or execution when a material public-claim
contradiction remains unresolved. Do not change the status just to make a test
run. The [protocol](protocol.md) defines this decision; it is independent of
how convenient environment preparation feels.

Keep source review, APK qualification, runtime, cleanup and publication distinct.
Plan time to finish cleanup before starting an executable slice. APKs and raw
UI/log evidence are temporary; [evidence policy](evidence-policy.md) explains
what is retained and why later independent re-audit can be limited.
A report review or successful test does not authorize posting it.

## Questions and improvements

Read [troubleshooting](troubleshooting.md) and the linked runbook section first.
If something remains unclear, a useful question identifies the repository and
commit, intended step, host OS, command and a short sanitized error excerpt.
Do not attach tokens, private paths, APKs, complete raw logs or personal data.
A question does not commit you to evaluating this workflow or joining research.

Our aim is to answer reusable questions by improving the relevant existing guide
and replying with a short link to the updated section. Direct help may be needed
for private details, urgent recovery or an individual environment issue; general
lessons can then go into the guide. This keeps useful answers available to the
next person. Documentation/publication changes retain their own review and
approval boundaries. No guaranteed response time or support service is promised.
