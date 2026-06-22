(setq use-short-answers t)
(global-auto-revert-mode 1)

(setq default-directory "~/")
(setq command-line-default-directory "~/")

(setq visible-bell 1)

(setq tab-always-indent nil)
;; Emacs 30: 使用空格缩进（更现代的做法）
(setq indent-tabs-mode nil) ;; for space-based indentation

;; dired: macOS 的 ls 不支持 --dired，GNU/Linux 默认支持
(pcase system-type
  ('darwin
   (setq dired-use-ls-dired nil)
   (setq insert-directory-program "ls"))
  ('gnu/linux
   (setq dired-use-ls-dired t)))

;; ============================================
;; 视觉微调 (TUI 专属, 2026-06 起)
;; ============================================
;; 统一 TUI 配置, 不再有 GUI 分支.

;; 光标: TUI 用 box (Emacs 默认), daemon 启动时不执行避免 headless 报错
(unless (daemonp)
  (setq-default cursor-type 'box))

;; ============================================
;; Emacs 30: 编码设置优化
;; ============================================
(prefer-coding-system 'utf-8)
(set-default-coding-systems 'utf-8)
(set-terminal-coding-system 'utf-8)
(set-keyboard-coding-system 'utf-8)
;; Emacs 30: 设置默认字符编码
(when (fboundp 'set-charset-priority)
  (set-charset-priority 'unicode))

(provide 'config-default)

