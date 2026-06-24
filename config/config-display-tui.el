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
;; 3. Dashboard / Treemacs — 纯文本
;; ============================================

(setq dashboard-display-icons-p nil
      treemacs-no-png-images t)

(provide 'config-display-tui)
;;; config-display-tui.el ends here
