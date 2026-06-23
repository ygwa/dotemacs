# Emacs 配置总览

> 本文档总结 `~/.emacs.d` 的设计目标、期望能力、技术选型与快捷键体系。  
> 键位细节以 [keybindings.md](./keybindings.md) 为单一真值源；场景工作流见 [usage-scenarios.md](./usage-scenarios.md)。

---

## 1. 核心目标

### 1.1 定位

为 **Emacs 30.2** 打造一套个人化、**TUI 优先** 的 **AI 工作台** 开发环境。

### 1.2 架构原则（2026-06 起）

| 原则 | 说明 |
|------|------|
| **TUI-only** | 统一在 `emacsclient + daemon` 下运行；早期 GUI 分支（`config-gui.el`）已下线 |
| **快速启动** | `early-init.el` 启动期 GC 最大化、延迟加载、`:defer` 按需加载 |
| **模块化** | 按职责拆分到 `config/*.el`，`init.el` 只做入口与加载顺序 |
| **稳定降级** | 外部二进制用 `executable-find` 检测，缺失时功能降级而非启动失败 |
| **单一键位源** | 无 `<leader>` 前缀，直接 `C-c <x>` 绑定；文档与代码 1:1 对应 |

### 1.3 期望做到的事

1. **日常入口**：启动即见 Dashboard（最近文件、项目、Org Agenda），快速进入工作状态  
2. **项目管理**：基于 Git + `project.el`，支持非 Git 前端项目（`package.json` 等 marker）  
3. **编程体验**：Tree-sitter 语法高亮 + Eglot LSP + Corfu 补全 + Consult 搜索  
4. **AI 辅助开发**：Treemacs 文件树 + agent-shell（OpenCode）右侧面板，一键布局  
5. **知识管理**：Org Inbox capture + Agenda，与 Dashboard 联动  
6. **多语言支持**：Rust / Python / TypeScript·JS / Web 前端 / Markdown  
7. **终端集成**：Eat 按项目作用域切换，适合 TUI 工作流  
8. **Git 工作流**：Magit 状态管理 + treemacs-magit 集成  

---

## 2. 启动与运行模型

```
early-init.el          → GC / frame / native-comp / 禁用 splash
        ↓
init.el                → load-path / package / exec-path-from-shell
        ↓
config-default         → 编码、dired、光标
config-org             → Org 路径、capture、agenda
config-shared          → 主题、modeline、窗口、dashboard
config-treesit       → Tree-sitter 语法库与 mode remap
config-web             → 前端 LSP、Prettier、npm 脚本
config-package       → 补全、搜索、Magit、eglot、dape、jinx
config-markdown      → Markdown 编辑与预览
config-agent         → agent-shell + OpenCode
config-ai-*          → Agent OS（memory / review / gh+glab / workbench）
config-git-review    → diff-hl / forge / magit-delta
config-workflow      → treemacs + 一键 AI 布局
```

**推荐启动方式：**

```bash
emacs --daemon          # 后台服务
emacsclient -t          # 终端连接 TUI frame
```

**性能策略：**

- 启动期 `gc-cons-threshold` 设为最大，完成后恢复 32MB  
- `use-package :defer t` 延迟非首屏包  
- USTC 镜像 ELPA（gnu / melpa / nongnu）  
- Native Comp JIT + `eln-cache/` 本地缓存  

---

## 3. 功能模块与特性

### 3.1 界面与视觉（TUI）

| 特性 | 实现 |
|------|------|
| 主题 | **catppuccin** mocha，24-bit color 终端直接渲染 |
| Mode line | **doom-modeline**，TUI 下关闭所有像素/unicode 图标 |
| 启动页 | **dashboard**：最近文件、项目、本周 Agenda |
| 行号 | `prog-mode` 相对行号；Org 关闭行号 |
| 折行 | 文本/Org/Info 开 `visual-line-mode`；编程 buffer 保持硬换行 |
| 图标 | **nerd-icons-dired / nerd-icons-corfu** 走 unicode 字符 fallback，不依赖 Nerd Font |
| 拼写 | **jinx**（需 enchant2），`M-$` 纠正 |
| 括号 | **rainbow-delimiters** + **smartparens** |
| 撤销 | `C-z` 普通撤销；`C-x u` **vundo** 可视化撤销树 |

