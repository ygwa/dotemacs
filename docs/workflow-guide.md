# Emacs Org Mode 简化配置指南

## 配置概述

这是一套**简单标准**的 Org Mode + Org Roam 配置，专注于核心功能，避免过度复杂。

## 快速开始

### 1. 目录结构
```
~/Documents/org/
├── roam/              # Org Roam 笔记目录
├── Tasks/             # 待办事项
├── Notes/             # 临时笔记
└── library/           # PDF 文献
```

### 2. 基础快捷键

| 快捷键 | 功能 |
|--------|------|
| `C-c c` | Org Capture |
| `C-c a` | Org Agenda |
| `C-c l` | Store Link |

## Org Roam 工作流

### 快速操作

| 快捷键 | 功能 |
|--------|------|
| `C-c n f` | 查找/创建笔记 |
| `C-c n i` | 插入笔记链接 |
| `C-c n l` | 切换 Roam 缓冲区 |
| `C-c n d` | 今日日记 |
| `C-c n c` | 捕获今日日记 |
| `C-c n [` | 前一天日记 |
| `C-c n ]` | 后一天日记 |

### 推荐工作流

**日常记录**：
```
1. C-c n d  - 打开今日日记
2. 记录工作内容、想法
3. 使用 C-c n i 链接到相关笔记
```

**知识积累**：
```
1. C-c n f  - 创建新笔记
2. 使用标准模板
3. 通过链接关联笔记
```

## 文献管理

| 快捷键 | 功能 |
|--------|------|
| `C-c r o` | 打开文献（BibTeX）|
| `C-c r i` | 插入文献引用 |

## 图片管理

| 快捷键 | 功能 |
|--------|------|
| `C-c n v` | 粘贴剪贴板图片 |
| `C-c n P` | 截图（macOS）|

## 博客导出

| 快捷键 | 功能 |
|--------|------|
| `C-c h h` | 打开 Easy Hugo 管理界面 |

## 帮助

按 `C-c ?` 查看所有快捷键。

## 简化说明

### 删除的功能

已删除以下复杂功能，回归标准用法：

1. ❌ SQL 查询统计（孤儿笔记、标签统计等）
2. ❌ 复杂的自定义函数
3. ❌ 动态 Agenda 缓存
4. ❌ 高级 Property Drawers
5. ❌ 时间追踪报告
6. ❌ 统一搜索系统
7. ❌ 工作流维护函数

### 保留的功能

保留了**核心且必要**的功能：

1. ✅ 基础 Org Mode 配置
2. ✅ 标准 Org Roam 模板
3. ✅ 简单的文献管理
4. ✅ 基础图片管理
5. ✅ 博客导出

## 配置文件

主要配置在 `config-org.el`，非常简洁：

```elisp
;; Org Mode 核心设置
(use-package org ...)

;; Org Roam 核心
(use-package org-roam ...)

;; 文献管理
(use-package citar ...)

;; 阅读器
(use-package pdf-tools ...)
(use-package nov ...)

;; 图片管理
(use-package org-download ...)

;; 博客导出
(use-package ox-hugo ...)
(use-package easy-hugo ...)
```

## 使用建议

### 日常记录

**早晨**：
```
C-c n d - 打开今日日记
开始记录今日计划
```

**工作中**：
```
随时在日记中记录
C-c n i - 链接到已有笔记
```

**遇到想法**：
```
C-c n f - 创建新笔记
记录想法
```

### 知识管理

**创建笔记**：
```
C-c n f - 查找或创建笔记
使用标准模板
```

**链接笔记**：
```
C-c l - 先存储链接
C-c n i - 插入链接
```

**查看图谱**：
```
M-x org-roam-ui
在浏览器中查看知识图谱
```

## 故障排除

### Org Roam 数据库问题

如果数据库损坏：
```elisp
M-x org-roam-db-clear-all
M-x org-roam-db-sync
```

### 笔记找不到

检查目录结构：
```
~/Documents/org/roam/  应该存在
```

### 图片无法粘贴

确保剪贴板有图片，或检查 `org-download` 配置。

## 扩展配置

如果需要更多功能，可以手动添加：

### 添加更多模板

编辑 `org-roam-capture-templates`：
```elisp
(setq org-roam-capture-templates
      '(("d" "default" plain "%?"
         :target (file+head "${slug}.org" "#+title: ${title}\n"))
        ("m" "meeting" plain "%?"
         :target (file+head "${slug}.org" "#+title: ${title}\n#+filetags: :meeting:\n"))))
```

### 添加自定义快捷键

```elisp
(global-set-key (kbd "C-c m") 'your-function)
```

## 总结

这是一套**简单、标准、易维护**的配置，专注于：

1. ✅ 快速记录
2. ✅ 知识管理
3. ✅ 文献阅读
4. ✅ 博客写作

没有复杂的统计和自动化，回归 Emacs 的本质：**编辑和管理纯文本**。

---

**配置版本**：v3.0 Simplified
**最后更新**：2025-01-07
