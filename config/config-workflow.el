;;; config-workflow.el --- AI-assisted development workflow -*- lexical-binding: t; -*-

;; ============================================
;; 1. Sidebar (formerly treemacs)
;; ============================================
;; 不再用 treemacs (依赖膨胀 ~15 包, TUI/GUI 表现参差).
;; my/sidebar-* 来自 lisp/my-sidebar.el, 是基于 dired + project.el 的轻量替代.
;; 这里只绑键位, 不 require 任何包.

;; ============================================
;; 2. 工作流布局函数
;; ============================================

(defun my/workflow-layout ()
  "AI 工作流布局: 左 sidebar (dired @ 项目根) + 右 agent 面板."
  (interactive)
  (delete-other-windows)
  (my/sidebar-open)
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

(defun my/project-save-layout ()
  "Save window layout for the current project."
  (interactive)
  (let ((root (my/project-root-or-error)))
    (puthash (expand-file-name root)
             (list (current-window-configuration))
             my/project-layouts)
    (my/project-layouts--save)
    (message "Saved layout: %s"
             (file-name-nondirectory (directory-file-name root)))))

(defun my/project-restore-layout ()
  "Restore saved window layout for the current project."
  (interactive)
  (let ((root (my/project-root-or-error)))
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
  (let ((root (my/project-root)))
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
    (when-let ((root (my/project-root)))
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

;; Sidebar (替代原 treemacs-*)
(global-set-key (kbd "C-x t t") #'my/sidebar-open)
(global-set-key (kbd "C-x t 1") #'my/sidebar-toggle)
(global-set-key (kbd "C-x t d") #'my/sidebar-toggle)

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
