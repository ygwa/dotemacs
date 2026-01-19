;;; init.el --- Optimized Configuration for Emacs 30.2  -*- lexical-binding: t; -*-
;;; 核心原则：快速启动、模块化、稳定

;; ============================================
;; 1. 启动性能优化 (早期加速)
;; ============================================

;; 暂时调高垃圾回收阈值以加速启动
(setq gc-cons-threshold (* 100 1024 1024))
;; 增加进程输出限制 (对 LSP 和阅读器有极大帮助)
(setq read-process-output-max (* 1024 1024))
;; 禁用某些不必要的底层处理
(setq idle-update-delay 1.0)

;; ============================================
;; 2. 加载路径管理
;; ============================================

(defun add-subdirs-to-load-path (dir)
  "将目录及其子目录添加到 load-path"
  (let ((default-directory (expand-file-name dir user-emacs-directory)))
    (when (file-directory-p default-directory)
      (add-to-list 'load-path default-directory)
      (normal-top-level-add-subdirs-to-load-path))))

;; 加载核心配置目录
(add-subdirs-to-load-path "lisp")
(add-subdirs-to-load-path "config")

;; ============================================
;; 3. 包管理器初始化 (Modern Style)
;; ============================================

(require 'package)

(setq package-archives
      '(("gnu" . "https://mirrors.ustc.edu.cn/elpa/gnu/")
        ("melpa" . "https://mirrors.ustc.edu.cn/elpa/melpa/")
        ("nongnu" . "https://mirrors.ustc.edu.cn/elpa/nongnu/")))

;; 初始化包
(unless (and (boundp 'package--initialized) package--initialized)
  (package-initialize))

;; Emacs 29/30 已内置 use-package，无需手动安装
(require 'use-package)
(setq use-package-always-ensure t)      ; 自动下载缺失的包
(setq use-package-expand-minimally t)   ; 减少字节码体积

;; ============================================
;; 4. 关键环境变量设置 (尤其是 macOS)
;; ============================================

(use-package exec-path-from-shell
  :if (memq system-type '(darwin berkeley-unix))
  :ensure t
  :config
  (exec-path-from-shell-initialize))

;; ============================================
;; 5. 模块化配置加载
;; ============================================

;; 按照逻辑顺序加载
(mapc #'require '(config-default
		  config-org
                  config-gui
		  config-web
                  config-package))

;; ============================================
;; 6. 运行期性能恢复 (启动完成后执行)
;; ============================================

(add-hook 'emacs-startup-hook
          (lambda ()
            (message "Emacs started in %s." (emacs-init-time))
            ;; 提示清理无用包
            (setq package-unused-archives nil)))

;; ============================================
;; 7. 自定义变量文件 (保持 init.el 干净)
;; ============================================

(setq custom-file (expand-file-name "custom.el" user-emacs-directory))
(when (file-exists-p custom-file)
  (load custom-file))

;;; init.el ends here
