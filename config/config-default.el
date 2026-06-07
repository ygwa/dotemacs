(setq use-short-answers t)
(global-auto-revert-mode 1)

(setq default-directory "~/")
(setq command-line-default-directory "~/")

(setq visible-bell 1)

(setq tab-always-indent nil)
;; Emacs 30: 使用空格缩进（更现代的做法）
(setq indent-tabs-mode nil) ;; for space-based indentation

;; fullscreen
(defun toggle-fullscreen ()
  "Toggle full screen"
  (interactive)
  (set-frame-parameter
   nil 'fullscreen
   (when (not (frame-parameter nil 'fullscreen)) 'fullboth)))

;; dired: macOS 的 ls 不支持 --dired，GNU/Linux 默认支持
(pcase system-type
  ('darwin
   (setq dired-use-ls-dired nil)
   (setq insert-directory-program "ls"))
  ('gnu/linux
   (setq dired-use-ls-dired t)))

(when (display-graphic-p)
  (global-set-key (kbd "<s-return>") 'toggle-fullscreen))

;; ============================================
;; 跨环境视觉微调 (GUI vs TUI)
;; ============================================

;; 光标样式: GUI 用细竖条, TUI 用方框 (Emacs 默认)
;; 不在 daemon/early-init 期执行, 避免 headless 启动时无 frame
(unless (daemonp)
  (setq-default cursor-type
                (if (display-graphic-p)
                    '(bar . 2)
                  'box)))

;; 行距: GUI 给一点呼吸感, TUI 不设置 (终端控不准)
(when (display-graphic-p)
  (setq-default line-spacing 0.1))

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

