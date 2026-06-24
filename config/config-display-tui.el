;;; config-display-tui.el --- TUI display profile -*- lexical-binding: t; -*-
;; 加载顺序: config-shared 之后, config-dashboard 之前

;; ============================================
;; 1. Mode-line — 字符级 fallback (无像素图标)
;; ============================================

(use-package doom-modeline
  :ensure nil
  :custom
  (doom-modeline-icon nil)
  (doom-modeline-unicode nil)
  (doom-modeline-major-mode-icon nil)
  (doom-modeline-major-mode-color-icon nil)
  (doom-modeline-buffer-state-icon nil)
  (doom-modeline-buffer-modification-icon nil)
  (doom-modeline-lsp-icon nil)
  (doom-modeline-time-icon nil)
  (doom-modeline-modal-icon nil))

;; ============================================
;; 2. nerd-icons — unicode 字符 fallback
;; ============================================

(use-package nerd-icons-dired
  :ensure t
  :hook (dired-mode . nerd-icons-dired-mode))

(use-package nerd-icons-corfu
  :ensure t
  :after corfu
  :config
  (add-to-list 'corfu-margin-formatters #'nerd-icons-corfu-formatter))

;; ============================================
;; 3. TUI 对比度增强 (主题加载后)
;; ============================================

(defun my/display--catppuccin-color (sym)
  "Return catppuccin color SYM when theme is active."
  (when (fboundp 'catppuccin-color)
    (catppuccin-color sym)))

(defun my/display--setup-tui-faces ()
  "Raise contrast for terminal frames (hl-line, line numbers, dashboard)."
  (when (not (my/graphic-frame-p))
    (if-let* ((bg (my/display--catppuccin-color 'base))
              (fg (my/display--catppuccin-color 'text))
              (hl (my/display--catppuccin-color 'surface0))
              (dim (my/display--catppuccin-color 'overlay0)))
        (progn
          (set-face-attribute 'default nil :background bg :foreground fg)
          (when (facep 'hl-line)
            (set-face-attribute 'hl-line nil :background hl :foreground fg :extend t))
          (when (facep 'line-number)
            (set-face-attribute 'line-number nil :foreground dim))
          (when (facep 'line-number-current-line)
            (set-face-attribute 'line-number-current-line nil
                                :foreground (my/display--catppuccin-color 'sky)
                                :weight 'bold))
          (set-face-attribute 'font-lock-comment-face nil :foreground dim)
          (set-face-attribute 'font-lock-doc-face nil
                              :foreground (my/display--catppuccin-color 'subtext0))
          (when (fboundp 'my/dashboard--setup-faces)
            (my/dashboard--setup-faces)))
      (when (facep 'hl-line)
        (set-face-attribute 'hl-line nil :inherit 'secondary-selection :extend t)))))

(add-hook 'my/tui-after-theme-hook #'my/display--setup-tui-faces)

;; 补跑 TUI 对比度 (主题已在 config-shared 加载)
(when (and (not (my/graphic-frame-p)) (featurep 'catppuccin-theme))
  (my/display--setup-tui-faces))

;; ============================================
;; 4. Dashboard / Treemacs — 纯文本
;; ============================================

(setq dashboard-display-icons-p nil
      dashboard-set-heading-icons nil
      dashboard-set-file-icons nil
      treemacs-no-png-images t)

(provide 'config-display-tui)
;;; config-display-tui.el ends here
