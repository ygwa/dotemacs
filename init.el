;;; init.el --- Optimized Configuration for Emacs 30.2  -*- lexical-binding: t; -*-
;;; 核心原则：快速启动、模块化、稳定

;; ============================================
;; 1. 启动性能优化 (早期加速)
;; ============================================

;; gc-cons-threshold 由 early-init.el 管理 (启动期 max, startup hook 恢复 32MB)
;; 增加进程输出限制 (LSP / 阅读器)
(setq read-process-output-max (* 4 1024 1024))

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
;; 4. 关键环境变量设置 (跨平台 — PATH 同步)
;; ============================================

(use-package exec-path-from-shell
  :if (memq system-type '(darwin berkeley-unix gnu/linux))
  :ensure t
  :config
  (exec-path-from-shell-initialize))

;; ============================================
;; 5. 模块化配置加载
;; ============================================

;; 按照逻辑顺序加载
;; TUI-first + GUI profile: my/display 检测后加载 config-display-tui 或 config-gui.
(require 'my-custom)
(require 'my-project)
(require 'my-display)
(mapc #'require '(config-default
		  config-org
                  config-shared))
(if (my/gui-session-p)
    (mapc #'require '(config-gui config-preview-gui))
  (require 'config-display-tui))
(mapc #'require '(config-dashboard
                  config-treesit
		  config-web
                  config-package
                  config-markdown))
(when (memq 'ai my/features)
  (require 'config-agent)
  (require 'config-ai))
(when (memq 'git-review my/features)
  (require 'config-git-review))
(require 'config-workflow)

;; ============================================
;; 6. 运行期性能恢复 (启动完成后执行)
;; ============================================

(add-hook 'emacs-startup-hook
          (lambda ()
            (message "Emacs started in %s." (emacs-init-time))))

;; ============================================
;; 7. 自定义变量文件 (保持 init.el 干净)
;; ============================================

(setq custom-file (expand-file-name "custom.el" user-emacs-directory))
(when (file-exists-p custom-file)
  (load custom-file))

;;; init.el ends here
