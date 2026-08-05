#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
UPSTREAM_REPOSITORY="https://github.com/SlimeVR/SlimeVR-Server.git"
UPSTREAM_COMMIT="${UPSTREAM_COMMIT:-d7205bb2940de9c3c75921db19f5b9bc2b0bd9d9}"
WORK_ROOT="$ROOT_DIR/work"
WORK_DIR="${WORK_DIR:-$WORK_ROOT/SlimeVR-Server}"
PATCH_ARCHIVE="$ROOT_DIR/patches/ratioslime.patch.gz.b64"
PATCH_FILE="$WORK_ROOT/ratioslime.patch"
PATCH_V2_B64="$WORK_ROOT/ratioslime-v2.patch.gz.b64"
PATCH_V2_GZ="$WORK_ROOT/ratioslime-v2.patch.gz"
PATCH_V2_FILE="$WORK_ROOT/ratioslime-v2.patch"
PATCH_V2_B64_SHA256="8ad3ca82100a224c41f9b49823eac852dc8adb7e1767d93e0dd4778335d94494"
PATCH_V2_GZ_SHA256="0e1cb62eddce116c7de5c1aeaf0c95274c46ca2c1f28ddcd8106aa134ba5019d"
DIST_DIR="$ROOT_DIR/dist"

require_command() {
  command -v "$1" >/dev/null 2>&1 || {
    echo "Missing required command: $1" >&2
    exit 1
  }
}

for command_name in git java node python3 base64 gzip sha256sum; do
  require_command "$command_name"
done

if [[ -z "${ANDROID_HOME:-${ANDROID_SDK_ROOT:-}}" ]]; then
  echo "ANDROID_HOME or ANDROID_SDK_ROOT must point to an Android SDK." >&2
  exit 1
fi

if [[ ! -f "$PATCH_ARCHIVE" ]]; then
  echo "Patch archive not found: $PATCH_ARCHIVE" >&2
  exit 1
fi

shopt -s nullglob
PATCH_V2_PARTS=("$ROOT_DIR"/patches/ratioslime-v2.part*)
shopt -u nullglob
if (( ${#PATCH_V2_PARTS[@]} == 0 )); then
  echo "Feature patch parts were not found." >&2
  exit 1
fi

mkdir -p "$WORK_ROOT" "$(dirname "$WORK_DIR")" "$DIST_DIR"
base64 --decode "$PATCH_ARCHIVE" | gzip --decompress > "$PATCH_FILE"
cat "${PATCH_V2_PARTS[@]}" | tr -d '[:space:]' > "$PATCH_V2_B64"
printf '%s  %s\n' "$PATCH_V2_B64_SHA256" "$PATCH_V2_B64" | sha256sum --check --strict -
base64 --decode "$PATCH_V2_B64" > "$PATCH_V2_GZ"
printf '%s  %s\n' "$PATCH_V2_GZ_SHA256" "$PATCH_V2_GZ" | sha256sum --check --strict -
gzip --test "$PATCH_V2_GZ"
gzip --decompress --stdout "$PATCH_V2_GZ" > "$PATCH_V2_FILE"

if [[ ! -d "$WORK_DIR/.git" ]]; then
  rm -rf "$WORK_DIR"
  git clone --filter=blob:none --no-checkout "$UPSTREAM_REPOSITORY" "$WORK_DIR"
fi

git -C "$WORK_DIR" fetch --depth 1 origin "$UPSTREAM_COMMIT"
git -C "$WORK_DIR" checkout --force "$UPSTREAM_COMMIT"
git -C "$WORK_DIR" reset --hard "$UPSTREAM_COMMIT"
git -C "$WORK_DIR" clean -ffdqx
git -C "$WORK_DIR" submodule sync --recursive
git -C "$WORK_DIR" submodule update --init --recursive

git -C "$WORK_DIR" apply --check "$PATCH_FILE"
git -C "$WORK_DIR" apply "$PATCH_FILE"
git -C "$WORK_DIR" apply --check "$PATCH_V2_FILE"
git -C "$WORK_DIR" apply "$PATCH_V2_FILE"

python3 "$WORK_DIR/scripts/ratio-math-smoke-test.py"

corepack enable
(
  cd "$WORK_DIR"
  pnpm install --no-frozen-lockfile
  cd gui
  pnpm run build
)

(
  cd "$WORK_DIR"
  chmod +x gradlew
  ./gradlew :server:android:assembleDebug --build-cache
)

APK_PATH="$(find "$WORK_DIR/server/android/build/outputs/apk/debug" -maxdepth 1 -type f -name '*.apk' | head -n 1)"
if [[ -z "$APK_PATH" ]]; then
  echo "Gradle finished but no APK was found." >&2
  exit 1
fi

cp "$APK_PATH" "$DIST_DIR/RatioSlime-debug.apk"
echo "APK: $DIST_DIR/RatioSlime-debug.apk"
