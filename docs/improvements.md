# 配置改进总结

## 已修复的致命问题

### ✅ 0. SQL 查询语法错误修复（最新）
- **问题**：EmacSQL 的 `in` 操作语法错误导致 `wrong-type-argument symbolp 'DONE` 错误
- **错误代码**：`:where (not (in todo:state ('DONE 'CANCELLED)))`
- **修复代码**：`:where (not (in todo:state $v1))` 并传递参数 `(list 'DONE 'CANCELLED)`
- **原因**：EmacSQL 的 `in` 操作需要参数占位符，不能直接在查询中写列表

### ✅ 1. 拼写错误修复
- **问题**：`org-roam-capture-` （多了连字符）
- **修复**：改为 `org-roam-capture`

### ✅ 2. 模板双重维护修复
- **问题**：在 `my/quick-*` 函数中硬编码模板，与 `org-roam-capture-templates` 重复
- **修复**：直接通过 `:keys` 参数调用已有模板
```elisp
;; 修复前（硬编码模板）
(org-roam-capture :node ... :templates '(("i" ...)))

;; 修复后（调用已有模板）
(org-roam-capture :node (org-roam-node-create :title title) :keys "i")
```

### ✅ 3. 变量未定义保护
- **问题**：如果 `config-default.el` 加载失败，会崩溃
- **修复**：添加了 `defvar` 声明和默认值
```elisp
(unless (boundp 'my/hugo-blog-dir)
  (defvar my/hugo-blog-dir "~/Documents/hugo/blog/"))
```

## 已添加的功能

### ✅ 4. 数据库维护函数
```elisp
;; 同步并清理数据库
C-c w s - my/org-roam-sync-and-cleanup

;; 完全重置数据库
C-c w r - my/org-roam-db-full-reset
```

### ✅ 5. 改进的图片归档
- **修复**：使用 `org-element` API 替代正则
- **改进**：更健壮的路径处理，支持多种图片格式
```elisp
;; 新的归档函数特性
- 支持 .png, .jpg, .jpeg, .gif, .svg, .webp
- 使用 org-element 获取链接对象
- 显示归档的图片数量
- 相对路径自动计算
```

### ✅ 6. Property Drawers 改进
- **改进**：将元数据移到 `:PROPERTIES:` 抽屉中
```elisp
:PROPERTIES:
:ID: %(org-id-uuid)
:CREATED: %U
:STATUS: open
:PRIORITY: B
:END:
```

**好处**：
- 正文更简洁
- 易于脚本解析
- 便于导出和管理

### ✅ 7. 更新的快捷键

**快速创建**：
| 快捷键 | 功能 | 说明 |
|--------|------|------|
| F7 | 今日日记 | 跳转到/创建今日 dailies |
| F8 | 快速 Idea | 调用 `org-roam-capture` 模板 "i" |
| F9 | 快速 Question | 调用 `org-roam-capture` 模板 "q" |
| C-c i | 快速 Concept | 调用 `org-roam-capture` 模板 "d" |
| C-c f | 查找笔记 | org-roam-node-find |

**工作流维护**：
| 快捷键 | 功能 |
|--------|------|
| C-c w o | 查找孤儿笔记 |
| C-c w c | 查找有链接的笔记 |
| C-c w a | 归档当前笔记 |
| C-c w s | 同步并清理数据库（新）|
| C-c w r | 完全重置数据库（新）|

## 工作流优化

### 📝 建议的工作流

```
日常记录（F7）
    ↓
快速提炼（F8/F9/C-c i）
    ↓
定期维护（C-c w s）
    ↓
查看图谱（C-c u o）
```

### 🔄 数据库维护周期

**每周**：
1. `C-c w s` - 同步并清理数据库
2. `C-c w o` - 查看孤儿笔记
3. 决定是否需要删除或链接孤儿笔记