### 3.2 搜索、补全与导航

采用 **Vertico + Orderless + Marginalia + Corfu + Cape + Consult + Embark + Avy** 组合：

| 层次 | 包 | 作用 |
|------|-----|------|
| Minibuffer | vertico, orderless, marginalia | 候选展示、模糊匹配、元数据 |
| 弹窗补全 | corfu, cape, nerd-icons-corfu | 2 字符触发、文件/历史/dabbrev 补全 |
| 搜索 | consult | 行搜索、buffer、ripgrep、书签、recent 等 |
| 上下文操作 | embark, embark-consult | `C-.` 对当前目标执行相关命令 |
| 屏幕跳转 | avy | `C-c j/J/W` 字符/行/词跳转 |

### 3.3 项目管理

- **project.el**（Emacs 30 内置）：`C-c p *` 前缀  
- 扩展 root marker：`package.json`、`requirements.txt`、`.project`  
- **treemacs** + **treemacs-magit**：左侧文件树，Git 状态集成  
- **shackle** + **ace-window** + **winner** + **windmove**：窗口布局与快速切换  

### 3.4 编程与 LSP

| 语言/场景 | Mode | LSP Server | 格式化 |
|-----------|------|------------|--------|
| Rust | rust-ts-mode | rust-analyzer | `C-c C-f` → eglot-format-buffer |
| Python | python-ts-mode | eglot 默认 | eglot |
| TypeScript/TSX/JS | *-ts-mode | vtsls（回退 typescript-language-server） | `C-c C-f` → apheleia (Prettier) |
| CSS | css-ts-mode | tailwindcss-language-server | Prettier |
| Markdown | markdown-ts-mode（Emacs 30+） | — | pandoc export（可选） |

**代码跳转**走原生 xref（不额外绑 LSP 键）：

- `M-.` 跳定义  
- `M-,` 跳回  
- `M-?` 查引用  
- `C-M-.` 模糊搜符号  

**LSP 专用前缀 `C-c s`（server）：** 重命名、格式化、代码操作、帮助、跳声明/实现/类型、整理 import（TS/TSX）

**符号搜索：** `C-c e s` → consult-eglot-symbols

### 3.5 Tree-sitter

- 语法库目录：`tree-sitter/`  
- Rust 预编译库开箱即用；Web/TS 需 `M-x treesit-install-language-grammar` 或 `M-x my/install-all-treesit-grammars`  
- `major-mode-remap-alist` 将 js/ts/json/css/yaml/python/markdown 映射到 `*-ts-mode`  

### 3.6 调试（Dape）

Emacs 30 内置 DAP 客户端 **dape**，替代 dap-mode：

| 语言 | Adapter | 依赖 |
|------|---------|------|
| Python | debugpy | `pip install debugpy` |
| Node/TS | vscode-js-debug | `npm i -g vscode-js-debug` |
| Rust | lldb-dap | `brew install lldb-dap` |

键位：`<f5>` 启动、`M-<f5>` 速查表、`C-c d b` 切换断点

### 3.7 Git

- **magit**：`C-x g` 打开状态  
- 详见 [magit-guide.md](./magit-guide.md)  

### 3.8 Org 知识管理

- 根目录：`~/Documents/org/`（可通过 `M-x customize-group my-config` 修改）  
- 默认笔记：`inbox.org`  
- Capture：`C-c c` → `i` 写入 Inbox headline  
- Agenda：`C-c a`；Dashboard 展示本周 agenda  
- 存链接：`C-c l`  

### 3.9 Markdown

