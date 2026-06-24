;;; my-sidebar.el --- Project-scoped dired sidebar (replaces treemacs)  -*- lexical-binding: t; -*-

;; 一个轻量项目作用域文件树: 基于 dired + project.el, 0 外部依赖.
;;
;; 设计目标:
;;   - 跟 project.el 深度集成: 跟随 (my/project-root), 切项目自动换 buffer
;;   - sidebar 按需显示: 不挡视野, 不抢 M-o / winner-undo
;;   - 保持 dired 经典交互: RET 进入, n/p 上/下文件, + 新建, d 删除, g 刷新
;;   - TUI/GUI 同样工作: 不用 nerd-icons, 用 dired 颜色 (diredfl) 或 Emacs 自带

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
         (existing (my/sidebar--find-buffer root)))
    (cond
     ;; Sidebar 已在显示: 切到它的窗口
     ((and existing (get-buffer-window existing))
      (select-window (get-buffer-window existing)))
     ;; Sidebar buffer 存在但窗口已关: 重开 + 复用 buffer
     (existing
      (my/sidebar--display existing))
     ;; 全新 sidebar: 用 find-file-noselect 触发 dired-mode (绕过 dired-noselect 的 ~ 缩写 bug)
     (t
      (let* ((buf (find-file-noselect root))
             (dired-listing-switches my/sidebar-listing-switches))
        (with-current-buffer buf
          (setq buffer-undo-list t)
          (rename-buffer (my/sidebar--buffer-name root) t)
          (my/sidebar--register-buffer root buf))
        (my/sidebar--display buf))))))

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

(provide 'my-sidebar)
;;; my-sidebar.el ends here
