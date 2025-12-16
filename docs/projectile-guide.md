# Projectile 项目管理指南

Projectile 是 Emacs 中强大的项目交互库，旨在提供一套高效的项目级功能，帮助开发者更便捷地管理和导航项目。

## 📋 目录

- [快速开始](#快速开始)
- [项目识别机制](#项目识别机制)
- [核心功能](#核心功能)
- [完整快捷键列表](#完整快捷键列表)
- [使用场景](#使用场景)
- [高级功能](#高级功能)
- [配置和自定义](#配置和自定义)
- [常见问题](#常见问题)

## 🚀 快速开始

### 基本使用

Projectile 已经在本配置中启用，默认快捷键前缀为：
- `C-c p` - 标准前缀
- `s-p` - Super 键前缀（macOS 上为 Command 键）

### 查看帮助

如果忘记了任何快捷键，可以：
- 输入 `C-c p C-h` 查看所有可用命令
- 或使用 `M-x projectile-command-map` 查看命令菜单

## 🔍 项目识别机制

### 自动识别

Projectile 会自动识别包含以下文件或目录的目录作为项目根目录：

**版本控制系统：**
- `.git` - Git 仓库
- `.hg` - Mercurial 仓库
- `.darcs` - Darcs 仓库
- `.bzr` - Bazaar 仓库
- `.svn` - Subversion 仓库

**项目标记文件：**
- `.projectile` - Projectile 项目标记文件
- `Makefile` - Make 构建文件
- `CMakeLists.txt` - CMake 项目
- `pom.xml` - Maven 项目
- `package.json` - Node.js 项目
- `Cargo.toml` - Rust 项目
- `requirements.txt` - Python 项目
- `setup.py` - Python 项目
- `Gemfile` - Ruby 项目
- `go.mod` - Go 项目
- 以及其他常见的项目配置文件

### 手动标记项目

**方法 1：创建 `.projectile` 文件**

在项目根目录下创建一个名为 `.projectile` 的文件：

```bash
touch .projectile
```

**方法 2：使用命令添加**

- 使用 `C-c p a` 或 `M-x projectile-add-known-project`
- 输入项目根目录的路径

### 项目缓存

Projectile 会缓存项目文件列表以提升性能。如果项目文件发生变化，可以：

- 使用 `C-c p i` 使项目缓存失效
- 或使用 `C-c p z` 将当前文件添加到缓存

## 🎯 核心功能

### 1. 文件导航

快速在项目中查找和打开文件。

**主要命令：**
- `C-c p f` - 查找项目文件（`projectile-find-file`）
- `C-c p e` - 显示最近打开的项目文件（`projectile-recentf`）

**特性：**
- 支持模糊搜索
- 自动过滤项目外的文件
- 支持 Vertico 补全（本配置已集成）

### 2. 目录导航

在项目目录中快速导航。

**主要命令：**
- `C-c p d` - 显示项目目录列表（`projectile-find-dir`）
- `C-c p D` - 在 dired 模式下打开项目根目录（`projectile-dired`）

### 3. 缓冲区管理

管理项目相关的缓冲区。

**主要命令：**
- `C-c p b` - 显示当前项目中所有已打开的缓冲区（`projectile-switch-to-buffer`）
- `C-c p k` - 删除所有项目的缓冲区（`projectile-kill-buffers`）

### 4. 代码搜索

在项目中进行代码搜索。

**主要命令：**
- `C-c p s g` - 在项目中执行 grep 搜索（`projectile-grep`）
- `C-c p s s` - 在项目中执行 ag 搜索（`projectile-ag`，需要 ag.el）
- `C-c p s a` - 在项目中执行 ack 搜索（`projectile-ack`，需要 ack-and-a-half）

**注意：** 本配置推荐使用 `C-c k` (consult-ripgrep) 进行搜索，它集成了 ripgrep 和 consult。

### 5. 项目切换

在多个项目之间快速切换。

**主要命令：**
- `C-c p p` - 切换项目（`projectile-switch-project`）

**特性：**
- 支持模糊搜索项目名称
- 记住最近访问的项目
- 自动打开项目根目录

### 6. 编译和测试

执行项目的编译和测试命令。

**主要命令：**
- `C-c p c` - 执行项目的标准编译命令（`projectile-compile-project`）
- `C-c p P` - 执行项目的标准测试命令（`projectile-test-project`）

**自动检测：**
- Projectile 会自动检测常见的构建工具（make, maven, gradle, cargo 等）
- 也可以手动配置编译和测试命令

### 7. 文本替换

在项目中进行批量文本替换。

**主要命令：**
- `C-c p r` - 在项目中执行 query-replace（`projectile-replace`）
- `C-c p o` - 对所有项目打开的缓冲区执行 multi-occur（`projectile-multi-occur`）

### 8. 测试文件管理

快速访问测试文件。

**主要命令：**
- `C-c p T` - 显示项目中的所有测试文件（`projectile-find-test-file`）

### 9. 项目配置

管理项目列表和配置。

**主要命令：**
- `C-c p a` - 添加项目到已知项目列表（`projectile-add-known-project`）
- `C-c p r` - 从已知项目列表中移除项目（`projectile-remove-known-project`）
- `C-c p R` - 重新生成项目的 TAGS 文件（`projectile-regenerate-tags`）

## ⌨️ 完整快捷键列表

### 文件操作

| 快捷键 | 命令 | 说明 |
|--------|------|------|
| `C-c p f` | `projectile-find-file` | 查找项目文件 |
| `C-c p e` | `projectile-recentf` | 最近打开的项目文件 |
| `C-c p d` | `projectile-find-dir` | 查找项目目录 |
| `C-c p D` | `projectile-dired` | 在 dired 中打开项目根目录 |

### 缓冲区操作

| 快捷键 | 命令 | 说明 |
|--------|------|------|
| `C-c p b` | `projectile-switch-to-buffer` | 切换到项目缓冲区 |
| `C-c p k` | `projectile-kill-buffers` | 删除所有项目缓冲区 |
| `C-c p o` | `projectile-multi-occur` | 在项目缓冲区中 multi-occur |

### 搜索操作

| 快捷键 | 命令 | 说明 |
|--------|------|------|
| `C-c p s g` | `projectile-grep` | 在项目中 grep 搜索 |
| `C-c p s s` | `projectile-ag` | 在项目中 ag 搜索 |
| `C-c p s a` | `projectile-ack` | 在项目中 ack 搜索 |
| `C-c p r` | `projectile-replace` | 在项目中替换文本 |

### 项目操作

| 快捷键 | 命令 | 说明 |
|--------|------|------|
| `C-c p p` | `projectile-switch-project` | 切换项目 |
| `C-c p a` | `projectile-add-known-project` | 添加项目 |
| `C-c p r` | `projectile-remove-known-project` | 移除项目 |

### 编译和测试

| 快捷键 | 命令 | 说明 |
|--------|------|------|
| `C-c p c` | `projectile-compile-project` | 编译项目 |
| `C-c p P` | `projectile-test-project` | 运行测试 |
| `C-c p T` | `projectile-find-test-file` | 查找测试文件 |

### 缓存和工具

| 快捷键 | 命令 | 说明 |
|--------|------|------|
| `C-c p i` | `projectile-invalidate-cache` | 使缓存失效 |
| `C-c p z` | `projectile-cache-current-file` | 缓存当前文件 |
| `C-c p R` | `projectile-regenerate-tags` | 重新生成 TAGS |

### 帮助

| 快捷键 | 命令 | 说明 |
|--------|------|------|
| `C-c p C-h` | `projectile-command-map` | 查看所有命令 |

## 💡 使用场景

### 场景 1: 快速切换项目

1. 按 `C-c p p`
2. 输入项目名称（支持模糊搜索）
3. 选择项目，自动打开项目根目录

### 场景 2: 在大型项目中查找文件

1. 按 `C-c p f`
2. 输入文件名（支持模糊搜索）
3. 使用 `C-n`/`C-p` 导航结果（Vertico 集成）

### 场景 3: 搜索代码

**方法 1：使用 Projectile（推荐用于项目内搜索）**
- `C-c p s g` - 使用 grep
- `C-c p s s` - 使用 ag（如果已安装）

**方法 2：使用 Consult（推荐，本配置已集成）**
- `C-c k` - 使用 ripgrep 搜索（`consult-ripgrep`）
- `C-c g` - Git grep 搜索（`consult-git-grep`）

### 场景 4: 批量替换

1. 按 `C-c p r`
2. 输入要查找的文本
3. 输入替换文本
4. 逐个确认或全部替换

### 场景 5: 管理项目缓冲区

1. 按 `C-c p b` 查看所有项目缓冲区
2. 快速切换到需要的缓冲区
3. 使用 `C-c p k` 清理不需要的缓冲区

### 场景 6: 编译和测试

1. 按 `C-c p c` 编译项目
2. 查看编译输出
3. 按 `C-c p P` 运行测试

## 🔧 高级功能

### 1. 项目特定配置

可以在项目根目录创建 `.dir-locals.el` 文件来设置项目特定的配置：

```elisp
((nil . ((projectile-project-compilation-cmd . "make build")
         (projectile-project-test-cmd . "make test"))))
```

### 2. 忽略文件和目录

在 `.projectile` 文件中列出要忽略的文件和目录（每行一个，以 `-` 开头表示忽略）：

```
-/build
-/dist
-/node_modules
-*.log
```

### 3. 项目类型检测

Projectile 会自动检测项目类型并应用相应的配置：

- **Rails** - 自动识别测试文件、配置文件等
- **Maven** - 识别 Java 项目结构
- **Leiningen** - 识别 Clojure 项目
- **Cargo** - 识别 Rust 项目
- 等等...

### 4. 与外部工具集成

**与 Helm 集成：**
```elisp
(use-package helm-projectile
  :ensure t
  :config
  (helm-projectile-on))
```

**与 Ivy/Counsel 集成：**
```elisp
(use-package counsel-projectile
  :ensure t
  :config
  (counsel-projectile-mode))
```

**注意：** 本配置使用 Vertico + Consult，已自动集成。

### 5. 项目索引

Projectile 支持多种索引方式：

- **文件系统索引** - 默认方式，扫描文件系统
- **Git 索引** - 仅索引 Git 跟踪的文件（更快）
- **外部索引** - 使用外部工具（如 `find` 或 `fd`）

可以通过 `projectile-indexing-method` 变量配置。

## ⚙️ 配置和自定义

### 常用配置选项

可以在 `config/config-package.el` 中添加以下配置：

```elisp
(use-package projectile
  :ensure t
  :config
  ;; 设置项目索引方法（可选：'native, 'git, 'alien）
  (setq projectile-indexing-method 'native)
  
  ;; 设置项目缓存文件位置
  (setq projectile-cache-file (expand-file-name "projectile.cache" user-emacs-directory))
  
  ;; 设置已知项目文件位置
  (setq projectile-known-projects-file (expand-file-name "projectile-bookmarks.eld" user-emacs-directory))
  
  ;; 启用项目缓存
  (setq projectile-enable-caching t)
  
  ;; 设置忽略的目录
  (setq projectile-globally-ignored-directories
        '(".idea" ".eclipse" ".ensime_cache" ".emacs.d" ".git" ".hg" ".fslckout"
          "_FOSSIL_" ".bzr" "_darcs" ".tox" ".svn" ".stack-work" ".ccls-cache"))
  
  ;; 设置忽略的文件后缀
  (setq projectile-globally-ignored-file-suffixes '(".elc" ".pyc" ".o"))
  
  ;; 键绑定
  (define-key projectile-mode-map (kbd "s-p") 'projectile-command-map)
  (define-key projectile-mode-map (kbd "C-c p") 'projectile-command-map)
  
  (projectile-mode 1))
```

### 自定义编译和测试命令

可以通过项目类型或项目特定配置自定义：

```elisp
(setq projectile-project-compilation-cmd
      '((cargo . "cargo build")
        (maven . "mvn compile")
        (make . "make")))
```

## ❓ 常见问题

### Q1: Projectile 无法识别我的项目

**解决方案：**
1. 检查项目根目录是否包含 `.git` 或其他项目标记文件
2. 在项目根目录创建 `.projectile` 文件
3. 使用 `C-c p a` 手动添加项目

### Q2: 文件搜索很慢

**解决方案：**
1. 使用 `C-c p i` 使缓存失效，然后重新索引
2. 在 `.projectile` 文件中添加要忽略的目录
3. 考虑使用 Git 索引方式（如果项目是 Git 仓库）

### Q3: 如何查看项目根目录？

**解决方案：**
- 使用 `C-c p D` 在 dired 中打开项目根目录
- 或使用 `M-x projectile-project-root` 查看项目根目录路径

### Q4: 如何清除项目缓存？

**解决方案：**
- 使用 `C-c p i` 使当前项目的缓存失效
- 或删除 `~/.emacs.d/projectile.cache` 文件

### Q5: Projectile 与其他工具冲突吗？

**解决方案：**
- Projectile 与 Vertico、Consult 等工具完全兼容
- 本配置已正确集成，无需额外配置

## 📚 相关资源

- [Projectile 官方网站](https://projectile.mx/)
- [Projectile 官方文档](https://docs.projectile.mx/)
- [Projectile GitHub 仓库](https://github.com/bbatsov/projectile)

## 🎓 最佳实践

1. **使用项目缓存** - 对于大型项目，启用缓存可以显著提升性能
2. **合理配置忽略列表** - 在 `.projectile` 中忽略构建目录、依赖目录等
3. **利用模糊搜索** - Projectile 的模糊搜索非常强大，善用它可以快速定位文件
4. **结合其他工具** - 与 Consult、Vertico 等工具结合使用，获得更好的体验
5. **定期清理缓存** - 如果项目结构发生重大变化，记得使缓存失效

---

**提示：** 本配置已优化 Projectile 的使用体验，与 Vertico、Consult 等现代工具完美集成。如有问题，请查看配置文件的 `config/config-package.el` 部分。


