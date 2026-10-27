---
name: project-design
description: 项目架构与设计约束
metadata:
  version: "1.0.0"
  lang: "zh-CN"
---

# tb321fu-brightness-overlay — 设计

## 多语言

**简体中文** | [English](en/DESIGN.md) | [Español](es/DESIGN.md)

## 文档

- 项目概览: [README](../README.md)

- 设计思路: [DESIGN](DESIGN.md)

- 项目状态: [LOG](LOG.md)
- 历史记录: [HISTORY](HISTORY.md)
- 变更日志: [CHANGELOG](CHANGELOG.md)

- 第三方声明: [THIRD_PARTY_NOTICES](THIRD_PARTY_NOTICES.md)

## 设计目标

- [x] TB321FU 上的 GSI 有自动亮度, 曲线和原厂 ZUI 一致
- [x] 只在 TB321FU 上生效
- [x] 模块不依赖 meta-overlayfs
- [x] 修正 Pixel Tablet 底包把横屏方向反过来的问题

## 架构

| 目录 | 职责 |
| --- | --- |
| `overlay/` | overlay 源码: `AndroidManifest.xml`, `res/values/` |
| `module/` | 模块: `module.prop`, `post-fs-data.sh` |
| `scripts/` | `build.sh` 编译签名 overlay; `pack.sh` 打模块 zip |
| `out/` | 构建输出和自动生成的签名密钥, 不提交 |

### 原因

自动亮度由 framework-res 里的几个配置决定. Pixel 机型的 GSI(komodo, tangorpro 等)用 Pixel 的 framework 配置: `config_automatic_brightness_available=false`, 亮度曲线数组全空, 自适应亮度开关不显示, 框架也不会启动自动亮度控制器. 在 TB321FU 上看到的现象: 光线传感器 `stk_stk3a5x Ambient Light Sensor` 正常工作, 但 `dumpsys display` 里 `mAmbientLux=0.0 (old/invalid)`.

GSI 自带一个联想平板的 phh overlay(`me.phh.treble.overlay.lenovo.y700_2023`), 它通过 `requiredSystemPropertyValue="TB320FC"` 只匹配 Y700 二代, 三代 TB321FU 用不上.

### 曲线从哪来

1. 取原厂 ZUI 的 `/system/framework/framework-res.apk`, 用 apktool 解码
2. 和 Pixel 底包的 framework-res 对比 `res/values/` 里与亮度有关的项, 把 ZUI 有值而 Pixel 为空或为 false 的复制到 overlay

| 资源 | Pixel 底包 | 本 overlay(=ZUI) | 含义 |
| --- | --- | --- | --- |
| `bool/config_automatic_brightness_available` | `false` | `true` | 是否支持自动亮度 |
| `array/config_autoBrightnessLevels` | 空 | `10, 60, 210, 350, 420, 1000, 1001` | 环境光分段点(lux), 比下一个数组少 1 项 |
| `array/config_autoBrightnessDisplayValuesNits` | 空 | `40, 40, 100, 150, 300, 420, 490, 500` | 每段对应的屏幕亮度(nits) |
| `array/config_screenBrightnessNits` | 空 | `0, 40, 100, 150, 300, 420, 490, 500` | 屏幕亮度(nits)和背光值的对照表 |
| `array/config_screenBrightnessBacklight` | 空 | `0, 20, 51, 77, 153, 214, 250, 255` | 和上一个数组一一对应的背光值(0 到 255) |
| `integer/config_screenBrightnessSettingMinimum` | 未记录 | `2` | 手动亮度的最小背光值 |

ZUI 里另有 `config_autoBrightnessLcdBacklightValues`(按背光值而不是 nits 的曲线). 有 `config_screenBrightnessNits` 时框架用 nits 曲线, 所以没有复制它.

### 旋转修正

tangorpro 底包的 `framework-res__tangorpro__auto_generated_rro_product.apk` 设置了:

- `config_reverseDefaultRotation=true`: Pixel Tablet 的屏幕自然方向是横屏, TB321FU 是竖屏, 为 true 时横屏和反向横屏对调, 只能横屏的应用会上下颠倒
- `config_deskDockRotation=270`: Pixel Tablet 底座方向, TB321FU 没有底座

本 overlay 设为 AOSP 默认值 `false` 和 `-1`. 在没有设置这两项的底包上, 这两行不改变任何行为.

### 挂载

overlay 用 `isStatic="true"`, priority 321(高于 TB320FC overlay 的 320), 目标 `android`. 静态 overlay 只在开机扫描时被识别, 所以文件必须在 system_server 启动前出现在 `/system/product/overlay/`.

`module/post-fs-data.sh` 在 post-fs-data 阶段把 APK 复制到 tmpfs, 再用 overlayfs 以 `lowerdir=<tmpfs>:/system/product/overlay` 叠到原目录上. 先复制是因为 overlayfs 不接受 `/data`(f2fs)做 lowerdir. 目录里已有同名 APK(ROM 已内置)时跳过.

不放进模块的 `system/` 目录交给模块管理器挂载, 是因为 KernelSU 没装 metamodule 时不会挂载 `system/`, 这台机器上实际遇到过.

## 设计约束

- overlay **必须**保留 `requiredSystemPropertyName="ro.product.vendor.device"` 和 `requiredSystemPropertyValue="TB321FU"`
- `config_autoBrightnessLevels` 的项数**必须**比 `config_autoBrightnessDisplayValuesNits` 少 1; `config_screenBrightnessNits` 和 `config_screenBrightnessBacklight` 项数**必须**相同
- 签名密钥**禁止**提交
