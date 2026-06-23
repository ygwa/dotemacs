;;; config-web.el --- Web 前端开发配置 (Next.js/React/TypeScript) -*- lexical-binding: t; -*-
;; Tree-sitter 语法库与 mode remap 见 config-treesit.el.

;; ============================================
;; 1. Eglot LSP 配置 (前端)
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
;; 2. Apheleia (异步代码格式化 - Prettier)
;; ============================================
;; 格式化键位: Web buffer 内 C-c C-f → apheleia-format-buffer (Prettier).
;; eglot-mode-map 的 C-c s f 仍走 LSP 格式化, 见 config-package.el.

(use-package apheleia
  :ensure t
  :defer t
  :hook ((typescript-ts-mode tsx-ts-mode js-ts-mode css-ts-mode json-ts-mode html-mode)
         . apheleia-mode)
  :config
  (setf (alist-get 'prettier apheleia-formatters)
        '("prettier" "--stdin-filepath" filepath))
  (setf (alist-get 'typescript-ts-mode apheleia-mode-alist) '(prettier))
  (setf (alist-get 'tsx-ts-mode apheleia-mode-alist) '(prettier))
  (setf (alist-get 'js-ts-mode apheleia-mode-alist) '(prettier))
  (setf (alist-get 'css-ts-mode apheleia-mode-alist) '(prettier))
  (setf (alist-get 'json-ts-mode apheleia-mode-alist) '(prettier))
  (setf (alist-get 'html-mode apheleia-mode-alist) '(prettier)))

;; ============================================
;; 3. 前端开发辅助功能
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
;; 4. 快捷键绑定
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
;; 5. 安装提示
;; ============================================

(provide 'config-web)
;;; config-web.el ends here

