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
;; 3. 多项目布局持久化 (Phase 4)
;; ============================================

(defvar my/project-layouts (make-hash-table :test 'equal)
  "Hash table: project root -> (window-configuration).")

(defvar my/project-layouts-file
  (expand-file-name "var/project-layouts.el" user-emacs-directory)
  "File persisting `my/project-layouts' across sessions.")

(defun my/project-layouts--load ()
  (when (file-exists-p my/project-layouts-file)
    (load my/project-layouts-file nil t)))

(defun my/project-layouts--save ()
  (let ((dir (file-name-directory my/project-layouts-file)))
    (unless (file-directory-p dir)
      (make-directory dir t)))
  (with-temp-file my/project-layouts-file
    (insert (format "(setq my/project-layouts %S)\n" my/project-layouts))))

(defun my/project-root-directory ()
  "Return expanded project root for current buffer, or nil."
  (when-let ((proj (project-current)))
    (expand-file-name (project-root proj))))

(defun my/project-save-layout ()
  "Save window layout for the current project."
  (interactive)
  (let ((root (or (my/project-root-directory) (vc-root-dir))))
    (unless root
      (user-error "Not in a project"))
    (puthash (expand-file-name root)
             (list (current-window-configuration))
             my/project-layouts)
    (my/project-layouts--save)
    (message "Saved layout: %s"
             (file-name-nondirectory (directory-file-name root)))))

(defun my/project-restore-layout ()
  "Restore saved window layout for the current project."
  (interactive)
  (let ((root (or (my/project-root-directory) (vc-root-dir))))
    (unless root
      (user-error "Not in a project"))
    (if-let ((entry (gethash (expand-file-name root) my/project-layouts)))
        (progn
          (set-window-configuration (car entry))
          (message "Restored layout: %s"
                   (file-name-nondirectory (directory-file-name root))))
      (user-error "No saved layout for this project"))))

(defun my/project-switch-project ()
  "Switch project; restore saved layout or apply AI workflow layout."
  (interactive)
  (require 'project)
  (call-interactively #'project-switch-project)
  (let ((root (my/project-root-directory)))
    (when root
      (if (gethash (expand-file-name root) my/project-layouts)
          (my/project-restore-layout)
        (my/workflow-layout)))))

;; ============================================
;; 4. Tab bar — 按项目分组 buffer (Phase 4)
;; ============================================

(defun my/tab-bar-tab-group (window)
  "Group tab-bar tabs by VCS project root."
  (with-current-buffer (window-buffer window)
    (when-let ((root (ignore-errors
                       (or (vc-root-dir)
                           (when (buffer-file-name)
                             (locate-dominating-file (buffer-file-name) ".git"))))))
      (file-name-nondirectory (directory-file-name (expand-file-name root))))))

(use-package tab-bar
  :ensure nil
  :hook (after-init . tab-bar-mode)
  :custom
  (tab-bar-show-new-button nil)
  (tab-bar-tab-group-function #'my/tab-bar-tab-group)
  (tab-bar-format '((side (right-side))
                    (cache side-group)
                    (format (("  " tab) " ")))))

(my/project-layouts--load)

;; ============================================
;; 5. 快捷键绑定
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

;; 多项目 (Phase 4)
(with-eval-after-load 'project
  (define-key project-prefix-map (kbd "p") #'my/project-switch-project)
  (define-key project-prefix-map (kbd "w") #'my/project-save-layout)
  (define-key project-prefix-map (kbd "W") #'my/project-restore-layout))

(provide 'config-workflow)
;;; config-workflow.el ends here
