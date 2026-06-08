;;; config-org.el --- Minimal Org-mode configuration  -*- lexical-binding: t; -*-

;; ============================================
;; 0. 核心路径定义
;; ============================================
;; dashboard / capture 都引用这些, 不要轻易改名

(defvar my/org-root-dir (expand-file-name "~/Documents/org/"))

(unless (file-exists-p my/org-root-dir)
  (make-directory my/org-root-dir t))

(defvar my/org-inbox-file    (expand-file-name "inbox.org"    my/org-root-dir))
(defvar my/org-todo-file     (expand-file-name "todos.org"    my/org-root-dir))
(defvar my/org-projects-file (expand-file-name "projects.org" my/org-root-dir))
(defvar my/org-notes-file    (expand-file-name "notes.org"    my/org-root-dir))

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
