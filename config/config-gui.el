(when (fboundp 'tool-bar-mode)
  (tool-bar-mode -1))
(when (fboundp 'scroll-bar-mode)
  (scroll-bar-mode -1))

;; simple 是 Emacs 内置包，不需要安装
;; 注意：use-package 的 :config 会在包加载后执行
;; 但 simple 是内置包，可能已经加载，所以直接执行配置
(menu-bar-mode -1)
;; Emacs 30: 使用 display-line-numbers-mode 替代废弃的 line-number-mode 和 global-linum-mode
(global-display-line-numbers-mode t)
(setq display-line-numbers-type 'relative) ; 显示相对行号
(show-paren-mode 1)
(auto-save-mode nil)
(blink-cursor-mode 1)
(delete-selection-mode t)
(global-visual-line-mode t)

;; Emacs 30: 优化配置选项
(setq auto-save-default nil
      visible-bell nil
      make-backup-files nil
      create-lockfiles nil
      debug-on-error nil
      tab-width 4
      x-select-enable-clipboard t
      x-select-enable-primary t
      save-interprogram-paste-before-kill t
      apropos-do-all t
      mouse-yank-at-point t)

;; Emacs 30: 启用内置的 which-key
(when (fboundp 'which-key-mode)
  (which-key-mode 1))

;; Emacs 30: 启用内置的 editorconfig 支持
(when (fboundp 'editorconfig-mode)
  (editorconfig-mode 1))

;; 使用 Emacs 内置的 modus-operandi 主题
(load-theme 'modus-operandi t)

(set-frame-font "JetBrains Mono:pixelsize=14")

(dolist (charset '(han kana symbol cjk-misc bopomofo))
  (set-fontset-font (frame-parameter nil 'font)
                    charset
                    (font-spec :family "Hiragino Sans GB" :size 16.3)))

(custom-set-faces
 ;; '(org-document-title ((t (:height 1.0))))
 ;; '(org-level-1 ((t (:inherit outline-1 :height 1.0))))
 ;; '(org-level-2 ((t (:inherit outline-2 :height 1.0))))
 ;; '(org-level-3 ((t (:inherit outline-3 :height 1.0))))
 ;; '(org-level-4 ((t (:inherit outline-4 :height 1.0))))
 ;; '(org-level-5 ((t (:inherit outline-5 :height 1.0))))
 
 '(rainbow-delimiters-depth-1-face ((t (:foreground "dark orange"))))
 '(rainbow-delimiters-depth-2-face ((t (:foreground "deep pink"))))
 '(rainbow-delimiters-depth-3-face ((t (:foreground "chartreuse"))))
 '(rainbow-delimiters-depth-4-face ((t (:foreground "deep sky blue"))))
 '(rainbow-delimiters-depth-5-face ((t (:foreground "yellow"))))
 '(rainbow-delimiters-depth-6-face ((t (:foreground "orchid"))))
 '(rainbow-delimiters-depth-7-face ((t (:foreground "spring green"))))
 '(rainbow-delimiters-depth-8-face ((t (:foreground "sienna1")))))

(provide 'config-gui)
