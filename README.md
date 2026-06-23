# Emacs 配置

为 Emacs 30.2 优化的个人配置。**TUI 优先（emacsclient + daemon）**，所有外部二进制依赖已用 `executable-find` 守护。

> **架构原则（2026-06）**：本配置统一为 TUI-only，不再包含 GUI 分支。
> 早期 `config-gui.el`（字体 / Mac 暗色 / 像素滚动 / 全屏快捷键）已整体下线。
> 所有视觉配置按 24-bit color TUI 终端优化（catppuccin mocha 主题、字符级 modeline / dashboard / nerd-icons fallback）。

## 🎯 启动后第一眼

真实 dashboard 缓冲区渲染（TUI 纯文本，无 nerd-icons；`emacs --batch` 抓取）：

```text
EMACS

AI 工作台

✦  79 packages  ·  loaded in 0.005731 seconds   ← `emacs --batch` 加载时间, daemon 实测约 0.8-1.5s

Recent Files: (r)
    ~/.emacs.d/init.el
    ...

Projects: (p)
    ~/.emacs.d/

Agenda for the coming week: (a)
      Task:        2025-01-25 TODO 每周回顾 (Weekly Review)
```

## 📁 目录结构

```
.emacs.d/
├── early-init.el          # 早期初始化（GC / frame / native-comp）
├── init.el                # 主入口
├── custom.el              # custom-set-variables 自动生成
├── config/
│   ├── config-default.el  # 基础设置（编码/dired/cursor）
│   ├── config-org.el      # Org 模式 + Inbox capture
│   ├── config-shared.el   # TUI UI（catppuccin/doom-modeline/dashboard/window）
│   ├── config-treesit.el  # Tree-sitter 语法库源、mode remap、一键安装
│   ├── config-package.el  # 包管理 + 编程工具（vertico/corfu/consult/eglot）
│   ├── config-markdown.el # Markdown 编辑与预览
│   ├── config-web.el      # Web 前端（tree-sitter/apheleia/eglot）
│   ├── config-agent.el    # agent-shell + OpenCode + 审阅桥
│   ├── config-ai-*.el     # Agent OS 层 (memory/review/pr/workbench)
│   ├── config-git-review.el # diff-hl / magit-delta / forge
│   └── config-workflow.el # 工作流布局（treemacs + AI panel + 多项目）
├── tree-sitter/           # tree-sitter 语法库（运行 M-x treesit-install-language-grammar 安装）
├── var/                   # 运行时数据
└── docs/                  # 详细使用指南
```

## 🚀 快速开始

```bash
git clone <repo> ~/.emacs.d
# 启动 Emacs, 包会自动安装
# 完整外部依赖清单见下"📦 外部依赖"章
```

启动后第一次会从 USTC 镜像下载 ~50 个包，耗时约 30s-2min。

> Web/TS 项目的 tree-sitter 语法库 (typescript/tsx/javascript/css/json/html/yaml) 需手动安装：打开任一 .ts 文件后跑 `M-x treesit-install-language-grammar` 按提示逐个装，或 `M-x my/install-all-treesit-grammars` 一键全装。Rust 语法库已预编译在 `tree-sitter/libtree-sitter-rust.dylib`，开箱即用。

## ⚙️ 加载顺序

`init.el` → `early-init.el` 先跑（GC/frame/native-comp）→ 主入口 `require` 顺序：

```
config-default  →  config-org  →  config-shared  →  config-treesit
                →  config-web  →  config-package →  config-markdown
                →  config-agent →  config-ai-* →  config-git-review →  config-workflow
```

## ⌨️ 快捷键

> 按模块组织，全局绑定加 ⭐。`<leader>` 未设，所有 `C-c <x>` 直接绑。

### 搜索与导航（全局）⭐

| 键 | 命令 | 说明 |
|---|---|---|
| `C-s` | `consult-line` | 当前 buffer 增量搜索 |
| `C-M-s` | `consult-line-multi` | 多 buffer 搜索 |
| `C-x b` | `consult-buffer` | 切换 buffer |
| `M-y` | `consult-yank-pop` | 剪贴板历史 |
| `C-c C-r` | `consult-recent-file` | 最近文件 |
| `C-c g` | `consult-git-grep` | 项目内 git grep |
| `C-c k` | `consult-ripgrep` | 项目内 ripgrep |
| `C-x l` | `consult-locate` | locate 数据库搜索 |
| `C-x r b` | `consult-bookmark` | 书签 |
| `C-c j / J / w` | `avy-goto-char/line/word-1` | 屏幕内快速跳转 |
| `C-.` | `embark-act` | 对当前目标执行上下文操作 |
| `C-;` | `embark-dwim` | 智能默认动作 |
| `C-h B` | `embark-bindings` | 查看键绑定 |

