;;; config-vcs-terminal.el --- Project, Magit, Eat, recentf  -*- lexical-binding: t; -*-

(recentf-mode 1)
(setq recentf-max-saved-items 512)

(use-package project
  :ensure nil
  :bind (("C-c p b" . project-switch-to-buffer)
         ("C-c p d" . project-dired)
         ("C-c p v" . project-vc-dir))
  :config
  (setq project-vc-extra-root-markers
        '("package.json" "requirements.txt" ".project")))

(add-hook 'shell-mode-hook 'ansi-color-for-comint-mode-on)

(use-package rainbow-delimiters
  :ensure t
  :defer t
  :hook (prog-mode . rainbow-delimiters-mode)
  :init
  (add-hook 'emacs-lisp-mode-hook #'rainbow-mode))

(use-package magit
  :ensure t
  :defer t
  :bind ("C-x g" . magit-status)
  :config
  (setq magit-push-always-verify nil
        magit-revert-buffers t))

(defun my/eat-toggle ()
  "Toggle Eat terminal for current project (show/hide project-scoped buffer)."
  (interactive)
  (require 'eat)
  (require 'project)
  (let* ((name (project-prefixed-buffer-name "eat"))
         (buf (get-buffer name)))
    (if (and buf (get-buffer-window buf))
        (delete-window (get-buffer-window buf))
      (eat-project))))

(use-package eat
  :ensure t
  :defer t
  :custom
  (eat-term-scrollback-size 10000)
  (eat-enable-directory-tracking t)
  :config
  (global-set-key (kbd "C-`") #'my/eat-toggle))

(with-eval-after-load 'project
  (define-key project-prefix-map (kbd "s") #'eat-project))

(provide 'config-vcs-terminal)
;;; config-vcs-terminal.el ends here
