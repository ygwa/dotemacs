;;; config-treesit.el --- Tree-sitter 语法库与模式映射 -*- lexical-binding: t; -*-

(when (>= emacs-major-version 30)
  (setq treesit-font-lock-level 4
        treesit-extra-load-path
        (list (expand-file-name "tree-sitter" user-emacs-directory)))

  ;; 内置 mode → tree-sitter mode
  (setq major-mode-remap-alist
        '((yaml-mode . yaml-ts-mode)
          (js-mode . js-ts-mode)
          (typescript-mode . typescript-ts-mode)
          (json-mode . json-ts-mode)
          (css-mode . css-ts-mode)
          (python-mode . python-ts-mode)))

  ;; tree-sitter 语法库下载源 (M-x treesit-install-language-grammar / my/install-all-treesit-grammars)
  (setq treesit-language-source-alist
        '((rust "https://github.com/tree-sitter/tree-sitter-rust")
          (typescript "https://github.com/tree-sitter/tree-sitter-typescript" "master" "typescript/src")
          (tsx "https://github.com/tree-sitter/tree-sitter-typescript" "master" "tsx/src")
          (javascript "https://github.com/tree-sitter/tree-sitter-javascript")
          (css "https://github.com/tree-sitter/tree-sitter-css")
          (json "https://github.com/tree-sitter/tree-sitter-json")
          (html "https://github.com/tree-sitter/tree-sitter-html")
          (yaml "https://github.com/tree-sitter/tree-sitter-yaml")
          (markdown "https://github.com/tree-sitter/tree-sitter-markdown" "master" "src")))

  ;; remap 未覆盖的扩展名
  (dolist (pair '(("\\.rs\\'"   . rust-ts-mode)
                  ("\\.tsx\\'"  . tsx-ts-mode)
                  ("\\.mts\\'"  . typescript-ts-mode)
                  ("\\.cts\\'"  . typescript-ts-mode)
                  ("\\.jsx\\'"  . js-ts-mode)
                  ("\\.mjs\\'"  . js-ts-mode)
                  ("\\.cjs\\'"  . js-ts-mode)))
    (add-to-list 'auto-mode-alist pair))

  (defun my/install-all-treesit-grammars ()
    "逐个安装 `treesit-language-source-alist' 中缺失的语法库。"
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

  ;; 首次打开对应 mode 时提示安装语法库
  (dolist (pair '((rust-ts-mode-hook        . rust)
                  (typescript-ts-mode-hook . typescript)
                  (tsx-ts-mode-hook        . tsx)
                  (js-ts-mode-hook         . javascript)
                  (css-ts-mode-hook        . css)
                  (json-ts-mode-hook       . json)))
    (add-hook (car pair)
              (lambda ()
                (let ((lang (cdr pair)))
                  (when (and (fboundp 'treesit-ready-p)
                             (not (treesit-ready-p lang t)))
                    (message "提示: %s Tree-sitter 语法库未安装。运行 M-x treesit-install-language-grammar RET %s RET 安装。"
                             lang lang))))))

  (with-eval-after-load 'rust-ts-mode
    (setq rust-ts-mode-indent-offset 4)))

(provide 'config-treesit)
;;; config-treesit.el ends here
