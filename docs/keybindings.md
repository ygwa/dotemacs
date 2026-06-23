# 全局快捷键速查表

> 单一真值源：本表所有键位均与 `config/*.el` 中 `global-set-key` / `use-package :bind` / `define-key` 的实际字符串 1:1 对应。
>
> 命名空间约定：`<leader>` 未设，全部 `C-c <x>` 直接绑。
>
> 4 轮重构后（2026-06）：配置统一 TUI-only（emacsclient + daemon），所有键位对 GUI/TUI 同源。

---

## 🔍 搜索 / 导航（全局）

| 键位 | 命令 | 说明 |
|---|---|---|
| `C-s` | `consult-line` | 当前 buffer 增量搜索 |
| `C-M-s` | `consult-line-multi` | 多 buffer 搜索 |
| `C-x b` | `consult-buffer` | 切换 buffer |
| `M-y` | `consult-yank-pop` | 剪贴板历史 |
| `C-c C-r` | `consult-recent-file` | 最近文件 |
| `C-x r b` | `consult-bookmark` | 书签 |
| `C-x l` | `consult-locate` | locate 数据库搜索 |
| `C-c g` | `consult-git-grep` | 项目内 git grep |
| `C-c k` | `consult-ripgrep` | 项目内 ripgrep |
| `C-c j` | `avy-goto-char` | 屏幕内跳到字符 |
| `C-c J` | `avy-goto-line` | 屏幕内跳到行 |
| `C-c W` | `avy-goto-word-1` | 屏幕内跳到单词 |
| `C-.` | `embark-act` | 对当前目标执行上下文操作 |
| `C-;` | `embark-dwim` | 智能默认动作 |
| `C-h B` | `embark-bindings` | 查看键绑定 |
| `C-h f` | `consult-describe-function` | 描述函数（`<f1> f` 同效） |
| `C-h v` | `consult-describe-variable` | 描述变量（`<f1> v` 同效） |
| `<f1> l` | `consult-find-library` | 查找 elisp 库 |
| `<f2> i` | `consult-info-lookup-symbol` | Info 查符号 |
| `<f2> u` | `consult-unicode-char` | Unicode 字符查询 |
| `<f6>` | `consult-buffer` | 切 buffer（与 `C-x b` 等效） |
| `C-r` (minibuffer) | `consult-expression-history` | minibuffer 表达式历史（`read-expression-map` 内） |

## 📁 项目（project.el 内置，Emacs 30）

| 键位 | 命令 | 说明 |
|---|---|---|
| `C-c p f` | `project-find-file` | 查找项目文件 |
| `C-c p b` | `project-switch-to-buffer` | 切换项目 buffer |
| `C-c p d` | `project-dired` | 打开项目根 dired |
| `C-c p v` | `project-vc-dir` | 打开项目 VCS 目录 |
| `C-c p s` | `eat-project` | 打开项目 Eat 终端 |
| `C-c p g` | `project-find-regexp` | 项目内搜 regex |
| `C-c p p` | `my/project-switch-project` | 切项目；有保存布局则恢复，否则 AI 工作台布局 |
| `C-c p w` | `my/project-save-layout` | 保存当前项目窗口布局 |
| `C-c p W` | `my/project-restore-layout` | 恢复当前项目已保存布局 |

## 🤖 AI Agent Shell（agent-shell + OpenCode）

> 工作流关键键位，与 `config-agent.el` 同步。

| 键位 | 命令 | 说明 |
|---|---|---|
| `C-c C-a` | `agent-shell-toggle` | 显示/隐藏当前 agent buffer |
| `C-c C-s` | `agent-shell-new-shell` | 新建会话（不同项目/任务） |
| `C-c C-o` | `agent-shell-opencode-start-agent` | 直接起 OpenCode（跳过选 provider） |
| `C-c C-t` | `my/agent-shell-view-transcript` | 在 markdown 中查看当前对话记录 |
| `C-c C-d` | `my/magit-send-diff-to-agent` / `my/markdown-send-to-agent` | Magit / Markdown 内：插入 diff 或文档到 agent 输入区（无 preset prompt） |
| `C-.` | embark-act | 可选动作含 “Send git diff / Markdown to agent shell” |

## 🧩 AI Workbench（`C-c C-w` 前缀）

