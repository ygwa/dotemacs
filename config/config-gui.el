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

(defvar my/monospace-font
  (if (eq system-type 'windows-nt) "Monospace-14" "JetBrains Mono-14")
  "等宽字体。Windows 用系统 Monospace, 其他平台用 JetBrains Mono。")

(defvar my/cjk-font-family
  (pcase system-type
    ('darwin "Hiragino Sans GB")
    ('gnu/linux "Noto Sans CJK SC")
    ('windows-nt "Microsoft YaHei")
    (_ nil))
  "中文字体 (按 system-type 选择 fallback)。nil 表示不配置。")

(defun my/setup-gui-fonts ()
  "配置 GUI 字体 (等宽 + CJK fallback)。"
  (set-face-attribute 'default nil :font my/monospace-font)
  (when my/cjk-font-family
    (dolist (charset '(han kana symbol cjk-misc bopomofo))
      (set-fontset-font t charset (font-spec :family my/cjk-font-family)))
    (add-to-list 'face-font-rescale-alist (cons my/cjk-font-family 1.1))))

;; 终端下不设置字体 (使用终端自己的字体)
(if (daemonp)
    (add-hook 'server-after-make-frame-hook
              (lambda ()
                (when (display-graphic-p)
                  (my/setup-gui-fonts))))
  (when (display-graphic-p)
    (my/setup-gui-fonts)))

;; ============================================
;; 4. macOS 暗色模式同步 (daemon 下也工作)
;; ============================================

(when (and (eq system-type 'darwin)
           (fboundp 'ns-system-appearance))
  (add-hook 'ns-system-appearance-change-functions
            (lambda (appearance)
              (let* ((dark (eq appearance 'dark))
                     (new-theme (if dark 'doom-one 'doom-one-light)))
                (when (and (display-graphic-p)
                           (not (equal my/theme new-theme)))
                  (setq my/theme new-theme)
                  (mapc #'disable-theme custom-enabled-themes)
                  (load-theme new-theme t))))))

(provide 'config-gui)
;;; config-gui.el ends here
