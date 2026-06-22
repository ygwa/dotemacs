;;; config-shared.el --- TUI-only cross-platform UI -*- lexical-binding: t; -*-
;; 2026-06 起: 统一 TUI 配置 (emacsclient + daemon),
;; 不再有 (display-graphic-p) 双分支. 所有视觉配置按 24-bit color TUI 终端优化.

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
;; 3. 主题 (catppuccin mocha)
;; ============================================
;; TUI 24-bit color 终端完美支持 catppuccin mocha.
;; `catppuccin-flavor' 切换其它 flavor 后需 `catppuccin-reload' 重生成 face.
;; 旧版 Mac 暗色模式同步 hook 已删除 (config-gui.el 整体下线).

(use-package catppuccin-theme
  :ensure t
  :custom
  (catppuccin-flavor 'mocha))

(defvar my/theme-flavor 'mocha
  "当前 catppuccin flavor.
切换后需 `catppuccin-reload' 重新生成主题.")

(defun my/load-theme ()
  "加载并启用 `catppuccin' 主题, 应用 `my/theme-flavor'.
daemon 下用 server-after-make-frame-hook 等首 frame 落地后再加载,
否则 frame 未创建时 load-theme 会用错 frame 参数."
  (when (and (require 'catppuccin-theme nil 'noerror)
             (locate-library "catppuccin-theme"))
    (setq catppuccin-flavor my/theme-flavor)
    (catppuccin-reload)              ; 触发 face 重新生成, 应用新 flavor
    (mapc #'disable-theme custom-enabled-themes)
    (load-theme 'catppuccin t)))

;; daemon 永远走 hook 路径; 前台启动直接调一次
(if (daemonp)
    (add-hook 'server-after-make-frame-hook #'my/load-theme)
  (my/load-theme))

;; ============================================
;; 4. Mode-line (doom-modeline) — TUI 字符级配置
;; ============================================
;; TUI 终端不渲染像素图标, 关掉所有 icon/unicode 渲染避免方框/断行.
;; 字符级 fallback 仍然清晰可读.

(use-package doom-modeline
  :ensure t
  :init (doom-modeline-mode 1)
  :custom
  ;; 高度 (像素). TUI 统一 20 像素 (字符模式两行高)
  (doom-modeline-height 20)
  (doom-modeline-bar-width 4)
  ;; TUI: 全部关掉像素/unicode 图标
  (doom-modeline-icon nil)
  (doom-modeline-unicode nil)
  (doom-modeline-major-mode-icon nil)
  (doom-modeline-major-mode-color-icon nil)
  (doom-modeline-buffer-state-icon nil)
  (doom-modeline-buffer-modification-icon nil)
  (doom-modeline-lsp-icon nil)
  (doom-modeline-time-icon nil)
  (doom-modeline-modal-icon nil)
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
  :defer t                       ; 显式延迟加载, 首次 M-o 时才加载包
  :bind ("M-o" . ace-window)
  :custom
  (aw-scope 'frame)
  (aw-dispatch-alist
   '((?x aw-delete-window "Delete Window")
     (?m aw-swap-window "Swap Window")
     (?n aw-split-window-horz "Split Window Horizontal")
     (?v aw-split-window-vert "Split Window Vertical")
     (?b aw-switch-buffer-in-window "Select Buffer")
     (?o ace-window-maximize-window "Maximize / Restore")
     (?= balance-windows "Balance All")
     (?u winner-undo "Winner Undo"))))

(use-package shackle
  :ensure t
  :defer t
  :config (shackle-mode 1)
  :custom
  (shackle-rules
   '(;; 日常查询窗: 右侧弹, 选中内容
     ("*Help*" :select t :align right :size 0.4)
     ("*compilation*" :select nil :align bottom :size 0.25 :autoclose t)
     ("*Messages*" :select nil :align bottom :size 0.2)
     ;; 出错/警告: 给大空间, 不自动关
     ("\\*Backtrace\\*" :select t :align right :size 0.5)
     ("\\*Warnings\\*"  :select t :align bottom :size 0.3)
     ("\\*Pp Eval Output\\*" :select t :align right :size 0.4)
     ;; Magit 状态窗: 右侧
     (magit-status-mode :select t :align right :size 0.5)
     ;; Embark 收集器: 右侧
     (embark-collect-mode :select t :align right :size 0.4)
     ;; Treemacs 文件树: 左侧
     (treemacs-mode :select t :align left :size 30))))

(winner-mode 1)
(setq winner-bdose 50)                   ; winner undo/redo 最多 50 步, 默认 1 太浅
(repeat-mode 1)                          ; 按一次 M-o 进弹窗, 重复 n 一直水平分屏

;; windmove: S-<arrows> 移焦点, S-M-<arrows> 移窗 (2 窗时比 M-o 更轻)
(windmove-default-keybindings)
(global-set-key (kbd "S-M-<left>")  #'windmove-swap-states-left)
(global-set-key (kbd "S-M-<right>") #'windmove-swap-states-right)
(global-set-key (kbd "S-M-<up>")    #'windmove-swap-states-up)
(global-set-key (kbd "S-M-<down>")  #'windmove-swap-states-down)

;; ============================================
;; 6. nerd-icons — TUI 下不安装主包, 仅用 dired unicode fallback
;; ============================================
;; TUI 不渲染 Nerd Font 像素图标, 主包 (nerd-icons.el) 安装但不激活也无意义.
;; nerd-icons-dired / nerd-icons-corfu 内部自带 unicode 字符级 fallback,
;; 不依赖主包即可在 TUI 下显示文字符号 (例如 dired 中显示 [DIR]).

(use-package nerd-icons-dired
  :ensure t
  :hook (dired-mode . nerd-icons-dired-mode))

(use-package nerd-icons-corfu
  :ensure t
  :after corfu
  :config
  (add-to-list 'corfu-margin-formatters #'nerd-icons-corfu-formatter))

;; ============================================
;; 7. 启动仪表盘 (Dashboard) — TUI 字符级
;; ============================================
;; 不用 Nerd Font 图标, banner 走 ascii (figlet 在窄终端会断行).

(use-package dashboard
  :ensure t
  :custom
  (initial-buffer-choice (lambda () (get-buffer-create "*dashboard*")))
  (dashboard-banner-logo-title "Thinking & Coding - 你的第二大脑")
  (dashboard-center-content t)
  ;; TUI: 全部关掉 nerd-icons, 走 unicode 字符级
  (dashboard-display-icons-p nil)
  (dashboard-icon-type nil)
  (dashboard-set-heading-icons nil)
  (dashboard-set-file-icons nil)
  ;; dashboard-items 是 alist: '(item-type . count), 顺序即渲染顺序.
  (dashboard-items '((recents  . 5)
                     (projects . 5)
                     (agenda   . 5)))
  (dashboard-projects-backend 'project-el)
  ;; TUI 优化: 关掉 navigator (快捷按钮在窄终端意义不大) + footer (版权/统计)
  (dashboard-set-navigator nil)
  (dashboard-set-footer nil)
  (dashboard-week-agenda-trim-leading-zero t)
  (dashboard-startupify-list '(dashboard-insert-banner
                               dashboard-insert-newline
                               dashboard-insert-banner-title
                               dashboard-insert-newline
                               dashboard-insert-init-info
                               dashboard-insert-items
                               dashboard-insert-newline
                               dashboard-insert-footer))
  :config
  ;; TUI: 走 'ascii' banner (避免 figlet 断行)
  (setq dashboard-startup-banner 'ascii)
  (setq dashboard-init-info
        (lambda ()
          (propertize
           (format "✦  %d packages  ·  loaded in %s"
                   (length package-activated-list)
                   (emacs-init-time))
           'face 'font-lock-comment-face)))
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