> 与 `config-ai-workbench.el` 同步。详见 [AI Workbench 指南](./ai-workbench.md)。

| 键位 | 命令 | 说明 |
|---|---|---|
| `C-c C-w n` | `my/ai-new-task` | AI Org 任务 + 布局 + agent |
| `C-c C-w p` | `my/ai-plan-from-org` | Org 标题 → `*AI-Plan*` |
| `C-c C-w a` | `my/ai-send-active-to-agent` | 送 Plan/Review 到 agent |
| `C-c C-w r` | `my/ai-review-local` | 本地 diff → `*AI-Review*` |
| `C-c C-w R` | `my/ai-review-send-to-agent` | 送 review 到 agent |
| `C-c C-w S` | `my/ai-review-save` | 保存到 `.agent/reviews/` |
| `C-c C-w g` | `my/ai-pr-review` | PR/MR 自动检测（gh/glab） |
| `C-c C-w h` | `my/ai-pr-review-github` | GitHub PR（`gh`） |
| `C-c C-w L` | `my/ai-pr-review-gitlab` | GitLab MR（`glab`） |
| `C-c C-w G` | `my/ai-pr-review-send-to-agent` | 拉 PR/MR 并送 agent |
| `C-c C-w P` | `my/ai-start-with-profile` | 加载 agent profile |
| `C-c C-w M` | `my/ai-memory-capture` | 追加 memory 笔记 |
| `C-c C-w m` | `my/ai-memory-send-to-agent` | 送 memory 到 agent |
| `C-c C-w o` / `d` | memory / decisions.org | 打开项目记忆文件 |
| `C-c C-w t` | `my/ai-tool-run` | 工具注册表 |
| `C-c C-w l` | `my/ai-log-show` | 显示 `*AI-Log*` |

## 🔍 Git 审阅（diff-hl / delta / forge）

| 键位 | 命令 | 说明 |
|---|---|---|
| （prog-mode 自动） | `diff-hl-mode` | 行内未提交改动标记 |
| `C-x g` | `magit-status` | Magit 状态窗 |
| `C-c C-d` | `my/magit-send-diff-to-agent` | Magit buffer 内送 diff 到 agent |
| `'` | `forge-dispatch` | Magit 内 Forge 菜单（GitHub / GitLab PR/MR） |
| 详见 [Forge 指南](./forge-guide.md) | | token 配置与自托管 GitLab |

## 📝 Markdown 审阅

| 键位 | 命令 | 说明 |
|---|---|---|
| `C-c C-d` | `my/markdown-send-to-agent` | 送 region 或全文到 agent |
| （markdown-mode 自动） | `flymake-mode` + markdownlint | 需 `markdownlint` 二进制 |
| `M-x markdown-view-mode` | TUI 渲染视图 | 只读预览 |

## 🧠 LSP（eglot，编程 buffer 内）

> `eglot-mode-map` 内绑定，前缀 `C-c s`（= **s**erver）。

| 键位 | 命令 | 说明 |
|---|---|---|
| `C-c s r` | `eglot-rename` | 重命名符号 |
| `C-c s f` | `eglot-format` | LSP 格式化（Web 文件格式化优先用 `C-c C-f` apheleia） |
| `C-c s a` | `eglot-code-actions` | 代码操作（Quick Fix） |
| `C-c s h` | `eglot-help-at-point` | 光标处文档 |
| `C-c s d` | `eglot-find-declaration` | 跳声明 |
| `C-c s i` | `eglot-find-implementation` | 跳实现（trait 等） |
| `C-c s t` | `eglot-find-typeDefinition` | 跳类型定义 |
| `C-c s o` | `eglot-code-action-organize-imports` | 整理 import（typescript-ts / tsx-ts mode 内） |
| `C-c e s` | `consult-eglot-symbols` | 按 LSP 符号搜项目 |

> 💡 **代码跳转**走原生 xref，**不绑 LSP 键**：
> `M-.` 跳定义 / `M-,` 跳回 / `M-?` 查引用 / `C-M-.` 模糊搜符号

## 🪟 窗口

