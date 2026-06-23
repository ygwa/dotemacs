;;; config-agent.el --- AI Agent shell (agent-shell + OpenCode)  -*- lexical-binding: t; -*-

;; ============================================
;; 1. agent-shell 基础
;; ============================================
;; 工作流:
;;   C-c C-a   agent-shell-toggle          显示/隐藏当前 agent buffer
;;   C-c C-s   agent-shell-new-shell       新建会话 (不同项目/任务用)
;;   C-c C-o   agent-shell-opencode-start  直接起 OpenCode (跳过选 provider)
;;   C-c C-t   my/agent-shell-view-transcript  在 markdown 中查看对话记录
;;   C-c C-d   my/magit-send-diff-to-agent / my/markdown-send-to-agent
;;             把 diff 或文档插入 agent 输入区 (无 preset prompt)
;;
;; 多轮对话: agent-shell-prefer-session-resume t (默认),
;;           OpenCode session 由 OpenCode 自己存, 重启 Emacs 可续.
;;
;; Markdown 渲染: agent 输出在 comint buffer 里被 markdown-overlays 渲染,
;;                不需要额外工具. 手写 .md 用 M-x markdown-view-mode.
;; Transcript: 对话记录自动保存到项目根目录 .agent-shell/transcripts/

;; ============================================
;; 0. Agent 审阅桥 (Phase 1 / 2 — 无 preset prompt)
;; ============================================

(defun my/agent-shell-ensure-shell ()
  "Ensure an agent-shell buffer exists for the current project."
  (require 'agent-shell)
  (unless (agent-shell--shell-buffer :no-create t)
    (agent-shell-toggle))
  (agent-shell--shell-buffer))

(defun my/agent-shell-send-text (text &optional submit)
  "Insert TEXT into the project agent-shell (SUBMIT nil = 仅插入, 不自动发送)."
  (unless (and text (not (string-empty-p (string-trim text))))
    (user-error "Nothing to send to agent shell"))
  (require 'agent-shell)
  (my/agent-shell-ensure-shell)
  (agent-shell-insert :text text :submit submit))

(defun my/magit--current-file ()
  "Return file path at Magit section, if any."
  (when-let* ((section (magit-current-section))
              (type (magit-section-type section)))
    (when (memq type '(file unstaged staged untracked))
      (magit-section-value section))))

(defun my/magit--diff-text ()
  "Collect git diff text appropriate for the current Magit context."
  (require 'magit)
  (let ((default-directory (or (magit-toplevel) default-directory)))
    (unless default-directory
      (user-error "Not in a git repository"))
    (cond
     ((or (derived-mode-p 'magit-log-mode)
          (derived-mode-p 'magit-reflog-mode))
      (when-let ((commit (magit-section-value (magit-current-section))))
        (magit-git-string "show" "--format=" commit)))
     ((derived-mode-p 'magit-diff-mode)
      (buffer-substring-no-properties (point-min) (point-max)))
     (t
      (let ((file (my/magit--current-file)))
        (if file
            (magit-git-string "diff" "HEAD" "--" file)
          (magit-git-string "diff" "HEAD")))))))

(defun my/magit-send-diff-to-agent ()
  "Insert current Magit diff into agent-shell input (no preset prompt)."
  (interactive)
  (when-let ((text (my/magit--diff-text)))
    (my/agent-shell-send-text text nil)))

(defun my/markdown-send-to-agent ()
  "Insert Markdown region or buffer into agent-shell input (no preset prompt)."
  (interactive)
  (my/agent-shell-send-text
   (if (use-region-p)
       (buffer-substring-no-properties (region-beginning) (region-end))
     (buffer-substring-no-properties (point-min) (point-max)))
   nil))

(defun my/agent-shell-view-transcript ()
  "在 markdown-mode 中打开当前会话的 transcript。"
  (interactive)
  (unless (derived-mode-p 'agent-shell-mode)
    (user-error "Not in an agent-shell buffer"))
  (when-let ((file agent-shell--transcript-file))
    (let ((buf (find-file-noselect file)))
      (with-current-buffer buf
        (markdown-mode)
        (read-only-mode 1))
      (display-buffer buf
                      '((display-buffer-reuse-window
                         display-buffer-in-side-window)
                        (side . right) (slot . 1) (window-width . 0.35))))))

(use-package agent-shell
  :ensure t
  :defer t
  :init
  ;; 上下文自动注入: 光标处 region / 文件 / 错误行 / 当前行
  (setq agent-shell-context-sources '(files region error line)
        ;; 跨 Emacs 重启续 session
        agent-shell-prefer-session-resume t
        ;; TUI-only (2026-06): viewport 交互依赖 frame 像素, 关掉
        agent-shell-prefer-viewport-interaction nil
        ;; TUI-only: 头样式走纯文本
        agent-shell-header-style 'text)

  :config
  ;; ============================================
  ;; 显示位置: 右侧 side window, 占 40% 宽
  ;; ============================================
  (setq agent-shell-display-action
        '((display-buffer-reuse-window display-buffer-in-side-window)
          (side . right) (slot . 0) (window-width . 0.4)))

  ;; ============================================
  ;; 工作目录: 跟随 git/svn/hg 项目根 (内置 vc-root-dir, 不依赖 projectile)
  ;; ============================================
  (setq agent-shell-cwd-function
        (lambda ()
          "跟随 VCS 项目根 (git/svn/hg 等), 找不到就用 buffer 的 default-directory."
          (or (vc-root-dir) default-directory)))

  ;; ============================================
  ;; Transcript 配置: 自动保存对话记录到项目目录
  ;; ============================================
  (setq agent-shell-transcript-file-path-function
        (lambda ()
          (let* ((root (or (vc-root-dir) default-directory))
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

(with-eval-after-load 'embark
  (add-to-list 'embark-general-alt-commands
               '(my/magit-send-diff-to-agent . "Send git diff to agent shell"))
  (add-to-list 'embark-general-alt-commands
               '(my/markdown-send-to-agent . "Send Markdown to agent shell")))

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
