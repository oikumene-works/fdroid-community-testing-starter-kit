# Guarded F-Droid Community Testing Starter Kit

This repository is a reusable Linux-host workflow for independent community
testing of third-party F-Droid new-app merge requests. It separates public
claim review, exact source preflight, built-APK qualification, disposable
emulator execution, report review, and public posting.

This is not an F-Droid project. A local result is community evidence only, not
an F-Droid review, acceptance decision, security audit, or endorsement.

**New here?** [Start with one read-only exercise](docs/start-here.md), including
prerequisites, scope limits and where to ask useful questions. This is experimental.

## Reference setup after the first exercise

The supported reference environment is a Linux host with Bubblewrap, an Android
SDK, a visible Android emulator, and usable KVM acceleration.

```sh
./scripts/session-bootstrap.sh
./scripts/doctor.sh
./scripts/init-workspace.sh
./scripts/check-all.sh
./scripts/fictional-dry-run.sh
```

Install the Android command-line tools through your distribution or Android
Studio. Review the requested packages before running an explicit SDK command:

```sh
sdkmanager "platform-tools" "emulator" \
  "platforms;android-34" "build-tools;36.0.0" \
  "system-images;android-34;default;x86_64"
sdkmanager --licenses
```

The kit never accepts SDK licenses or downloads SDK components for you. The
doctor reports `READY`, `WARNING`, or `BLOCKED` and verifies the configured SDK
packages, KVM, and display. After reviewing `.local/config/android.env`, you may
separately create the project-local AVD:

```sh
./scripts/create-disposable-avd.sh
```

Creating the AVD does not start it or invoke ADB. Environment readiness never
authorizes downloading or running a candidate.

## Learn the workflow

Follow the [first real case runbook](docs/first-case-runbook.md). It labels each
command by effect, gives field-by-field sources and success markers, and links
the [protocol](docs/protocol.md), [session procedure](docs/session-continuity.md),
and [fictional walkthrough](examples/fictional/README.md). The example cannot be
activated, downloaded, executed, or posted.

Create a real case with every executable and external gate closed:

```sh
./scripts/create-case.sh my-app-12345
```

An unfinished inactive case is a valid hygiene-checked checkpoint. Fill it from
exact public state, audit claims, perform the separately approved APK
qualification, and activate it only after every preflight part passes. Approval
strings accepted by scripts are safeguards against accidental execution; they
do not create human authorization.

## Safety boundaries

- Never use a physical device or an emulator shared with another project.
- Prefer candidates without `INTERNET` or sensitive permissions.
- Use synthetic inputs and retain only minimal sanitized facts.
- Keep executable actions, external uploads, and public mutations separately
  approved.
- Stop on any pinned-state change, target ambiguity, unexpected permission, or
  cleanup failure.

See the [threat model](docs/threat-model.md), [evidence policy](docs/evidence-policy.md),
and [platform limits](docs/platform-limits.md) before a real case.

## Included reports

The [Social Deduction Game report](reports/social-deduction-game-47820-bounded-functional-test.md)
documents a completed bounded functional test on a dedicated disposable
emulator. The [ScrubPony report](reports/scrubpony-46152-pre-installation-review-stop.md)
documents an APK-qualified pre-installation review stop; it is not a failed or
completed functional test. Each report states its own evidence class and limits.

## License

Original material in this repository is available under the Zero-Clause BSD
license (`0BSD`). Third-party apps, names, logos, source, binaries, and linked
documentation are not relicensed by this repository.
