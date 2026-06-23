# 使用场景指南

> 本目录提供各开发场景的实战工作流。
> **TUI-only 上下文**（2026-06）：配置统一在 emacsclient + daemon 模式运行，catppuccin mocha 主题，所有视觉按 24-bit color 终端优化。

## 📚 可用指南

- [配置总览](./configuration-overview.md) — 目标、特性、插件与快捷键体系
- [全局快捷键速查表](./keybindings.md) — 所有键位单一真值源
- [Rust 开发指南](./rust-development.md) — Eglot + rust-analyzer
- [Magit Git 管理指南](./magit-guide.md) — magit 单字母键与场景
- [Forge GitHub/GitLab 指南](./forge-guide.md) — PR/MR 审阅与 token 配置
- [AI Workbench 指南](./ai-workbench.md) — Agent OS 层（memory / review / gh+glab）

## 🧭 常用工作流

### 启动与连接（daemon 模式）

```bash
# 1. 启动后台 daemon (GUI / TUI client 共享 session)
emacs --daemon

# 2. 在终端里连 TUI frame
emacsclient -t

# 3. 在 GUI 里连 (如需 GUI client, daemon 模式支持混合)
emacsclient -c
```

> daemon 启动时主题走 `server-after-make-frame-hook`，第一个 frame 创建后才加载 catppuccin 配色。

### 第一次进 editor：开 dashboard

启动后默认进 `*dashboard*`（dual flow 工作台：Inbox / Studies / Principles / Code），按 `r` 进最近文件，`p` 进项目。

### 项目内工作（5 个常用键）

| 键位 | 动作 |
|---|---|
| `C-c p f` | 搜项目内文件（fuzzy） |
| `C-c p g` | 项目内搜 regex |
| `C-c p s` | 开项目 Eat 终端（项目根目录） |
| `C-c p b` | 切到项目内的 buffer |
| `C-c p d` | 打开项目根 dired |

> 项目识别基于 Git + `package.json` / `requirements.txt` / `.project`（见 `config-package.el:23` `project-vc-extra-root-markers`）。

### AI 编程工作流（一键布局）

按 `C-c f l` → 左侧 treemacs 文件树 + 右侧 agent-shell 面板（OpenCode 接管）。退出时 `C-c f c` 清窗。

### 代码 / Git / Markdown 审阅 → AI

| 场景 | 操作 |
|---|---|
| Magit 未提交 diff | `C-x g` → `C-c C-d` 插入 diff 到 agent 输入区 |
| Magit log 某 commit | 光标在 commit 上 → `C-c C-d` |
| Markdown 文档 | `C-c C-d` 送全文；选中段落则送 region |
| embark | `C-.` → “Send git diff / Markdown to agent shell” |
| 行内改动 | prog-mode 自动 `diff-hl-mode` 标记未提交行 |
| Markdown lint | 安装 `markdownlint` 后 flymake 自动提示 |
| GitHub/GitLab PR | Magit 内 `'` → Forge；打开 MR diff 后 `C-c C-d` |

无 preset prompt：内容仅插入 agent 输入区，自行补充指令后回车发送。

### 多项目切换（Phase 4）

| 键 | 动作 |
|---|---|
| `C-c p p` | 切项目；有保存布局则恢复，否则 `C-c f l` 工作台 |
| `C-c p w` | 保存当前项目窗口布局 |
| `C-c p W` | 恢复当前项目布局 |
| tab-bar | 启动后自动启用，按 VCS 根目录分组 tab |

布局持久化在 `var/project-layouts.el`（gitignore）。

### AI Workbench（Agent OS 层）

前缀 **`C-c C-w`**。项目数据在 **`project/.agent/`**（memory、profiles、reviews）。

| 场景 | 操作 |
|---|---|
| 新 AI 任务 | `C-c C-w n` → Org capture + 布局 + agent |
| Org 任务 → 规划 | 光标在 Org 标题 → `C-c C-w p` → `*AI-Plan*` |
| 本地代码审阅 | `C-c C-w r` → `*AI-Review*` → `C-c C-w a` 送 agent |
| GitHub PR | `C-c C-w h`（需 `gh auth login`） |
| GitLab MR | `C-c C-w L`（需 `glab auth login`） |
| 保存 review | `C-c C-w S` → `.agent/reviews/` |
| 项目记忆 | `C-c C-w M` 捕获 / `m` 送 agent / `o` 打开 memory.org |
| Agent 角色 | 编辑 `.agent/profiles/*.md` → `C-c C-w P` |

详见 [AI Workbench 指南](./ai-workbench.md)。

### LSP 触发条件

打开文件 → mode 是 `python-mode` / `rust-mode` / `rust-ts-mode` / `typescript-ts-mode` / `tsx-ts-mode` / `js-ts-mode` → eglot 自动启动（`config-package.el:211-212` 与 `config-web.el:97-99` 的 `:hook (eglot-ensure)` 触发）。

### 代码补全（Corfu）

补全自动启用，2 字符起弹（`corfu-auto-prefix 2`），弹窗内：

- `C-n` / `C-p` — 上下选
- `C-i` — 完成
- `M-d` — 看文档
- `M-l` — 看定义位置

### Org 收件箱

- `C-c c` → 选 `i` 进 Inbox（headline "Inbox"）
- `C-c a` → 开 agenda
- `C-c l` → 存当前位置为链接

> 当前 `config-org.el` 只配 Inbox capture，TODO 走 agenda + headline，不在 capture 里。

### Magit 提交流程

`C-x g` → magit 状态窗 → `s` 暂存 → `c c` 提交 → `C-c C-c` 完成 → `P P` 推送。详见 [Magit 指南](./magit-guide.md)。

### Web / Node 项目

在项目根按 `C-c r n` → 自动选 pnpm > yarn > npm → 列出 `package.json` scripts → 选一个跑。

### Python / Rust 调试

按 `<f5>` 启动 dape（按 dir-locals 配置）。需要 `debugpy`（Python）或 `lldb-dap`（Rust）。`M-<f5>` 看速查表，`C-c d b` 切当前行断点。

## 🔮 计划中的指南

- **Python 开发** — Eglot + debugpy + dape
- **TypeScript/JavaScript 开发** — Eglot + vscode-js-debug + apheleia(prettier)
- **Go 开发** — Eglot + gopls

## 🤝 贡献指南

新建场景文档时：

1. 在 `docs/` 下创建 markdown
2. 开头声明"4 轮重构后 (2026-06) 真值"
3. 键位优先引用 [keybindings.md](./keybindings.md)，不在子文档里重复
4. 包含：前置要求 / 工作流 / 常见问题
5. 在本文件加链接