| 键位 | 命令 | 说明 |
|---|---|---|
| `M-o` | `ace-window` | 快速跳转分屏；弹窗内：<br>`x` 删窗 / `m` 换窗 / `n` 横分 / `v` 竖分 / `b` 选 buffer / `o` 最大化 / `=` 平铺 / `u` 撤销 |
| `C-c <left>` | `winner-undo` | 撤销布局（emacs winner-mode 内置） |
| `C-c <right>` | `winner-redo` | 重做布局 |
| `S-<left>` / `S-<right>` / `S-<up>` / `S-<down>` | `windmove-left` / `right` / `up` / `down` | 移焦点（`windmove-default-keybindings`） |
| `S-M-<left>` | `windmove-swap-states-left` | 移窗 |
| `S-M-<right>` | `windmove-swap-states-right` | 移窗 |
| `S-M-<up>` | `windmove-swap-states-up` | 移窗 |
| `S-M-<down>` | `windmove-swap-states-down` | 移窗 |

## 🌲 Treemacs 文件树

| 键位 | 命令 | 说明 |
|---|---|---|
| `C-x t 1` | `treemacs-select-window` | 跳到 treemacs 窗 |
| `C-x t t` | `treemacs` | 切换 treemacs |
| `C-x t d` | `treemacs-delete-other-windows` | 删其它窗 |

## 🛠️ 工作流布局

| 键位 | 命令 | 说明 |
|---|---|---|
| `C-c f l` | `my/workflow-layout` | 一键 AI 工作台：左 treemacs + 右 agent-shell |
| `C-c f c` | （清窗 lambda） | 关掉所有其它窗 |
| `C-c r n` | `my/npm-run` | 选 pnpm > yarn > npm 跑 `package.json` 脚本（web/node 项目） |
| `C-c y` | `youdao-dictionary-search-at-point+` | 光标处查词典 |
| `C-c C-f` | `apheleia-format-buffer` | 格式化整个文件（typescript / tsx / js mode 内） |
| `C-c C-f` | `eglot-format-buffer` | 格式化整个文件（rust-ts-mode 内） |

## 🔧 Git / Magit

| 键位 | 命令 | 说明 |
|---|---|---|
| `C-x g` | `magit-status` | 打开 magit 状态窗 |
| 详见 [Magit 指南](./magit-guide.md) | | magit buffer 内单字母键 |

## 💻 终端 / Shell

