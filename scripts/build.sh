#!/usr/bin/env bash
# 编译并签名 overlay, 输出 out/treble-overlay-lenovo-tb321fu.apk.
# 需要: aapt2, zipalign, apksigner, keytool. FW: 任意 Android framework-res.apk, 只用来解析清单里的 android: 属性.
# KS: 签名用的 PKCS12 keystore(别名 overlay, 口令 android), 不设时自动生成 out/overlay.keystore.
set -euo pipefail
ROOT=$(cd "$(dirname "$0")/.." && pwd)
FW=${FW:-/usr/share/android-framework-res/framework-res.apk}
KS=${KS:-$ROOT/out/overlay.keystore}
VER=2
OUT=$ROOT/out/treble-overlay-lenovo-tb321fu.apk
T=$(mktemp -d); trap 'rm -rf "$T"' EXIT
mkdir -p "$ROOT/out" "$T/c"
if [[ ! -f $KS ]]; then
    keytool -genkeypair -keystore "$KS" -storetype PKCS12 -alias overlay -keyalg RSA -keysize 2048 \
        -validity 10000 -storepass android -keypass android -dname "CN=TB321FU brightness overlay"
fi
aapt2 compile --dir "$ROOT/overlay/res" -o "$T/c/res.zip"
aapt2 link -o "$T/unsigned.apk" --manifest "$ROOT/overlay/AndroidManifest.xml" -I "$FW" \
    --min-sdk-version 35 --target-sdk-version 35 --version-code "$VER" --version-name "$VER.0" \
    --package-id 0x7f --allow-reserved-package-id --no-resource-removal "$T/c/res.zip"
zipalign -f -p 4 "$T/unsigned.apk" "$T/aligned.apk"
apksigner sign --ks "$KS" --ks-key-alias overlay --ks-pass pass:android --key-pass pass:android --out "$OUT" "$T/aligned.apk"
rm -f "$OUT.idsig"
apksigner verify "$OUT"
echo "$OUT"
