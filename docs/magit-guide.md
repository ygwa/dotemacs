# Magit Git 管理指南

> Magit 是 Emacs 内最强大的 Git 界面，单字母键 + 可组合设计。
> 本配置全局入口：`C-x g`（`magit-status`）。

## 快速开始

| 键位 | 命令 |
|---|---|
| `C-x g` | `magit-status`（全局绑定） |
| 在 magit 状态窗按 `?` | 查看所有可用键 |

## 核心概念

- **状态窗（status buffer）** 显示：当前分支、未暂存 / 已暂存更改、未跟踪文件、最近提交
- **单字母键** 上下文相关：同一键在不同区域可能做不同事
- **可组合**：连续按多键完成复杂操作（如 `b b` 切分支、`f a` 全远程 fetch）
- **底部提示**：状态窗底部始终显示当前可用操作

## 状态窗键位速查

| 键 | 功能 |
|---|---|
| `s` | 暂存当前项（文件 / 块 / 行） |
| `u` | 取消暂存 |
| `S` | 暂存所有 |
| `U` | 取消所有暂存 |
| `d` | 差异菜单 |
| `D` | 显示提交差异 |
| `k` | 丢弃当前项（危险） |
| `x` | 重置到 HEAD |
| `c` | 提交菜单 |
| `b` | 分支菜单 |
| `f` | fetch / pull 菜单 |
| `p` | 推送菜单 |
| `m` | 合并菜单 |
| `r` | 变基菜单 |
| `l` | 日志菜单 |
| `z` | 暂存区（stash）菜单 |
| `t` | 标签菜单 |
| `w` | 补丁菜单 |
| `v` | 反转提交 |
| `?` / `h` | 帮助 |
| `g` | 刷新 |
| `q` | 退出当前窗 |

## 提交流程

```
C-x g                       ; 状态窗
s                           ; 暂存文件
c c                         ; 创建提交
; 写 commit message
C-c C-c                     ; 完成
P P                         ; 推 pushremote
```

## 常见组合

| 操作 | 键序列 |
|---|---|
| 创建分支 | `b c` |
| 切分支 | `b b` |
| 重命名分支 | `b w` |
| 删除分支 | `b k` |
| merge 到当前 | `b m` |
| fetch | `f f` |
| 全远程 fetch | `f a` |
| pull (fetch+merge) | `f p` |
| pull + rebase | `f u` |
| 推 pushremote | `p p` |
| 推上游 | `p u` |
| 推标签 | `p t` |
| merge 分支 | `m m` |
| 中止 merge | `m a` |
| 开始 rebase | `r r` |
| 继续 rebase | `r c` |
| 跳过 | `r s` |
| 中止 rebase | `r a` |
| 改 rebase commit | `r e` |
| 看日志 | `l l` |
| 看全分支日志 | `l a` |
| 看文件日志 | `l f` |
| 创建 stash | `z z` |
| 应用 stash | `z a` |
| 弹 stash | `z p` |
| 删 stash | `z d` |

## 提交信息窗

| 键 | 功能 |
|---|---|
| `C-c C-c` | 完成提交 |
| `C-c C-k` | 取消提交 |
| `C-c C-a` | 加 GPG 签名 |

## 日志窗

| 键 | 功能 |
|---|---|
| `RET` | 看 commit 详情 |
| `d` | 看 commit 差异 |
| `a` | cherry-pick |
| `c` | 在此 commit 上建新提交 |
| `f` | 建修复提交 |

## 交互式 rebase

`r r` 选目标后进入 rebase 缓冲区：

| 键 | 动作 |
|---|---|
| `p` | pick（保留） |
| `r` | reword（改 message） |
| `e` | edit（停下来改） |
| `s` | squash（合并到上一个，保留 message） |
| `f` | fixup（同 squash 但丢 message） |
| `d` | drop（删） |
| `x` | exec（执行 shell） |

## 实战场景

### 场景 1：基本提交

```
C-x g → s → c c → 写 message → C-c C-c → P P
```

### 场景 2：建并切新分支

```
C-x g → b c → 输入名字 → 开工 → b b 切回
```

### 场景 3：merge 分支

```
(切到目标) C-x g → m m → 选源分支 → 解决冲突 → C-c C-c
```

### 场景 4：rebase 改历史

```
C-x g → r r → 选目标
  r e (停下来改 commit)
  r s (跳过)
  r c (continue)
  r a (abort)
```

### 场景 5：暂存切走再回

```
C-x g → z z → 切分支做事 → 切回 → z a (应用)
```

### 场景 6：解决冲突

```
merge / rebase 中冲突
→ 打开冲突文件手改
→ 回 magit 按 s 暂存
→ r c (rebase) 或完成 merge
```

## 当前配置

`config/config-package.el`：

```elisp
(use-package magit
  :ensure t
  :bind ("C-x g" . magit-status)
  :config
  (setq magit-push-always-verify nil
        magit-revert-buffers t))
```

## 与 Consult 集成

| 命令 | 说明 |
|---|---|
| `M-x consult-git-grep` | 在 Git 仓库内 grep |
| `M-x consult-git-log` | 搜 commit 历史 |
| `C-c s g` | `consult-git-grep`（`C-c s` search 前缀） |

## 常见问题

**Q: 撤销最后一次提交？**

```
C-x g → c w → c a (修改最后 commit)
```

**Q: 状态窗不更新？**

按 `g` 手动刷新，或 `(setq magit-auto-revert-mode t)`。

**Q: 文件 Git 历史？**

```
在文件 buffer 内: M-x magit-log-buffer-file
或在状态窗: l f 选文件
```

**Q: 改远程 URL？**

```
C-x g → M → M u (URL)
```

## 相关资源

- [Magit 官网](https://magit.vc/)
- [Magit 用户手册](https://magit.vc/manual/magit.html)
