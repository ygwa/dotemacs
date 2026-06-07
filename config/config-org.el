;;; config-org.el --- 双流向笔记系统 & Hugo 博客配置 -*- lexical-binding: t; -*-

;; ============================================
;; 0. 核心路径定义
;; ============================================

(defvar my/org-root-dir (expand-file-name "~/Documents/org/"))

;; 确保目录存在
(unless (file-exists-p my/org-root-dir)
  (make-directory my/org-root-dir t))

;; 笔记流文件
(defvar my/org-inbox-file    (expand-file-name "inbox.org" my/org-root-dir))
(defvar my/org-todo-file     (expand-file-name "todos.org" my/org-root-dir))
(defvar my/org-projects-file (expand-file-name "projects.org" my/org-root-dir))
(defvar my/org-notes-file    (expand-file-name "notes.org" my/org-root-dir))

;; 博客流文件 (Hugo)
(defvar my/hugo-root "~/Documents/hugo/ygwa.github.io/")
(defvar my/org-hugo-posts-file (expand-file-name "blog.org" my/org-root-dir))

;; ============================================
;; 1. 视觉美化 (Modern Look)
;; ============================================

(use-package org-modern
  :ensure t
  :hook ((org-mode . org-modern-mode)
         (org-agenda-finalize . org-modern-agenda))
  :custom
  ;; 标题符号 (heading bullets)
  (org-modern-star '("◉" "○" "◈" "◇" "✳" "▪"))
  ;; 表格: 关闭 org-modern 自带的表格样式, 用 valign-mode 接管
  (org-modern-table nil)
  (org-modern-table-vertical 1)
  (org-modern-table-horizontal 0.2)
  ;; 列表项前缀
  (org-modern-list '((43 . "➤") (45 . "•") (42 . "–")))
  ;; 如想启用 emoji 标签前缀, 取消下面 4 行注释
  ;; (org-modern-tag
  ;;  '(("QUESTION" . "❓")
  ;;    ("NOTE" . "📝")
  ;;    ("PROJECT" . "🏗️")
  ;;    ("BLOG" . "✍️")))
  )

;; ============================================
;; 2. Org Mode 核心行为
;; ============================================

(use-package org
  :ensure nil
  :config
  ;; 基础设置
  (setq org-directory my/org-root-dir)
  (setq org-default-notes-file my/org-inbox-file)
  (setq org-startup-indented t)
  (setq org-hide-emphasis-markers t)
  (setq org-image-actual-width 600)
  (setq org-startup-with-inline-images t)

  ;; 源代码块
  (setq org-src-fontify-natively t)
  (setq org-src-tab-acts-natively t)
  (setq org-confirm-babel-evaluate nil)

  ;; 快捷键
  (global-set-key (kbd "C-c l") #'org-store-link)
  (global-set-key (kbd "C-c a") #'org-agenda)
  (global-set-key (kbd "C-c c") #'org-capture))

(use-package org-appear
  :ensure t
  :hook (org-mode . org-appear-mode)
  :custom
  (org-appear-autolinks t)
  (org-appear-autosubmarkers t))

;; ============================================
;; 3. Diagram / Babel 支持
;; ============================================

(use-package ob-mermaid
  :ensure t)

(org-babel-do-load-languages
 'org-babel-load-languages
 `((emacs-lisp . t)
   (shell . t)
   ,@(when (executable-find "mermaid")  '((mermaid . t)))
   ,@(when (executable-find "plantuml") '((plantuml . t)))
   ,@(when (executable-find "dot")      '((dot . t)))
   ,@(when (executable-find "gnuplot")  '((gnuplot . t)))))

(add-hook 'org-mode-hook #'org-display-inline-images)

;; ============================================
;; 4. 双流向工作流 (Capture & Refile)
;; ============================================

;; 优化后的 Capture 模板：直通 Todo，直通 Hugo，只有 Idea 进 Inbox
(setq org-capture-templates
      `(
        ;; === 路径 A: 执行流 (明确的任务 -> Todos) ===
        ("t" "Todo Task" entry (file+headline my/org-todo-file "Tasks")
         "* TODO %^{任务名称} \n:PROPERTIES:\n:CAPTURED: %U\n:END:\n\n%?" 
         :empty-lines 1)

        ;; === 路径 B: 孵化流 (模糊的想法 -> Inbox -> 知识加工) ===
        ("i" "Inbox / Idea" entry (file+headline my/org-inbox-file "Inbox")
         "* %^{想法/灵感} :NOTE:\n:PROPERTIES:\n:CAPTURED: %U\n:END:\n\n- 背景: %?\n- 思考: "
         :empty-lines 1)
        
        ("q" "Question" entry (file+headline my/org-inbox-file "Inbox")
         "* TODO %^{你要解决什么问题？} :QUESTION:\n:PROPERTIES:\n:CAPTURED: %U\n:END:\n\n- 现状: %?\n- 猜测: ")

        ;; === 路径 C: 输出流 (博客 -> Hugo -> 发布) ===
        ;; 注意：这需要你的 blog.org 里面有一个 "Blog Posts" 的标题
        ("b" "Blog Post (Hugo)" entry (file+olp my/org-hugo-posts-file "Blog Posts")
         "* TODO %^{文章标题}\n:PROPERTIES:\n:EXPORT_FILE_NAME: %^{Slug (文件名)}\n:EXPORT_DATE: %t\n:END:\n\n%?"
         :empty-lines 1)
        ))

(setq org-todo-keywords
      '((sequence "TODO(t!)"  ; 待办
                  "NEXT(n)"   ; 下一步
                  "WAIT(w@/!)"; 等待
                  "|" 
                  "DONE(d!)"  ; 完成
                  "KILL(k@)") ; 取消
        ))

(setq org-todo-keyword-faces
      '(("TODO" . (:foreground "red" :weight bold))
        ("NEXT" . (:foreground "orange" :weight bold))
        ("WAIT" . (:foreground "gray" :slant italic))
        ("DONE" . (:foreground "forest green" :weight bold))))

;; Agenda 视图包含所有相关文件
(setq org-agenda-files 
      (list my/org-inbox-file 
            my/org-projects-file 
            my/org-todo-file
            ;; 博客计划也包含在日程中，方便管理发布进度
            my/org-hugo-posts-file))

;; Refile 目标：主要用于处理 Inbox 里的内容
(setq org-refile-targets
      `((,my/org-projects-file . (:maxlevel . 3))
        (,my/org-notes-file    . (:maxlevel . 3))
        ;; 偶尔 Inbox 里的想法变成任务时，也可以 Refile 到 Todo
        (,my/org-todo-file     . (:maxlevel . 1))))

(setq org-refile-use-outline-path 'file)
(setq org-outline-path-complete-in-steps nil)
(setq org-refile-allow-creating-parent-nodes 'confirm)

;; ============================================
;; 5. Hugo 博客系统 (ox-hugo)
;; ============================================
(defvar my/org-hugo--save-timer nil
  "保存 blog.org 时用于 debounce 的 timer 对象。")

(defun my/org-hugo-export-debounced ()
  "保存 blog.org 后延迟导出 (debounce 5s, 防连续保存抖动)。
比 `org-hugo-auto-export-mode' 更可控 — 后者是每次保存立即导出。"
  (when (and (eq major-mode 'org-mode)
             (buffer-file-name)
             (string= (buffer-file-name) my/org-hugo-posts-file))
    (when (timerp my/org-hugo--save-timer)
      (cancel-timer my/org-hugo--save-timer))
    (setq my/org-hugo--save-timer
          (run-with-idle-timer 5 nil #'org-hugo-export-wim))))

(use-package ox-hugo
  :ensure t
  :after ox
  :config
  ;; 设置 Hugo 站点的根目录
  (setq org-hugo-base-dir my/hugo-root)

  ;; 默认将内容导出到 content/posts (你可以根据需要修改 section)
  (setq org-hugo-section "writings"))

;; 注册 debounce hook (放在 use-package 外面, 避免 config 重复运行导致 hook 累积)
(add-hook 'after-save-hook #'my/org-hugo-export-debounced)



;; ============================================
;; 6. 附件 / 引用
;; ============================================

(use-package org-download
  :ensure t
  :after org
  :config
  (setq org-download-method 'directory)
  (setq org-download-image-dir "images")
  (setq org-download-heading-lvl nil)
  :hook ((dired-mode . org-download-enable)
         (org-mode . org-download-enable)))

(use-package citar
  :ensure t
  :custom
  (citar-bibliography (list (expand-file-name "references.bib" my/org-root-dir)))
  (citar-library-paths (list (expand-file-name "library/" my/org-root-dir)))
  :bind (:map org-mode-map
              ("C-c r o" . citar-open)
              ("C-c r i" . citar-insert-citation)))

(use-package valign
  :ensure t
  :hook ((org-mode . valign-mode)
         (markdown-mode . valign-mode))
  :config
  (setq valign-fancy-bar t)
  (setq valign-max-line-width 1))

(provide 'config-org)
;;; config-org.el ends here