- **markdown-mode** + Tree-sitter 增强（Emacs 30+）  
- 编辑期：隐藏 markup、代码块原生高亮、electric pair  
- 查看：`M-x markdown-view-mode` / `gfm-view-mode`（TUI 只读渲染）  
- 导出：`C-c C-e`（需 pandoc）；预览：`C-c C-p`  

### 3.10 AI Agent 工作流

- **agent-shell** + **OpenCode**（`opencode acp`）  
- 右侧 side window（40% 宽），跟随 VCS 项目根  
- 对话 transcript 自动保存到 `.agent-shell/transcripts/`  
- 上下文注入：region / 文件 / 错误行 / 当前行  
- 一键布局 `C-c f l`：左 treemacs + 右 agent-shell  

### 3.11 终端

- **eat**：`` C-` `` `my/eat-toggle` / `C-c p s` `eat-project` 按项目作用域切换  

### 3.12 其它工具

- **youdao-dictionary**：`C-c y` 光标处查词  
- **ws-butler**：保存时清理被修改行的 trailing whitespace  
- **editorconfig** / **which-key**（Emacs 内置）  
- **plantuml-mode**：Org Babel 出图（需 plantuml / dot）  

---

## 4. 插件与依赖清单

### 4.1 Emacs 30 内置（:ensure nil）

| 包 | 用途 |
|----|------|
| use-package | 声明式配置 |
| project | 项目管理 |
| org | 笔记与 Agenda |
| eglot | LSP 客户端 |
| tree-sitter | 语法解析 |
| dape | DAP 调试 |
| which-key / editorconfig | 键位提示 / 编辑器配置 |

### 4.2 ELPA 第三方包（约 50+）

**补全与搜索：** vertico, orderless, marginalia, corfu, cape, consult, embark, embark-consult, avy, consult-eglot  

**编辑与 UI：** catppuccin-theme, doom-modeline, dashboard, nerd-icons-dired, nerd-icons-corfu, ace-window, shackle, rainbow-delimiters, rainbow-mode, smartparens, vundo, jinx, ws-butler  

**开发工具：** magit, eat, apheleia, dape, plantuml-mode  

**AI 与工作流：** agent-shell, treemacs, treemacs-magit  

**语言模式：** markdown-mode  

**环境：** exec-path-from-shell  

**词典：** youdao-dictionary  

### 4.3 外部二进制（可选，缺失时降级）

| 二进制 | 触发功能 |
|--------|----------|
| pandoc | Markdown export |
| rust-analyzer | Rust LSP |
| vtsls / typescript-language-server | TS/JS LSP |
| tailwindcss-language-server | CSS LSP |
| prettier | Web 格式化（apheleia） |
| ripgrep | `C-c k` 项目搜索 |
| python + debugpy | Python 调试 |
| node + vscode-js-debug | Node 调试 |
| lldb-dap | Rust 调试 |
| enchant2 + pkgconf | jinx 拼写检查 |
| opencode | AI agent（agent-shell） |

---

## 5. 快捷键体系

### 5.1 命名空间约定

- **无 `<leader>`**：所有自定义键直接绑定，不经过 evil/leader 层  
- **前缀分区**：按功能模块划分前缀，避免冲突  

| 前缀/区域 | 模块 | 示例 |
|-----------|------|------|
| `C-s` / `C-M-s` | Consult 行搜索 | 当前 buffer / 多 buffer |
| `C-x b/l/g` 等 | 内置键 remap 到 Consult/Magit | buffer / locate / magit |
| `C-c p *` | project.el | `f` 找文件、`g` 搜 regex |
| `C-c s *` | eglot（编程 buffer 内） | `r` 重命名、`a` 代码操作 |
| `C-c e s` | consult-eglot | LSP 符号搜索 |
| `C-c C-*` | 双 Ctrl 高优先级 | `C-a` agent、`C-s` 新 shell |
| `C-c f *` | workflow 布局 | `l` 一键 AI 工作台 |
| `C-c r n` | Web/Node | npm/yarn/pnpm 跑脚本 |
| `C-c j/J/W` | avy | 屏幕内跳转 |
| `C-c g/k` | consult | git grep / ripgrep |
| `C-c a/c/l` | org | agenda / capture / store-link |
| `C-x t *` | treemacs | `t` 切换、`1` 聚焦 |
| `M-o` | ace-window | 窗口跳转与分屏 |
| `C-` ` | my/eat-toggle | 项目终端 |
| `C-.` / `C-;` | embark | 上下文操作 / DWIM |
| `M-$` | jinx | 拼写纠正 |
| `<f5>` / `M-<f5>` | dape | 调试 / 速查表 |

