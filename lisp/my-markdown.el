;;; my-markdown.el --- Markdown review: render, file links, tables  -*- lexical-binding: t; -*-

(require 'markdown-mode)
(require 'my-project)

;; ============================================
;; Mode helpers (markdown-ts-mode vs markdown-mode)
;; ============================================

(defun my/markdown-mode-p ()
  "Non-nil if current buffer uses a Markdown editing mode."
  (or (derived-mode-p 'markdown-mode 'gfm-mode)
      (eq major-mode 'markdown-ts-mode)))

(defun my/markdown-activate ()
  "Enable Markdown editing mode (tree-sitter when remapped)."
  (require 'markdown-mode)
  (let ((mode (cdr (assoc 'markdown-mode major-mode-remap-alist))))
    (if (and mode (not (eq mode 'markdown-mode)) (fboundp mode))
        (funcall mode)
      (markdown-mode))))

;; ============================================
;; File path detection & open
;; ============================================

(defconst my/markdown-path-ext-regexp
  "el\\|emacs\\|md\\|markdown\\|org\\|ts\\|tsx\\|js\\|jsx\\|mjs\\|cjs\\|rs\\|py\\|json\\|yaml\\|yml\\|toml\\|go\\|sh\\|bash\\|zsh\\|css\\|scss\\|html\\|txt\\|review\\|diff\\|lock"
  "File extensions treated as openable paths in review buffers.")

(defvar my/markdown-path-link-keymap
  (let ((map (make-sparse-keymap)))
    (define-key map [follow-link] #'my/markdown-open-path-at-point)
    (define-key map (kbd "RET") #'my/markdown-open-path-at-point)
    (define-key map [mouse-2] #'my/markdown-open-path-at-point)
    map)
  "Keymap for fontified file paths.")

(defface my/markdown-path-link-face
  '((t :inherit markdown-link-face :underline t))
  "Clickable file path in Markdown review."
  :group 'markdown-faces)

(defun my/markdown--path-root ()
  "Project root for resolving relative paths."
  (or (my/project-root) default-directory))

(defun my/markdown--normalize-path (path)
  "Clean PATH from diff/markdown wrappers."
  (when path
    (let ((s (string-trim path)))
      (when (string-match-p "\\`[`'\"]" s)
        (setq s (substring s 1)))
      (when (string-match-p "[`'\"]\\'" s)
        (setq s (substring s 0 (1- (length s)))))
      (when (string-match-p "\\`[ab]/" s)
        (setq s (substring s 2)))
      (when (string-match-p "\\`\\./" s)
        (setq s (substring s 2)))
      s)))

(defun my/markdown--resolve-path (path)
  "Expand PATH relative to `my/markdown--path-root'."
  (let* ((root (my/markdown--path-root))
         (clean (my/markdown--normalize-path path))
         (full (expand-file-name clean root)))
    (when (and clean (not (string-empty-p clean)))
      full)))

(defun my/markdown--path-at-point ()
  "Return a project-relative file path at point, or nil."
  (or (get-text-property (point) 'my/markdown-path)
      (save-excursion
        (let ((path nil))
          (cond
           ((get-text-property (point) 'markdown-pre)
            nil)
           ((thing-at-point-looking-at
             (format "`\\([^`']+/[^`']+\\.\\(?:%s\\)\\)`"
                     my/markdown-path-ext-regexp))
            (setq path (match-string-no-properties 1)))
           ((thing-at-point-looking-at
             (format "`\\([^`']+\\.\\(?:%s\\)\\)`"
                     my/markdown-path-ext-regexp))
            (setq path (match-string-no-properties 1)))
           ((thing-at-point-looking-at
             (format "^[ \t]*[+-][+-][+-] [ab]/\\([^ \t]+\\)"))
            (setq path (match-string-no-properties 1)))
           ((thing-at-point-looking-at
             (format "[^ \t\n`'\"<>|()\\[\\]]+/[^ \t\n`'\"<>|()\\[\\]]+\\.\\(?:%s\\)"
                     my/markdown-path-ext-regexp))
            (setq path (match-string-no-properties 0)))
           ((thing-at-point-looking-at
             (format "[^ \t\n`'\"<>|()\\[\\]/]+\\.\\(?:%s\\)"
                     my/markdown-path-ext-regexp))
            (setq path (match-string-no-properties 0))))
          path))))

(defun my/markdown-open-path-at-point ()
  "Open file path at point (project-relative or in backticks)."
  (interactive)
  (let* ((raw (my/markdown--path-at-point))
         (file (and raw (my/markdown--resolve-path raw))))
    (unless (and file (file-exists-p file))
      (user-error "No openable file at point%s"
                  (if raw (format ": %s" raw) "")))
    (find-file file)))

(defun my/markdown-follow-thing-at-point (arg)
  "Follow link, wiki link, or project file path at point."
  (interactive "P")
  (condition-case err
      (markdown-follow-thing-at-point arg)
    (error
     (my/markdown-open-path-at-point))))

;; ============================================
;; Path fontification
;; ============================================

(defun my/markdown--fontify-path (path)
  "Add link properties for PATH span at point."
  (let ((beg (match-beginning 1))
        (end (match-end 1)))
    (put-text-property beg end 'my/markdown-path path)
    (put-text-property beg end 'help-echo (concat "Open: " path))
    (put-text-property beg end 'mouse-face 'highlight)
    (put-text-property beg end 'keymap my/markdown-path-link-keymap)
    (add-face-text-property beg end 'my/markdown-path-link-face)))

(defun my/markdown-fontify-paths ()
  "Fontify file paths as clickable links (review buffers)."
  (font-lock-add-keywords
   nil
   (list
    (list (format "`\\([^`']+/[^`']+\\.\\(?:%s\\)\\)`"
                  my/markdown-path-ext-regexp)
          1 'my/markdown--fontify-path)
    (list (format "`\\([^`']+\\.\\(?:%s\\)\\)`"
                  my/markdown-path-ext-regexp)
          1 'my/markdown--fontify-path)
    (list (format "^[ \t]*[+-][+-][+-] [ab]/\\([^ \t]+\\)")
          1 'my/markdown--fontify-path)
    (list (format "\\(?:^\\|[ \t(]\\)\\([^ \t\n`'\"<>|()\\[\\]]+/[^ \t\n`'\"<>|()\\[\\]]+\\.\\(?:%s\\)\\)"
                  my/markdown-path-ext-regexp)
          1 'my/markdown--fontify-path))))

;; ============================================
;; Tables
;; ============================================

(defun my/markdown-align-all-tables ()
  "Align every GFM table in the current buffer."
  (interactive)
  (let ((inhibit-read-only (buffer-read-only-p)))
    (save-excursion
      (goto-char (point-min))
      (while (re-search-forward "^[ \t]*|" nil t)
        (when (markdown-table-at-point-p)
          (markdown-table-align)
          (goto-char (line-end-position)))))))

;; ============================================
;; Review view
;; ============================================

(defvar-local my/markdown-view-parent-mode nil
  "Major mode to restore when leaving `markdown-view-mode'.")

(defun my/markdown-review-setup (&optional align-tables)
  "Enable markup hiding, path links, and optional table alignment."
  (setq-local markdown-hide-markup t
              markdown-mouse-follow-link t
              markdown-table-align-p t
              markdown-fontify-code-blocks-natively t)
  (add-to-invisibility-spec 'markdown-markup)
  (my/markdown-fontify-paths)
  (when align-tables
    (my/markdown-align-all-tables))
  (font-lock-flush)
  (font-lock-ensure))

(defun my/markdown-toggle-review-view ()
  "Toggle read-only review view with rendering and path links."
  (interactive)
  (cond
   ((eq major-mode 'markdown-view-mode)
    (funcall (or my/markdown-view-parent-mode #'my/markdown-activate)))
   ((and (eq major-mode 'markdown-ts-mode) buffer-read-only)
    (read-only-mode -1))
   ((derived-mode-p 'my/ai-review-mode)
    (my/markdown-review-setup t)
    (message "AI-Review 审阅视图已刷新"))
   ((my/markdown-mode-p)
    (setq my/markdown-view-parent-mode major-mode)
    (let ((file buffer-file-name))
      (if (eq major-mode 'markdown-ts-mode)
          (progn
            (my/markdown-review-setup t)
            (read-only-mode 1))
        (markdown-view-mode)
        (when file (setq buffer-file-name file))
        (my/markdown-review-setup t))))
   (t
    (user-error "C-c C-r 仅在 Markdown buffer 内可用 (当前: %s)" major-mode))))

(defun my/markdown--bind-map (map)
  "Bind review keys on MAP."
  (when (and map (keymapp map))
    (define-key map (kbd "C-c C-p") #'my/markdown-preview-dwim)
    (define-key map (kbd "C-c C-r") #'my/markdown-toggle-review-view)
    (define-key map (kbd "C-c C-v") nil)
    (define-key map (kbd "C-c C-o") #'my/markdown-follow-thing-at-point)
    (define-key map (kbd "C-c C-t") #'my/markdown-align-all-tables)))

(defun my/markdown-setup-keys ()
  "Bind Markdown review keys on all relevant mode maps."
  (dolist (sym '(markdown-mode-map markdown-view-mode-map markdown-ts-mode-map))
    (when (boundp sym)
      (my/markdown--bind-map (symbol-value sym))))
  (when (boundp 'my/ai-review-mode-map)
    (my/markdown--bind-map my/ai-review-mode-map))
  (when (boundp 'markdown-view-mode-map)
    (define-key markdown-view-mode-map (kbd "q") #'my/markdown-toggle-review-view)))

(defun my/markdown-on-mode ()
  "Hook: visual line + key bindings for any Markdown mode."
  (visual-line-mode 1)
  (my/markdown-setup-keys))

(defun my/markdown-review-mode-hook ()
  "Default hook for read-only Markdown review buffers."
  (my/markdown-review-setup t)
  (my/markdown-setup-keys))

(with-eval-after-load 'markdown-ts-mode
  (my/markdown-setup-keys))

(provide 'my-markdown)
;;; my-markdown.el ends here
