;;; config-org.el --- Minimal Org-mode configuration  -*- lexical-binding: t; -*-

;; ============================================
;; 0. 核心路径
;; ============================================
;; ~/Documents 是 macOS 默认个人目录, 开启 iCloud 同步后 org 文件
;; 会自动跨设备; 非 macOS 用户可改为 ~/org 或 ~/.emacs.d/org.
;; dashboard 引用此路径, capture 模板拼 inbox.org 即可, 不再单独 defcustom 文件路径.

(defcustom my/org-root-dir (expand-file-name "~/Documents/org/")
  "Org 模式根目录. dashboard / capture 都引用此路径.
macOS 用户可设为 ~/Documents/org (iCloud 同步), Linux/Windows 用 ~/org.
M-x customize-group my-config 改."
  :type 'directory
  :group 'my-config)

(unless (file-exists-p my/org-root-dir)
  (make-directory my/org-root-dir t))

;; ============================================
;; 1. Org 基础行为
;; ============================================

(use-package org
  :ensure nil
  :config
  (setq org-directory my/org-root-dir
        org-default-notes-file (expand-file-name "inbox.org" my/org-root-dir)
        org-hide-emphasis-markers t
        org-confirm-babel-evaluate nil)

  ;; 基础快捷键
  (global-set-key (kbd "C-c l") #'org-store-link)
  (global-set-key (kbd "C-c a") #'org-agenda)
  (global-set-key (kbd "C-c c") #'org-capture))

;; ============================================
;; 2. Capture 模板 (只留 Inbox; Todo 走 org-agenda, 不在 capture 里)
;; ============================================

(setq org-capture-templates
      '(("i" "Inbox" entry (file+headline my/org-root-dir "Inbox")
         "* %^{想法}\n%?" :empty-lines 1)))

(provide 'config-org)
;;; config-org.el ends here