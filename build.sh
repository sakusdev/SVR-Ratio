#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
UPSTREAM_REPOSITORY="https://github.com/SlimeVR/SlimeVR-Server.git"
UPSTREAM_COMMIT="${UPSTREAM_COMMIT:-d7205bb2940de9c3c75921db19f5b9bc2b0bd9d9}"
WORK_DIR="${WORK_DIR:-$ROOT_DIR/work/SlimeVR-Server}"
PATCH_FILE="$ROOT_DIR/patches/ratioslime.patch"
DIST_DIR="$ROOT_DIR/dist"

require_command() {
  command -v "$1" >/dev/null 2>&1 || {
    echo "Missing required command: $1" >&2
    exit 1
  }
}

require_command git
require_command java
require_command node
require_command python3

if [[ -z "${ANDROID_HOME:-${ANDROID_SDK_ROOT:-}}" ]]; then
  echo "ANDROID_HOME or ANDROID_SDK_ROOT must point to an Android SDK." >&2
  exit 1
fi

if [[ ! -f "$PATCH_FILE" ]]; then
  echo "Patch not found: $PATCH_FILE" >&2
  exit 1
fi

mkdir -p "$(dirname "$WORK_DIR")" "$DIST_DIR"

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