### 补全

Corfu 弹窗内：`C-n/C-p` 上下、`C-i` 完成、`C-s` 分隔、`M-d` 文档、`M-l` 位置。
Vertico 在 minibuffer 中自动启用，`C-n/C-p` 导航。

### 项目（project.el 内置）⭐

| 键 | 命令 |
|---|---|
| `C-c p f` | `project-find-file` |
| `C-c p b` | `project-switch-to-buffer` |
| `C-c p d` | `project-dired` |
| `C-c p v` | `project-vc-dir` |
| `C-c p s` | `eat-project` |
| `C-c p g` | `project-find-regexp` |
| `C-c p p` | `my/project-switch-project` | 切项目并恢复布局 / 或一键 AI 布局 |
| `C-c p w` | `my/project-save-layout` | 保存当前项目窗口布局 |
| `C-c p W` | `my/project-restore-layout` | 恢复已保存的项目布局 |

### AI 审阅 ⭐

| 键 | 命令 | 说明 |
|---|---|---|
| `C-c C-a` | `agent-shell-toggle` | 显示/隐藏 agent 面板 |
| `C-c C-o` | `agent-shell-opencode-start-agent` | 启动 OpenCode |
| `C-c C-d` | 送 diff/文档到 agent | Magit / Markdown buffer 内；仅插入内容，无 preset prompt |
| `C-c f l` | `my/workflow-layout` | 左 treemacs + 右 agent |

Magit 内 Forge（GitHub / GitLab PR/MR）：按 `'` 打开 dispatch 菜单。CLI 审阅：`C-c C-w g/h/L`（gh/glab）。详见 [AI Workbench](./docs/ai-workbench.md) 与 [Forge 指南](./docs/forge-guide.md)。

### AI Workbench（`C-c C-w`）⭐

| 键 | 说明 |
|---|---|
| `C-c C-w n` | 新建 AI Org 任务 + 工作台布局 |
| `C-c C-w r` | 本地 diff → `*AI-Review*` |
| `C-c C-w g` / `h` / `L` | PR/MR 审阅（auto / GitHub `gh` / GitLab `glab`） |
| `C-c C-w a` | 送 Plan/Review 到 agent |
| `C-c C-w P` | 加载 agent profile |
| `C-c C-w m` | 送项目 memory 到 agent |

完整键位见 [AI Workbench 指南](./docs/ai-workbench.md)。

### 窗口

