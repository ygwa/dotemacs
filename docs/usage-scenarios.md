# 使用场景指南

本目录包含各种开发场景的详细使用指南。

## 📚 可用指南

- [Rust 开发指南](./RUST-DEVELOPMENT.md) - 使用 Eglot 和 rust-analyzer 进行 Rust 开发
- [Projectile 项目管理指南](./PROJECTILE-GUIDE.md) - Projectile 的完整功能和使用指南

## 🔮 计划中的指南

以下场景的指南正在计划中，欢迎贡献：

- **Python 开发** - 使用 Eglot 和 pyright/pylsp 进行 Python 开发
- **TypeScript/JavaScript 开发** - 使用 Eglot 和 TypeScript 服务器进行前端开发
- **Go 开发** - 使用 Eglot 和 gopls 进行 Go 开发
- **通用 LSP 使用** - Eglot 的通用配置和使用技巧

## 💡 通用开发技巧

### 代码导航

所有支持 LSP 的语言都使用相同的标准 Emacs 键位：

- `M-.` - 跳转到定义
- `M-,` - 返回原处
- `M-?` - 查找引用
- `C-M-.` - 模糊搜索符号

### 代码补全

- Corfu 会自动提供补全建议
- 使用 `C-n`/`C-p` 导航候选项
- 使用 `C-i` 完成补全
- 使用 `M-d` 查看文档

### 项目管理

- `C-c p p` - 切换项目
- `C-c p f` - 查找项目文件
- `C-c p s g` - 在项目中搜索

### 搜索和导航

- `C-s` - 在当前缓冲区搜索
- `C-c k` - 使用 ripgrep 搜索
- `C-c j` - 快速跳转到字符
- `C-c J` - 快速跳转到行

## 🤝 贡献指南

如果你想为某个开发场景添加使用指南，请：

1. 在 `docs/` 目录下创建新的 Markdown 文件
2. 参考 `RUST-DEVELOPMENT.md` 的格式
3. 包含以下内容：
   - 前置要求
   - 快捷键说明
   - 实际使用场景
   - 工作流程建议
   - 常见问题排查

4. 在本文件中添加链接

