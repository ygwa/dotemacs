;;; config-debug.el --- Dape debugger  -*- lexical-binding: t; -*-

(use-package dape
  :ensure t
  :defer t
  :bind (("<f5>" . dape)
         ("M-<f5>" . dape-hydra/body)
         ("C-c d b" . dape-breakpoint-toggle))
  :config
  (add-hook 'dape-on-start-hooks
            (defun my/dape--save-on-start ()
              (save-some-buffers t t)))
  (dape-breakpoint-load)
  (add-hook 'kill-emacs-hook #'dape-breakpoint-save)

  (when (executable-find "python")
    (add-to-list 'dape-adapters
                 '(python
                   (cwd . default-directory)
                   (host . "localhost")
                   (port . 5678))))

  (when (executable-find "node")
    (add-to-list 'dape-adapters
                 '(node-js
                   (program . "vscode-js-debug")
                   (args . ("--server" "--port=0"))
                   (request . "attach")
                   (cwd . default-directory))))

  (when (executable-find "lldb-dap")
    (add-to-list 'dape-adapters
                 '(lldb-dap
                   (program . "lldb-dap")
                   (request . "launch")
                   (cwd . default-directory)
                   (lldb-dap-path-command . "lldb-dap")
                   (lldb-dap-launch-configuration . "launch.json")))))

(provide 'config-debug)
;;; config-debug.el ends here
