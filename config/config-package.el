;;; config-package.el --- 包管理和编程语言配置 -*- lexical-binding: t; -*-

;; use-package 已在 init.el 中加载

;; ============================================
;; 1. 基础功能
;; ============================================

;; recentf
(recentf-mode 1)
(setq recentf-max-saved-items 512)

(use-package project
  :ensure nil ; 内置包
  :bind (("C-c p f" . project-find-file)
         ("C-c p b" . project-switch-to-buffer)
         ("C-c p d" . project-dired)
         ("C-c p v" . project-vc-dir)
         ("C-c p s" . project-shell)
         ("C-c p g" . project-find-regexp))
  :config
  ;; 增强非 Git 项目识别（例如只有 package.json 的前端项目）
  (setq project-vc-extra-root-markers '("package.json" "requirements.txt" ".project")))

;; shell
(add-hook 'shell-mode-hook 'ansi-color-for-comint-mode-on)

(use-package rainbow-delimiters
  :ensure t
  :init
  (add-hook 'prog-mode-hook #'rainbow-delimiters-mode)
  (add-hook 'emacs-lisp-mode-hook 'rainbow-mode))

;; ============================================
;; 2. Git 集成
;; ============================================

(use-package magit
  :ensure t
  :config
  (setq magit-push-always-verify nil
        magit-revert-buffers t))

;; ============================================
;; 3. 终端
;; ============================================

(use-package vterm
  :ensure t
  :config
  (setq vterm-max-scrollback 10000))

(use-package vterm-toggle
  :ensure t
  :bind ("C-`" . vterm-toggle)
  :custom
  (vterm-toggle-scope 'project))

;; ============================================
;; 4. 代码补全 (Corfu + Cape)
;; ============================================

(use-package corfu
  :ensure t
  :demand t
  :init
  (global-corfu-mode)
  (corfu-popupinfo-mode 1)                ; 启用弹窗, M-d / M-l 才生效
  :custom
  (corfu-cycle t)
  (corfu-auto t)
  (corfu-auto-delay 0.1)
  (corfu-auto-prefix 2)
  (corfu-quit-at-boundary t)
  (corfu-quit-no-match t)
  (corfu-preview-current nil)
  ;; TUI 窄终端 (< 80) 时 min-width 不应硬卡 80, 用窗口宽度的 60% 当上限
  (corfu-min-width 30)
  (corfu-max-width (lambda () (max 30 (floor (* (window-width) 0.6)))))
  (corfu-count 10)
  :config
  (define-key corfu-map (kbd "C-n") 'corfu-next)
  (define-key corfu-map (kbd "C-p") 'corfu-previous)
  (define-key corfu-map (kbd "C-i") 'corfu-complete)
  (define-key corfu-map (kbd "C-s") 'corfu-insert-separator)
  (define-key corfu-map (kbd "M-d") 'corfu-show-documentation)
  (define-key corfu-map (kbd "M-l") 'corfu-show-location))

(use-package cape
  :ensure t
  :init
  (add-to-list 'completion-at-point-functions #'cape-dabbrev)
  (add-to-list 'completion-at-point-functions #'cape-file)
  (add-to-list 'completion-at-point-functions #'cape-history))

;; ============================================
;; 5. 搜索和导航
;; ============================================

(use-package vertico
  :ensure t
  :demand t
  :init
  (vertico-mode))

(use-package orderless
  :ensure t
  :custom
  (completion-styles '(orderless basic))
  (completion-category-overrides '((file (styles basic partial-completion)))))

(use-package consult
  :ensure t
  :demand t
  :config
  (global-set-key (kbd "C-s") 'consult-line)
  (global-set-key (kbd "C-M-s") 'consult-line-multi)
  (global-set-key (kbd "C-x b") 'consult-buffer)
  (global-set-key (kbd "M-y") 'consult-yank-pop)
  (global-set-key (kbd "C-x r b") 'consult-bookmark)
  (global-set-key (kbd "C-c C-r") 'consult-recent-file)
  (global-set-key (kbd "C-c g") 'consult-git-grep)
  (global-set-key (kbd "C-c k") 'consult-ripgrep)
  (global-set-key (kbd "C-x l") 'consult-locate)
  (global-set-key (kbd "<f1> f") 'consult-describe-function)
  (global-set-key (kbd "<f1> v") 'consult-describe-variable)
  (global-set-key (kbd "<f1> l") 'consult-find-library)
  (global-set-key (kbd "<f2> i") 'consult-info-lookup-symbol)
  (global-set-key (kbd "<f2> u") 'consult-unicode-char)
  (global-set-key (kbd "<f6>") 'consult-buffer)
  (define-key read-expression-map (kbd "C-r") 'consult-expression-history))

(use-package embark
  :ensure t
  :demand t
  :config
  (global-set-key (kbd "C-.") 'embark-act)
  (global-set-key (kbd "C-;") 'embark-dwim)
  (global-set-key (kbd "C-h B") 'embark-bindings))

(use-package embark-consult
  :ensure t
  :after (embark consult)
  :hook (embark-collect-mode . consult-preview-at-point-mode))

(use-package marginalia
  :ensure t
  :init
  (marginalia-mode))

(use-package avy
  :ensure t
  :demand t
  :config
  (global-set-key (kbd "C-c j") 'avy-goto-char)
  (global-set-key (kbd "C-c J") 'avy-goto-line)
  (global-set-key (kbd "C-c w") 'avy-goto-word-1))

;; ============================================
;; 6. 环境变量
;; ============================================
;; 注意: exec-path-from-shell 已在 init.el 中统一配置

;; ============================================
;; 7. 撤销可视化
;; ============================================

(use-package vundo
  :ensure t
  :bind (("C-z" . undo)
         ("C-x u" . vundo))
  :config
  (setq vundo-compact-display t))

;; ============================================
;; 8. 其他工具
;; ============================================

(use-package plantuml-mode
  :ensure t)

(use-package smartparens
  :ensure t
  :diminish smartparens-mode
  :config
  (require 'smartparens-config)
  (smartparens-global-mode 1))

(use-package youdao-dictionary
  :ensure t
  :init
  (setq url-automatic-caching t)
  :config
  (global-set-key (kbd "C-c y") 'youdao-dictionary-search-at-point+))

  ;; 建立模式映射，当打开 .yaml/.json 时自动使用 Tree-sitter 模式
(setq major-mode-remap-alist
      '((yaml-mode . yaml-ts-mode)
        (js-mode . js-ts-mode)
        (typescript-mode . typescript-ts-mode)
        (json-mode . json-ts-mode)
        (css-mode . css-ts-mode)
        (python-mode . python-ts-mode)))

;; ============================================
;; 9. Eglot LSP (Emacs 30 内置)
;; ============================================

(use-package eglot
  :ensure nil  ; Emacs 30 内置
  :hook
  ((python-mode rust-mode rust-ts-mode) . eglot-ensure)
  :config
  ;; 通用 Eglot 配置
  (setq eglot-autoshutdown t
        eglot-confirm-server-initiated-edits nil
        eglot-events-buffer-size 0
        eglot-connect-timeout 60
        eglot-sync-connect 1)
  
  ;; Rust 配置 — 通用 executable-find 查找，不再硬编码路径
  (let ((ra (executable-find "rust-analyzer")))
    (when ra
      (add-to-list 'eglot-server-programs `(rust-mode . ,(vector ra)) t)
      (add-to-list 'eglot-server-programs `(rust-ts-mode . ,(vector ra)) t)))
  
  ;; 通用键绑定 (C-c s = server)
  (define-key eglot-mode-map (kbd "C-c s r") 'eglot-rename)
  (define-key eglot-mode-map (kbd "C-c s f") 'eglot-format)
  (define-key eglot-mode-map (kbd "C-c s a") 'eglot-code-actions)
  (define-key eglot-mode-map (kbd "C-c s h") 'eglot-help-at-point)
  (define-key eglot-mode-map (kbd "C-c s d") 'eglot-find-declaration)
  (define-key eglot-mode-map (kbd "C-c s i") 'eglot-find-implementation)
  (define-key eglot-mode-map (kbd "C-c s t") 'eglot-find-typeDefinition)
  
  ;; Rust 安装提示 (rust-mode / rust-ts-mode 共用)
  (defvar my/rust-analyzer-install-hint
    "提示: 未找到 rust-analyzer。请安装: curl -L https://github.com/rust-lang/rust-analyzer/releases/latest/download/rust-analyzer-$(uname | tr '[:upper:]' '[:lower:]')-$(uname -m) | sudo tee /usr/local/bin/rust-analyzer && sudo chmod +x /usr/local/bin/rust-analyzer")
  (defun my/rust-analyzer-hint ()
    "缺少 rust-analyzer 时打印安装提示。"
    (unless (executable-find "rust-analyzer")
      (message my/rust-analyzer-install-hint)))
  (add-hook 'rust-mode-hook   #'my/rust-analyzer-hint)
  (add-hook 'rust-ts-mode-hook #'my/rust-analyzer-hint))

;; ============================================
;; 10. Tree-sitter (Emacs 30 内置)
;; ============================================

(when (>= emacs-major-version 30)
  (setq treesit-font-lock-level 4)
  (setq treesit-extra-load-path
        (list (expand-file-name "tree-sitter" user-emacs-directory)))
  
  ;; Rust
  (add-to-list 'auto-mode-alist '("\\.rs\\'" . rust-ts-mode))
  
  (with-eval-after-load 'rust-ts-mode
    (setq rust-ts-mode-indent-offset 4)
    (define-key rust-ts-mode-map (kbd "C-c C-f") 'eglot-format-buffer))
  
  (add-hook 'rust-ts-mode-hook
            (lambda ()
              (when (and (fboundp 'treesit-ready-p)
                         (not (treesit-ready-p 'rust)))
                (message "提示: Rust Tree-sitter 语法库未安装。运行 M-x treesit-install-language-grammar RET rust RET 安装。")))))

(provide 'config-package)
;;; config-package.el ends here
