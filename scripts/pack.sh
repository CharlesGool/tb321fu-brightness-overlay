#!/usr/bin/env bash
# 打 KernelSU / Magisk 模块 zip(先跑 scripts/build.sh). 用法: scripts/pack.sh [输出 zip]
set -euo pipefail
ROOT=$(cd "$(dirname "$0")/.." && pwd)
VER=$(sed -n 's/^version=//p' "$ROOT/module/module.prop")
APK=$ROOT/out/treble-overlay-lenovo-tb321fu.apk
ZIP=$(realpath -m "${1:-$ROOT/out/tb321fu_brightness_overlay_$VER.zip}")
[[ -f $APK ]] || { echo "缺 $APK, 先跑 scripts/build.sh" >&2; exit 1; }
if grep -l $'\r' "$ROOT"/module/*.sh "$ROOT"/module/*.prop; then echo "CRLF in module files" >&2; exit 1; fi
T=$(mktemp -d); trap 'rm -rf "$T"' EXIT
cp "$ROOT"/module/module.prop "$ROOT"/module/post-fs-data.sh "$T/"
mkdir -p "$T/files" && cp "$APK" "$T/files/"
mkdir -p "$(dirname "$ZIP")"; rm -f "$ZIP"
(cd "$T" && zip -q -X -r "$ZIP" module.prop post-fs-data.sh files)
unzip -l "$ZIP"
sha256sum "$ZIP"