| 键位 | 命令 | 说明 |
|---|---|---|
| `C-` ` | `my/eat-toggle` | 切 Eat 终端（按项目作用域） |

## 🐛 调试（Dape，Emacs 30 内置 DAP）

| 键位 | 命令 | 说明 |
|---|---|---|
| `<f5>` | `dape` | 启动调试（按 dir-locals） |
| `M-<f5>` | `dape-hydra/body` | 速查表（下一步/进入/出/继续/断点） |
| `C-c d b` | `dape-breakpoint-toggle` | 当前行切断点 |

## ↩️ 撤销

| 键位 | 命令 | 说明 |
|---|---|---|
| `C-z` | `undo` | 撤销（默认） |
| `C-x u` | `vundo` | 可视化撤销树 |

## ✏️ 拼写（Jinx）

| 键位 | 命令 | 说明 |
|---|---|---|
| `M-$` | `jinx-correct` | 拼写纠正（remap ispell-word） |

> ⚠️ Jinx 需 `brew install enchant2 pkgconf`（macOS）才生效；未装时 `M-$` 提示失败但不中断编辑器。

## 📝 Org 模式

| 键位 | 命令 | 说明 |
|---|---|---|
| `C-c c` | `org-capture` | 捕获条目（Inbox / 任务） |
| `C-c a` | `org-agenda` | 打开 agenda |
| `C-c l` | `org-store-link` | 存链接 |

## 🌐 Web / Node

| 键位 | 命令 | 说明 |
|---|---|---|
| `C-c r n` | `my/npm-run` | 选 pnpm > yarn > npm 跑 `package.json` 脚本 |

## 📐 内置补全（Corfu 弹窗内）

| 键位 | 命令 | 说明 |
|---|---|---|
| `C-n` / `C-p` | `corfu-next` / `corfu-previous` | 上下选 |
| `C-i` | `corfu-complete` | 完成 |
| `C-s` | `corfu-insert-separator` | 插入分隔符（多候选） |
| `M-d` | `corfu-show-documentation` | 看文档 |
| `M-l` | `corfu-show-location` | 看位置 |

## 🔢 内置 minibuffer（Vertico）

| 键位 | 说明 |
|---|---|
| `C-n` / `C-p` | 上下导航候选 |

---

## 🗂️ 按键位字母序速查（精简版）

| 键位 | 命令 | 模块 |
|---|---|---|
| `C-.` | embark-act | embark |
| `C-;` | embark-dwim | embark |
| `` C-` `` | my/eat-toggle | eat |
| `C-c C-a` | agent-shell-toggle | agent-shell |
| `C-c C-d` | my/magit-send-diff-to-agent / my/markdown-send-to-agent | agent |
| `C-c C-o` | agent-shell-opencode-start-agent | agent-shell |
| `C-c C-r` | consult-recent-file | consult |
| `C-c C-s` | agent-shell-new-shell | agent-shell |
| `C-c C-t` | my/agent-shell-view-transcript | agent-shell |
| `C-c <left>` | winner-undo | winner |
| `C-c <right>` | winner-redo | winner |
| `C-c a` | org-agenda | org |
| `C-c c` | org-capture | org |
| `C-c d b` | dape-breakpoint-toggle | dape |
| `C-c e s` | consult-eglot-symbols | consult-eglot |
| `C-c f c` | （清窗） | workflow |
| `C-c f l` | my/workflow-layout | workflow |
| `C-c g` | consult-git-grep | consult |
| `C-c j` | avy-goto-char | avy |
| `C-c J` | avy-goto-line | avy |
| `C-c k` | consult-ripgrep | consult |
| `C-c l` | org-store-link | org |
| `C-c p b` | project-switch-to-buffer | project |
| `C-c p d` | project-dired | project |
| `C-c p f` | project-find-file | project |
| `C-c p g` | project-find-regexp | project |
| `C-c p p` | my/project-switch-project | workflow |
| `C-c p s` | eat-project | eat |
| `C-c p v` | project-vc-dir | project |
| `C-c p w` | my/project-save-layout | workflow |
| `C-c p W` | my/project-restore-layout | workflow |
| `C-c r n` | my/npm-run | web |
| `C-c s a` | eglot-code-actions | eglot |
| `C-c s d` | eglot-find-declaration | eglot |
| `C-c s f` | eglot-format | eglot |
| `C-c s h` | eglot-help-at-point | eglot |
| `C-c s i` | eglot-find-implementation | eglot |
| `C-c s r` | eglot-rename | eglot |
| `C-c s t` | eglot-find-typeDefinition | eglot |
| `C-c W` | avy-goto-word-1 | avy |
| `C-h B` | embark-bindings | embark |
| `C-M-s` | consult-line-multi | consult |
| `C-x b` | consult-buffer | consult |
| `C-x g` | magit-status | magit |
| `C-x l` | consult-locate | consult |
| `C-x r b` | consult-bookmark | consult |
| `C-x t 1` | treemacs-select-window | treemacs |
| `C-x t d` | treemacs-delete-other-windows | treemacs |
| `C-x t t` | treemacs | treemacs |
| `C-x u` | vundo | vundo |
| `C-z` | undo | undo |
| `M-$` | jinx-correct | jinx |
| `M-o` | ace-window | ace-window |
| `M-y` | consult-yank-pop | consult |
| `S-M-<arrows>` | windmove-swap-states-* | windmove |
| `S-<arrows>` | windmove | windmove |
| `<f1> f` | consult-describe-function | consult |
| `<f1> l` | consult-find-library | consult |
| `<f1> v` | consult-describe-variable | consult |
| `<f2> i` | consult-info-lookup-symbol | consult |
| `<f2> u` | consult-unicode-char | consult |
| `<f5>` | dape | dape |
| `<f6>` | consult-buffer | consult |
| `M-<f5>` | dape-hydra/body | dape |

---

## 📖 模块↔文档索引

| 模块 | 主文档 |
|---|---|
| Magit | [magit-guide.md](./magit-guide.md) |
| Forge (GitHub/GitLab) | [forge-guide.md](./forge-guide.md) |
| Rust 开发 | [rust-development.md](./rust-development.md) |
| 使用场景 | [usage-scenarios.md](./usage-scenarios.md) |
