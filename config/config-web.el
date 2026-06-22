;;; config-web.el --- Web 前端开发配置 (Next.js/React/TypeScript) -*- lexical-binding: t; -*-

;; ============================================
;; 1. Tree-sitter 模式配置 (Emacs 30 内置)
;; ============================================

(when (>= emacs-major-version 30)
  ;; TS/JS/CSS/JSON 走 major-mode-remap-alist (config-package.el); 这里只补
  ;; remap 没覆盖的 .tsx / .mts / .cts / .jsx / .mjs / .cjs
  (add-to-list 'auto-mode-alist '("\\.tsx\\'" . tsx-ts-mode))
  (add-to-list 'auto-mode-alist '("\\.mts\\'" . typescript-ts-mode))
  (add-to-list 'auto-mode-alist '("\\.cts\\'" . typescript-ts-mode))
  (add-to-list 'auto-mode-alist '("\\.jsx\\'" . js-ts-mode))
  (add-to-list 'auto-mode-alist '("\\.mjs\\'" . js-ts-mode))
  (add-to-list 'auto-mode-alist '("\\.cjs\\'" . js-ts-mode))

  ;; 提示用户安装 tree-sitter 语法库 (5 种, 用 alist 平铺避免重复 lambda)
  (dolist (pair '((typescript-ts-mode-hook . typescript)
                  (tsx-ts-mode-hook        . tsx)
                  (js-ts-mode-hook         . javascript)
                  (css-ts-mode-hook        . css)
                  (json-ts-mode-hook       . json)))
    (add-hook (car pair)
              (lambda ()
                (when (and (fboundp 'treesit-ready-p)
                           (not (treesit-ready-p (cdr pair) t)))
                  (message "提示: %s Tree-sitter 语法库未安装。运行 M-x treesit-install-language-grammar RET %s RET 安装。"
                           (cdr pair) (cdr pair)))))))

;; ============================================
;; 2. Tree-sitter 语法库源配置
;; ============================================

(setq treesit-language-source-alist
      '((typescript "https://github.com/tree-sitter/tree-sitter-typescript" "master" "typescript/src")
        (tsx "https://github.com/tree-sitter/tree-sitter-typescript" "master" "tsx/src")
        (javascript "https://github.com/tree-sitter/tree-sitter-javascript")
        (css "https://github.com/tree-sitter/tree-sitter-css")
        (json "https://github.com/tree-sitter/tree-sitter-json")
        (html "https://github.com/tree-sitter/tree-sitter-html")
        (yaml "https://github.com/tree-sitter/tree-sitter-yaml")
        (markdown "https://github.com/tree-sitter/tree-sitter-markdown" "master" "src")))

