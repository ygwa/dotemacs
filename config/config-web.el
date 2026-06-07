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

  ;; 提示用户安装 tree-sitter 语法库
  (defun my/check-treesit-grammar (mode grammar)
    "检查并提示安装 tree-sitter 语法库。"
    (add-hook mode
              (lambda ()
                (when (and (fboundp 'treesit-ready-p)
                           (not (treesit-ready-p grammar t)))
                  (message "提示: %s Tree-sitter 语法库未安装。运行 M-x treesit-install-language-grammar RET %s RET 安装。"
                           grammar grammar)))))
  
  (my/check-treesit-grammar 'typescript-ts-mode-hook 'typescript)
  (my/check-treesit-grammar 'tsx-ts-mode-hook 'tsx)
  (my/check-treesit-grammar 'js-ts-mode-hook 'javascript)
  (my/check-treesit-grammar 'css-ts-mode-hook 'css)
  (my/check-treesit-grammar 'json-ts-mode-hook 'json))

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
        (yaml "https://github.com/tree-sitter/tree-sitter-yaml")))

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

;; 缩进设置
(defun my/web-mode-setup ()
  "Web 开发模式通用设置。"
  (setq-local indent-tabs-mode nil)
  (setq-local tab-width 2)
  (setq-local js-indent-level 2)
  (setq-local typescript-ts-mode-indent-offset 2)
  (setq-local css-indent-offset 2))

(add-hook 'typescript-ts-mode-hook #'my/web-mode-setup)
(add-hook 'tsx-ts-mode-hook #'my/web-mode-setup)
(add-hook 'js-ts-mode-hook #'my/web-mode-setup)
(add-hook 'css-ts-mode-hook #'my/web-mode-setup)

;; npm/yarn/pnpm 脚本运行
(defun my/npm-run ()
  "运行 npm/yarn/pnpm 脚本。"
  (interactive)
  (let* ((root (locate-dominating-file default-directory "package.json"))
         (pkg-manager (cond
                       ((file-exists-p (expand-file-name "pnpm-lock.yaml" root)) "pnpm")
                       ((file-exists-p (expand-file-name "yarn.lock" root)) "yarn")
                       (t "npm")))
         (script (completing-read
                  (format "[%s] Run script: " pkg-manager)
                  (my/get-npm-scripts root))))
    (compile (format "cd %s && %s run %s" root pkg-manager script))))

(defun my/get-npm-scripts (root)
  "获取 package.json 中的脚本列表。
如果文件不存在或解析失败，返回 nil。"
  (when root
    (let ((pkg-file (expand-file-name "package.json" root)))
      (condition-case err
          (when (file-exists-p pkg-file)
            (let* ((json-object-type 'alist)
                   (json-array-type 'list)
                   (pkg (json-read-file pkg-file))
                   (scripts (alist-get 'scripts pkg)))
              (mapcar #'car scripts)))
        (error
         (message "解析 package.json 失败: %s" (error-message-string err))
         nil)))))

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

(defun my/check-web-dev-tools ()
  "检查 Web 开发所需的工具是否已安装。"
  (interactive)
  (let ((tools '(("vtsls" . "npm install -g @vtsls/language-server (推荐)")
                 ("typescript-language-server" . "npm install -g typescript typescript-language-server (备选)")
                 ("tailwindcss-language-server" . "npm install -g @tailwindcss/language-server")
                 ("prettier" . "npm install -g prettier")
                 ("eslint" . "npm install -g eslint"))))
    (dolist (tool tools)
      (if (executable-find (car tool))
          (message "✓ %s 已安装" (car tool))
        (message "✗ %s 未安装 - 运行: %s" (car tool) (cdr tool))))))

;; 首次加载时提示检查工具
(run-with-idle-timer 5 nil
                     (lambda ()
                       (unless (or (executable-find "vtsls")
                                   (executable-find "typescript-language-server"))
                         (message "提示: TypeScript LSP 未安装。推荐安装 vtsls: npm install -g @vtsls/language-server"))))

(provide 'config-web)
;;; config-web.el ends here

