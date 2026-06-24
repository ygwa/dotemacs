;;; config-package.el --- Package layer orchestrator  -*- lexical-binding: t; -*-
;; Submodules split by responsibility; init.el still requires this file only.

(mapc #'require '(config-vcs-terminal
                  config-completion
                  config-navigation
                  config-lsp
                  config-lang-rust
                  config-lang-python
                  config-tools
                  config-debug))

(provide 'config-package)
;;; config-package.el ends here
