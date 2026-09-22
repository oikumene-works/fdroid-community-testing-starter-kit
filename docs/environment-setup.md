# Environment Setup

## Host

Use a dedicated Linux user or otherwise isolated working directory. The
workflow expects Bash, Git, Bubblewrap, curl, jq, ripgrep, XML tools, ShellCheck, Android
SDK command-line tools, GitHub CLI, and GitLab CLI. Usable KVM acceleration and
a graphical display are required by the supported reference execution profile.

Run `./scripts/doctor.sh` first. It is read-only and reports missing tools, SDK
components, KVM access, display state, and Git remote state as `READY`,
`WARNING`, or `BLOCKED`. A normal clone remote is only a warning and authorizes
nothing. The doctor does not use the network, download, accept licenses, start
ADB, or start an emulator.

## Android SDK

Install Android Studio or the official command-line tools yourself. Review the
package list and license text before explicitly using `sdkmanager`; this kit
does not hide SDK downloads or license acceptance.

The default configuration expects:

- platform tools;
- emulator;
- Android 34 platform;
- build tools 36.0.0; and
- AOSP `system-images;android-34;default;x86_64`.

Set `ANDROID_SDK_ROOT` when the SDK is not discoverable through `sdkmanager`,
`adb`, or `emulator` on `PATH`.

## Local workspace

`./scripts/init-workspace.sh` creates ignored `.local/` directories and copies
`config/android.env.example` to `.local/config/android.env` without
overwriting an existing file. Review the copied configuration before use.

`./scripts/create-disposable-avd.sh` creates static AVD state below `.local/`.
It refuses to download a missing system image and does not invoke ADB or boot
the emulator.

## Authentication

Read-only preflight uses `gh` and `glab`. Authenticate them using their normal
interactive setup, then verify the selected accounts. Do not put access tokens
in case files, shell history, reports, or tracked configuration.

The posting helper independently verifies the configured GitLab username.
Authentication does not authorize a mutation.
