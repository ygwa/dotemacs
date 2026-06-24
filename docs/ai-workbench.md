# AI Workbench（Agent OS 层）

> 前缀 **`C-c C-w`** — AI 工作台（不含 AI Context Engineering UI）。
> 项目数据目录：**`.agent/`**（含 profiles、reviews、transcripts）。

## 目录结构

```text
project/.agent/
├── memory.org          # 长期记忆 / 踩坑
├── decisions.org       # ADR 架构决策
├── profiles/
│   ├── planner.md
│   ├── coder.md
│   └── reviewer.md
├── reviews/
│   └── YYYY-MM-DD-HHMMSS.review.md
└── transcripts/        # agent-shell 对话记录（自动保存）
```

首次使用任一 `C-c C-w` 命令会自动 bootstrap 模板文件。

---

## 快捷键（`C-c C-w`）

| 键 | 命令 | 说明 |
|---|---|---|
| `n` | `my/ai-new-task` | 捕获 AI Org 任务 + 工作台布局 + agent |
| `p` | `my/ai-plan-from-org` | 当前 Org 标题 → `*AI-Plan*` |
| `a` | `my/ai-send-active-to-agent` | 送 `*AI-Plan*` 或 `*AI-Review*` 到 agent |
| `r` | `my/ai-review-local` | 本地 `git diff HEAD` → `*AI-Review*` |
| `R` | `my/ai-review-send-to-agent` | 送 review buffer 到 agent |
| `S` | `my/ai-review-save` | 保存 review 到 `.agent/reviews/` |
| `g` | `my/ai-pr-review` | 自动检测 GitHub/GitLab 选 PR/MR |
| `h` | `my/ai-pr-review-github` | GitHub PR（`gh`） |
| `L` | `my/ai-pr-review-gitlab` | GitLab MR（`glab`） |
| `G` | `my/ai-pr-review-send-to-agent` | 拉 PR/MR 并送 agent |
| `P` | `my/ai-start-with-profile` | 加载 `.agent/profiles/*.md` 到 agent |
| `M` | `my/ai-memory-capture` | 追加一条 memory 笔记 |
| `m` | `my/ai-memory-send-to-agent` | 送 memory + decisions 到 agent |
| `o` / `d` | 打开 memory.org / decisions.org |
| `t` | `my/ai-tool-run` | 工具注册表（git-diff / search / …） |
| `l` | `my/ai-log-show` | 显示 `*AI-Log*` 事件日志 |

无 preset prompt：内容只插入 agent 输入区，自行补充指令后发送。

---

## Org AI 任务

Capture 模板 `C-c c` → **`a` AI Task**：

```org
* TODO 任务标题
  :PROPERTIES:
  :AI_TASK: t
  :AI_PROFILE: coder
  :END:

  Context:
  - ...
```

`C-c C-w n` = capture + sidebar/agent 布局。

---

## GitHub PR / GitLab MR Review

### 依赖

| 工具 | 用途 | 安装 |
|---|---|---|
| `gh` | GitHub PR list/view/diff | `brew install gh` |
| `glab` | GitLab MR list/view/diff | `brew install glab` |

在项目根目录执行（需已 `gh auth login` / `glab auth login`）。

### 工作流

1. **`C-c C-w g`** — 根据 `origin` URL 自动选 GitHub 或 GitLab；两者都有时询问
2. **`C-c C-w g h`** / **`g l`** — 强制 GitHub / GitLab
3. 选中 PR/MR → 内容进入 `*AI-Review*`（meta + diff）
4. **`C-c C-w a`** — 送到 agent 审阅
5. **`C-c C-w S`** — 保存为 `.agent/reviews/*.review.md`

与 Forge（Magit `'`）互补：Forge 偏 Magit 内浏览；`gh`/`glab` 流程适合你的 glab MR 习惯。

---

## Agent Profiles

编辑 `project/.agent/profiles/planner.md` 等，**`C-c C-w P`** 插入 profile 到 agent（不自动发送）。

---

## Tool Registry

`C-c C-w t` 可选：

| 工具 | 作用 |
|---|---|
| `git-diff` | 当前项目 diff |
| `git-log` | 最近 20 条 commit |
| `search-code` | ripgrep / git grep |
| `run-shell` | 在项目根跑 shell 命令（执行前确认） |
| `open-memory` | 读取 memory.org |

输出显示在 `*AI-Log*`，可选送 agent。

---

## 专用 Buffer

| Buffer | 用途 |
|---|---|
| `*AI-Plan*` | Org 任务 / 规划 |
| `*AI-Review*` | 本地 diff / PR / MR |
| `*AI-Log*` | 工作台事件（非 chat transcript） |

Transcript 保存在 `.agent/transcripts/`（与 workbench 共用 `.agent/` 根目录）。

---

## 模块加载

`init.el` → `config-agent` + `config-ai`（`my/features` 含 `ai` 时；内部聚合 core/memory/review/pr-review/workbench）

详见 [configuration-overview.md](./configuration-overview.md)。
