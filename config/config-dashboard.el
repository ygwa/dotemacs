;;; config-dashboard.el --- Dashboard: Git / Projects / Agenda  -*- lexical-binding: t; -*-

;; Git 区: 未提交改动的 repo（分支 + 变更数）
;; Projects 区: 当前项目 🔥 + 类型标签

(defvar my/dashboard-dirty-alist nil)
(defvar my/dashboard--projects-cache-item-format nil)

(defvar my/dashboard-ascii-banner
  "
        ╭──────────────────────────────────────╮
        │         ◆  AI  WORKBENCH  ◆          │
        ╰──────────────────────────────────────╯
"
  "ASCII banner shown at dashboard top (TUI + GUI).")

;; ============================================
;; Helpers
;; ============================================

(defun my/dashboard--git-root (path)
  (when path
    (let ((dir (if (file-directory-p path) path (file-name-directory path))))
      (and dir
           (or (and (fboundp 'vc-git-root) (vc-git-root dir))
               (locate-dominating-file dir (lambda (d)
                                             (file-directory-p
                                              (expand-file-name ".git" d)))))))))

(defun my/dashboard--git-string (root &rest args)
  (let ((default-directory root))
    (with-temp-buffer
      (when (zerop (apply #'call-process "git" nil t nil args))
        (string-trim (buffer-string))))))

(defun my/dashboard--git-branch (root)
  (or (my/dashboard--git-string root "rev-parse" "--abbrev-ref" "HEAD") "?"))

(defun my/dashboard--git-change-count (root)
  (let ((out (my/dashboard--git-string root "status" "--porcelain")))
    (if (or (not out) (string-empty-p out))
        0
      (length (split-string out "\n" t)))))

(defun my/dashboard--candidate-repo-roots ()
  (let (roots)
    (when (fboundp 'project-known-project-roots)
      (require 'project)
      (setq roots (append roots (project-known-project-roots))))
    (when (recentf-enabled-p)
      (dolist (f recentf-list)
        (when-let ((root (my/dashboard--git-root f)))
          (push root roots))))
    (when-let ((root (my/dashboard--git-root user-emacs-directory)))
      (push root roots))
    (cl-delete-duplicates (mapcar #'expand-file-name roots) :test #'string-equal)))

(defun my/dashboard--git-dirty-p (root)
  (let ((default-directory root))
    (and (file-directory-p (expand-file-name ".git" root))
         (> (my/dashboard--git-change-count root) 0))))

(defun my/dashboard--dirty-repo-roots ()
  (cl-remove-if-not #'my/dashboard--git-dirty-p (my/dashboard--candidate-repo-roots)))

(defun my/dashboard--projects-with-current-first (roots)
  (let ((current (my/project-root)))
    (if current
        (let ((cur (expand-file-name current)))
          (cons cur (cl-remove cur roots :test (lambda (a b) (string-equal a b)))))
      roots)))

(defun my/dashboard--project-kind (root)
  (cond
   ((file-exists-p (expand-file-name "package.json" root)) "web")
   ((file-exists-p (expand-file-name "Cargo.toml" root)) "rust")
   ((file-exists-p (expand-file-name "requirements.txt" root)) "py")
   (t "proj")))

(defun my/dashboard--time-greeting ()
  (let ((h (string-to-number (format-time-string "%H"))))
    (cond ((< h 6) "夜深了")
          ((< h 12) "早上好")
          ((< h 18) "下午好")
          (t "晚上好"))))

(defun my/dashboard--profile-label ()
  (cond
   ((and (fboundp 'my/gui-session-p) (my/gui-session-p)) "GUI")
   (t "TUI")))

;; ============================================
;; Custom insert hooks
;; ============================================

(defun my/dashboard-insert-greeting ()
  "Insert time-of-day greeting and date under the banner."
  (dashboard-insert-center
   (propertize
    (format "%s · %s"
            (my/dashboard--time-greeting)
            (format-time-string "%A %Y-%m-%d"))
    'face 'font-lock-doc-face))
  (insert "\n"))

(defun my/dashboard-init-info ()
  "Profile, package count, and startup time."
  (propertize
   (format "✦  %s profile  ·  %d packages  ·  Emacs %s  ·  loaded in %s"
           (my/dashboard--profile-label)
           (length package-activated-list)
           emacs-version
           (emacs-init-time))
   'face 'font-lock-comment-face))

(defun my/dashboard--ai-layout ()
  (interactive)
  (require 'config-workflow)
  (my/workflow-layout))

(defun my/dashboard--nav-action (command)
  "Dashboard widget action: ignore WIDGET/EVENT, run COMMAND."
  (lambda (_widget _event)
    (call-interactively command)))

(defun my/dashboard--nav-buttons ()
  "One row of navigator buttons (7-tuple each: icon title help action face prefix suffix)."
  (list
   (cl-remove-if
    #'null
    (list
     (when (memq 'ai my/features)
       (list "⚡" "AI 布局" "Sidebar + Agent"
             (my/dashboard--nav-action #'my/dashboard--ai-layout)
             'font-lock-function-name-face nil nil))
     (when (fboundp 'magit-status)
       (list "◎" "Magit" "Git 状态"
             (my/dashboard--nav-action #'magit-status)
             'font-lock-string-face nil nil))
     (list "✎" "Capture" "Org Inbox"
           (lambda (_widget _event) (org-capture nil "i"))
           'font-lock-keyword-face nil nil)
     (list "⌕" "找文件" "项目内搜索"
           (my/dashboard--nav-action #'project-find-file)
           'font-lock-type-face nil nil)
     (list "☷" "Agenda" "本周日程"
           (my/dashboard--nav-action #'org-agenda)
           'font-lock-constant-face nil nil)))))

(defun my/dashboard-insert-navigator ()
  "Quick-launch buttons under init info."
  (setq dashboard-navigator-buttons (my/dashboard--nav-buttons))
  (dashboard-insert-navigator))

(defun my/dashboard-insert-shortcuts-hint ()
  (dashboard-insert-center
   (propertize
    " j/k · ↑↓ 移动 · RET 打开 · Tab 切换按钮 · 1-9 跳区 · R 刷新 · { } 上下区"
    'face 'font-lock-comment-face))
  (insert "\n"))

;; ============================================
;; Custom sections
;; ============================================

(defun my/dashboard-insert-dirty-repos (list-size)
  "Git repos with uncommitted changes; clean-state message when none."
  (setq my/dashboard-dirty-alist nil)
  (let ((repos (my/dashboard--dirty-repo-roots)))
    (if repos
        (dashboard-insert-section
         "⎇ Git:"
         (dashboard-shorten-paths repos 'my/dashboard-dirty-alist 'dirty-repos)
         list-size
         'dirty-repos
         (dashboard-get-shortcut 'dirty-repos)
         `(lambda (&rest _)
            (let ((dir (dashboard-expand-path-alist ,el my/dashboard-dirty-alist)))
              (let ((default-directory dir))
                (require 'magit)
                (magit-status))))
         (let* ((dir (dashboard-expand-path-alist el my/dashboard-dirty-alist))
                (name (file-name-nondirectory (directory-file-name dir)))
                (branch (my/dashboard--git-branch dir))
                (n (my/dashboard--git-change-count dir)))
           (format "● %s  %s  (+%d)"
                   (propertize name 'face 'font-lock-warning-face)
                   (propertize branch 'face 'font-lock-comment-face)
                   n)))
      (dashboard-insert-heading "⎇ Git:"
                                (when dashboard-show-shortcuts "g")
                                nil)
      (insert "\n    "
              (propertize "✓ 所有已知仓库工作区干净" 'face 'font-lock-comment-face))
      (insert "\n"))))

(defun my/dashboard-insert-projects (list-size)
  (setq dashboard--projects-cache-item-format nil)
  (setq dashboard-projects-alist nil)
  (let* ((roots (dashboard-projects-backend-load-projects))
         (current (my/project-root))
         (sorted (my/dashboard--projects-with-current-first roots))
         (items (dashboard-subseq sorted list-size)))
    (dashboard-insert-section
     "📁 Projects:"
     (dashboard-shorten-paths items 'dashboard-projects-alist 'projects)
     list-size
     'projects
     (dashboard-get-shortcut 'projects)
     `(lambda (&rest _)
        (funcall (dashboard-projects-backend-switch-function)
                 (dashboard-expand-path-alist ,el dashboard-projects-alist)))
     (let* ((file (dashboard-expand-path-alist el dashboard-projects-alist))
            (filename (dashboard-f-base file))
            (path (dashboard-extract-key-path-alist el dashboard-projects-alist))
            (kind (my/dashboard--project-kind file))
            (badge (propertize (format "[%s]" kind) 'face 'font-lock-comment-face))
            (current-p (and current
                            (string-equal (expand-file-name file)
                                          (expand-file-name current))))
            (name (if current-p
                      (propertize (format "🔥 %s" filename) 'face 'font-lock-type-face)
                    filename)))
       (cl-case dashboard-projects-show-base
         (`align
          (unless dashboard--projects-cache-item-format
            (let* ((len-align (dashboard--align-length-by-type 'projects))
                   (new-fmt (dashboard--generate-align-format
                             dashboard-projects-item-format len-align)))
              (setq dashboard--projects-cache-item-format new-fmt)))
          (format dashboard--projects-cache-item-format
                  (format "%s %s" badge name) path))
         (`nil (format "%s %s" badge (if current-p (format "🔥 %s" path) path)))
         (t (format dashboard-projects-item-format
                    (format "%s %s" badge name) path)))))))

(defun my/dashboard--setup-faces ()
  (set-face-attribute 'dashboard-banner-logo-title nil
                      :inherit 'font-lock-type-face :weight 'bold :height 1.2)
  (set-face-attribute 'dashboard-text-banner nil
                      :inherit 'font-lock-comment-face)
  (set-face-attribute 'dashboard-heading nil
                      :inherit 'font-lock-function-name-face :weight 'bold)
  (set-face-attribute 'dashboard-no-items-face nil
                      :inherit 'font-lock-comment-face)
  (set-face-attribute 'dashboard-footer-face nil
                      :inherit 'font-lock-comment-face :slant 'italic))

;; ============================================
;; use-package dashboard
;; ============================================

(use-package dashboard
  :ensure t
  :init
  (fset 'dashboard-setup-startup-hook (lambda () "noop"))
  :custom
  (dashboard-banner-logo-title "AI 工作台")
  (dashboard-banner-ascii my/dashboard-ascii-banner)
  (dashboard-center-content t)
  (dashboard-hide-cursor nil)
  (dashboard-show-shortcuts t)
  (dashboard-set-heading-icons t)
  (dashboard-set-file-icons t)
  (dashboard-page-separator
   (propertize "  ────────────────────────────────────────────────"
               'face 'font-lock-comment-face))
  (dashboard-items '((projects    . 6)
                     (agenda      . 6)
                     (dirty-repos . 6)
                     (recents     . 6)))
  (dashboard-item-generators
   '((recents     . dashboard-insert-recents)
     (bookmarks   . dashboard-insert-bookmarks)
     (projects    . my/dashboard-insert-projects)
     (agenda      . dashboard-insert-agenda)
     (registers   . dashboard-insert-registers)
     (dirty-repos . my/dashboard-insert-dirty-repos)))
  (dashboard-item-shortcuts
   '((dirty-repos . "g")
     (recents     . "r")
     (bookmarks   . "m")
     (projects    . "p")
     (agenda      . "a")
     (registers   . "e")))
  (dashboard-item-names
   '(("⎇ Git:" . "Git")
     ("📁 Projects:" . "Projects")
     ("Recent Files:" . "Recent Files")))
  (dashboard-projects-backend 'project-el)
  (dashboard-week-agenda-trim-leading-zero t)
  (dashboard-footer-messages
   '(" C-c f l → AI 工作台  ·  C-c s f → 找文件  ·  C-c c → 捕获  ·  C-x g → Magit "
     " M-o → 跳窗口  ·  C-c a → Agenda  ·  S-Return → 全屏 (GUI) "
     " j/k 导航  ·  RET 打开  ·  R 刷新 Dashboard "))
  (dashboard-startupify-list
   '(dashboard-insert-banner
     dashboard-insert-newline
     my/dashboard-insert-greeting
     dashboard-insert-banner-title
     dashboard-insert-newline
     dashboard-insert-init-info
     dashboard-insert-newline
     my/dashboard-insert-navigator
     dashboard-insert-newline
     dashboard-insert-items
     dashboard-insert-newline
     my/dashboard-insert-shortcuts-hint
     dashboard-insert-footer))
  :config
  (setq dashboard-startup-banner 'ascii
        dashboard-init-info #'my/dashboard-init-info)
  (my/dashboard--setup-faces)
  (add-hook 'dashboard-mode-hook
            (lambda ()
              (hl-line-mode 1)
              (setq-local cursor-type 'bar)
              (setq-local cursor-margin 1)))
  (define-key dashboard-mode-map (kbd "R") #'dashboard-refresh-buffer)
  (advice-add #'dashboard--current-section :around
              (lambda (orig &rest args)
                (save-excursion
                  (goto-char (point))
                  (beginning-of-line)
                  (let ((ln (thing-at-point 'line t)))
                    (if (and ln (string-match-p "Git:" ln))
                        'dirty-repos
                      (apply orig args)))))
              '((name . my/dashboard-current-section)))
  (when (< (length command-line-args) 2)
    (add-hook 'window-size-change-functions #'dashboard-resize-on-hook 100)
    (add-hook 'server-after-make-frame-hook
              (lambda ()
                (when (buffer-live-p (get-buffer dashboard-buffer-name))
                  (with-selected-frame (selected-frame)
                    (dashboard-insert-startupify-lists)
                    (switch-to-buffer dashboard-buffer-name)
                    (delete-other-windows)))))
    (add-hook 'after-init-hook #'dashboard-insert-startupify-lists)))

(setq initial-buffer-choice
      (lambda () (get-buffer-create dashboard-buffer-name)))

(provide 'config-dashboard)
;;; config-dashboard.el ends here
