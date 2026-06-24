;;; config-completion.el --- Corfu + Cape  -*- lexical-binding: t; -*-

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
  (add-to-list 'completion-at-point-functions #'cape-history))

(provide 'config-completion)
;;; config-completion.el ends here
