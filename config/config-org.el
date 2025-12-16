;; ============================================
;; Org Mode 核心配置
;; ============================================

;; 抑制 org-element 在非 org buffer 中的警告
;; 这个警告通常由某些包（如 org-roam）在非 org buffer 中尝试使用 org-element 时触发
;; 通过包装 org-element-at-point 来安全处理非 org buffer 的情况
(defun org-element-at-point-safe (orig-fun &rest args)
  "安全版本的 org-element-at-point，在非 org buffer 中静默返回 nil"
  (condition-case err
      (if (derived-mode-p 'org-mode)
          (apply orig-fun args)
        nil)
    (error nil)))
;; 启用 advice 来抑制警告
(advice-add 'org-element-at-point :around #'org-element-at-point-safe)

(use-package org
  :demand
  :config
  ;; 基础快捷键
  (global-set-key (kbd "C-c C-w") 'org-refile)
  (global-set-key (kbd "C-c c") 'org-capture)
  (global-set-key (kbd "C-c a") 'org-agenda)
  (global-set-key (kbd "C-c l") 'org-store-link)
  
  ;; Org Tempo - 快速插入代码块和结构
  (require 'org-tempo)
  
  ;; 基础设置
  (setq org-confirm-babel-evaluate nil)
  (setq org-log-done 'time)
  (setq org-log-into-drawer t)  ; 将日志放入抽屉
  (setq org-startup-with-inline-images t)
  (setq org-image-actual-width nil)  ; 使用实际图片宽度
  (setq org-startup-folded nil)  ; 启动时不折叠
  (setq org-hide-emphasis-markers t)  ; 隐藏强调标记
  
  ;; TODO 关键词配置
  (setq org-todo-keywords
        '((sequence "TODO(t)" "INPROGRESS(i)" "WAITING(w)" "|" "DONE(d)" "CANCELLED(c)")))
  (setq org-todo-keyword-faces
        '(("TODO" . org-todo)
          ("INPROGRESS" . "yellow")
          ("WAITING" . "orange")
          ("DONE" . org-done)
          ("CANCELLED" . "gray")))
  
  ;; 优先级
  (setq org-priority-faces
        '((?A . (:foreground "red" :weight bold))
          (?B . (:foreground "orange"))
          (?C . (:foreground "green"))))
  
  ;; 目录结构配置
  (setq org-directory "~/Documents/org")
  (setq org-inbox-file (expand-file-name "inbox/inbox.org" org-directory))
  
  ;; Refile 配置
  (setq org-refile-targets
        '((org-inbox-file :maxlevel . 3)
          (nil :maxlevel . 3)))
  (setq org-refile-use-outline-path 'file)
  (setq org-outline-path-complete-in-steps nil)
  (setq org-refile-allow-creating-parent-nodes 'confirm)
  
  ;; Agenda 配置
  (setq org-agenda-files
        (list org-inbox-file
              (expand-file-name "roam" org-directory)))  ; 包含 org-roam 目录
  
  ;; PlantUML 配置
  (setq org-plantuml-jar-path
        (expand-file-name "~/Documents/tools/plantuml.jar"))
  (add-to-list 'org-src-lang-modes '("plantuml" . plantuml))
  (org-babel-do-load-languages
   'org-babel-load-languages
   '((plantuml . t)
     (shell . t)
     (python . t)
     (emacs-lisp . t)))
  
  ;; 链接配置
  (setq org-link-abbrev-alist
        '(("google" . "http://www.google.com/search?q=%s")
          ("wiki" . "https://en.wikipedia.org/wiki/%s")))
  
  ;; 导出配置
  (setq org-export-with-toc t)
  (setq org-export-headline-levels 3)
  
  ;; Capture 模板（将在 org-roam 配置后扩展）
  (setq org-capture-templates
        `(("t" "Todo [inbox]" entry
           (file+headline ,org-inbox-file "Tasks")
           "* TODO %?\n%U\n%a")
          ("n" "Note [inbox]" entry
           (file+headline ,org-inbox-file "Notes")
           "* %?\n%U\n%a")
          ("j" "Journal entry" entry
           (file+datetree "~/Documents/journal/journal.org")
           "* %?\n%U"))))

;; ============================================
;; Org Mode 美化
;; ============================================

(use-package org-modern
  :ensure t
  :after org
  :custom
  (org-modern-hide-stars nil)
  (org-modern-table nil)  ; 如果表格显示有问题可以设为 nil
  :hook (org-mode . org-modern-mode))

;; 备用：如果 org-modern 不工作，使用 org-superstar
;; (use-package org-superstar
;;   :ensure t
;;   :after org
;;   :hook (org-mode . org-superstar-mode)
;;   :custom
;;   (org-superstar-headline-bullets-list '("◉" "○" "✸" "✿" "✜" "◆" "▶"))
;;   (org-superstar-item-bullet-alist '((?* . ?•) (?+ . ?➤) (?- . ?•))))

;; ============================================
;; Org Roam - 知识网络管理
;; ============================================

(use-package org-roam
  :ensure t
  :after org
  :init
  (setq org-roam-v2-ack t)  ; 使用 v2 API
  :custom
  (org-roam-directory (expand-file-name "~/Documents/org/roam"))
  (org-roam-db-location (expand-file-name "org-roam.db" user-emacs-directory))
  (org-roam-db-gc-threshold most-positive-fixnum)  ; 减少数据库更新频率
  (org-roam-completion-everywhere nil)  ; 只在 org-mode 中补全链接，避免在非 org buffer 中触发警告
  (org-roam-capture-templates
   `(("d" "default" plain "%?"
      :target (file+head "${slug}.org" "#+title: ${title}\n#+date: %<%Y-%m-%d>\n#+last_modified: %U\n\n")
      :unnarrowed t)
     ("r" "reference" plain "%?"
      :target (file+head "${slug}.org" "#+title: ${title}\n#+date: %<%Y-%m-%d>\n#+last_modified: %U\n#+roam_tags: reference\n\n")
      :unnarrowed t)
     ("p" "project" plain "%?"
      :target (file+head "${slug}.org" "#+title: ${title}\n#+date: %<%Y-%m-%d>\n#+last_modified: %U\n#+roam_tags: project\n\n")
      :unnarrowed t)
     ("l" "literature note" plain "%?"
      :target (file+head "${slug}.org" "#+title: ${title}\n#+date: %<%Y-%m-%d>\n#+last_modified: %U\n#+roam_tags: literature\n\n")
      :unnarrowed t)
     ("m" "meeting" plain "%?"
      :target (file+head "${slug}.org" "#+title: ${title}\n#+date: %<%Y-%m-%d>\n#+last_modified: %U\n#+roam_tags: meeting\n\n")
      :unnarrowed t)))
  (org-roam-dailies-capture-templates
   `(("d" "default" entry "* %?"
      :target (file+head "%<%Y-%m-%d>.org" "#+title: %<%Y-%m-%d>\n\n"))))
  :bind (("C-c n l" . org-roam-buffer-toggle)
         ("C-c n f" . org-roam-node-find)
         ("C-c n g" . org-roam-graph)
         ("C-c n i" . org-roam-node-insert)
         ("C-c n c" . org-roam-capture)
         ("C-c n j" . org-roam-dailies-capture-today)
         ("C-c n t" . org-roam-tag-add)
         ("C-c n a" . org-roam-alias-add)
         :map org-mode-map
         ("C-M-i" . completion-at-point))
  :config
  (org-roam-setup)
  ;; 自动同步数据库
  (org-roam-db-autosync-mode))

;; ============================================
;; Org Roam UI - 可视化知识网络
;; ============================================

(use-package org-roam-ui
  :ensure t
  :after org-roam
  :custom
  (org-roam-ui-sync-theme t)
  (org-roam-ui-follow t)
  (org-roam-ui-update-on-save t)
  (org-roam-ui-open-on-start nil)  ; 启动时不自动打开
  :bind ("C-c n u" . org-roam-ui-mode))

;; ============================================
;; Consult Org Roam - 增强的搜索功能
;; ============================================

(use-package consult-org-roam
  :ensure t
  :after org-roam
  :custom
  (consult-org-roam-grep-func #'consult-ripgrep)
  :bind (("C-c n s" . consult-org-roam-search)
         ("C-c n r" . consult-org-roam)
         ("C-c n b" . consult-org-roam-backlinks))
  :config
  ;; consult-org-roam-mode 是全局模式，但只在 org-mode 相关操作时使用
  ;; 如果仍然出现警告，可以注释掉下面这行
  (consult-org-roam-mode 1))

;; ============================================
;; Org Journal - 日记功能
;; ============================================

(use-package org-journal
  :ensure t
  :bind (("C-c C-s" . org-journal-search))
  :custom
  (org-journal-dir "~/Documents/journal/")
  (org-journal-date-format "%Y-%m-%d")
  (org-journal-file-format "%Y-%m-%d.org")
  (org-journal-enable-agenda-integration t))

;; ============================================
;; Org Appear - 更好的显示效果
;; ============================================

(use-package org-appear
  :ensure t
  :after org
  :hook (org-mode . org-appear-mode)
  :custom
  (org-appear-autolinks t)
  (org-appear-autokeywords t)
  (org-appear-autoentities t)
  (org-appear-autosubmarkers t)
  (org-appear-delay 0.3))

;; ============================================
;; Org 其他增强功能
;; ============================================

;; Org 链接预览（只在 org-mode 中启用）
(use-package org-link-beautify
  :ensure t
  :after org
  :hook (org-mode . org-link-beautify-mode))

;; Org 表格美化
(use-package valign
  :ensure t
  :after org
  :hook (org-mode . valign-mode))

;; ============================================
;; 目录结构建议
;; ============================================
;; ~/Documents/org/
;; ├── inbox/
;; │   └── inbox.org          # 收件箱，临时任务和笔记
;; ├── roam/                  # Org-roam 笔记目录
;; │   ├── 2024-01-01.org     # 每日笔记
;; │   ├── project-xxx.org    # 项目笔记
;; │   └── ...                # 其他笔记
;; └── journal/               # 日记目录（org-journal）
;;     └── 2024-01-01.org

(provide 'config-org)
