;;; my-sidebar.el --- Project-scoped dired sidebar (replaces treemacs)  -*- lexical-binding: t; -*-

;; 一个轻量项目作用域文件树: 基于 dired + project.el, 0 外部依赖.
;;
;; 设计目标:
;;   - 跟 project.el 深度集成: 跟随 (my/project-root), 切项目自动换 buffer
;;   - sidebar 按需显示: 不挡视野, 不抢 M-o / winner-undo
;;   - 保持 dired 经典交互: RET 进入, n/p 上/下文件, + 新建, d 删除, g 刷新
;;   - TUI/GUI 同样工作: 不用 nerd-icons, 用 dired 颜色 (diredfl) 或 Emacs 自带
;;   - DWIM RET: 目录在当前 sidebar 进入 (覆盖列表), 文件在主窗口打开 (右侧/other)

(require 'my-project)

(defgroup my-sidebar nil
  "Project-scoped dired sidebar (treemacs replacement)."
  :group 'my-config
  :prefix "my/sidebar-")

(defcustom my/sidebar-width 30
  "Sidebar window width (chars)."
  :type 'integer
  :group 'my-sidebar)

(defcustom my/sidebar-listing-switches "-al"
  "Listing switches for sidebar dired buffer (default: hidden files on)."
  :type 'string
  :group 'my-sidebar)

(defvar my/sidebar--buffer-alist nil
  "Alist: project-root → dired-buffer for open sidebar buffers.")

(defun my/sidebar--buffer-name (root)
  "Sidebar buffer name scoped to ROOT."
  (format "*sidebar:%s*"
          (file-name-nondirectory (directory-file-name (expand-file-name root)))))

(defun my/sidebar--display (buf)
  "Display BUF as left side window."
  (display-buffer
   buf
   `((display-buffer-reuse-window display-buffer-in-side-window)
     (side . left) (slot . 0) (window-width . ,my/sidebar-width))))

(defun my/sidebar--find-buffer (root)
  "Return sidebar buffer for ROOT, or nil."
  (cdr (assoc (expand-file-name root) my/sidebar--buffer-alist)))

(defun my/sidebar--register-buffer (root buf)
  "Register BUF as sidebar for ROOT (idempotent)."
  (let ((root (expand-file-name root)))
    (setq my/sidebar--buffer-alist
          (cons (cons root buf)
                (assq-delete-all root my/sidebar--buffer-alist)))))

(defun my/sidebar-open ()
  "Open or focus project-scoped dired sidebar at (my/project-root)."
  (interactive)
  (let* ((root (file-name-as-directory
                (expand-file-name (or (my/project-root) default-directory))))
         (existing (my/sidebar--find-buffer root))
         (buf (or existing
                  (let* ((new-buf (find-file-noselect root))
                         (dired-listing-switches my/sidebar-listing-switches))
                    (with-current-buffer new-buf
                      (setq buffer-undo-list t)
                      (rename-buffer (my/sidebar--buffer-name root) t)
                      (my/sidebar--register-buffer root new-buf))
                    new-buf))))
    ;; 每次都重新 bind DWIM 键位 (覆盖 dired 默认 RET)
    (with-current-buffer buf (my/sidebar--setup-keys))
    (let ((win (or (get-buffer-window buf)
                   (progn (my/sidebar--display buf)
                          (get-buffer-window buf)))))
      (when win
        (select-window win)))))

(defun my/sidebar-close ()
  "Close sidebar window if visible."
  (interactive)
  (when-let* ((root (file-name-as-directory
                     (expand-file-name (or (my/project-root) default-directory))))
              (buf (my/sidebar--find-buffer root))
              (win (get-buffer-window buf)))
    (delete-window win)))

(defun my/sidebar-toggle ()
  "Toggle project-scoped dired sidebar."
  (interactive)
  (let* ((root (file-name-as-directory
                (expand-file-name (or (my/project-root) default-directory))))
         (buf (my/sidebar--find-buffer root))
         (win (and buf (get-buffer-window buf))))
    (if win (my/sidebar-close) (my/sidebar-open))))

(defun my/sidebar-refresh ()
  "Refresh sidebar at current project root."
  (interactive)
  (when-let* ((root (file-name-as-directory
                     (expand-file-name (or (my/project-root) default-directory))))
              (buf (my/sidebar--find-buffer root)))
    (with-current-buffer buf
      (let ((default-directory root)
            (dired-listing-switches my/sidebar-listing-switches))
        (revert-buffer)))
    (message "Sidebar refreshed: %s" root)))

(defun my/sidebar--file-dwim ()
  "Sidebar DWIM open at point:
  - directory: enter in sidebar (replace listing, navigate tree in-place)
  - file:      open in main editing window (other-window if exists, else right side)"
  (interactive)
  (let* ((file (dired-file-name-at-point))
         (is-dir (and file (file-directory-p file))))
    (cond
     ((null file)
      (user-error "No file at point"))
     (is-dir
      ;; 目录: 替换 sidebar 当前 listing (深入子树, 不分屏)
      (let* ((default-directory file)
             (dired-listing-switches my/sidebar-listing-switches)
             (new-buf (dired-noselect file)))
        (switch-to-buffer new-buf)
        (goto-char (point-min))
        (forward-line 2)
        (dired-move-to-filename)))
     (t
      ;; 文件: 跳到主窗口 (other-window 或右侧 side window)
      (let ((main-win (my/sidebar--main-window)))
        (if main-win
            ;; 已有主窗口: 切换到那里再打开文件
            (progn
              (select-window main-win)
              (find-file file))
          ;; 独立 sidebar: 右侧开 side window 显示文件
          (delete-other-windows)
          (find-file file)
          (my/sidebar-open)))))))

(defun my/sidebar--main-window ()
  "Return the main editing window (non-sidebar), or nil if only sidebar exists."
  (let ((sb-buf (current-buffer)))
    (or (car (seq-filter
              (lambda (w)
                (and (not (eq (window-buffer w) sb-buf))
                     (not (window-dedicated-p w))
                     ;; 排除 side windows (我们的 sidebar 是 left side window)
                     (not (eq 'left (window-parameter w 'window-side)))))
              (window-list)))
        nil)))

(defun my/sidebar--setup-keys ()
  "Bind RET/mouse-2 in sidebar buffer for DWIM open."
  (local-set-key (kbd "RET") #'my/sidebar--file-dwim)
  (local-set-key (kbd "<mouse-2>") #'my/sidebar--file-dwim))

(provide 'my-sidebar)
;;; my-sidebar.el ends here
