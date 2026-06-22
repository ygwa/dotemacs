;;; config-gui.el --- GUI-only Configuration -*- lexical-binding: t; -*-
;; 加载顺序: 必须在 config-shared.el 之后 (依赖 my/theme)
;; 终端下本文件除字体/Mac 暗色相关 hook 之外, 其余变量无副作用

;; ============================================
;; 1. 弹窗/文件对话框 (GUI 专属, TUI 无效)
;; ============================================

(setq use-file-dialog nil
      use-dialog-box nil)

;; ============================================
;; 2. 平滑像素滚动 (GUI 专属; TUI 终端无 pixel 概念)
;; ============================================

(when (and (fboundp 'pixel-scroll-precision-mode)
           (display-graphic-p))
  (pixel-scroll-precision-mode 1))

;; ============================================
;; 3. 字体与中文排版 (跨平台 fallback)
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
  "配置 GUI 字体 (等宽 + CJK fallback)。
TUI frame 调用时是 noop (字体由终端控制, 我们主动 reset 回 nil
避免上次 GUI frame 残留的字体污染这个 frame)。"
  (set-face-attribute 'default nil :font
                      (if (display-graphic-p) my/monospace-font nil))
  (when (and (display-graphic-p) my/cjk-font-family)
    (dolist (charset '(han kana symbol cjk-misc bopomofo))
      (set-fontset-font t charset (font-spec :family my/cjk-font-family)))
    (add-to-list 'face-font-rescale-alist (cons my/cjk-font-family 1.1))))

;; 每个新 frame 都跑一次 (daemon 同时服务 GUI+TUI client 时, TUI 拿回默认字体)
(if (daemonp)
    (add-hook 'after-make-frame-functions
              (lambda (_frame) (my/setup-gui-fonts)))
  (my/setup-gui-fonts))

;; ============================================
;; 4. macOS 暗色模式同步 (daemon 下也工作)
;; ============================================

(when (and (eq system-type 'darwin)
           (fboundp 'ns-system-appearance))
  (add-hook 'ns-system-appearance-change-functions
            (lambda (appearance)
              (let* ((dark (eq appearance 'dark))
                     (new-flavor (if dark 'mocha 'latte)))
                (when (and (display-graphic-p)
                           (not (eq my/theme-flavor new-flavor)))
                  (setq my/theme-flavor new-flavor)
                  (setq catppuccin-flavor new-flavor)
                  (catppuccin-reload)      ; 触发 face 重新生成
                  (mapc #'disable-theme custom-enabled-themes)
                  (load-theme 'catppuccin t))))))

(context-menu-mode 1)                   ; GUI 右键上下文菜单 (Emacs 29+)

(provide 'config-gui)
;;; config-gui.el ends here
