;;; config-lang-rust.el --- Rust LSP helpers  -*- lexical-binding: t; -*-

(dolist (hook '(rust-mode-hook rust-ts-mode-hook))
  (add-hook hook
            (lambda ()
              (unless (executable-find "rust-analyzer")
                (message (pcase system-type
                           ('darwin "提示: 未找到 rust-analyzer。推荐:\n  brew install rust-analyzer\n  rustup component add rust-analyzer")
                           ('gnu/linux "提示: 未找到 rust-analyzer。推荐:\n  rustup component add rust-analyzer\n  或从 https://github.com/rust-lang/rust-analyzer/releases 下载")
                           (_ "提示: 未找到 rust-analyzer。请访问 https://rust-analyzer.github.io/ 安装。")))))))

(when (>= emacs-major-version 30)
  (with-eval-after-load 'rust-ts-mode
    (define-key rust-ts-mode-map (kbd "C-c C-f") 'eglot-format-buffer)))

(provide 'config-lang-rust)
;;; config-lang-rust.el ends here
