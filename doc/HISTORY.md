---
name: project-history
description: 历史记录
metadata:
  version: "1.0.0"
  lang: "zh-CN"
---

# 历史记录

## 多语言

**简体中文** | [English](en/HISTORY.md) | [Español](es/HISTORY.md)

## 文档

- 项目概览: [README](../README.md)

- 设计思路: [DESIGN](DESIGN.md)

- 项目状态: [LOG](LOG.md)
- 历史记录: [HISTORY](HISTORY.md)
- 变更日志: [CHANGELOG](CHANGELOG.md)

- 第三方声明: [THIRD_PARTY_NOTICES](THIRD_PARTY_NOTICES.md)

## 历史记录

- 2026-10-26: 第一版 overlay 放在测试模块 `tb321fu_gsi_fix` 的 `system/product/overlay/` 里, 第一轮因为 KernelSU 没装 metamodule 没有挂载; 装 meta-overlayfs 后第二轮生效, 用户确认自动亮度正常
- 2026-10-27: TB321FU_PixelOS_15_Tangorpro V5 在同一个 overlay 里加入旋转修正