(defun my/install-all-treesit-grammars ()
  "逐个安装所有 tree-sitter 语法库 (按顺序而非并行, 避免编译风暴)。
每个语法库下载+编译需数秒到数十秒, 总耗时约 2-5 分钟。
已安装的会自动跳过, 失败可重跑续装。
注意: 下载是异步的, \"处理完毕\"只是请求已发出; 实际编译在后台完成。"
  (interactive)
  (let ((pending (seq-filter
                  (lambda (lang) (not (treesit-ready-p lang t)))
                  (mapcar #'car treesit-language-source-alist))))
    (if (null pending)
        (message "treesit: 所有语法库已安装 ✓")
      (let ((total (length pending))
            (i 0))
        (message "treesit: 待安装 %d 个 — %s"
                 total
                 (mapconcat #'symbol-name pending ", "))
        (dolist (lang pending)
          (setq i (1+ i))
          (message ">>> [%d/%d] 正在安装 %s..." i total lang)
          (treesit-install-language-grammar lang))))))

;; ============================================
;; 3. Eglot LSP 配置 (前端)
;; ============================================

(with-eval-after-load 'eglot
  ;; TypeScript/JavaScript LSP
  ;; 优先使用 vtsls (更快、重构支持更好)，回退到 typescript-language-server
  (let ((ts-server (if (executable-find "vtsls")
                       '("vtsls" "--stdio")
                     '("typescript-language-server" "--stdio"))))
    (add-to-list 'eglot-server-programs
                 `((typescript-ts-mode tsx-ts-mode) . ,ts-server))
    (add-to-list 'eglot-server-programs
                 `((js-ts-mode) . ,ts-server)))
  
  ;; TailwindCSS LSP
  (add-to-list 'eglot-server-programs
               '(css-ts-mode . ("tailwindcss-language-server" "--stdio")))
  
  ;; ESLint 集成 (通过 typescript-language-server 的插件)
  ;; 注意：需要项目中配置 eslint
  (setq-default eglot-workspace-configuration
                '(:typescript (:inlayHints (:parameterNames (:enabled "all")
                                            :parameterTypes (:enabled t)
                                            :variableTypes (:enabled t)
                                            :propertyDeclarationTypes (:enabled t)
                                            :functionLikeReturnTypes (:enabled t)))
                  :javascript (:inlayHints (:parameterNames (:enabled "all")
                                            :parameterTypes (:enabled t)
                                            :variableTypes (:enabled t))))))

;; 自动启用 eglot
(add-hook 'typescript-ts-mode-hook 'eglot-ensure)
(add-hook 'tsx-ts-mode-hook 'eglot-ensure)
(add-hook 'js-ts-mode-hook 'eglot-ensure)

;; 启用 inlay hints (参数类型/变量类型, 配合 eglot-workspace-configuration)
(add-hook 'typescript-ts-mode-hook #'eglot-inlay-hints-mode)
(add-hook 'tsx-ts-mode-hook #'eglot-inlay-hints-mode)

(add-hook 'css-ts-mode-hook 'rainbow-mode)

;; ============================================
;; 4. Apheleia (异步代码格式化 - Prettier)
;; ============================================

(use-package apheleia
  :ensure t
  :config
  ;; Prettier 配置
  (setf (alist-get 'prettier apheleia-formatters)
        '("prettier" "--stdin-filepath" filepath))
  
  ;; 为前端模式设置 Prettier
  (setf (alist-get 'typescript-ts-mode apheleia-mode-alist) '(prettier))
  (setf (alist-get 'tsx-ts-mode apheleia-mode-alist) '(prettier))
  (setf (alist-get 'js-ts-mode apheleia-mode-alist) '(prettier))
  (setf (alist-get 'css-ts-mode apheleia-mode-alist) '(prettier))
  (setf (alist-get 'json-ts-mode apheleia-mode-alist) '(prettier))
  (setf (alist-get 'html-mode apheleia-mode-alist) '(prettier))
  
  ;; 全局启用 apheleia
  (apheleia-global-mode +1))

;; ============================================
;; 5. 前端开发辅助功能
;; ============================================

;; 缩进设置 (4 种 web mode 共享同一组 indent 设置)
(dolist (hook '(typescript-ts-mode-hook tsx-ts-mode-hook js-ts-mode-hook css-ts-mode-hook))
  (add-hook hook
            (lambda ()
              (setq-local indent-tabs-mode nil
                            tab-width 2
                            js-indent-level 2
                            typescript-ts-mode-indent-offset 2
                            css-indent-offset 2))))

;; npm/yarn/pnpm 脚本运行 (按 lockfile 自动选包管理器, 解析 package.json 拿 scripts)
(defun my/npm-run ()
  "运行 npm/yarn/pnpm 脚本。按 lockfile 自动选包管理器。"
  (interactive)
  (let* ((root (locate-dominating-file default-directory "package.json"))
         (pkg-manager (cond
                       ((file-exists-p (expand-file-name "pnpm-lock.yaml" root)) "pnpm")
                       ((file-exists-p (expand-file-name "yarn.lock" root)) "yarn")
                       (t "npm")))
         (pkg-file (expand-file-name "package.json" root))
         (scripts (and (file-exists-p pkg-file)
                       (condition-case err
                           (let* ((json-object-type 'alist)
                                  (json-array-type 'list)
                                  (pkg (json-read-file pkg-file)))
                             (mapcar #'car (alist-get 'scripts pkg)))
                         (error
                          (message "解析 package.json 失败: %s" (error-message-string err))
                          nil))))
         (script (completing-read
                  (format "[%s] Run script: " pkg-manager)
                  (or scripts '("no-scripts")))))
    (compile (format "cd %s && %s run %s" root pkg-manager script))))

(global-set-key (kbd "C-c r n") 'my/npm-run)

;; ============================================
;; 7. 快捷键绑定
;; ============================================

(with-eval-after-load 'typescript-ts-mode
  (define-key typescript-ts-mode-map (kbd "C-c C-f") 'apheleia-format-buffer)
  (define-key typescript-ts-mode-map (kbd "C-c s o") 'eglot-code-action-organize-imports))

(with-eval-after-load 'tsx-ts-mode
  (define-key tsx-ts-mode-map (kbd "C-c C-f") 'apheleia-format-buffer)
  (define-key tsx-ts-mode-map (kbd "C-c s o") 'eglot-code-action-organize-imports))

(with-eval-after-load 'js-ts-mode
  (define-key js-ts-mode-map (kbd "C-c C-f") 'apheleia-format-buffer))

;; ============================================
;; 9. 安装提示
;; ============================================

(provide 'config-web)
;;; config-web.el ends here

