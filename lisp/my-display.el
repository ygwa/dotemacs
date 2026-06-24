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
    (if (my/markdown-mode-p)
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

;; ============================================
;; GUI frame 检测 / 延迟加载 / 全屏 (S-Return)
;; ============================================
;; TUI daemon + emacsclient -c 时 init 阶段无图形 display, config-gui 不会加载;
;; 首个 GUI frame 创建时再 require config-gui 并绑定键位.

(defvar my/display--gui-keys-bound nil
  "Non-nil once GUI-only keys (e.g. S-Return fullscreen) are bound.")

(defvar my/display--gui-profile-loaded nil
  "Non-nil once config-gui has been loaded for a graphic frame.")

(defun my/toggle-frame-fullscreen ()
  "Toggle native fullscreen on the selected frame (GUI only).
Like iTerm2 Shift+Return: normal ↔ fullscreen."
  (interactive)
  (let ((frame (selected-frame)))
    (unless (display-graphic-p frame)
      (user-error "Fullscreen toggle requires a GUI frame"))
    (cond
     ((fboundp 'toggle-frame-fullscreen)
      (call-interactively #'toggle-frame-fullscreen))
     ((fboundp 'ns-toggle-fullscreen)
      (call-interactively #'ns-toggle-fullscreen))
     (t
      (let ((fullscreen (frame-parameter frame 'fullscreen)))
        (modify-frame-parameters
         (list frame)
         (list (cons 'fullscreen
                     (if fullscreen nil 'fullboth)))))))))

(defun my/display--bind-gui-keys ()
  "Bind GUI-only global keys once."
  (unless my/display--gui-keys-bound
    (setq my/display--gui-keys-bound t)
    (dolist (key '("S-<return>" "<S-return>"))
      (global-set-key (kbd key) #'my/toggle-frame-fullscreen))
    ;; macOS: 抑制未绑定的 Super+鼠标拖拽提示
    (when (eq system-type 'darwin)
      (global-set-key (kbd "s-<drag-mouse-1>") #'ignore))))

(defun my/display--ensure-gui-profile (frame)
  "Late-load GUI profile when the first graphic frame appears."
  (when (and frame (display-graphic-p frame) (not my/display--gui-profile-loaded))
    (setq my/display--gui-profile-loaded t)
    (unless (featurep 'config-gui)
      (require 'config-gui nil t))
    (when (fboundp 'my/setup-gui-fonts)
      (with-selected-frame frame (my/setup-gui-fonts)))))

(defun my/display--on-make-frame (frame)
  (when (display-graphic-p frame)
    (my/display--ensure-gui-profile frame)
    (my/display--bind-gui-keys)))

(add-hook 'after-make-frame-functions #'my/display--on-make-frame)

(when (display-graphic-p)
  (my/display--bind-gui-keys))

(provide 'my-display)
;;; my-display.el ends here
