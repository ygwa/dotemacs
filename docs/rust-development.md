# Rust 开发指南

本指南介绍如何在 Emacs 30 中使用 Eglot 和 rust-analyzer 进行 Rust 开发。

## 📋 前置要求

### 1. 安装 Rust 工具链

```bash
# 使用 rustup 安装（推荐）
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

# 或使用 Homebrew (macOS)
brew install rust
```

### 2. 安装 rust-analyzer

```bash
# 方法 1: 使用 rustup 组件
rustup component add rust-analyzer

# 方法 2: 使用 Homebrew (macOS)
brew install rust-analyzer

# 方法 3: 使用 Cargo
cargo install rust-analyzer
```

### 3. 安装 Tree-sitter 语法库（Emacs 30）

在 Emacs 中运行：

```
M-x treesit-install-language-grammar RET rust RET
```

或者如果未自动安装，系统会提示你安装。

## 🎯 核心导航快捷键

由于你使用的是 **Emacs 30** 配合 **Eglot (内置 LSP)**，代码跳转功能完全基于 Emacs 原生的 **Xref** 机制实现。这意味着你不需要记一套奇怪的 LSP 快捷键，用的都是 Emacs 几十年来通用的标准键位。

### 标准 Emacs 键位（Vanilla Emacs）

| 功能 | 快捷键 | 命令 (M-x) | 说明 |
| :--- | :--- | :--- | :--- |
| **跳转定义** | **`M-.`** (Alt + .) | `xref-find-definitions` | 能够跳到变量、结构体、函数定义处。 |
| **跳回原处** | **`M-,`** (Alt + ,) | `xref-pop-marker-stack` | 看完定义后，按这个键像浏览器"后退"一样返回。 |
| **查找引用** | **`M-?`** | `xref-find-references` | 查看这个函数/变量在哪些地方被用到了。 |
| **模糊搜索** | **`C-M-.`** | `xref-find-apropos` | 记不清名字时，按模式搜索符号。 |

> **注**：`M` 代表 Meta 键，通常是键盘上的 **Alt** (Windows/Linux) 或 **Option** (macOS)。

## 🔧 Rust 开发专属动作

### Eglot 专用快捷键

这些快捷键已经在配置中绑定到 `C-c l` 前缀：

| 功能 | 快捷键 | 命令 (M-x) | 说明 |
| :--- | :--- | :--- | :--- |
| **查看实现** | `C-c l i` | `eglot-find-implementation` | 在 Rust 中用于查看某个 Trait 被谁 `impl` 了。 |
| **查看类型** | `C-c l t` | `eglot-find-typeDefinition` | 跳转到变量类型的定义（比如 `let x = foo()`，跳到 x 的类型 struct 定义）。 |
| **重命名** | `C-c l r` | `eglot-rename` | 变量/函数重命名（Refactor）。 |
| **格式化** | `C-c l f` | `eglot-format` | 格式化当前缓冲区。 |
| **查看文档** | `C-c l h` | `eglot-help-at-point` | 在光标处显示详细文档。 |
| **代码修复** | `C-c l a` | `eglot-code-actions` | 相当于 VS Code 的 "Quick Fix" (小灯泡)，处理 `unwrap` 或导包建议。 |
| **查找声明** | `C-c l d` | `eglot-find-declaration` | 查找声明位置。 |

### 其他有用的快捷键

| 功能 | 快捷键 | 说明 |
| :--- | :--- | :--- |
| **格式化缓冲区** | `C-c C-f` | 在 rust-ts-mode 中格式化整个文件 |
| **查看文档** | `C-h .` | 显示光标处的详细文档 (Eldoc) |

## 💡 实际场景演示

假设你有以下 Rust 代码：

```rust
trait Animal {
    fn speak(&self);
}

struct Dog;

impl Animal for Dog {
    fn speak(&self) { println!("Woof"); }
}

fn main() {
    let d = Dog;
    d.speak(); 
}
```

### 场景 1: 查看定义

1. 光标放在 `main` 里的 `Dog` 上
2. 按 **`M-.`** → 跳转到 `struct Dog` 定义
3. 按 **`M-,`** → 返回 `main` 函数

### 场景 2: 查看接口定义和实现

1. 光标放在 `d.speak()` 的 `speak` 上
2. 按 **`M-.`** → 跳转到 `trait Animal` 里的 `fn speak` 定义
3. 按 **`C-c l i`** → 跳转到 `impl Animal for Dog` 里的 `fn speak` 实现

### 场景 3: 查看文档

1. 光标放在 `println!` 上
2. 按 **`C-h .`** → 底部显示宏的文档
3. 或按 **`C-c l h`** → 显示 Eglot 提供的文档

### 场景 4: 代码修复

1. 当有编译错误或警告时，光标放在错误位置
2. 按 **`C-c l a`** → 显示可用的代码修复选项
3. 选择修复方案（如添加 `use` 语句、处理 `unwrap` 等）

### 场景 5: 查找所有引用

1. 光标放在函数名或变量名上
2. 按 **`M-?`** → 显示所有使用该符号的位置
3. 使用 `C-n`/`C-p` 导航结果列表

### 场景 6: 重命名

1. 光标放在要重命名的符号上
2. 按 **`C-c l r`** → 输入新名称
3. 所有引用该符号的地方都会被自动更新

## 🚀 工作流程建议

### 1. 创建新项目

```bash
# 在终端创建项目
cargo new my-project
cd my-project

# 在 Emacs 中打开
emacs Cargo.toml
```

### 2. 打开项目文件

- 使用 `C-c p f` (Projectile) 快速查找项目中的文件
- 使用 `C-c p p` 切换项目

### 3. 开发流程

1. **编写代码** → 自动补全（Corfu）会提供建议
2. **查看定义** → `M-.` 跳转到定义
3. **查看实现** → `C-c l i` 查看 trait 实现
4. **查看文档** → `C-h .` 或 `C-c l h`
5. **代码修复** → `C-c l a` 处理错误和警告
6. **格式化** → `C-c l f` 或 `C-c C-f`
7. **查找引用** → `M-?` 查看所有使用位置

### 4. 编译和运行

```bash
# 在终端中
cargo build
cargo run
cargo test

# 或使用 Emacs 的编译命令
M-x compile RET cargo build
```

## 🔍 调试技巧

### 查看 Eglot 状态

- `M-x eglot-events-buffer` - 查看 Eglot 事件日志
- `M-x eglot-reconnect` - 重新连接 LSP 服务器
- `M-x eglot-shutdown` - 关闭 LSP 服务器

### 常见问题

1. **rust-analyzer 未启动**
   - 检查是否安装了 rust-analyzer: `which rust-analyzer`
   - 检查 Eglot 日志: `M-x eglot-events-buffer`
   - 重启 Eglot: `M-x eglot-reconnect`

2. **补全不工作**
   - 确保 Corfu 已启用: `M-x global-corfu-mode`
   - 检查 Eglot 是否连接: 查看模式行是否有 `Eglot:rust-analyzer`

3. **跳转不工作**
   - 确保项目已编译: `cargo build`
   - 检查 rust-analyzer 是否正在索引项目（可能需要一些时间）

## 📚 相关资源

- [Rust 官方文档](https://doc.rust-lang.org/)
- [rust-analyzer 文档](https://rust-analyzer.github.io/)
- [Eglot 文档](https://github.com/joaotavora/eglot)
- [Emacs Xref 文档](https://www.gnu.org/software/emacs/manual/html_node/emacs/Xref.html)