| 键 | 命令 |
|---|---|
| `M-o` | `ace-window`（`x` 删/`m` 换/`n`/`v` 分屏/`b` 选 buffer/`u` 撤销）|
| `C-`` | `my/eat-toggle`（按项目作用域）|

### 撤销

`C-z` 撤销（默认），`C-x u` `vundo` 可视化撤销树。

### Org 模式 ⭐

| 键 | 命令 |
|---|---|
| `C-c c` | `org-capture`（`i` Inbox）|
| `C-c a` | `org-agenda` |
| `C-c l` | `org-store-link` |

### LSP（eglot，编程 buffer 内）⭐

| 键 | 命令 | 说明 |
|---|---|---|
| `C-c s r` | 重命名 | |
| `C-c s f` | `eglot-format` | LSP 格式化（所有 eglot buffer）|
| `C-c s a` | 代码操作 | |
| `C-c s h` | 帮助 | |
| `C-c s d` | 跳声明 | |
| `C-c s i` | 跳实现 | |
| `C-c s t` | 跳类型定义 | |

### 文件格式化（mode 内）

| 键 | 命令 | 适用 |
|---|---|---|
| `C-c C-f` | `apheleia-format-buffer` | TS/TSX/JS/CSS/JSON/HTML（Prettier）|
| `C-c C-f` | `eglot-format-buffer` | `rust-ts-mode` |

### Web / Node

`C-c r n` `my/npm-run`（自动选 pnpm > yarn > npm，运行 `package.json` 脚本）。

### 其他

| 键 | 命令 |
|---|---|
| `C-c y` | `youdao-dictionary-search-at-point+` |

## 📦 外部依赖

以下二进制是配置**真实守护**的（`executable-find` 检测，缺失时优雅降级）——只装你用到的语言/工作流对应的那几个即可。

| 二进制 | 触发什么 | 缺失时行为 | 安装（macOS / Debian-Ubuntu）|
|---|---|---|---|
| `pandoc` | Markdown export (gfm → html5) | 静默回退，能编辑不能导出 | `brew install pandoc` / `apt install pandoc` |
| `rust-analyzer` | Rust LSP（eglot）| 首次开 .rs 时 *Messages* 提示安装命令 | `brew install rust-analyzer` 或 `rustup component add rust-analyzer` |
| `vtsls` | TypeScript LSP（eglot）| 静默回退到 `typescript-language-server` | `npm i -g vtsls`（或 `typescript-language-server`）|
| `python` | Dape Python 调试（debugpy）| 静默跳过，Python 调试不工作 | 系统自带；`pip install debugpy` 装 DAP adapter |
| `node` | Dape Node.js 调试（vscode-js-debug）| 静默跳过，Node 调试不工作 | `brew install node` / `apt install nodejs`；`npm i -g vscode-js-debug` |
| `lldb-dap` | Dape Rust 调试 | 静默跳过，Rust 调试不工作 | `brew install lldb-dap`（LLVM 自带）|
| `delta` | Magit diff 语法高亮（magit-delta）| 静默回退普通 Magit diff | `brew install git-delta` |
| `markdownlint` | Markdown flymake lint | 静默跳过，无 lint 提示 | `brew install markdownlint-cli` |
| `opencode` | agent-shell OpenCode provider | agent 无法启动 | 见 OpenCode 安装文档 |
| `gh` | GitHub PR review（`C-c C-w h`）| 无法用 gh 拉 PR | `brew install gh` |
| `glab` | GitLab MR review（`C-c C-w L`）| 无法用 glab 拉 MR | `brew install glab` |

**Forge（GitHub / GitLab）** 需 `~/.authinfo` 配置 token，见 [Forge 指南](./docs/forge-guide.md)。无 token 时 Magit 仍可用，Forge 功能不可用。

**可选工具**（README 之前提过但配置里不依赖）：
- `ripgrep` — `C-c k` 走 `consult-ripgrep` 速度比 git grep 快 10x
- `plantuml` / `graphviz (dot)` — Org Babel 代码块出图

**没装某个外部二进制不会让启动失败**，只是对应功能降级。

## 📦 主要依赖

### 补全与搜索
- **vertico** / **orderless** / **marginalia** — minibuffer 增强
- **corfu** / **cape** — 弹窗补全
- **consult** / **embark** / **embark-consult** — 搜索与上下文操作
- **avy** — 屏幕内跳转

### 编辑
- **magit** — Git
- **catppuccin-theme** / **doom-modeline** — 主题与 mode-line
- **nerd-icons** / **nerd-icons-dired** / **nerd-icons-corfu** — 图标（TUI 自动关闭）
- **dashboard** — 启动仪表盘
- **which-key** / **editorconfig** — 内置增强
- **ace-window** / **shackle** / **winner** — 窗口管理
- **smartparens** / **rainbow-delimiters** / **rainbow-mode** — 括号/颜色
- **vundo** — 撤销可视化

### Git / 审阅
- **magit** / **forge** / **diff-hl** / **magit-delta** — Git、PR/MR 审阅、行内 diff
- **flymake-markdownlint** — Markdown 结构 lint

### 终端与 Shell
- **eat** — 集成终端（NonGNU ELPA，纯 Elisp）

### 项目
- **project**（Emacs 30 内置）— 项目管理

### Org
- **org**（Emacs 30 内置）— Org 模式基础
- **plantuml-mode** — Babel plantuml 代码块

### 编辑器
- **markdown-mode** — Markdown
- **magit** — Git

### LSP / 语法
- **eglot**（Emacs 30 内置）— LSP 客户端
- **tree-sitter**（Emacs 30 内置）— 语法高亮
- **apheleia** — 异步格式化（prettier）

### 环境
- **exec-path-from-shell** — 同步 `$PATH`（macOS / Linux）

## 📚 详细文档

`docs/` 目录下：

- [配置总览](./docs/configuration-overview.md) — 目标、特性、插件与快捷键体系
- [全局快捷键速查表](./docs/keybindings.md) — 所有键位单一真值源
- [使用场景索引](./docs/usage-scenarios.md)
- [Rust 开发指南](./docs/rust-development.md) — eglot + rust-analyzer
- [Magit Git 管理指南](./docs/magit-guide.md)
- [Forge GitHub/GitLab 指南](./docs/forge-guide.md)
- [AI Workbench 指南](./docs/ai-workbench.md)

## 🔧 TUI 行为

- **启动方式**：emacsclient + daemon（`emacs --daemon` 启动后台服务，`emacsclient -t` 连 TUI frame）
- **24-bit color 终端**：catppuccin mocha 主题直接渲染
- **TUI 字符级 fallback**：nerd-icons-dired / nerd-icons-corfu / dashboard 全部走 unicode 字符（不依赖 Nerd Font）
- **daemon 适配**：`my/load-theme` 走 `server-after-make-frame-hook`，cursor-type / 字体设置跳过 daemon 启动
- **外部依赖**：`pandoc` / `mermaid` / `plantuml` / `dot` / `gnuplot` 用 `executable-find` 守护，未安装不报错

## 📝 许可

个人使用配置。
