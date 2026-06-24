;;; config-gui.el --- GUI display profile -*- lexical-binding: t; -*-
;; 加载顺序: config-shared 之后, config-dashboard 之前

;; ============================================
;; 1. 弹窗/文件对话框
;; ============================================

(setq use-file-dialog nil
      use-dialog-box nil)

;; ============================================
;; 2. 平滑像素滚动
;; ============================================

(when (fboundp 'pixel-scroll-precision-mode)
  (pixel-scroll-precision-mode 1))

;; 可选: GUI 保留右侧滚动条 (early-init 默认禁用)
(push '(vertical-scroll-bars . right) default-frame-alist)

;; ============================================
;; 3. 字体与中文排版
;; ============================================

(defcustom my/monospace-font
  (if (eq system-type 'windows-nt) "Monospace-14" "JetBrains Mono-14")
  "等宽字体。Windows 用系统 Monospace, 其他平台用 JetBrains Mono。
M-x customize-group my-config 改, 然后 M-x my/setup-gui-fonts 或重启 Emacs 生效。"
  :type 'string
  :group 'my-config)

(defcustom my/cjk-font-family
  (pcase system-type
    ('darwin "Hiragino Sans GB")
    ('gnu/linux "Noto Sans CJK SC")
    ('windows-nt "Microsoft YaHei")
    (_ nil))
  "中文字体 (按 system-type 选择 fallback)。nil 表示不配置 CJK fontset。
M-x customize-group my-config 改。"
  :type '(choice (const :tag "不配置" nil)
                 (string :tag "字体名"))
  :group 'my-config)

(defun my/setup-gui-fonts ()
  "配置 GUI 字体 (等宽 + CJK fallback)."
  (when (display-graphic-p)
    (set-face-attribute 'default nil :font my/monospace-font)
    (when my/cjk-font-family
      (dolist (charset '(han kana symbol cjk-misc bopomofo))
        (set-fontset-font t charset (font-spec :family my/cjk-font-family)))
      (add-to-list 'face-font-rescale-alist (cons my/cjk-font-family 1.1)))))

(if (daemonp)
    (add-hook 'after-make-frame-functions
              (lambda (_frame) (my/setup-gui-fonts)))
  (my/setup-gui-fonts))

;; ============================================
;; 4. macOS 暗色模式同步 (可选, 默认关闭)
;; ============================================
;; 取消注释以下块以随系统外观切换 catppuccin mocha/latte:
;;
;; (when (and (eq system-type 'darwin)
;;            (fboundp 'ns-system-appearance))
;;   (add-hook 'ns-system-appearance-change-functions
;;             (lambda (appearance)
;;               (let* ((dark (eq appearance 'dark))
;;                      (new-flavor (if dark 'mocha 'latte)))
;;                 (when (and (display-graphic-p)
;;                            (not (eq my/theme-flavor new-flavor)))
;;                   (setq my/theme-flavor new-flavor)
;;                   (setq catppuccin-flavor new-flavor)
;;                   (catppuccin-reload)
;;                   (mapc #'disable-theme custom-enabled-themes)
;;                   (load-theme 'catppuccin t))))))

(context-menu-mode 1)

;; ============================================
;; 5. Mode-line — Nerd Font 像素图标
;; ============================================

(use-package doom-modeline
  :ensure nil
  :custom
  (doom-modeline-icon t)
  (doom-modeline-unicode t)
  (doom-modeline-major-mode-icon t)
  (doom-modeline-major-mode-color-icon t)
  (doom-modeline-buffer-state-icon t)
  (doom-modeline-buffer-modification-icon t)
  (doom-modeline-lsp-icon t)
  (doom-modeline-time-icon t)
  (doom-modeline-modal-icon t))

;; ============================================
;; 6. nerd-icons — 全量 Nerd Font
;; ============================================

(use-package nerd-icons
  :ensure t
  :custom
  (nerd-icons-default-icons-font "Symbols Nerd Font Mono"))

(use-package nerd-icons-dired
  :ensure t
  :hook (dired-mode . nerd-icons-dired-mode))

(use-package nerd-icons-corfu
  :ensure t
  :after corfu
  :config
  (add-to-list 'corfu-margin-formatters #'nerd-icons-corfu-formatter))

;; ============================================
;; 7. Dashboard — 图标 (sidebar 已用 dired, 不再需要 treemacs)
;; ============================================

(setq dashboard-display-icons-p t
      dashboard-set-heading-icons t
      dashboard-set-file-icons t)

;; ============================================
;; 8. 浏览器预览默认 — 系统默认 handler (formerly config-preview-gui.el)
;; ============================================
;; DWIM 命令定义在 my-display.el; 这里只设置 browse-url 走系统默认.

(setq browse-url-browser-function #'browse-url-default-browser)

(provide 'config-gui)
;;; config-gui.el ends here
