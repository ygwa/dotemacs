;;; config-navigation.el --- Vertico, Consult, Embark, Avy  -*- lexical-binding: t; -*-
;; Search prefix: C-c s. LSP prefix: C-c l (config-lsp.el).

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
  "Consult / project lookup (`C-c s` prefix).")

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

(provide 'config-navigation)
;;; config-navigation.el ends here