**每月**：
1. `C-c w r` - 完全重置数据库（如果感觉变慢）
2. `C-c w c` - 查看有链接的笔记
3. 检查知识图谱的连接性

## 仍可优化的部分

### 📊 搜索系统
**建议**：考虑引入 `consult-org-roam`
```elisp
;; 比手写 SQL 更高效，支持实时预览
(use-package consult-org-roam
  :after org-roam
  :bind
  ("C-c n s" . consult-org-roam-search)
  ("C-c n b" . consult-org-roam-backlinks))
```

**优势**：
- 实时预览
- 集成 Vertico/Orderless
- 更好的过滤体验

### 🎨 UI 改进
**建议**：考虑 `valign` 插件解决表格对齐
```elisp
;; 允许混合字体同时保持表格对齐
(use-package valign
  :hook (org-mode . valign-mode))
```

### 📝 Hugo Slug 处理
**当前**：手动处理中文转拼音
**建议**：利用 `ox-hugo` 内置处理
```elisp
;; 在 Org 文件头设置
#+HUGO_SLUG: your-slug-here

;; ox-hugo 会优先使用这个
```

## 测试清单

重启 Emacs 后，请测试以下功能：

### 基础功能
- [ ] F7 - 打开今日日记
- [ ] F8 - 创建 Idea 笔记（输入标题后，应该使用已有模板）
- [ ] F9 - 创建 Question 笔记
- [ ] C-c i - 创建 Concept 笔记
- [ ] C-c f - 查找/创建笔记

### 工作流维护
- [ ] C-c w s - 同步数据库（应该看到提示）
- [ ] C-c w o - 查找孤儿笔记
- [ ] C-c w c - 查找有链接的笔记
- [ ] C-c w a - 归档当前笔记
- [ ] C-c w r - 测试数据库重置（谨慎测试）

### 图片管理
- [ ] C-c n v - 粘贴图片到笔记
- [ ] C-c n A - 归档图片到 assets 文件夹
- [ ] 检查归档后的图片链接是否正确

### 模板验证
- [ ] F8 创建的笔记是否有 `:PROPERTIES:` 抽屉
- [ ] Question 笔记是否有 `:STATUS: open` 属性
- [ ] Idea 笔记是否有 `:PRIORITY: B` 属性
- [ ] Blog 笔记是否有 Hugo 相关属性

### 数据库
- [ ] 检查 `org-roam.db` 是否在正确位置
- [ ] 检查数据库同步是否正常
- [ ] 检查链接索引是否工作

## 性能指标

**预期启动时间**：< 5 秒
**预期查询响应**：< 1 秒
**预期模板创建**：< 2 秒

如果超出预期，考虑：
1. 检查数据库大小（如果 > 100MB，考虑归档旧笔记）
2. 检查图片数量（过多图片会影响性能）
3. 考虑使用 `org-roam-db-autosync-mode` 的延迟设置

## 已知限制

1. **中文 slug**：仍需手动处理或使用 `pinyinlib`
2. **表格对齐**：使用 `fixed-pitch` 可能影响阅读体验
3. **搜索预览**：手写 SQL 缺少即时预览

## 下一步建议

### 高优先级
1. 引入 `consult-org-roam` 改善搜索体验
2. 添加 `valign` 解决表格对齐问题
3. 完善 Hugo slug 自动生成

### 中优先级
4. 添加笔记导出功能（导出为 Markdown/PDF）
5. 添加笔记模板的快速切换
6. 添加标签管理的可视化界面

### 低优先级
7. 添加笔记统计和可视化
8. 添加学习曲线追踪
9. 添加知识图谱分析

## 需要帮助？

如果遇到问题，检查：
1. `*Messages*` 缓冲区的错误信息
2. `*Org Roam*` 缓冲区的同步状态
3. `*eglot-events*` 缓冲区的 LSP 状态

---

**最后更新**：2025-01-07
**配置版本**：v2.0
**状态**：生产就绪