### 5.2 按使用频率分层

**⭐ 全局高频（每天必用）**

```
C-s          consult-line              当前 buffer 搜索
C-x b        consult-buffer            切换 buffer
C-c p f      project-find-file         项目内找文件
C-c g/k      git-grep / ripgrep        项目内搜索
C-x g        magit-status              Git 状态
M-o          ace-window                窗口跳转
C-c c/a      org-capture / org-agenda  笔记与日程
C-c f l      my/workflow-layout        AI 工作台布局
C-c C-a      agent-shell-toggle        AI 面板
C-`          my/eat-toggle             终端
```

**编程 buffer 内**

```
M-. / M-,    xref                      跳定义 / 跳回
C-c s *      eglot                     LSP 操作
C-c C-f      apheleia / eglot-format   格式化
C-n/C-p      corfu                     补全导航
```

**辅助 / 低频**

```
C-x u        vundo                     可视化撤销
C-h B        embark-bindings           查键绑定
C-c y        youdao-dictionary         查词
C-c C-t      view agent transcript     查看 AI 对话记录
```

### 5.3 键位冲突规避策略

- Org 占 `C-c a/c/l`，agent-shell 用双 Ctrl `C-c C-a/s/o/t`  
- eglot 统一 `C-c s`（server），不与 project `C-c p` 冲突  
- workflow 用 `C-c f`（flow），Web 脚本用 `C-c r`（run）  
- Magit 保留标准 `C-x g`  

---

## 6. 典型工作流

### 6.1 日常启动

1. `emacs --daemon` → `emacsclient -t`  
2. Dashboard 显示最近文件、项目、Agenda  
3. `r` 进最近文件 / `p` 进项目 / `a` 开 Agenda  

### 6.2 AI 辅助编程

1. 进入项目 → `C-c f l`（treemacs + agent-shell）  
2. 左侧浏览文件，右侧与 OpenCode 对话  
3. `C-c C-t` 在 Markdown 中查看 transcript  
4. 结束 → `C-c f c` 清窗  

### 6.3 项目内开发

1. `C-c p f` 找文件 → 自动 eglot + corfu  
2. `M-.` 跳定义，`C-c s a` Quick Fix  
3. `C-c C-f` 格式化 → `C-x g` Magit 提交  

### 6.4 快速捕获想法

1. `C-c c` → `i` → 写入 Inbox  
2. `C-c a` 在 Agenda 中处理  

---

## 7. 配置自定义入口

| 方式 | 说明 |
|------|------|
| `M-x customize-group my-config` | 修改 `my/org-root-dir` 等个人变量 |
| `custom.el` | `custom-set-variables` 自动生成，勿手改 |
| `M-x customize-variable my/theme-flavor` | 切换 catppuccin flavor |

---

## 8. 相关文档索引

| 文档 | 内容 |
|------|------|
| [keybindings.md](./keybindings.md) | 全部键位单一真值源 |
| [usage-scenarios.md](./usage-scenarios.md) | 场景工作流索引 |
| [rust-development.md](./rust-development.md) | Rust + eglot 指南 |
| [magit-guide.md](./magit-guide.md) | Magit 单字母键与提交流程 |
| [../README.md](../README.md) | 快速开始与目录结构 |

---

*最后更新：2026-06，对应 4 轮重构后的 TUI-only 配置。*
