;;; config-agent.el --- AI Agent shell (agent-shell + OpenCode)  -*- lexical-binding: t; -*-

;; ============================================
;; 1. agent-shell 基础
;; ============================================
;; 工作流:
;;   C-c C-a   agent-shell-toggle          显示/隐藏当前 agent buffer
;;   C-c C-s   agent-shell-new-shell       新建会话 (不同项目/任务用)
;;   C-c C-o   agent-shell-opencode-start  直接起 OpenCode (跳过选 provider)
;;   C-c C-t   my/agent-shell-view-transcript  在 markdown 中查看对话记录
;;
;; 多轮对话: agent-shell-prefer-session-resume t (默认),
;;           OpenCode session 由 OpenCode 自己存, 重启 Emacs 可续.
;;
;; Markdown 渲染: agent 输出在 comint buffer 里被 markdown-overlays 渲染,
;;                不需要额外工具. 手写 .md 用 M-x markdown-view-mode.
;; Transcript: 对话记录自动保存到项目根目录 .agent-shell/transcripts/

(use-package agent-shell
  :ensure t
  :init
  ;; 上下文自动注入: 光标处 region / 文件 / 错误行 / 当前行
  (setq agent-shell-context-sources '(files region error line)
        ;; 跨 Emacs 重启续 session
        agent-shell-prefer-session-resume t
        ;; TUI 下不用 viewport 交互 (它依赖 frame 像素)
        agent-shell-prefer-viewport-interaction (display-graphic-p)
        ;; 头样式: GUI 用图形, TUI 用纯文本
        agent-shell-header-style (if (display-graphic-p) 'graphical 'text))

  :config
  ;; ============================================
  ;; 显示位置: 右侧 side window, 占 40% 宽
  ;; ============================================
  (setq agent-shell-display-action
        '((display-buffer-reuse-window display-buffer-in-side-window)
          (side . right) (slot . 0) (window-width . 0.4)))

  ;; ============================================
  ;; 工作目录: 跟随 projectile 项目根
  ;; agent-shell-project.el 默认就是 projectile, 这里显式确认
  ;; ============================================
  (setq agent-shell-cwd-function
        (lambda ()
          "跟随 projectile 项目根, 找不到就用 buffer 的 default-directory."
          (or (and (fboundp 'projectile-project-root)
                   (projectile-project-root))
              default-directory)))

  ;; ============================================
  ;; Transcript 配置: 自动保存对话记录到项目目录
  ;; ============================================
  (setq agent-shell-transcript-file-path-function
        (lambda ()
          (let* ((root (or (and (fboundp 'projectile-project-root)
                                (projectile-project-root))
                           default-directory))
                 (dir (expand-file-name ".agent-shell/transcripts" root)))
            (unless (file-directory-p dir) (make-directory dir t))
            (expand-file-name
             (format-time-string "%F-%H-%M-%S.md") dir))))

  ;; ============================================
  ;; 快捷键 (全局)
  ;; 注意: 不抢 C-c a (org-agenda) / C-c c (org-capture)
  ;; ============================================
  :bind
  (("C-c C-a" . agent-shell-toggle)
   ("C-c C-s" . agent-shell-new-shell)
   ("C-c C-o" . agent-shell-opencode-start-agent)
   ("C-c C-t" . my/agent-shell-view-transcript)))

;; ============================================
;; 2. OpenCode provider 配置
;; ============================================
;; agent-shell-opencode-acp-command 默认 '("opencode" "acp"),
;; opencode CLI 已在 PATH (1.15.13+), 零额外配置即可调起.
;;
;; 如需预设默认 model / session mode, 取消下面注释并填 ID:
;;   M-x agent-shell-opencode-start-agent
;;   启动 banner 会列出 Available models / Available modes, 复制 ID 填入.
;;
;; (setq agent-shell-opencode-default-model-id        "your-model-id")
;; (setq agent-shell-opencode-default-session-mode-id "your-mode-id")
;;
;; 不设 = 每次启动 OpenCode 时让你选 (跟 B 方案的"不阻塞你"承诺一致).

(provide 'config-agent)
;;; config-agent.el ends here
