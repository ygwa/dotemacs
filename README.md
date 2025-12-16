# Emacs 配置

这是一个为 Emacs 30.2 优化的配置仓库。

## 📁 目录结构

```
.emacs.d/
├── early-init.el          # 早期初始化（性能优化）
├── init.el                # 主入口文件
├── config/                # 配置文件目录
│   ├── config-default.el  # 默认设置
│   ├── config-gui.el      # 界面配置
│   ├── config-package.el  # 包管理配置
│   ├── config-org.el      # Org 模式配置
│   ├── config-hugo.el     # Hugo 博客配置
│   └── config-export.el   # 导出配置
├── lisp/                  # 自定义函数和工具
│   ├── init-utils.el      # 初始化工具函数
│   └── package-utils.el   # 包管理工具函数
├── scripts/               # 辅助脚本
│   ├── check-packages.el  # 包检查脚本
│   └── fix-packages.el    # 包修复脚本
└── docs/                  # 文档目录
    ├── MIGRATION-GUIDE.md
    ├── PACKAGE-OPTIMIZATION.md
    └── ...
```

## 🚀 快速开始

1. 克隆或复制此配置到 `~/.emacs.d/`
2. 启动 Emacs，包会自动安装
3. 确保安装了 ripgrep（某些功能需要）：
   ```bash
   brew install ripgrep
   ```

## 📚 文档

### 使用场景指南

详细的使用场景指南请查看 `docs/` 目录：

- **[使用场景索引](./docs/usage-scenarios.md)** - 所有使用场景的索引
- **[Rust 开发指南](./docs/rust-development.md)** - 使用 Eglot 和 rust-analyzer 进行 Rust 开发的完整指南
- **[Projectile 项目管理指南](./docs/projectile-guide.md)** - Projectile 的完整功能和使用指南
- **[Magit Git 管理指南](./docs/magit-guide.md)** - Magit 的完整功能和使用指南

### 其他文档

- `docs/MIGRATION-GUIDE.md` - 包迁移指南
- `docs/PACKAGE-OPTIMIZATION.md` - 包优化说明
- `docs/STRUCTURE-OPTIMIZATION.md` - 结构优化说明

## ⚙️ 主要特性

- ✅ Emacs 30.2 优化
- ✅ 现代化包栈（vertico, consult, embark）
- ✅ 原生编译支持
- ✅ 性能优化
- ✅ 模块化配置

## ⌨️ 快捷键指南

### 🔍 搜索和导航

#### Consult（现代化搜索命令集合）
- `C-s` - 在当前缓冲区中搜索（`consult-line`）
- `C-M-s` - 在多个缓冲区中搜索（`consult-line-multi`）
- `C-x b` - 切换缓冲区（`consult-buffer`）
- `M-y` - 查看剪贴板历史（`consult-yank-pop`）
- `C-x r b` - 打开书签（`consult-bookmark`）
- `C-c C-r` - 打开最近文件（`consult-recent-file`）
- `C-c g` - Git Grep 搜索（`consult-git-grep`）
- `C-c k` - 使用 ripgrep 搜索（`consult-ripgrep`，替代 `counsel-ag`）
- `C-x l` - 定位文件（`consult-locate`）
- `<f1> f` - 描述函数（`consult-describe-function`）
- `<f1> v` - 描述变量（`consult-describe-variable`）
- `<f1> l` - 查找库（`consult-find-library`）
- `<f2> i` - 信息查找符号（`consult-info-lookup-symbol`）
- `<f2> u` - Unicode 字符查找（`consult-unicode-char`）
- `<f6>` - 切换缓冲区（`consult-buffer`，替代 `ivy-resume`）

#### Embark（上下文操作）
- `C-.` - 对当前目标执行操作（`embark-act`）
- `C-;` - 执行默认操作（`embark-dwim`）
- `C-h B` - 查看所有键绑定（`embark-bindings`）

