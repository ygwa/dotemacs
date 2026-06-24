# Rust 开发指南

> 本指南基于 **Emacs 30.2 + 内置 Eglot + rust-analyzer**。
> 配置统一 TUI-only（emacsclient + daemon），所有键位与 `config/*.el` 1:1 对应。完整键位见 [keybindings.md](./keybindings.md)。

## 前置要求

### 1. Rust 工具链

```bash
# rustup（推荐）
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

# 或 Homebrew
brew install rust
```

### 2. rust-analyzer

```bash
# rustup 组件（推荐，跟 rustc 同步）
rustup component add rust-analyzer

# 或 Homebrew
brew install rust-analyzer
```

> 配置中检测方式：`executable-find "rust-analyzer"`，找不到时首次打开 .rs 会在 *Messages* 提示安装命令（macOS / Linux 分平台）。

### 3. Tree-sitter Rust 语法库（Emacs 30 内置）

本配置已预编译 `tree-sitter/libtree-sitter-rust.dylib`，开箱即用。**无需**手动 `M-x treesit-install-language-grammar`。

如需重装：

```
M-x treesit-install-language-grammar RET rust RET
```

## 自动启动 eglot

打开 `.rs` 文件时自动触发：

```elisp
;; config-package.el
:hook ((python-mode rust-mode rust-ts-mode) . eglot-ensure)
```

`rust-mode` 和 `rust-ts-mode` 都覆盖（后者是 tree-sitter 驱动的高亮，启用需 `treesit-ready-p 'rust`）。

## 核心导航键位

代码跳转走**原生 xref**，不绑 LSP 键：

| 键位 | 命令 | 说明 |
|---|---|---|
| `M-.` | `xref-find-definitions` | 跳定义 |
| `M-,` | `xref-pop-marker-stack` | 跳回原处 |
| `M-?` | `xref-find-references` | 查引用 |
| `C-M-.` | `xref-find-apropos` | 模糊搜符号 |

> `M` = Meta 键（macOS = Option，Win/Linux = Alt）。

## Eglot 键位（编程 buffer 内）

前缀 `C-c l`（= **l**anguage server）。符号搜索走 `C-c s e`。

| 键位 | 命令 | 说明 |
|---|---|---|
| `C-c l r` | `eglot-rename` | 重命名 |
| `C-c l f` | `eglot-format` | 格式化 |
| `C-c l a` | `eglot-code-actions` | Quick Fix（小灯泡） |
| `C-c l h` | `eglot-help-at-point` | 光标处文档 |
| `C-c l d` | `eglot-find-declaration` | 跳声明 |
| `C-c l i` | `eglot-find-implementation` | 跳实现（trait impl） |
| `C-c l t` | `eglot-find-typeDefinition` | 跳类型定义 |
| `C-c s e` | `consult-eglot-symbols` | 按符号搜项目 |

## Rust 专属格式

```elisp
;; config-package.el
(with-eval-after-load 'rust-ts-mode
  (setq rust-ts-mode-indent-offset 4)
  (define-key rust-ts-mode-map (kbd "C-c C-f") 'eglot-format-buffer))
```

| 键位 | 命令 | 说明 |
|---|---|---|
| `C-c C-f` | `eglot-format-buffer` | 在 `rust-ts-mode` 内格式化整个文件 |

## 实际场景

假设有：

```rust
trait Animal { fn speak(&self); }
struct Dog;
impl Animal for Dog { fn speak(&self) { println!("Woof"); } }
fn main() { let d = Dog; d.speak(); }
```

### 场景 1：跳定义 + 跳回

1. 光标在 `main` 里的 `Dog` 上
2. `M-.` → 跳到 `struct Dog`
3. `M-,` → 返回

### 场景 2：trait 定义 + 它的所有实现

1. 光标在 `d.speak()` 的 `speak` 上
2. `M-.` → `trait Animal` 的 `fn speak`
3. `C-c l i` → `impl Animal for Dog` 的 `fn speak` 实现

### 场景 3：文档

1. 光标在 `println!` 上
2. `C-h .` → 底部 eldoc 显示
3. `C-c l h` → eglot 完整 hover 文档

### 场景 4：Quick Fix

1. 编译错误 / 未导入的 crate，光标在错误位
2. `C-c l a` → 选修复（加 `use` / 处理 `unwrap` 等）

### 场景 5：找所有引用

1. 光标在函数 / 变量名
2. `M-?` → 候选列表
3. `C-n` / `C-p` 选，回车跳

### 场景 6：重命名

1. 光标在要重命名的符号
2. `C-c l r` → 输入新名 → 所有引用自动更新

## 编译运行

```bash
# 终端
cargo build
cargo run
cargo test
```

或在 Emacs 内：`M-x compile RET cargo build`。

## 调试（Dape）

| 键位 | 说明 |
|---|---|
| `<f5>` | 启动 dape（按 dir-locals） |
| `M-<f5>` | 速查表 |
| `C-c d b` | 当前行切断点 |

需要 `brew install lldb-dap`，`config-package.el:309-317` 已配 adapter。

## 项目导航

用**内置 `project.el`**，无需 Projectile（配置中无 projectile）：

| 键位 | 命令 |
|---|---|
| `C-c s f` | `project-find-file` |
| `C-c s p` | `project-find-regexp` |
| `C-c p b` | `project-switch-to-buffer` |
| `C-c p s` | `eat-project` |

## 常见问题

### rust-analyzer 未启动

```bash
which rust-analyzer        # 检查 PATH
M-x eglot-events-buffer    # 看 Eglot 日志
M-x eglot-reconnect        # 重连
```

### 补全不工作

`M-x global-corfu-mode` 确认 Corfu 开启；看 mode-line 是否有 `Eglot:rust-analyzer`。

### 跳转不工作

确认项目已 `cargo build`（rust-analyzer 需要编译产物定位源码）。

### tree-sitter 高亮缺失

`M-x treesit-install-language-grammar RET rust RET`。

## 相关资源

- [Rust 官方文档](https://doc.rust-lang.org/)
- [rust-analyzer 用户手册](https://rust-analyzer.github.io/manual.html)
- [Eglot 用户手册](https://www.gnu.org/software/emacs/manual/eglot.html)
- [Emacs Xref 文档](https://www.gnu.org/software/emacs/manual/html_node/emacs/Xref.html)
