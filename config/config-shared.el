;;; config-shared.el --- Cross-platform shared UI -*- lexical-binding: t; -*-
;; TUI / GUI 视觉差异由 config-display-tui.el 或 config-gui.el 按 profile 加载.

;; ============================================
;; 1. 基础 UI 行为
;; ============================================
;; UI 栏 (tool/menu/scroll-bar) 在 early-init.el 靠 default-frame-alist 提前禁用
;; inhibit-startup-screen 在 early-init.el 与 inhibit-startup-message 一并设置

;; 行号: prog-mode 显示, org-mode 关闭
(setq display-line-numbers-type 'relative)
(add-hook 'prog-mode-hook #'display-line-numbers-mode)
(add-hook 'org-mode-hook (lambda () (display-line-numbers-mode -1)))

;; ============================================
;; 2. Emacs 30 内置增强
;; ============================================

(setq which-key-idle-delay 0.5)
(add-hook 'after-init-hook #'which-key-mode)

(editorconfig-mode 1)

(show-paren-mode 1)
(delete-selection-mode t)
;; 视觉折行: 只在长文本模式开, 编程 buffer 保持硬换行
;; 避免 M-f/M-b 按视觉行跳、复制粘贴破坏列对齐
(add-hook 'text-mode-hook #'visual-line-mode)
(add-hook 'org-mode-hook #'visual-line-mode)
(add-hook 'Info-mode-hook #'visual-line-mode)

;; ============================================
;; 3. 主题 (catppuccin)
;; ============================================

(use-package catppuccin-theme
  :ensure t)

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
;; 4. Mode-line (doom-modeline) — 公共配置
;; ============================================
;; 图标开关由 config-display-tui / config-gui profile 分别设置.

(use-package doom-modeline
  :ensure t
  :init (doom-modeline-mode 1)
  :custom
  (doom-modeline-height 20)
  (doom-modeline-bar-width 4)
  (doom-modeline-time t)
  (doom-modeline-env t)
  (doom-modeline-buffer-encoding nil)
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
     (treemacs-mode :select t :align left :size 30)
     ;; AI workbench buffers
     ("\\*AI-Plan\\*" :select t :align right :size 0.35)
     ("\\*AI-Review\\*" :select t :align right :size 0.45)
     ("\\*AI-Log\\*" :select nil :align bottom :size 0.22))))

(winner-mode 1)
(setq winner-ring-size 50)
(repeat-mode 1)                          ; 按一次 M-o 进弹窗, 重复 n 一直水平分屏

;; windmove: S-<arrows> 移焦点, S-M-<arrows> 移窗 (2 窗时比 M-o 更轻)
(windmove-default-keybindings)
(global-set-key (kbd "S-M-<left>")  #'windmove-swap-states-left)
(global-set-key (kbd "S-M-<right>") #'windmove-swap-states-right)
(global-set-key (kbd "S-M-<up>")    #'windmove-swap-states-up)
(global-set-key (kbd "S-M-<down>")  #'windmove-swap-states-down)

;; Dashboard → config/config-dashboard.el
;; nerd-icons / dashboard icons → config-display-tui.el 或 config-gui.el

;; ============================================
;; 6. 其它细节
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
