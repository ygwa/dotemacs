;;; config-lang-python.el --- Python (python-ts-mode) LSP  -*- lexical-binding: t; -*-

(add-hook 'python-ts-mode-hook #'eglot-ensure)

(with-eval-after-load 'eglot
  (let ((server (cond
                 ((executable-find "pyright-langserver")
                  '("pyright-langserver" "--stdio"))
                 ((executable-find "pylsp")
                  '("pylsp"))
                 ((executable-find "python3")
                  '("python3" "-m" "pylsp"))
                 (t nil))))
    (when server
      (add-to-list 'eglot-server-programs `(python-ts-mode . ,server) t))))

(dolist (hook '(python-ts-mode-hook))
  (add-hook hook
            (lambda ()
              (unless (or (executable-find "pyright-langserver")
                          (executable-find "pylsp"))
                (message "提示: 未找到 Python LSP。推荐: pip install pyright 或 pip install python-lsp-server")))))

(provide 'config-lang-python)
;;; config-lang-python.el ends here
