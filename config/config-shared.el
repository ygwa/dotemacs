;;; config-shared.el --- Cross-platform UI (GUI + TUI) -*- lexical-binding: t; -*-
;; 所有视觉配置已用 (display-graphic-p) / (executable-find) 守护, TUI 下自动降级
;; 加载顺序: 本文件必须在 config-gui.el 之前 (gui 依赖 my/theme)

;; ============================================
;; 1. 基础 UI 行为
;; ============================================
;; UI 栏 (tool/menu/scroll-bar) 在 early-init.el 靠 default-frame-alist 提前禁用

(setq inhibit-startup-screen t)

;; 行号: prog-mode 显示, org-mode 关闭
(setq display-line-numbers-type 'relative)
(add-hook 'prog-mode-hook #'display-line-numbers-mode)
(add-hook 'org-mode-hook (lambda () (display-line-numbers-mode -1)))

;; ============================================
;; 2. Emacs 30 内置增强
;; ============================================

(setq which-key-idle-delay 0.5)
(which-key-mode)

(editorconfig-mode 1)

(show-paren-mode 1)
(delete-selection-mode t)
;; 视觉折行: 只在长文本模式开, 编程 buffer 保持硬换行
;; 避免 M-f/M-b 按视觉行跳、复制粘贴破坏列对齐
(add-hook 'text-mode-hook #'visual-line-mode)
(add-hook 'org-mode-hook #'visual-line-mode)
(add-hook 'markdown-mode-hook #'visual-line-mode)
(add-hook 'Info-mode-hook #'visual-line-mode)

;; ============================================
;; 3. 主题 (doom-themes, GUI/TUI 通用)
;; ============================================
;; Mac 暗色模式 hook 在 config-gui.el 中挂

(defvar my/theme 'doom-one
  "当前主题。GUI/TUI 通用。")

(defun my/load-theme (&optional _frame)
  "加载并启用 `my/theme'。daemon 下 frame hook 安全。
`_frame' 参数让此函数可挂在 `server-after-make-frame-hook'。"
  (when (and (require 'doom-themes nil 'noerror)
             (locate-library "doom-themes"))
    (mapc #'disable-theme custom-enabled-themes)
    (load-theme my/theme t)))

(if (daemonp)
    (add-hook 'server-after-make-frame-hook #'my/load-theme)
  (my/load-theme))

;; ============================================
;; 4. Mode-line (doom-modeline) — 跨环境现代 mode-line
;; ============================================
;; :init 阶段启用, 否则首屏显示默认 mode-line

(use-package doom-modeline
  :ensure t
  :init (doom-modeline-mode 1)
  :custom
  ;; 高度 (像素). GUI 给 25, TUI 自动降到 20
  (doom-modeline-height (if (display-graphic-p) 25 20))
  (doom-modeline-bar-width 4)
  ;; TUI 守护: 像素图标 / unicode 箭头在窄终端会渲染为方框或断行
  (doom-modeline-icon (display-graphic-p))
  (doom-modeline-unicode (display-graphic-p))
  (doom-modeline-major-mode-icon (display-graphic-p))
  (doom-modeline-major-mode-color-icon (display-graphic-p))
  (doom-modeline-buffer-state-icon (display-graphic-p))
  (doom-modeline-buffer-modification-icon (display-graphic-p))
  (doom-modeline-lsp-icon (display-graphic-p))
  (doom-modeline-time-icon (display-graphic-p))
  (doom-modeline-modal-icon (display-graphic-p))
  (doom-modeline-time t)
  (doom-modeline-env t)
  (doom-modeline-buffer-encoding nil)
  ;; VCS 集成 (仅在项目下显示 branch)
  (doom-modeline-vcs-max-length 30)
  (doom-modeline-project-detection 'auto))

;; ============================================
;; 5. 窗口管理
;; ============================================

(global-set-key (kbd "C-c <right>") #'winner-redo)  ; 配 winner-undo (C-c <left>) 双向撤销布局

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

(winner-mode 1)
(repeat-mode 1)                          ; 按一次 M-o 进弹窗, 重复 n 一直水平分屏

;; ============================================
;; 6. nerd-icons (含 TUI 守护)
;; ============================================
;; TUI 下字符级 fallback 仍占启动时间, 干脆不加载

(use-package nerd-icons
  :ensure t
  :if (display-graphic-p))

(use-package nerd-icons-dired
  :ensure t
  :hook (dired-mode . nerd-icons-dired-mode))

(use-package nerd-icons-corfu
  :ensure t
  :after corfu
  :config
  (when (display-graphic-p)
    (add-to-list 'corfu-margin-formatters #'nerd-icons-corfu-formatter)))

;; ============================================
;; 7. 启动仪表盘 (Dashboard) - 双流向工作台版
;; ============================================

(use-package dashboard
  :ensure t
  :custom
  (initial-buffer-choice (lambda () (get-buffer-create "*dashboard*")))
  (dashboard-banner-logo-title "Thinking & Coding - 你的第二大脑")
  (dashboard-center-content t)
  (dashboard-display-icons-p (display-graphic-p))
  (dashboard-icon-type (and (display-graphic-p) 'nerd-icons))
  (dashboard-set-heading-icons (display-graphic-p))
  (dashboard-set-file-icons (display-graphic-p))
  (dashboard-items '((recents  . 5)
                     (projects . 5)
                     (agenda   . 5)))
  (dashboard-projects-backend 'project-el)
  (dashboard-set-navigator t)
  (dashboard-set-footer nil)
  (dashboard-week-agenda-trim-leading-zero t)
  (dashboard-startupify-list '(dashboard-insert-banner
                               dashboard-insert-newline
                               dashboard-insert-banner-title
                               dashboard-insert-newline
                               dashboard-insert-navigator
                               dashboard-insert-newline
                               dashboard-insert-init-info
                               dashboard-insert-items
                               dashboard-insert-newline
                               dashboard-insert-footer))
  :config
  ;; Banner 适配: GUI 用 official, 终端用 'ascii (figlet 在窄终端会断行)
  (setq dashboard-startup-banner
        (if (display-graphic-p) 'official 'ascii))
  (setq dashboard-init-info
        (lambda ()
          (propertize
           (format "✦  %d packages  ·  loaded in %s"
                   (length package-activated-list)
                   (emacs-init-time))
           'face 'font-lock-comment-face)))
  (setq dashboard-navigator-buttons
        ;; TUI 下 emoji 渲染不可靠, 用纯文本替代
        (let ((icon-fmt (lambda (g text) (if (display-graphic-p) g text))))
          `(;; 第一排: 知识管理流
            ((,(funcall icon-fmt "📥" "[i]") "Inbox" "捕捉想法"
              (lambda (&rest _) (find-file my/org-inbox-file)))
             (,(funcall icon-fmt "🔭" "[s]") "Studies" "专题研究"
              (lambda (&rest _) (find-file my/org-projects-file)))
             (,(funcall icon-fmt "🏛️" "[p]") "Principles" "底层模型"
              (lambda (&rest _) (find-file my/org-notes-file))))
            ;; 第二排: 开发流
            ((,(funcall icon-fmt "💻" "[c]") "Code" "编程项目"
              (lambda (&rest _) (project-switch-project)))))))
  ;; 替代 dashboard-setup-startup-hook, 避免 init-info 重复显示
  (when (< (length command-line-args) 2)
    (add-hook 'window-size-change-functions #'dashboard-resize-on-hook 100)
    (add-hook 'after-init-hook #'dashboard-insert-startupify-lists)
    (add-hook 'emacs-startup-hook #'dashboard-initialize)))

;; ============================================
;; 8. 其它细节
;; ============================================

;; auto-save 启用 (写到 var/auto-save-list/, 防 Emacs crash / 断电丢失未保存内容)
;; backup 和 lockfile 仍然禁用, 避免污染项目目录
(setq auto-save-default t
      auto-save-interval 300           ; 5 分钟一次自动保存
      auto-save-silent t               ; 不弹窗打扰
      auto-save-list-file-prefix
      (expand-file-name "var/auto-save-list/session-" user-emacs-directory)
      make-backup-files nil
      create-lockfiles nil
      tab-width 4
      scroll-margin 2                  ; 滚动时上方保留 2 行
      mouse-yank-at-point t)

(provide 'config-shared)
;;; config-shared.el ends here
