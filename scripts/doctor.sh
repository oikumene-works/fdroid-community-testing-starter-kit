#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
cd -- "$repo_root"

required=(
    bash git curl jq rg sed sort sha256sum shellcheck bwrap timeout xmllint
    awk base64 cut date find gzip mktemp nohup paste pgrep seq setsid ss tail tar tr
)
android=(sdkmanager avdmanager emulator adb aapt apksigner zipalign)
remote=(gh glab)
blocked=0
warnings=0

check_tools() {
    local label="$1"
    shift
    local tool
    echo "$label"
    for tool in "$@"; do
        if command -v "$tool" >/dev/null 2>&1; then
            printf '  READY    %s\n' "$tool"
        else
            printf '  BLOCKED  %s is missing\n' "$tool"
            blocked=$((blocked + 1))
        fi
    done
}

check_path() {
    local label="$1"
    local path="$2"
    if [[ -e "$path" ]]; then
        printf '  READY    %s\n' "$label"
    else
        printf '  BLOCKED  %s is missing: %s\n' "$label" "$path"
        blocked=$((blocked + 1))
    fi
}

echo "READ-ONLY ENVIRONMENT DOCTOR"
echo "Legend: READY is usable, WARNING needs review, BLOCKED prevents the reference workflow."
check_tools "Host tools:" "${required[@]}"
check_tools "Android commands:" "${android[@]}"
check_tools "Remote-service clients:" "${remote[@]}"

config_file=".local/config/android.env"
if [[ -f "$config_file" ]]; then
    echo "  READY    local Android config is present"
else
    config_file="config/android.env.example"
    echo "  WARNING  local Android config is absent; component checks use the example defaults"
    warnings=$((warnings + 1))
fi
# The selected file is repository or operator-maintained configuration.
# shellcheck source=/dev/null
source "$config_file"

sdk_root="${ANDROID_SDK_ROOT:-${ANDROID_HOME:-}}"
if [[ -z "$sdk_root" ]] && command -v emulator >/dev/null 2>&1; then
    sdk_root="$(cd -- "$(dirname -- "$(command -v emulator)")/.." && pwd)"
fi
if [[ -z "$sdk_root" || ! -d "$sdk_root" ]]; then
    echo "  BLOCKED  Android SDK root could not be resolved"
    blocked=$((blocked + 1))
else
    echo "Exact SDK components:"
    check_path "platform-tools" "$sdk_root/platform-tools/adb"
    check_path "emulator package" "$sdk_root/emulator/emulator"
    check_path "Android ${EXPECTED_ANDROID_API} platform" \
        "$sdk_root/platforms/android-${EXPECTED_ANDROID_API}/android.jar"
    check_path "build tools ${ANDROID_BUILD_TOOLS_VERSION}" \
        "$sdk_root/build-tools/${ANDROID_BUILD_TOOLS_VERSION}/aapt"
    check_path "build-tools signer" \
        "$sdk_root/build-tools/${ANDROID_BUILD_TOOLS_VERSION}/apksigner"
    check_path "build-tools alignment checker" \
        "$sdk_root/build-tools/${ANDROID_BUILD_TOOLS_VERSION}/zipalign"
    image_path="$sdk_root/${AVD_IMAGE_PACKAGE//;/\/}"
    check_path "configured AOSP system image" "$image_path/package.xml"
fi

if [[ -r /dev/kvm && -w /dev/kvm ]]; then
    echo "  READY    KVM acceleration is available"
else
    echo "  BLOCKED  KVM access is required for the supported reference execution profile"
    blocked=$((blocked + 1))
fi
if [[ -n "${DISPLAY:-}${WAYLAND_DISPLAY:-}" ]]; then
    echo "  READY    graphical display is configured"
else
    echo "  BLOCKED  a graphical display is required for visible execution"
    blocked=$((blocked + 1))
fi

if remotes="$(git remote -v 2>/dev/null)"; then
    if [[ -n "$remotes" ]]; then
        echo "  WARNING  Git remote is configured; this is normal for a clone but authorizes nothing"
        warnings=$((warnings + 1))
    else
        echo "  READY    no Git remote is configured"
    fi
else
    echo "  BLOCKED  Git remote state is unknown (Git inspection failed)"
    blocked=$((blocked + 1))
fi

echo "This doctor did not use network access, download software, accept licenses, start ADB, or start an emulator."
if ((blocked)); then
    echo "DOCTOR_STATUS=BLOCKED ($blocked blockers, $warnings warnings)"
    exit 1
fi
if ((warnings)); then
    echo "DOCTOR_STATUS=WARNING ($warnings warnings)"
else
    echo "DOCTOR_STATUS=READY"
fi
