;;; config-tools.el --- Editing utilities (jinx, vundo, etc.)  -*- lexical-binding: t; -*-

(use-package vundo
  :ensure t
  :defer t
  :bind (("C-z" . undo)
         ("C-x u" . vundo))
  :config
  (setq vundo-compact-display t))

(use-package plantuml-mode
  :ensure t
  :defer t)

(use-package smartparens
  :ensure t
  :defer t
  :diminish smartparens-mode
  :hook (prog-mode . smartparens-strict-mode)
  :config
  (require 'smartparens-config))

(use-package youdao-dictionary
  :ensure t
  :defer t
  :init
  (setq url-automatic-caching t)
  :config
  (global-set-key (kbd "C-c y") 'youdao-dictionary-search-at-point+))

(use-package jinx
  :ensure t
  :defer t
  :bind ([remap ispell-word] . jinx-correct)
  :init
  (defvar my/jinx--unavailable nil
    "Non-nil when jinx failed to load (e.g. missing enchant2).")
  (defun my/jinx-mode-safe ()
    "Enable jinx once; warn once if enchant/jinx-mod is missing."
    (unless my/jinx--unavailable
      (condition-case err
          (jinx-mode 1)
        (error
         (setq my/jinx--unavailable t)
         (jinx-mode -1)
         (unless (getenv "MY_JINX_WARNED")
           (setenv "MY_JINX_WARNED" "1")
           (message "Jinx 不可用: %S (可选: brew install enchant2 pkgconf)" err))))))
  (when (executable-find "enchant-2")
    (dolist (hook '(text-mode-hook prog-mode-hook))
      (add-hook hook #'my/jinx-mode-safe)))
  :config
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

(use-package ws-butler
  :ensure t
  :defer t
  :hook ((prog-mode text-mode) . ws-butler-mode))

(provide 'config-tools)
;;; config-tools.el ends here
