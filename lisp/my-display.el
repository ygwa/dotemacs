;;; my-display.el --- TUI / GUI session detection and preview DWIM  -*- lexical-binding: t; -*-

(defun my/gui-session-p ()
  "当前 Emacs 实例是否按 GUI profile 启动.
前台 GUI 启动时 `display-graphic-p' 为 t;
GUI daemon 可通过环境变量 MY_EMACS_GUI=1 标记."
  (or (display-graphic-p)
      (string-equal (getenv "MY_EMACS_GUI") "1")))

(defun my/markdown-preview-dwim ()
  "GUI 下浏览器预览 Markdown; TUI 下切换 markdown-view-mode."
  (interactive)
  (if (my/gui-session-p)
      (if (executable-find "pandoc")
          (markdown-preview)
        (user-error "需要 pandoc 才能浏览器预览 Markdown"))
    (if (derived-mode-p 'markdown-mode 'gfm-mode)
        (call-interactively
         (if (eq major-mode 'gfm-mode) #'gfm-view-mode #'markdown-view-mode))
      (user-error "当前 buffer 不是 Markdown"))))

(defun my/org-preview-dwim ()
  "GUI 下导出 HTML 并在浏览器打开; TUI 下提示用导出或 agenda."
  (interactive)
  (unless (derived-mode-p 'org-mode)
    (user-error "当前 buffer 不是 Org"))
  (if (my/gui-session-p)
      (let ((file (org-html-export-to-file nil nil "html")))
        (when file (browse-url file)))
    (message "TUI: 用 C-c C-e 导出 HTML, 或 C-c a 在 agenda 中阅读")))

(provide 'my-display)
;;; my-display.el ends here
