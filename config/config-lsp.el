;;; config-lsp.el --- Eglot + consult-eglot  -*- lexical-binding: t; -*-

(defvar my/eglot-map
  (let ((map (make-sparse-keymap "Language Server")))
    (define-key map (kbd "r") #'eglot-rename)
    (define-key map (kbd "f") #'eglot-format)
    (define-key map (kbd "a") #'eglot-code-actions)
    (define-key map (kbd "h") #'eglot-help-at-point)
    (define-key map (kbd "d") #'eglot-find-declaration)
    (define-key map (kbd "i") #'eglot-find-implementation)
    (define-key map (kbd "t") #'eglot-find-typeDefinition)
    map)
  "Eglot commands (`C-c l` prefix in eglot buffers).")

(use-package eglot
  :ensure nil
  :hook
  ((rust-mode rust-ts-mode) . eglot-ensure)
  :config
  (setq eglot-autoshutdown t
        eglot-confirm-server-initiated-edits nil
        eglot-events-buffer-size 0
        eglot-connect-timeout 60
        eglot-sync-connect 1)
  (let ((ra (executable-find "rust-analyzer")))
    (when ra
      (add-to-list 'eglot-server-programs `(rust-mode . ,(vector ra)) t)
      (add-to-list 'eglot-server-programs `(rust-ts-mode . ,(vector ra)) t)))
  (define-key eglot-mode-map (kbd "C-c l") my/eglot-map))

(use-package consult-eglot
  :ensure t
  :defer t
  :after (consult eglot)
  :config
  (define-key my/search-map (kbd "e") #'consult-eglot-symbols))

(provide 'config-lsp)
;;; config-lsp.el ends here
