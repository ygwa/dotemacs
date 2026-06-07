;;; config-gui.el --- UI and Appearance Configuration -*- lexical-binding: t; -*-

;; ============================================
;; 1. 基础 UI 行为优化
;; ============================================

;; 提示：UI 栏的禁用建议留在 early-init.el 以防闪烁
;; 这里保留作为双重保险
(setq use-file-dialog nil
      use-dialog-box nil
      inhibit-startup-screen t)

(dolist (mode '(tool-bar-mode scroll-bar-mode menu-bar-mode))
  (when (fboundp mode) (funcall mode -1)))

;; 增强 Emacs 30 的平滑滚动（对阅读电子书至关重要）
(when (fboundp 'pixel-scroll-precision-mode)
  (pixel-scroll-precision-mode 1))

;; 行号配置：阅读模式下通常不需要行号，但在编写博客代码块时很有用
(setq display-line-numbers-type 'relative)
(add-hook 'prog-mode-hook #'display-line-numbers-mode)
;; 在 Org-mode 和阅读模式中禁用行号，保持页面干净
(add-hook 'org-mode-hook (lambda () (display-line-numbers-mode -1)))

;; ============================================
;; 2. Emacs 30 内置增强功能
;; ============================================

;; 启用内置 which-key (Emacs 30+)
(setq which-key-idle-delay 0.5)
(which-key-mode)

;; 启用内置 editorconfig
(editorconfig-mode 1)

;; 基础交互增强
(show-paren-mode 1)
(delete-selection-mode t)
(global-visual-line-mode t) ; 自动折行，阅读体验更佳

;; ============================================
;; 3. 字体与中文排版优化 (跨平台 fallback)
;; ============================================

;; 按平台选择字体 fallback
(defvar my/monospace-font
  (pcase system-type
    ('darwin "JetBrains Mono-14")
    ('gnu/linux "JetBrains Mono-14")
    (_ "Monospace-14"))
  "等宽字体 (按 system-type 选择)。")

(defvar my/cjk-font-family
  (pcase system-type
    ('darwin "Hiragino Sans GB")
    ('gnu/linux "Noto Sans CJK SC")
    (_ nil))
  "中文字体 (按 system-type 选择 fallback)。nil 表示不配置。")

(defun my/setup-gui-fonts ()
  "配置 GUI 字体 (等宽字体 + CJK fallback)。"
  (set-face-attribute 'default nil :font my/monospace-font)
  (when my/cjk-font-family
    (dolist (charset '(han kana symbol cjk-misc bopomofo))
      (set-fontset-font t charset (font-spec :family my/cjk-font-family)))
    (add-to-list 'face-font-rescale-alist (cons my/cjk-font-family 1.1))))

;; 终端下不设置字体 (使用终端自己的字体)
(if (daemonp)
    (add-hook 'server-after-make-frame-hook
              (lambda ()
                (when (display-graphic-p)
                  (my/setup-gui-fonts))))
  (when (display-graphic-p)
    (my/setup-gui-fonts)))

;; 主题设置
(load-theme 'modus-operandi t)

;; 注意: rainbow-delimiters 已在 config-package.el 中配置

;; ============================================
;; 4. 窗口管理 (Window Management)
;; ============================================

;; Ace-window: 快速跳转分屏
(use-package ace-window
  :ensure t
  :bind ("M-o" . ace-window)
  :custom
  (aw-scope 'frame)
  (aw-dispatch-alist
   '((?x aw-delete-window "Delete Window")
     (?m aw-swap-window "Swap Window")
     (?n aw-split-window-horz "Split Window Horizontal")
     (?v aw-split-window-vert "Split Window Vertical")
     (?b aw-switch-buffer-in-window "Select Buffer")
     (?u winner-undo "Winner Undo"))))

;; Shackle: 控制弹出窗口位置（防止阅读时被弹出窗口干扰）
(use-package shackle
  :ensure t
  :hook (after-init . shackle-mode)
  :custom
  (shackle-rules
   '(("*Help*" :select t :align right :size 0.35)
     ("*compilation*" :select nil :align bottom :size 0.2 :autoclose t)
     ("*Messages*" :select nil :align bottom :size 0.2)
     ("*Org-roam*" :select nil :align right :size 0.3)
     (magit-status-mode :select t :same t))))

;; Winner-mode: 允许 C-c left 撤销窗口布局改变
(winner-mode 1)

;; ============================================
;; 5. 启动仪表盘 (解决 Scratch 启动问题)
;; ============================================

(use-package nerd-icons
  :ensure t)

;; 让 Dired 显示图标
(use-package nerd-icons-dired
  :ensure t
  :hook (dired-mode . nerd-icons-dired-mode))

;; 让补全列表显示图标 (配合 config-package.el 中的 corfu)
(use-package nerd-icons-corfu
  :ensure t
  :after corfu
  :config
  (add-to-list 'corfu-margin-formatters #'nerd-icons-corfu-formatter))

;; ============================================
;; 5. 启动仪表盘 (Dashboard) - 双流向工作台版
;; ============================================
(use-package dashboard
  :ensure t
  :custom
  ;; 1. 基础外观设置
  (initial-buffer-choice (lambda () (get-buffer-create "*dashboard*")))
  (dashboard-startup-banner 'official)
  (dashboard-banner-logo-title "Thinking & Coding - 你的第二大脑")
  (dashboard-center-content t)
  
  ;; 2. 内容模块布局
  (dashboard-display-icons-p t)
  (dashboard-icon-type 'nerd-icons)
  (dashboard-set-heading-icons t)
  (dashboard-set-file-icons t)

  (dashboard-items '((recents  . 5)
                     (projects . 5)
                     (agenda   . 5)))
  
  (dashboard-projects-backend 'project-el)

  ;; 3. 启用导航按钮
  (dashboard-set-navigator t)
  (dashboard-set-footer nil)
  (dashboard-week-agenda-trim-leading-zero t)

  ;; 4. 关键：设置 startupify-list 包含 navigator
  (dashboard-startupify-list '(dashboard-insert-banner
                               dashboard-insert-newline
                               dashboard-insert-banner-title
                               dashboard-insert-newline
                               dashboard-insert-navigator  ;; 导航按钮
                               dashboard-insert-newline
                               dashboard-insert-init-info
                               dashboard-insert-items
                               dashboard-insert-newline
                               dashboard-insert-footer))
  :config
  ;; 5. 自定义导航按钮 (使用 Emoji)
  (setq dashboard-navigator-buttons
        `(;; 第一排：知识管理流
          (("📥" "Inbox" "捕捉想法"
            (lambda (&rest _) (find-file my/org-inbox-file)))
           ("🔭" "Studies" "专题研究"
            (lambda (&rest _) (find-file my/org-projects-file)))
           ("🏛️" "Principles" "底层模型"
            (lambda (&rest _) (find-file my/org-notes-file))))
          ;; 第二排：输出与开发流
          (("💻" "Code" "编程项目"
            (lambda (&rest _) (project-switch-project)))
           ("✍️" "New Post" "新建博客"
            (lambda (&rest _) (call-interactively 'my/org-blog-new-post)))
           ("🚀" "Publish" "发布博客"
            (lambda (&rest _) (call-interactively 'my/publish-blog))))))

  (dashboard-setup-startup-hook))

;; ============================================
;; 6. 其它细节设置
;; ============================================

(setq auto-save-default nil
      make-backup-files nil
      create-lockfiles nil
      tab-width 4
      scroll-margin 2       ; 滚动时上方保留2行，视觉更舒适
      mouse-yank-at-point t)

(provide 'config-gui)

