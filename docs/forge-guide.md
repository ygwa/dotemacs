# Forge — GitHub / GitLab PR & Issue 审阅

> Magit 扩展，在 Emacs 内浏览 PR/MR、Issue，无需离开编辑器。
> 全局入口仍在 `C-x g`（magit-status）；Forge 菜单在 magit buffer 内按 `'`。

## 支持的平台

| 平台 | 开箱即用 | 说明 |
|---|---|---|
| GitHub (`github.com`) | 是 | `api.github.com` |
| GitLab (`gitlab.com`) | 是 | `gitlab.com/api/v4` |
| 自托管 GitLab | 需配置 | 见下文 `my/forge-extra-gitlab-instances` |

## 一次性 Setup

### 1. 配置 Git 用户名

```bash
# GitHub
git config --global github.user YOUR_GITHUB_USERNAME

# GitLab.com
git config --global gitlab.user YOUR_GITLAB_USERNAME

# 自托管 GitLab (HOST = 例如 gitlab.example.com)
git config --global gitlab.HOST.user YOUR_USERNAME
```

### 2. 生成 Personal Access Token

| 平台 | Token 权限 |
|---|---|
| GitHub | `repo`, `read:org`（组织仓库时） |
| GitLab | `api`, `read_api`, `read_user` |

### 3. 写入 auth-source

在 `~/.authinfo` 或 `~/.authinfo.gpg` 添加：

```text
machine api.github.com login YOUR_GITHUB_USERNAME^forge password ghp_xxxx
machine gitlab.com login YOUR_GITLAB_USERNAME^forge password glpat-xxxx
machine gitlab.example.com login YOUR_USERNAME^forge password glpat-xxxx
```

注意：`login` 必须是 `USERNAME^forge`（无空格）。

配置后执行 `M-x auth-source-forget-all-cached`，让 Emacs 重新读取 token。

### 4. 自托管 GitLab（可选）

在 `config/config-vcs.el` 或 `custom.el` 中设置：

```elisp
(setq my/forge-extra-gitlab-instances
      '(("gitlab.example.com"
         "gitlab.example.com/api/v4"
         "gitlab.example.com"
         forge-gitlab-repository)))
```

### 5. 注册仓库

打开项目的 `magit-status`，执行：

```text
M-x forge-add-repository
```

Forge 会把 PR/MR、Issue 缓存到本地数据库（首次可能较慢）。

## Magit 内常用键

| 键 | 说明 |
|---|---|
| `'` | Forge dispatch 菜单（推荐入口） |
| `N` | Forge 子菜单（旧绑定） |

在 dispatch 菜单中可：拉取 topics、浏览 PR/MR、打开 Issue 等。详见 [Forge 手册](https://magit.vc/manual/forge/)。

## 与 AI 审阅配合

1. 在 Forge 中打开 PR/MR diff（Magit diff buffer）
2. 按 `C-c C-d` — 将 diff 插入 agent-shell 输入区（无 preset prompt，可自行输入指令）
3. 或选中 region 后 `C-.`（embark-act）→ “Send git diff to agent shell”

## CLI 审阅（gh / glab）— 推荐 GitLab MR 习惯

与 Forge 并行，Workbench 直接调用 CLI：

| 键 | 命令 | 工具 |
|---|---|---|
| `C-c C-w g` | 自动检测 origin | gh 或 glab |
| `C-c C-w h` | GitHub PR | `gh pr view` + `gh pr diff` |
| `C-c C-w L` | GitLab MR | `glab mr view` + `glab mr diff` |

前置：`gh auth login` / `glab auth login`。内容进入 `*AI-Review*`，`C-c C-w a` 送 agent，`C-c C-w S` 存 `.agent/reviews/`。

详见 [AI Workbench 指南](./ai-workbench.md)。

## 常见问题

**Forge 报 auth 错误** — 检查 `^forge` 后缀、token 权限、`auth-source-forget-all-cached`。

**自托管 GitLab 404** — 确认 `forge-alist` 中 APIHOST 带 `/api/v4`，authinfo 的 `machine` 用主机名（不带 `/api/v4`）。

**数据库位置** — Forge 使用 `~/.emacs.d/var/forge/`（随 `var/` 目录，已在 `.gitignore`）。
