;;; config-dashboard.el --- Dashboard: Git dirty + Projects  -*- lexical-binding: t; -*-

;; Git 区: 未提交改动的 repo
;; Projects 区: 当前项目标记 🔥

(defvar my/dashboard-dirty-alist nil
  "Alist mapping shortened paths to repo roots (dirty repos section).")

(defvar my/dashboard--projects-cache-item-format nil)

;; ============================================
;; Helpers
;; ============================================

(defun my/dashboard--current-project-root ()
  "Expanded root of current project, or nil."
  (condition-case nil
      (or (and (fboundp 'project-current)
               (let ((proj (project-current)))
                 (when proj (expand-file-name (project-root proj)))))
          (vc-root-dir))
    (error nil)))

(defun my/dashboard--git-root (path)
  "Return git root containing PATH, or nil."
  (when path
    (let ((dir (if (file-directory-p path) path (file-name-directory path))))
      (and dir
           (or (and (fboundp 'vc-git-root) (vc-git-root dir))
               (locate-dominating-file dir (lambda (d)
                                             (file-directory-p
                                              (expand-file-name ".git" d)))))))))

(defun my/dashboard--candidate-repo-roots ()
  "Collect candidate git repo roots from projects and recent files."
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
    (cl-delete-duplicates
     (mapcar #'expand-file-name roots)
     :test #'string-equal)))

(defun my/dashboard--git-dirty-p (root)
  "Non-nil when git repo ROOT has uncommitted changes."
  (let ((default-directory root))
    (and (file-directory-p (expand-file-name ".git" root))
         (with-temp-buffer
           (let ((status (call-process "git" nil t nil "status" "--porcelain")))
             (and (zerop status) (> (buffer-size) 0)))))))

(defun my/dashboard--dirty-repo-roots ()
  "List dirty git repo roots among known candidates."
  (cl-remove-if-not #'my/dashboard--git-dirty-p
                    (my/dashboard--candidate-repo-roots)))

(defun my/dashboard--projects-with-current-first (roots)
  "Sort project ROOTS with current project first."
  (let ((current (my/dashboard--current-project-root)))
    (if current
        (let ((cur (expand-file-name current)))
          (cons cur (cl-remove cur roots :test (lambda (a b) (string-equal a b)))))
      roots)))

;; ============================================
;; Custom dashboard sections
;; ============================================

(defun my/dashboard--insert-section-rule ()
  "Insert `------------' under Git / Projects headings."
  (insert (propertize "    ------------\n" 'face 'font-lock-comment-face)))

(defun my/dashboard-insert-dirty-repos (list-size)
  "Dashboard section: git repos with uncommitted changes."
  (setq my/dashboard-dirty-alist nil)
  (let ((repos (my/dashboard--dirty-repo-roots)))
    (dashboard-insert-section
     "Git:"
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
            (name (file-name-nondirectory (directory-file-name dir))))
       (format "● %s" name)))))

(defun my/dashboard-insert-projects (list-size)
  "Dashboard section: projects, current project marked with 🔥."
  (setq dashboard--projects-cache-item-format nil)
  (setq dashboard-projects-alist nil)
  (let* ((roots (dashboard-projects-backend-load-projects))
         (current (my/dashboard--current-project-root))
         (sorted (my/dashboard--projects-with-current-first roots))
         (items (dashboard-subseq sorted list-size)))
    (dashboard-insert-section
     "Projects:"
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
            (current-p (and current
                            (string-equal (expand-file-name file)
                                          (expand-file-name current)))))
       (cl-case dashboard-projects-show-base
         (`align
          (unless dashboard--projects-cache-item-format
            (let* ((len-align (dashboard--align-length-by-type 'projects))
                   (new-fmt (dashboard--generate-align-format
                             dashboard-projects-item-format len-align)))
              (setq dashboard--projects-cache-item-format new-fmt)))
          (format dashboard--projects-cache-item-format
                  (if current-p (format "🔥 %s" filename) filename)
                  path))
         (`nil (if current-p (format "🔥 %s" path) path))
         (t (format dashboard-projects-item-format
                    (if current-p (format "🔥 %s" filename) filename)
                    path)))))))

(use-package dashboard
  :ensure t
  :init
  (fset 'dashboard-setup-startup-hook (lambda () "noop"))
  :custom
  (dashboard-banner-logo-title "AI 工作台")
  (dashboard-center-content t)
  ;; dashboard-display-icons-p 由 config-display-tui / config-gui profile 预设
  (dashboard-items '((dirty-repos . 8)
                     (projects    . 8)
                     (recents     . 5)
                     (agenda      . 5)))
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
   '(("Git:" . "Git")
     ("Projects:" . "Projects")))
  (dashboard-projects-backend 'project-el)
  (dashboard-week-agenda-trim-leading-zero t)
  (dashboard-startupify-list '(dashboard-insert-banner
                               dashboard-insert-newline
                               dashboard-insert-banner-title
                               dashboard-insert-newline
                               dashboard-insert-init-info
                               dashboard-insert-items
                               dashboard-insert-newline))
  :config
  (setq dashboard-startup-banner 'ascii)
  (setq dashboard-init-info
        (lambda ()
          (propertize
           (format "✦  %d packages  ·  loaded in %s"
                   (length package-activated-list)
                   (emacs-init-time))
           'face 'font-lock-comment-face)))
  (advice-add #'dashboard-insert-heading :after
              (lambda (heading &rest _)
                (when (member heading '("Git:" "Projects:"))
                  (my/dashboard--insert-section-rule)))
              '((name . my/dashboard-heading-separator)))
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
