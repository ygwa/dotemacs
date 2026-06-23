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
        ;; TUI-only (2026-06): 永远不用 PNG 图标
        treemacs-no-png-images t
        treemacs-sorting 'alphabetic-asc
        treemacs-follow-after-init t
        treemacs-collapse-dirs 3
        treemacs-silence-other-window-warning t)
  (treemacs-follow-mode t)
  (treemacs-filewatch-mode t))

(use-package treemacs-magit
  :ensure t
  :after (treemacs magit))

;; ============================================
;; 2. 工作流布局函数
;; ============================================

(defun my/workflow-layout ()
  "设置AI开发工作流布局：左侧treemacs，右侧代码+AI面板"
  (interactive)
  ;; 先清空所有窗口, shackle autoclose 弹的窗也会一起被清掉
  (delete-other-windows)
  (treemacs)
  (other-window 1)
  (agent-shell-toggle))

;; ============================================
;; 3. 快捷键绑定
;; ============================================

;; 文件树
(global-set-key (kbd "C-x t 1") #'treemacs-select-window)
(global-set-key (kbd "C-x t t") #'treemacs)
(global-set-key (kbd "C-x t d") #'treemacs-delete-other-windows)

;; 工作流布局
(global-set-key (kbd "C-c f l") #'my/workflow-layout)
(global-set-key (kbd "C-c f c")
                (lambda ()
                  (interactive)
                  (delete-other-windows)))

(provide 'config-workflow)
;;; config-workflow.el ends here
