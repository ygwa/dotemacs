;;; my-custom.el --- Personal customization group  -*- lexical-binding: t; -*-

(defgroup my-config nil
  "Personal Emacs configuration customizations."
  :group 'convenience
  :prefix "my/")

(defcustom my/features '(ai)
  "Optional modules to load at startup.
`ai' — agent-shell + AI workbench."
  :type '(set (const ai))
  :group 'my-config)

(defcustom my/theme-flavor 'mocha
  "Catppuccin flavor for GUI frames.
Switch via `M-x customize-variable my/theme-flavor', then `M-x catppuccin-reload'."
  :type '(choice (const mocha) (const macchiato) (const frappe) (const latte))
  :group 'my-config)

(defcustom my/tui-theme-flavor 'macchiato
  "Catppuccin flavor for TUI (terminal / emacsclient -t).
macchiato 与 frappe 比 mocha 更亮、终端对比更好; latte 适合浅色终端背景."
  :type '(choice (const macchiato) (const frappe) (const mocha) (const latte))
  :group 'my-config)

(defcustom my/tui-theme nil
  "Optional non-catppuccin theme for TUI only (Emacs 30 内置, 终端优化).
nil = 继续用 catppuccin + `my/tui-theme-flavor'."
  :type '(choice (const :tag "catppuccin (default)" nil)
                 (const modus-vivendi)
                 (const modus-vivendi-tinted)
                 (const modus-operandi)
                 (const modus-operandi-tinted))
  :group 'my-config)

(defcustom my/forge-extra-gitlab-instances nil
  "Self-hosted GitLab instances for Forge.
Each entry: (GITHOST APIHOST WEBHOST CLASS). Example:
  ((\"gitlab.example.com\"
    \"gitlab.example.com/api/v4\"
    \"gitlab.example.com\"
    forge-gitlab-repository))"
  :type '(repeat (list string string string symbol))
  :group 'my-config)

(provide 'my-custom)
;;; my-custom.el ends here
