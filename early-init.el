;;; early-init.el --- Early initialization for Emacs 30.2  -*- lexical-binding: t; -*-

;; ============================================
;; 1. 垃圾回收 (GC) 与加载性能优化
;; ============================================

;; 启动时将 GC 阈值设为最大，防止启动期间触发回收造成卡顿
(setq gc-cons-threshold most-positive-fixnum)

;; 暂时禁用 file-name-handler-alist 以加速文件加载
;; 这个变量用于处理压缩包或远程文件，加载本地配置时不需要
(defvar default-file-name-handler-alist file-name-handler-alist)
(setq file-name-handler-alist nil)

;; 启动完成后恢复 GC 阈值和 file-name-handler
(add-hook 'emacs-startup-hook
          (lambda ()
            (setq gc-cons-threshold (* 16 1024 1024)) ; 恢复到 16MB
            (setq file-name-handler-alist default-file-name-handler-alist)))

;; ============================================
;; 2. 界面视觉优化 (防止启动闪烁)
;; ============================================

;; 彻底禁用不必要的 UI 元素 (在窗口创建前执行)
(setq inhibit-startup-message t)
(setq inhibit-startup-echo-area-message user-login-name)
(setq inhibit-default-init t)
(setq initial-scratch-message nil)

;; 禁用 UI 栏 (Emacs 30 这样写更高效)
(push '(menu-bar-lines . 0) default-frame-alist)
(push '(tool-bar-lines . 0) default-frame-alist)
(push '(vertical-scroll-bars) default-frame-alist)

;; 禁止在加载字体时调整窗口大小 (极大加速启动并减少闪烁)
(setq frame-inhibit-implied-resize t)

;; ============================================
;; 3. 包管理器与自定义文件设置
;; ============================================

;; 禁用启动时的自动包初始化 (在 init.el 中由 use-package 接管)
(setq package-enable-at-startup nil)

;; 设置自定义变量文件的存储路径，避免其内容写进 init.el
(setq custom-file (expand-file-name "custom.el" user-emacs-directory))

;; ============================================
;; 4. Emacs 30 原生编译 (Native Comp) 优化
;; ============================================

(when (and (fboundp 'native-comp-available-p)
           (native-comp-available-p))
  ;; 即使后台编译包，也保持静默，不要弹出编译警告 Buffer
  (setq native-comp-async-report-warnings-errors 'silent)
  ;; 开启 JIT (即时编译)
  (setq native-comp-jit-compilation t)
  ;; 设置编译后的缓存路径
  (setq native-comp-eln-load-path
        (list (expand-file-name "eln-cache/" user-emacs-directory))))

;; ============================================
;; 5. 杂项性能设置
;; ============================================

;; 禁用自动双向渲染 (针对非阿拉伯语/希伯来语用户加速显著)
(setq-default bidi-display-reordering 'left-to-right)
(setq bidi-paragraph-direction 'left-to-right)

;; 提高单行长文本的渲染性能 (针对 Org 里的超长链接或表格)
(setq-default bidi-inhibit-bpa t)

(provide 'early-init)
;;; early-init.el ends here
