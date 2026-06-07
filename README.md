# Emacs 配置

为 Emacs 30.2 优化的个人配置。**GUI / TUI 同源**，所有视觉配置已用 `(display-graphic-p)` 守护，所有外部二进制依赖已用 `executable-find` 守护。

## 📁 目录结构

```
.emacs.d/
├── early-init.el          # 早期初始化（GC / frame / native-comp）
├── init.el                # 主入口
├── custom.el              # custom-set-variables 自动生成
├── config/
│   ├── config-default.el  # 基础设置（编码/dired/cursor/视觉微调）
│   ├── config-org.el      # Org 模式 + Hugo 博客 + Babel
│   ├── config-shared.el   # 跨平台 UI（modeline/dashboard/window/nerd-icons）
│   ├── config-gui.el      # GUI 专属（字体/Mac 暗色/dialog）
│   ├── config-package.el  # 包管理 + 编程工具（vertico/corfu/consult/eglot）
│   ├── config-markdown.el # Markdown 编辑与预览
│   └── config-web.el      # Web 前端（tree-sitter/apheleia/eglot）
├── lisp/                  # 自定义函数（按需）
├── tree-sitter/           # tree-sitter 语法库（运行 M-x treesit-install-language-grammar 安装）
├── var/                   # 运行时数据
└── docs/                  # 详细使用指南
```

## 🚀 快速开始

```bash
git clone <repo> ~/.emacs.d
# 启动 Emacs, 包会自动安装
# 推荐安装 (跨平台): ripgrep, fd, pandoc, plantuml, graphviz (dot)
# macOS GUI:       brew install ripgrep pandoc plantuml graphviz
# Debian/Ubuntu:   sudo apt install ripgrep pandoc plantuml graphviz
```

启动后第一次会从 USTC 镜像下载 ~50 个包，耗时约 30s-2min。

## ⚙️ 加载顺序

`init.el` → `early-init.el` 先跑（GC/frame/native-comp）→ 主入口 `require` 顺序：

```
config-default  →  config-org  →  config-shared  →  config-gui
                →  config-web  →  config-package →  config-markdown
```

`config-shared` 必须在 `config-gui` 之前（gui 依赖 `my/theme`）。

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
| `C-c p s` | `project-shell` |
| `C-c p g` | `project-find-regexp` |

### 窗口

| 键 | 命令 |
|---|---|
| `M-o` | `ace-window`（`x` 删/`m` 换/`n`/`v` 分屏/`b` 选 buffer/`u` 撤销）|
| `C-`` | `vterm-toggle`（按项目作用域）|

### 撤销

`C-z` 撤销（默认），`C-x u` `vundo` 可视化撤销树。

### Org 模式 ⭐

| 键 | 命令 |
|---|---|
| `C-c c` | `org-capture`（`t` 待办 / `i` Inbox / `q` 问题 / `b` 博客）|
| `C-c a` | `org-agenda` |
| `C-c l` | `org-store-link` |
| `C-c r o/i` | `citar-open / insert-citation`（org-mode 内）|

### LSP（eglot，编程 buffer 内）⭐

| 键 | 命令 |
|---|---|
| `C-c s r` | 重命名 |
| `C-c s f` | 格式化（apheleia）|
| `C-c s a` | 代码操作 |
| `C-c s h` | 帮助 |
| `C-c s d` | 跳声明 |
| `C-c s i` | 跳实现 |
| `C-c s t` | 跳类型定义 |

### Web / Node

`C-c r n` `my/npm-run`（自动选 pnpm > yarn > npm，运行 `package.json` 脚本）。

### 其他

| 键 | 命令 |
|---|---|
| `C-c y` | `youdao-dictionary-search-at-point+` |
| `<s-return>` | `toggle-fullscreen`（**仅 GUI**）|

## 📦 主要依赖

### 补全与搜索
- **vertico** / **orderless** / **marginalia** — minibuffer 增强
- **corfu** / **cape** — 弹窗补全
- **consult** / **embark** / **embark-consult** — 搜索与上下文操作
- **avy** — 屏幕内跳转

### 编辑
- **magit** — Git
- **doom-themes** / **doom-modeline** — 主题与 mode-line
- **nerd-icons** / **nerd-icons-dired** / **nerd-icons-corfu** — 图标（TUI 自动关闭）
- **dashboard** — 启动仪表盘
- **which-key** / **editorconfig** — 内置增强
- **ace-window** / **shackle** / **winner** — 窗口管理
- **smartparens** / **rainbow-delimiters** / **rainbow-mode** — 括号/颜色
- **vundo** — 撤销可视化

### 终端与 Shell
- **vterm** / **vterm-toggle** — 集成终端

### 项目
- **project**（Emacs 30 内置）— 项目管理

### Org
- **org** / **org-modern** / **org-appear** — Org 模式美化
- **ox-hugo** — Hugo 博客导出
- **org-download** / **ob-mermaid** / **plantuml-mode** — 附件与 Babel
- **valign** / **citar** — 表格对齐与文献引用

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

- [使用场景索引](./docs/usage-scenarios.md)
- [Rust 开发指南](./docs/rust-development.md) — eglot + rust-analyzer
- [Magit Git 管理指南](./docs/magit-guide.md)
- [笔记管理系统使用指南](./docs/note-taking-guide.md)
- [Org Mode 简化配置指南](./docs/workflow-guide.md)
- [配置改进总结](./docs/improvements.md)

## 🔧 跨平台行为

- **GUI 专属**（在 `config-gui.el`）：字体配置、Mac 暗色模式、像素滚动、`<s-return>` 全屏
- **跨平台**（在 `config-shared.el`）：modeline、dashboard、nerd-icons（TUI 下自动隐藏）、ace-window、shackle
- **TUI 守护**：所有 `nerd-icons` / `dashboard` 图标、`pixel-scroll` 已在 `display-graphic-p` 下静默关闭
- **外部依赖**：`pandoc` / `mermaid` / `plantuml` / `dot` / `gnuplot` 用 `executable-find` 守护，未安装不报错

## 📝 许可

个人使用配置。
