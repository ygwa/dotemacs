;;; early-init.el --- Early initialization for Emacs 30.2
;;; 早期初始化文件，用于性能优化
;;; 这个文件在 init.el 之前加载，用于优化启动性能

;; 禁用不必要的功能以提升启动速度
(setq package-enable-at-startup nil)  ; 延迟包初始化
(setq frame-inhibit-implied-resize t)  ; 禁止自动调整窗口大小

;; 禁用 GUI 功能（如果不需要）
(when (fboundp 'tool-bar-mode)
  (tool-bar-mode -1))
(when (fboundp 'menu-bar-mode)
  (menu-bar-mode -1))
(when (fboundp 'scroll-bar-mode)
  (scroll-bar-mode -1))

;; 性能优化：减少垃圾回收频率
(setq gc-cons-threshold (* 50 1024 1024))  ; 50MB

;; 原生编译优化（如果支持）
(when (fboundp 'native-comp-available-p)
  (when (native-comp-available-p)
    (setq native-comp-async-report-warnings-errors 'silent)
    (setq package-native-compile t)))

;; 设置自定义文件位置（避免在 init.el 中设置）
(setq custom-file (expand-file-name "custom.el" user-emacs-directory))

;; 禁用自动保存和备份（在早期阶段）
(setq auto-save-default nil)
(setq make-backup-files nil)

;; 提供 early-init 模块
(provide 'early-init)