#### Avy（快速跳转）
- `C-c j` - 跳转到字符（`avy-goto-char`）
- `C-c J` - 跳转到行（`avy-goto-line`）
- `C-c w` - 跳转到单词（`avy-goto-word-1`）

#### Vertico（垂直补全框架）
- 自动启用，无需快捷键
- 在 minibuffer 中使用 `C-n`/`C-p` 导航候选项

### 💻 代码补全

#### Corfu（现代补全弹窗）
- `C-n` - 下一个候选项（`corfu-next`）
- `C-p` - 上一个候选项（`corfu-previous`）
- `C-i` - 完成补全（`corfu-complete`）
- `C-s` - 插入分隔符（`corfu-insert-separator`）
- `M-d` - 显示文档（`corfu-show-documentation`）
- `M-l` - 显示位置（`corfu-show-location`）

#### Cape（补全后端）
- 自动集成到 `completion-at-point`，无需快捷键

### 📁 项目管理

#### Projectile

Projectile 是强大的项目管理工具，可以快速切换项目、查找文件、搜索代码等。

**快捷键：**
- `s-p` - 打开 Projectile 命令菜单（`projectile-command-map`）
- `C-c p` - 打开 Projectile 命令菜单（`projectile-command-map`）

**常用命令（在 `C-c p` 或 `s-p` 后输入）：**
- `p` - 切换项目（`projectile-switch-project`）
- `f` - 在当前项目中查找文件（`projectile-find-file`）
- `d` - 在 dired 模式下打开项目根目录（`projectile-dired`）
- `b` - 显示当前项目中已打开的缓冲区列表（`projectile-switch-to-buffer`）
- `s g` - 在项目中执行 grep 搜索（`projectile-grep`）
- `s s` - 在项目中搜索（`projectile-ag`，需要 ag 或 ripgrep）
- `a` - 添加项目到已知项目列表（`projectile-add-known-project`）
- `r` - 从已知项目列表中移除项目（`projectile-remove-known-project`）
- `D` - 打开项目根目录（`projectile-dired`）
- `c` - 编译项目（`projectile-compile-project`）
- `T` - 运行测试（`projectile-test-project`）

**如何添加项目到项目清单：**

Projectile 会自动识别包含以下文件或目录的目录作为项目根目录：
- `.git`（Git 仓库）
- `.hg`（Mercurial 仓库）
- `.projectile`（Projectile 项目标记文件）
- `Makefile`、`CMakeLists.txt`、`pom.xml`、`package.json` 等

**方法 1：自动识别**
- 如果项目包含 `.git` 目录或其他项目标记文件，Projectile 会自动识别
- 只需在项目目录中打开文件，Projectile 会自动检测

**方法 2：手动添加**
- 使用命令：`M-x projectile-add-known-project`
- 或使用快捷键：`C-c p a`（在 Projectile 命令菜单中按 `a`）
- 然后输入项目根目录的路径

**方法 3：创建 `.projectile` 文件**
- 在项目根目录下创建一个名为 `.projectile` 的空文件
- Projectile 会自动识别该目录为项目根目录
- 也可以在 `.projectile` 文件中列出要忽略的文件和目录（每行一个）

**使用技巧：**
1. 使用 `C-c p p` 快速切换项目，支持模糊搜索项目名称
2. 使用 `C-c p f` 在当前项目中快速查找文件
3. 使用 `C-c p s g` 在项目中进行代码搜索（需要 ripgrep 或 ag）
4. Projectile 会记住最近访问的项目，方便快速切换

### 🔧 版本控制

#### Magit
- 使用 Magit 默认快捷键
- 主要命令：`M-x magit-status`

### 📝 Org 模式

#### Org 核心功能
- `C-c C-w` - 重新归档（`org-refile`）
- `C-c c` - 捕获（`org-capture`）
- `C-c a` - 议程（`org-agenda`）

#### Org Journal
- `C-c C-s` - 搜索日记（`org-journal-search`）

### 🌐 博客管理

#### Easy Hugo
- `C-c C-e` - 打开 Easy Hugo 菜单（`easy-hugo`）

