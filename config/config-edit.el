;;; config-edit.el --- Editing experience: search, completion, LSP, tools  -*- lexical-binding: t; -*-
;;
;; 合并自 4 个旧文件 (config-navigation / config-completion / config-lsp / config-tools),
;; 按职责分 4 节:
;;   §1 Search & navigation — my/search-map + vertico/orderless/consult/embark/avy
;;   §2 Completion          — corfu + cape (in-buffer popup)
;;   §3 LSP                 — eglot + consult-eglot (my/eglot-map)
;;   §4 Editing tools       — vundo, smartparens, youdao, jinx, ws-butler, plantuml-mode
;;
;; 加载顺序通过 :after / :demand 显式控制, 避免跨文件契约.
;; 唯一外部契约: `my/search-map` 与 `my/eglot-map' 是 §1/§3 提供的 defvar,
;; 其它模块不要修改, 需要扩展走 additional key bindings.

;; ============================================
;; §1 Search & navigation — C-c s prefix
;; ============================================

(defvar my/search-map
  (let ((map (make-sparse-keymap "Search")))
    (define-key map (kbd "b") #'consult-buffer)
    (define-key map (kbd "f") #'project-find-file)
    (define-key map (kbd "g") #'consult-git-grep)
    (define-key map (kbd "k") #'consult-ripgrep)
    (define-key map (kbd "r") #'consult-recent-file)
    (define-key map (kbd "p") #'project-find-regexp)
    (define-key map (kbd "o") #'consult-locate)
    (define-key map (kbd "m") #'consult-bookmark)
    map)
  "Consult / project lookup (`C-c s' prefix).")

(global-set-key (kbd "C-c s") my/search-map)

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
  :defer t
  :bind
  (("C-s" . consult-line)
   ("C-M-s" . consult-line-multi)
   ("M-y" . consult-yank-pop)
   ("<f1> f" . consult-describe-function)
   ("<f1> v" . consult-describe-variable)
   ("<f1> l" . consult-find-library)
   ("<f2> i" . consult-info-lookup-symbol)
   ("<f2> u" . consult-unicode-char)
   :map read-expression-map
   ("C-r" . consult-expression-history)))

(use-package embark
  :ensure t
  :defer t
  :bind
  (("C-." . embark-act)
   ("C-;" . embark-dwim)
   ("C-h B" . embark-bindings)))

(use-package embark-consult
  :ensure t
  :after consult
  :hook (embark-collect-mode . consult-preview-at-point-mode))

(use-package marginalia
  :ensure t
  :defer t
  :after vertico
  :init
  (marginalia-mode))

(use-package avy
  :ensure t
  :defer t
  :bind
  (("C-c j" . avy-goto-char)
   ("C-c J" . avy-goto-line)
   ("C-c W" . avy-goto-word-1)))

;; ============================================
;; §2 Completion — Corfu in-buffer popup
;; ============================================

(use-package corfu
  :ensure t
  :demand t
  :init
  (global-corfu-mode)
  (corfu-popupinfo-mode 1)
  :custom
  (corfu-cycle t)
  (corfu-auto t)
  (corfu-auto-delay 0.1)
  (corfu-auto-prefix 2)
  (corfu-quit-at-boundary t)
  (corfu-quit-no-match t)
  (corfu-preview-current nil)
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
  (add-to-list 'completion-at-point-functions #'cape-history)
  (add-to-list 'completion-at-point-functions #'cape-capf)
  (add-to-list 'completion-at-point-functions #'cape-elisp))

;; ============================================
;; §3 LSP — Eglot client + consult-eglot symbols
;; ============================================
;; Search prefix: C-c s.  LSP prefix: C-c l.

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
  "Eglot commands (`C-c l' prefix in eglot buffers).")

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
  (define-key eglot-mode-map (kbd "C-c l") my/eglot-map)
  (add-hook 'eglot-managed-mode-hook #'eldoc-mode))

(with-eval-after-load 'xref
  (add-hook 'xref-after-jump-hook #'xref-pulse-at-point))

(use-package consult-eglot
  :ensure t
  :defer t
  :after (consult eglot)
  :config
  (define-key my/search-map (kbd "e") #'consult-eglot-symbols))

;; ============================================
;; §4 Editing tools — undo, parens, spell, lang helpers
;; ============================================

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

(use-package expand-region
  :ensure t
  :defer t
  :bind (("C-=" . er/expand-region)
         ("C--" . er/contract-region)))

(use-package hl-todo
  :ensure t
  :defer t
  :hook (prog-mode . hl-todo-mode))

(provide 'config-edit)
;;; config-edit.el ends here
