# tb321fu-brightness-overlay

**简体中文** | [English](doc/en/README.md) | [Español](doc/es/README.md)

修复拯救者 Y700 三代 (TB321FU) 刷 Pixel / AOSP 类 GSI 后自动亮度不能用的问题: 一个 framework overlay, 打开自动亮度并使用原厂 ZUI 的亮度曲线, 做成 KernelSU / Magisk 模块.

[![License](https://img.shields.io/badge/License-MIT-orange)](LICENSE)

## 文档

- 项目概览: [README](README.md)

- 设计思路: [DESIGN](doc/DESIGN.md)

- 项目状态: [LOG](doc/LOG.md)
- 历史记录: [HISTORY](doc/HISTORY.md)
- 变更日志: [CHANGELOG](doc/CHANGELOG.md)

- 第三方声明: [THIRD_PARTY_NOTICES](doc/THIRD_PARTY_NOTICES.md)

## 简介

- 设置里出现"自适应亮度"开关, 光线传感器按原厂 ZUI 的曲线调节屏幕亮度
- overlay 只在 `ro.product.vendor.device=TB321FU` 时生效, 装在别的设备上不起作用
- 顺带修正 Pixel Tablet (tangorpro) 底包的两个旋转设置, 只能横屏的应用(如 B 站全屏)不再上下颠倒; 在其他底包上这两个值就是 AOSP 默认值, 没有影响
- 模块自己挂载 overlay, 不需要 meta-overlayfs

为什么 GSI 上自动亮度不能用, 以及曲线怎么从 ZUI 取出来, 见 [DESIGN](doc/DESIGN.md#架构).

[TB321FU_PixelOS_15_Tangorpro](https://github.com/CharlesGool/TB321FU_PixelOS_15_Tangorpro) 已经内置这个 overlay; 模块在这种 ROM 上检测到 overlay 已存在会自动跳过.

## 要求

- 拯救者 Y700 三代 (TB321FU), vendor 是原厂 ZUI
- system 分区刷了 Pixel / AOSP 类 GSI(Android 15)
- KernelSU 或 Magisk
- 自己构建时: `aapt2`, `zipalign`, `apksigner`, `keytool`, `zip`, 一个 Android framework-res.apk(Debian / Ubuntu 上 `apt install aapt apksigner zipalign android-framework-res default-jdk-headless zip`)

## 安装

### 快速安装

```bash
scripts/build.sh
scripts/pack.sh
adb push out/tb321fu_brightness_overlay_v1.zip /sdcard/Download/
```

在 KernelSU 或 Magisk 里安装 `/sdcard/Download/tb321fu_brightness_overlay_v1.zip`, 重启.

### 常规安装

把 `out/treble-overlay-lenovo-tb321fu.apk` 做进 system 镜像: 放到 `/system/product/overlay/`, 权限 0644, SELinux 标签 `u:object_r:system_file:s0`, 然后重新签名镜像. 这样不需要 root.

`scripts/build.sh` 默认用 `/usr/share/android-framework-res/framework-res.apk`, 可以用环境变量 `FW` 换成别的; 签名密钥默认自动生成 `out/overlay.keystore`, 可以用 `KS` 指定(PKCS12, 别名 `overlay`, 口令 `android`).

装过旧的 `tb321fu_gsi_fix` 测试模块(v1 到 v4)的, 先卸载它, 它里面带了同一个 overlay.

## 指南

检查 overlay 是否生效:

```bash
adb shell cmd overlay list android | grep tb321fu
adb shell cmd overlay lookup android android:bool/config_automatic_brightness_available
adb shell dumpsys display | grep -E "mBrightnessLevelsLux|mBrightnessLevelsNits|mAmbientLux"
```

期望: 第一条输出 `[x] me.phh.treble.overlay.lenovo.tb321fu`; 第二条输出 `true`; 第三条里的曲线是 `[0, 10, 60, 210, 350, 420, 1000, 1001]` lux 对 `[40, 40, 100, 150, 300, 420, 490, 500]` nits, `mAmbientLux` 随环境光变化.

模块日志在 `/data/adb/modules/tb321fu_brightness_overlay/mount.log`.

想改曲线就改 `overlay/res/values/arrays.xml`, 重新构建打包. 各数组的含义见 [DESIGN](doc/DESIGN.md#架构).

## 升级

从旧的 `tb321fu_gsi_fix` 测试模块迁移: 在 KernelSU 或 Magisk 里卸载 `tb321fu_gsi_fix`, 重启, 再安装本模块. 旧模块里的蓝牙修复在 [tb321fu-bt-audio-fix](https://github.com/CharlesGool/tb321fu-bt-audio-fix).

## 卸载

### 快速卸载

在 KernelSU 或 Magisk 里卸载模块, 重启. overlay 只在开机时挂载, 重启后恢复原样.

### 完全卸载

同快速卸载. 自动亮度开关会消失, 系统设置里的亮度模式值保留, 不影响使用.

## 致谢

暂无

## 许可证

MIT License(`MIT`), 全文见 [LICENSE](LICENSE). 亮度曲线的数值取自联想原厂 ZUI, 见 [THIRD_PARTY_NOTICES](doc/THIRD_PARTY_NOTICES.md).
