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
  (add-hook 'emacs-lisp-mode-hook #'rainbow-mode))

;; ============================================
;; 2. Git 集成
;; ============================================

(use-package magit
  :ensure t
  :bind ("C-x g" . magit-status)
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
  :config
  (global-set-key (kbd "C-.") 'embark-act)
  (global-set-key (kbd "C-;") 'embark-dwim)
  (global-set-key (kbd "C-h B") 'embark-bindings))

(use-package embark-consult
  :ensure t
  :after consult          ; embark 已在 :demand t, 只需等 consult
  :hook (embark-collect-mode . consult-preview-at-point-mode))

(use-package marginalia
  :ensure t
  :init
  (marginalia-mode))

(use-package avy
  :ensure t
  :config
  (global-set-key (kbd "C-c j") 'avy-goto-char)
  (global-set-key (kbd "C-c J") 'avy-goto-line)
  (global-set-key (kbd "C-c W") 'avy-goto-word-1))

;; ============================================
;; 6. 环境变量
;; ============================================
;; 注意: exec-path-from-shell 在 init.el 第 4 节统一配置,
;; 这里只放编程工具.

;; ============================================
;; 7. 撤销可视化
;; ============================================

(use-package vundo
  :ensure t
  :defer t                       ; 首屏不撤销, 延迟到首次 C-x u 触发
  :bind (("C-z" . undo)
         ("C-x u" . vundo))
  :config
  (setq vundo-compact-display t))

;; ============================================
;; 8. 其他工具
;; ============================================

(use-package plantuml-mode
  :ensure t
  :defer t)                       ; 打开 .iuml/.plantuml 文件时自动加载, 首屏不需

(use-package smartparens
  :ensure t
  :diminish smartparens-mode
  :config
  (require 'smartparens-config)
  (smartparens-global-mode 1))

(use-package youdao-dictionary
  :ensure t
  :defer t                       ; 首屏不查词典, 延迟到首次 C-c y
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

  ;; Rust 安装提示 hook 注册在 use-package 外顶层 (见下方 dolist), 不依赖 eglot 懒加载,
  ;; 否则首次打开 .rs 时 hint 还没注册, 第一次无提示
  )

;; ============================================
;; 9b. consult-eglot (LSP 符号搜索)
;; ============================================
;; 打通 eglot LSP workspace/symbol 与 consult,
;; 在项目里按符号搜 (跨文件), 区别于 consult-git-grep (按文本).
;; C-c e s  搜项目符号 (LSP workspace/symbol)
;;
;; consult-eglot 只有一个公共命令 `consult-eglot-symbols',
;; 内部已处理"跨项目"vs"单文件"选择 (有 project 时查项目 server, 无时查当前 server).
;; 想再细粒度区分, 走 C-c s d/i/t (eglot 跳声明/实现/类型).

(use-package consult-eglot
  :ensure t
  :defer t
  :after (consult eglot)
  :bind ("C-c e s" . consult-eglot-symbols))

;; ============================================
;; 10. Jinx 拼写检查 (替代 flyspell)
;; ============================================
;; 依赖: brew install enchant2 pkgconf  (macOS 编译 jinx-mod.so 所需)
;; 作者: Daniel Mendler (vertico/corfu/consult/orderless 同一人)
;; GNU ELPA 收录, 月度发版, 零 open issues
;; TUI 完美支持 (C 模块加速)

(use-package jinx
  :ensure t
  :defer t  ; 延迟到首次拼写相关调用, 不影响启动
  :bind ([remap ispell-word] . jinx-correct)  ; M-$ 直接纠正
  :init
  ;; jinx 强依赖 enchant-2, 没装 brew install enchant2 pkgconf 时 jinx-mode 会抛
  ;; Compilation of jinx-mod.dylib failed, 中断 prog-mode-hook 链 → 派生 mode
  ;; (emacs-lisp-mode 等) 的 font-lock 不跑. condition-case 包住, 失败时仅
  ;; *Messages* 提示, 不污染其它 hook.
  (dolist (hook '(text-mode-hook prog-mode-hook))
    (add-hook hook
              (lambda ()
                (condition-case err
                    (jinx-mode 1)
                  (error
                   (message "Jinx 加载失败: %S (运行 `brew install enchant2 pkgconf` 修复)" err)
                   (jinx-mode -1))))))
  :config
  ;; 排除 org/LaTeX 的字体锁 face, 避免语法标记被误判为错字
  (cl-callf
      (lambda (pl)
        (delete-dups
         (append '(org-block font-lock-comment-face) pl)))
      (alist-get 'org-mode jinx-exclude-faces))
  (cl-callf
      (lambda (pl)
        (delete-dups
         (append '(font-lock-constant-face TeX-fold-unfolded-face) pl)))
      (alist-get 'tex-mode jinx-exclude-faces)))

;; ============================================
;; 10b. ws-butler — 保存时清被改行的行尾空格
;; ============================================
;; 只清理当前 buffer 中**实际被修改过**的行, 不动未碰的行, 避免
;; 全盘格式化污染 git diff. 文本模式也启用, 让 prose 也保持干净.
;; 卸载更老的 whitespace-cleanup (本配置未装).

(use-package ws-butler
  :ensure t
  :defer t
  :hook ((prog-mode text-mode) . ws-butler-mode))

;; ============================================
;; 11. Dape 调试器 (DAP 协议, eglot 哲学)
;; ============================================
;; 替代 dap-mode, GNU ELPA 收录, 月度发版
;; TUI 完美支持
;; 依赖各语言 DAP adapter 二进制 (debugpy / lldb-dap / vscode-js-debug 等)
;;
;; 快捷键:
;;   <f5>        dape              启动调试 (根据 dir-locals 配置)
;;   M-<f5>      dape-hydra/body   速查表 (下一步/进入/出/继续/断点等)
;;   C-c d b     dape-breakpoint-toggle  当前行切换断点

(use-package dape
  :ensure t
  :defer t
  :bind (("<f5>" . dape)
         ("M-<f5>" . dape-hydra/body)
         ("C-c d b" . dape-breakpoint-toggle))
  :config
  ;; 启动前自动保存 buffer (解释型语言调试需要磁盘上是最新的)
  (add-hook 'dape-on-start-hooks
            (defun my/dape--save-on-start ()
              (save-some-buffers t t)))
  ;; 断点持久化: 启动时加载, 退出时保存
  (dape-breakpoint-load)
  (add-hook 'kill-emacs-hook #'dape-breakpoint-save)

  ;; Python: debugpy (pip install debugpy)
  (when (executable-find "python")
    (add-to-list 'dape-adapters
                 '(python
                   (cwd . default-directory)
                   (host . "localhost")
                   (port . 5678))))

  ;; Node/TypeScript: vscode-js-debug (npm i -g vscode-js-debug)
  (when (executable-find "node")
    (add-to-list 'dape-adapters
                 '(node-js
                   (program . "vscode-js-debug")
                   (args . ("--server" "--port=0"))
                   (request . "attach")
                   (cwd . default-directory))))

  ;; Rust: lldb-dap (brew install lldb-dap)
  (when (executable-find "lldb-dap")
    (add-to-list 'dape-adapters
                 '(lldb-dap
                   (program . "lldb-dap")
                   (request . "launch")
                   (cwd . default-directory)
                   (lldb-dap-path-command . "lldb-dap")
                   (lldb-dap-launch-configuration . "launch.json")))))

;; Rust 安装提示 (hook 在 use-package 外顶层注册, 不依赖 eglot 懒加载).
;; 第一次打开 .rs 文件时若 rust-analyzer 不在 PATH, 打印按 system-type 分平台的安装命令.
(dolist (hook '(rust-mode-hook rust-ts-mode-hook))
  (add-hook hook
            (lambda ()
              (unless (executable-find "rust-analyzer")
                (message (pcase system-type
                           ('darwin "提示: 未找到 rust-analyzer。推荐:\n  brew install rust-analyzer            ; Homebrew 用户\n  rustup component add rust-analyzer   ; rustup 用户")
                           ('gnu/linux "提示: 未找到 rust-analyzer。推荐:\n  rustup component add rust-analyzer\n  或从 https://github.com/rust-lang/rust-analyzer/releases 下载预编译二进制放到 PATH")
                           (_ "提示: 未找到 rust-analyzer。请访问 https://rust-analyzer.github.io/ 安装。")))))))

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
