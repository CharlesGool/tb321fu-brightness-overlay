---
name: project-log
description: 项目缺陷, 限制, 决策和交接
metadata:
  version: "1.0.0"
  lang: "zh-CN"
---

# 日志

## 多语言

**简体中文** | [English](en/LOG.md) | [Español](es/LOG.md)

## 文档

- 项目概览: [README](../README.md)

- 设计思路: [DESIGN](DESIGN.md)

- 项目状态: [LOG](LOG.md)
- 历史记录: [HISTORY](HISTORY.md)
- 变更日志: [CHANGELOG](CHANGELOG.md)

- 第三方声明: [THIRD_PARTY_NOTICES](THIRD_PARTY_NOTICES.md)

## 记录

- [历史记录](HISTORY.md)
- [变更日志](CHANGELOG.md)

## 缺陷

- [ ] 本模块的挂载方式(tmpfs + overlayfs)没有上机验证. overlay 本身在旧测试模块 `tb321fu_gsi_fix`(依赖 meta-overlayfs)和 TB321FU_PixelOS_15_Tangorpro V1 到 V6 中验证过; 同样的挂载方式在 paranoidsense-gsi-port 的模块里用于 `/system/product/overlay` 并验证过

## 限制

暂无

## 决策

| 日期 | 决策 | 状态 | 原因 |
| --- | --- | --- | --- |
| 2026-10-27 | 模块自己用 tmpfs + overlayfs 挂载, 不放进 `system/` | 接受 | KernelSU 没装 metamodule 时不挂载 `system/` |
| 2026-10-26 | 只复制 ZUI 的 nits 曲线, 不复制 `config_autoBrightnessLcdBacklightValues` | 接受 | 有 nits 对照表时框架用 nits 曲线 |

## 交接

- 分支: `main`
- 已完成: 从 TB321FU_PixelOS_15_Tangorpro 的 `overlay/` 拆出亮度 overlay; 模块改为自己挂载; 签名密钥改为自动生成; 文档
- 检查: `scripts/build.sh` 编出的 APK 除签名外和 ROM 里上机通过的版本相同(`AndroidManifest.xml`, `resources.arsc`); `scripts/pack.sh` 打包成功; `sh -n` 语法检查通过
- 剩余: 上机安装验证
- 临时项目规则: 未发现
