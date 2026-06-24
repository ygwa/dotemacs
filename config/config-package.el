;;; config-package.el --- Package layer orchestrator  -*- lexical-binding: t; -*-
;; Each submodule is a single domain concern (edit/vcs/lang/debug).
;; init.el requires this file only — add new submodules here.

(mapc #'require '(config-vcs
                  config-edit
                  config-lang-rust
                  config-lang-python
                  config-debug))

(provide 'config-package)
;;; config-package.el ends here
