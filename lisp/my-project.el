;;; my-project.el --- Unified project root detection  -*- lexical-binding: t; -*-

(defun my/project-root ()
  "Return expanded project root for current context, or nil.
Prefer `project.el', then VC root, then `.git' from buffer path."
  (condition-case nil
      (or (and (fboundp 'project-current)
               (let ((proj (project-current)))
                 (when proj (expand-file-name (project-root proj)))))
          (and (fboundp 'vc-root-dir) (vc-root-dir))
          (when (buffer-file-name)
            (locate-dominating-file
             (buffer-file-name)
             (lambda (d)
               (or (file-directory-p (expand-file-name ".git" d))
                   (file-exists-p (expand-file-name "package.json" d))
                   (file-exists-p (expand-file-name "requirements.txt" d))
                   (file-exists-p (expand-file-name ".project" d))))))
          (when (and default-directory (file-directory-p default-directory))
            default-directory))
    (error nil)))

(defun my/project-root-or-error ()
  "Like `my/project-root', but signal if nil."
  (or (my/project-root) (user-error "Not in a project")))

(defun my/ai-project-root ()
  "Backward-compatible alias for `my/project-root'."
  (my/project-root))

(defun my/project-root-directory ()
  "Backward-compatible alias for `my/project-root'."
  (my/project-root))

(provide 'my-project)
;;; my-project.el ends here
