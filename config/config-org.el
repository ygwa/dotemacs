;;; config-org.el --- Minimal Org-mode configuration  -*- lexical-binding: t; -*-

;; ============================================
;; 0. 核心路径定义
;; ============================================
;; dashboard / capture 都引用这些, 不要轻易改名
;;
;; ~/Documents 是 macOS 默认个人目录, 开启 iCloud 同步后 org 文件
;; 会自动跨设备; 非 macOS 用户可改为 ~/org 或 ~/.emacs.d/org.

(defcustom my/org-root-dir (expand-file-name "~/Documents/org/")
  "Org 模式根目录. dashboard / capture 都引用此路径.
macOS 用户可设为 ~/Documents/org (iCloud 同步), Linux/Windows 用 ~/org.
M-x customize-group my-config 改."
  :type 'directory
  :group 'my-config)

(unless (file-exists-p my/org-root-dir)
  (make-directory my/org-root-dir t))

(defcustom my/org-inbox-file (expand-file-name "inbox.org" my/org-root-dir)
  "Inbox 文件路径, 默认 my/org-root-dir/inbox.org.
快速捕获想法用."
  :type 'file
  :group 'my-config)

(defcustom my/org-todo-file (expand-file-name "todos.org" my/org-root-dir)
  "Todo 文件路径, 默认 my/org-root-dir/todos.org.
C-c c t 模板写入此处."
  :type 'file
  :group 'my-config)

(defcustom my/org-projects-file (expand-file-name "projects.org" my/org-root-dir)
  "Projects 文件路径, 默认 my/org-root-dir/projects.org."
  :type 'file
  :group 'my-config)

(defcustom my/org-notes-file (expand-file-name "notes.org" my/org-root-dir)
  "Notes 文件路径, 默认 my/org-root-dir/notes.org."
  :type 'file
  :group 'my-config)

;; ============================================
;; 1. Org 基础行为
;; ============================================

(use-package org
  :ensure nil
  :config
  (setq org-directory my/org-root-dir
        org-default-notes-file my/org-inbox-file
        org-startup-indented t
        org-hide-emphasis-markers t
        org-src-fontify-natively t
        org-confirm-babel-evaluate nil)

  ;; 基础快捷键
  (global-set-key (kbd "C-c l") #'org-store-link)
  (global-set-key (kbd "C-c a") #'org-agenda)
  (global-set-key (kbd "C-c c") #'org-capture))

;; ============================================
;; 2. Capture 模板
;; ============================================

(setq org-capture-templates
      '(("t" "Todo" entry (file+headline my/org-todo-file "Tasks")
         "* TODO %^{任务名称}\n%?" :empty-lines 1)
        ("i" "Inbox" entry (file+headline my/org-inbox-file "Inbox")
         "* %^{想法}\n%?" :empty-lines 1)
        ("b" "Blog" entry (file+headline my/org-inbox-file "Inbox")
         "* %^{标题}\n%?" :empty-lines 1)))

;; ============================================
;; 3. Todo 关键字
;; ============================================

(setq org-todo-keywords
      '((sequence "TODO(t)" "NEXT(n)" "WAIT(w)" "|"
                  "DONE(d)" "CANCELLED(c)")))

(provide 'config-org)
;;; config-org.el ends here
