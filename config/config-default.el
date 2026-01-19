(setq use-short-answers t)
(global-auto-revert-mode 1)

;; ============================================
;; 文献管理路径配置
;; ============================================

(defvar my/bibliography-file "~/Documents/org/references.bib"
  "文献数据库文件路径。")

(defvar my/library-path "~/Documents/org/library/"
  "文献PDF存储目录。")

(defvar my/lit-notes-path "~/Documents/org/roam/lit/"
  "文献笔记目录。")

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

(when (string= system-type "darwin")
  ;; Emacs 30: macOS 特定优化
  (setq dired-use-ls-dired nil)
  ;; Emacs 30: 优化 macOS 上的文件操作性能
  (when (>= emacs-major-version 30)
    (setq insert-directory-program "ls")))

(global-set-key (kbd "<s-return>") 'toggle-fullscreen)

;; Emacs 30: 编码设置优化
(prefer-coding-system 'utf-8)
(set-default-coding-systems 'utf-8)
(set-terminal-coding-system 'utf-8)
(set-keyboard-coding-system 'utf-8)
;; Emacs 30: 设置默认字符编码
(when (fboundp 'set-charset-priority)
  (set-charset-priority 'unicode))

(display-time)

(provide 'config-default)

