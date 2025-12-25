;; use-package 已在 init.el 中加载

;; recentf
(recentf-mode 1)
(setq recentf-max-saved-items 512)

(use-package projectile
  :ensure t
  :config
  (setq projectile-project-search-path '("~/"))
  (setq projectile-auto-discover t)
  (define-key projectile-mode-map (kbd "s-p") 'projectile-command-map)
  (define-key projectile-mode-map (kbd "C-c p") 'projectile-command-map)
  (projectile-mode 1))

;; ag 已替换为 ripgrep（通过 consult-ripgrep）
;; 注意：需要系统安装 ripgrep: brew install ripgrep

(use-package yaml-mode
  :ensure t
  :init
  (add-hook 'yaml-mode-hook
          (lambda ()
            (define-key yaml-mode-map "\C-m" 'newline-and-indent))))

;; window-numbering 已替换为 avy（更强大的跳转功能）

;; shell
(add-hook 'shell-mode-hook 'ansi-color-for-comint-mode-on)

;;; rainbow
(use-package rainbow-mode
  :ensure t)

(use-package rainbow-delimiters
  :ensure t
  :init
  (add-hook 'prog-mode-hook #'rainbow-delimiters-mode)
  (add-hook 'emacs-lisp-mode-hook 'rainbow-mode)
  (add-hook 'css-mode-hook 'rainbow-mode)
  (add-hook 'web-mode-hook 'rainbow-mode))

;; magit
(use-package magit
  ;; for git config
  :ensure t
  :config
  ;; Emacs 30: 优化 magit 配置
  (setq magit-push-always-verify nil
        magit-revert-buffers t))

(use-package json-mode
  :defer t)

(use-package vterm
  :ensure t
  :config
  ;; 优化：让 vterm 也就是 Emacs 里的终端 buffer 更好用
  (setq vterm-max-scrollback 10000)
  
  ;; 这是一个很酷的功能：允许 vterm 跟 Emacs 互通剪贴板
  ;; 即使你在 CLI 里，也能把内容快速弄到 Emacs 笔记里
  )

;; 绑定一个快捷键快速呼出/隐藏终端
(use-package vterm-toggle
  :ensure t
  :bind ("C-`" . vterm-toggle) ;; 按 Ctrl+` 就像 VSCode 一样调出终端
  :custom
  (vterm-toggle-scope 'project)) ;; 自动在当前项目根目录打开

;; ============================================
;; Emacs 30 新标准栈：代码补全
;; ============================================

;; corfu - 现代补全弹窗（替代 company，更轻量、更快）
(use-package corfu
  :ensure t
  :demand t
  :init
  (global-corfu-mode)
  :custom
  (corfu-cycle t)                ; 允许循环选择
  (corfu-auto t)                 ; 自动补全
  (corfu-auto-delay 0.1)         ; 自动补全延迟
  (corfu-auto-prefix 2)          ; 最小前缀长度
  (corfu-quit-at-boundary t)     ; 在边界处退出
  (corfu-quit-no-match t)        ; 无匹配时退出
  (corfu-preview-current nil)    ; 不预览当前候选项
  (corfu-min-width 80)           ; 最小宽度
  (corfu-max-width corfu-min-width)
  (corfu-count 10)               ; 显示候选项数量
  :config
  ;; 键绑定
  (define-key corfu-map (kbd "C-n") 'corfu-next)
  (define-key corfu-map (kbd "C-p") 'corfu-previous)
  (define-key corfu-map (kbd "C-i") 'corfu-complete)
  (define-key corfu-map (kbd "C-s") 'corfu-insert-separator)
  (define-key corfu-map (kbd "M-d") 'corfu-show-documentation)
  (define-key corfu-map (kbd "M-l") 'corfu-show-location))

;; cape - 为 corfu 提供额外的补全后端
(use-package cape
  :ensure t
  :init
  ;; 添加补全后端
  (add-to-list 'completion-at-point-functions #'cape-dabbrev)
  (add-to-list 'completion-at-point-functions #'cape-file)
  (add-to-list 'completion-at-point-functions #'cape-history))


;; popwin 已移除（使用频率可能不高，Emacs 30 的窗口管理已改进）

(use-package youdao-dictionary
  :ensure t
  :init
  (setq url-automatic-caching t)
  :config
  (global-set-key (kbd "C-c y") 'youdao-dictionary-search-at-point+))

;; ============================================
;; 现代化搜索和导航栈（替代 ivy/counsel/swiper）
;; ============================================

;; vertico - 现代垂直补全框架
(use-package vertico
  :ensure t
  :demand t  ; 确保立即加载
  :init
  (vertico-mode)
  :config
  (vertico-mode))

;; orderless - 强大的模糊匹配
(use-package orderless
  :ensure t
  :custom
  (completion-styles '(orderless basic))
  (completion-category-overrides '((file (styles basic partial-completion)))))

;; consult - 现代化的搜索命令集合
(use-package consult
  :ensure t
  :demand t  ; 确保立即加载
  :config
  ;; 使用 global-set-key 确保键绑定生效
  (global-set-key (kbd "C-s") 'consult-line)
  (global-set-key (kbd "C-M-s") 'consult-line-multi)
  (global-set-key (kbd "C-x b") 'consult-buffer)
  (global-set-key (kbd "M-y") 'consult-yank-pop)
  (global-set-key (kbd "C-x r b") 'consult-bookmark)
  (global-set-key (kbd "C-c C-r") 'consult-recent-file)
  (global-set-key (kbd "C-c g") 'consult-git-grep)
  (global-set-key (kbd "C-c k") 'consult-ripgrep)  ; 替代 counsel-ag
  (global-set-key (kbd "C-x l") 'consult-locate)
  (global-set-key (kbd "<f1> f") 'consult-describe-function)
  (global-set-key (kbd "<f1> v") 'consult-describe-variable)
  (global-set-key (kbd "<f1> l") 'consult-find-library)
  (global-set-key (kbd "<f2> i") 'consult-info-lookup-symbol)
  (global-set-key (kbd "<f2> u") 'consult-unicode-char)
  (global-set-key (kbd "<f6>") 'consult-buffer)  ; 替代 ivy-resume
  (define-key read-expression-map (kbd "C-r") 'consult-expression-history))

;; embark - 强大的上下文操作
(use-package embark
  :ensure t
  :demand t  ; 确保立即加载
  :config
  (global-set-key (kbd "C-.") 'embark-act)
  (global-set-key (kbd "C-;") 'embark-dwim)
  (global-set-key (kbd "C-h B") 'embark-bindings))

;; embark-consult - Embark 和 Consult 的集成
(use-package embark-consult
  :ensure t
  :after (embark consult)
  :hook (embark-collect-mode . consult-preview-at-point-mode))

;; marginalia - 在 minibuffer 中显示额外信息
(use-package marginalia
  :ensure t
  :init
  (marginalia-mode))

;; avy - 强大的跳转功能（替代 window-numbering）
(use-package avy
  :ensure t
  :demand t  ; 确保立即加载
  :config
  (global-set-key (kbd "C-c j") 'avy-goto-char)
  (global-set-key (kbd "C-c J") 'avy-goto-line)
  (global-set-key (kbd "C-c w") 'avy-goto-word-1))

(use-package exec-path-from-shell
  :ensure t
  :config
  (when (memq window-system '(mac ns))
    ;; 优化：只同步必要的环境变量，减少执行时间
    (setq exec-path-from-shell-variables '("PATH" "MANPATH"))
    (setq exec-path-from-shell-arguments nil)  ; 不使用 shell 参数，加快速度
    (exec-path-from-shell-initialize))
  ;; 确保 Homebrew 路径在 exec-path 中（macOS）
  ;; 如果 exec-path-from-shell 失败，使用备用方法
  (when (eq system-type 'darwin)
    (let ((brew-path "/opt/homebrew/bin"))
      (when (file-directory-p brew-path)
        (add-to-list 'exec-path brew-path)
        (setenv "PATH" (concat brew-path ":" (or (getenv "PATH") "")))))))

;; vundo - 现代撤销可视化（替代 undo-tree）
(use-package vundo
  :ensure t
  :bind (("C-z" . undo)
         ("C-S-z" . vundo))
  :config
  (setq vundo-compact-display t))

(use-package plantuml-mode
  :ensure t)

(use-package smartparens
  :ensure t
  :diminish smartparens-mode
  :config
  (require 'smartparens-config)
  (smartparens-global-mode 1)
  (show-paren-mode t))

;; smart-comment 已移除（功能简单，可用内置功能替代）
;; 替代方案：使用内置的 comment-region 和 uncomment-region

;; highlight-symbol 已移除（功能可被 consult-line 替代）
;; 替代方案：使用 consult-line 或 consult-git-grep 进行搜索

;; ============================================
;; Emacs 30 新标准栈：LSP 和语法高亮
;; ============================================

;; eglot - LSP 客户端（Emacs 30 内置，替代 lsp-mode）
;; 更轻量、更快、更符合 Emacs 哲学
(use-package eglot
  :ensure nil  ; Emacs 30 内置，不需要安装
  :hook
  ((python-mode rust-mode rust-ts-mode typescript-mode javascript-mode go-mode) . eglot-ensure)
  :config
  ;; 优化 Eglot 配置
  (setq eglot-autoshutdown t
        eglot-confirm-server-initiated-edits nil
        eglot-events-buffer-size 0  ; 禁用事件缓冲区以提升性能
        eglot-connect-timeout 60
        eglot-sync-connect 1)
  
  ;; 配置 rust-analyzer 路径（如果不在 PATH 中）
  (when (eq system-type 'darwin)
    ;; macOS: 检查常见安装位置
    (let ((possible-paths '("/opt/homebrew/bin/rust-analyzer"
                            "/usr/local/bin/rust-analyzer"
                            "~/.cargo/bin/rust-analyzer"))
          (found nil))
      (dolist (path possible-paths)
        (let ((expanded-path (expand-file-name path)))
          (when (and (not found) (file-executable-p expanded-path))
            (add-to-list 'eglot-server-programs
                         `(rust-mode . (,expanded-path))
                         t)
            (add-to-list 'eglot-server-programs
                         `(rust-ts-mode . (,expanded-path))
                         t)
            (message "找到 rust-analyzer: %s" expanded-path)
            (setq found t))))))
  
  ;; 键绑定
  (define-key eglot-mode-map (kbd "C-c l r") 'eglot-rename)
  (define-key eglot-mode-map (kbd "C-c l f") 'eglot-format)
  (define-key eglot-mode-map (kbd "C-c l a") 'eglot-code-actions)
  (define-key eglot-mode-map (kbd "C-c l h") 'eglot-help-at-point)
  (define-key eglot-mode-map (kbd "C-c l d") 'eglot-find-declaration)
  (define-key eglot-mode-map (kbd "C-c l i") 'eglot-find-implementation)
  (define-key eglot-mode-map (kbd "C-c l t") 'eglot-find-typeDefinition)
  
  ;; 如果找不到 rust-analyzer，提供安装提示
  (add-hook 'rust-mode-hook
            (lambda ()
              (when (not (executable-find "rust-analyzer"))
                (message "提示: 未找到 rust-analyzer。请安装: brew install rust-analyzer 或 cargo install rust-analyzer"))))
  (add-hook 'rust-ts-mode-hook
            (lambda ()
              (when (not (executable-find "rust-analyzer"))
                (message "提示: 未找到 rust-analyzer。请安装: brew install rust-analyzer 或 cargo install rust-analyzer")))))

;; tree-sitter - 语法高亮（Emacs 30 内置，替代 regex-based font-lock）
;; 提供更准确、更快的语法高亮
(when (>= emacs-major-version 30)
  ;; Tree-sitter 是 Emacs 30 的内置功能，不需要 use-package
  (setq treesit-font-lock-level 4)  ; 最大语法高亮级别
  ;; 设置 tree-sitter 语法库的安装目录
  (setq treesit-extra-load-path
        (list (expand-file-name "tree-sitter" user-emacs-directory)))
  )

;; rust-ts-mode - Rust 模式（Emacs 30 内置，基于 Tree-sitter）
(when (>= emacs-major-version 30)
  ;; 自动关联 .rs 文件到 rust-ts-mode
  (add-to-list 'auto-mode-alist '("\\.rs\\'" . rust-ts-mode))
  
  ;; Rust 特定配置
  (with-eval-after-load 'rust-ts-mode
    (setq rust-ts-mode-indent-offset 4)
    (define-key rust-ts-mode-map (kbd "C-c C-f") 'eglot-format-buffer))
  
  ;; 提示用户如何安装 Tree-sitter 语法库（如果需要）
  (add-hook 'rust-ts-mode-hook
            (lambda ()
              (when (and (fboundp 'treesit-ready-p)
                         (not (treesit-ready-p 'rust)))
                (message "提示: Rust Tree-sitter 语法库未安装。运行 M-x treesit-install-language-grammar RET rust RET 安装。"))))
  )

(provide 'config-package)