### 🔤 LSP（语言服务器协议）

#### Eglot
- `C-c l r` - 重命名（`eglot-rename`）
- `C-c l f` - 格式化（`eglot-format`）
- `C-c l a` - 代码操作（`eglot-code-actions`）
- `C-c l h` - 帮助（`eglot-help-at-point`）
- `C-c l d` - 查找声明（`eglot-find-declaration`）
- `C-c l i` - 查找实现（`eglot-find-implementation`）
- `C-c l t` - 查找类型定义（`eglot-find-typeDefinition`）

### 🛠️ 其他工具

#### 有道词典
- `C-c y` - 在光标处查询单词（`youdao-dictionary-search-at-point+`）

#### 撤销管理
- `C-z` - 撤销（`undo`）
- `C-S-z` - 可视化撤销树（`vundo`）

#### 窗口管理
- `<s-return>` - 切换全屏（`toggle-fullscreen`）

## 📦 主要依赖包

### 搜索和导航
- **vertico** - 现代垂直补全框架
- **consult** - 现代化搜索命令集合
- **embark** - 强大的上下文操作
- **embark-consult** - Embark 和 Consult 的集成
- **marginalia** - 在 minibuffer 中显示额外信息
- **orderless** - 强大的模糊匹配
- **avy** - 快速跳转（替代 window-numbering）

### 代码补全
- **corfu** - 现代补全弹窗（替代 company）
- **cape** - 为 corfu 提供额外的补全后端

### 项目管理
- **projectile** - 项目管理工具

### 版本控制
- **magit** - Git 管理工具

### Org 模式
- **org** - Org 模式核心
- **org-bullets** - Org 模式美化
- **org-journal** - 日记功能

### 博客
- **easy-hugo** - Hugo 博客管理

### LSP 和语法高亮
- **eglot** - LSP 客户端（Emacs 30 内置）
- **tree-sitter** - 语法高亮（Emacs 30 内置）

### 其他工具
- **youdao-dictionary** - 有道词典
- **vundo** - 现代撤销可视化（替代 undo-tree）
- **smartparens** - 智能括号匹配
- **rainbow-delimiters** - 彩虹括号
- **rainbow-mode** - 颜色显示
- **plantuml-mode** - PlantUML 支持
- **json-mode** - JSON 文件支持
- **yaml-mode** - YAML 文件支持
- **rust-mode** - Rust 语言支持
- **exec-path-from-shell** - 同步 shell 环境变量

## 💡 使用技巧

### 搜索文件
1. 使用 `C-c C-r` 快速打开最近文件
2. 使用 `C-c k` 在当前项目中搜索文本（ripgrep）
3. 使用 `C-c g` 在 Git 仓库中搜索

### 代码补全
- Corfu 会自动在输入时提供补全建议
- 使用 `C-i` 快速完成补全
- 使用 `M-d` 查看函数文档

### 快速跳转
- 使用 `C-c j` 快速跳转到屏幕上的任意字符
- 使用 `C-c J` 快速跳转到任意行
- 使用 `C-c w` 快速跳转到单词

### Org 模式
- 使用 `C-c c` 快速捕获任务或笔记
- 使用 `C-c a` 查看和管理议程
- 使用 `C-c C-s` 搜索日记条目

### 项目管理
- 使用 `C-c p p` 快速切换项目，支持模糊搜索
- 使用 `C-c p f` 在当前项目中快速查找文件
- 使用 `C-c p a` 手动添加项目到项目清单
- 在项目根目录创建 `.projectile` 文件可确保项目被识别
- 使用 `C-c p s g` 在项目中进行代码搜索

### 上下文操作
- 在 minibuffer 中使用 `C-.` 对当前候选项执行操作
- 使用 `C-;` 执行默认操作

## 🔧 维护

- 配置文件在 `config/` 目录
- 自定义函数在 `lisp/` 目录
- 辅助脚本在 `scripts/` 目录

## 📝 许可证

个人使用配置

