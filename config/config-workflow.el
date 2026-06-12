;;; config-workflow.el --- AI-assisted development workflow -*- lexical-binding: t; -*-

;; ============================================
;; 1. Treemacs 文件树
;; ============================================

(use-package treemacs
  :ensure t
  :defer t
  :config
  (setq treemacs-width 30
        treemacs-is-never-other-window t
        treemacs-show-hidden-files t
        treemacs-no-png-images (not (display-graphic-p))
        treemacs-sorting 'alphabetic-asc
        treemacs-follow-after-init t
        treemacs-collapse-dirs 3
        treemacs-silence-other-window-warning t)
  (treemacs-follow-mode t)
  (treemacs-filewatch-mode t))

(use-package treemacs-nerd-icons
  :ensure t
  :after (treemacs nerd-icons)
  :config
  (treemacs-load-theme "nerd-icons"))

(use-package treemacs-magit
  :ensure t
  :after (treemacs magit))

;; ============================================
;; 2. 工作流布局函数
;; ============================================

(defun my/workflow-layout ()
  "设置AI开发工作流布局：左侧treemacs，右侧代码+AI面板"
  (interactive)
  (when (fboundp 'shackle-close-all-windows)
    (shackle-close-all-windows))
  (treemacs)
  (other-window 1)
  (agent-shell-toggle))

(defun my/workflow-focus-code ()
  "专注代码模式：隐藏所有面板"
  (interactive)
  (when (fboundp 'shackle-close-all-windows)
    (shackle-close-all-windows))
  (delete-other-windows))

;; ============================================
;; 3. Transcript查看函数
;; ============================================

(defun my/agent-shell-view-transcript ()
  "在markdown-mode中打开当前会话的transcript"
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

;; ============================================
;; 4. 快捷键绑定
;; ============================================

;; 文件树
(global-set-key (kbd "C-x t 1") #'treemacs-select-window)
(global-set-key (kbd "C-x t t") #'treemacs)
(global-set-key (kbd "C-x t d") #'treemacs-delete-other-windows)

;; 工作流布局
(global-set-key (kbd "C-c f l") #'my/workflow-layout)
(global-set-key (kbd "C-c f c") #'my/workflow-focus-code)

;; Transcript查看
(global-set-key (kbd "C-c C-t") #'my/agent-shell-view-transcript)

(provide 'config-workflow)
;;; config-workflow.el ends here