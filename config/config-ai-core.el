;;; config-ai-core.el --- AI workbench shared utilities  -*- lexical-binding: t; -*-

;; Agent OS 层基础设施: 项目 .agent/ 目录、专用 buffer、日志.
;; 不含 AI Context Engineering UI (按用户要求跳过).

(defgroup my-ai nil
  "AI workbench (Agent OS layer)."
  :group 'my-config
  :prefix "my/ai-")

(defconst my/ai--plan-buffer "*AI-Plan*"
  "Buffer for planner output / Org task view.")

(defconst my/ai--review-buffer "*AI-Review*"
  "Buffer for code / PR / MR review material.")

(defconst my/ai--log-buffer "*AI-Log*"
  "Buffer for workbench events (not agent chat transcript).")

(defvar my/ai--post-capture-hook nil
  "One-shot hook run after `org-capture' finalizes (used by `my/ai-new-task').")

(defun my/ai-project-root ()
  "Return expanded project root, or nil."
  (condition-case nil
      (or (and (fboundp 'project-current)
               (let ((proj (project-current)))
                 (when proj (expand-file-name (project-root proj)))))
          (vc-root-dir)
          (when (buffer-file-name)
            (locate-dominating-file (buffer-file-name ".git")))
          default-directory)
    (error nil)))

(defun my/ai-agent-dir (&optional root)
  "Return `.agent/' directory for ROOT or current project."
  (expand-file-name ".agent" (or root (my/ai-project-root) default-directory)))

(defun my/ai-ensure-agent-dir (&optional root)
  "Create `.agent/' and standard subdirs; return directory path."
  (let* ((root (or root (my/ai-project-root) default-directory))
         (dir (my/ai-agent-dir root)))
    (unless (file-directory-p dir)
      (make-directory dir t))
    (dolist (sub '(profiles reviews))
      (let ((path (expand-file-name sub dir)))
        (unless (file-directory-p path)
          (make-directory path t))))
    dir))

(defun my/ai-agent-file (name &optional root)
  "Path to NAME inside `.agent/'."
  (expand-file-name name (my/ai-ensure-agent-dir root)))

(defun my/ai--write-if-missing (file content)
  (unless (file-exists-p file)
    (with-temp-file file
      (insert content))))

(defun my/ai-bootstrap-project (&optional root)
  "Bootstrap `.agent/' templates for ROOT."
  (let ((dir (my/ai-ensure-agent-dir root)))
    (my/ai--write-if-missing
     (expand-file-name "memory.org" dir)
     "#+TITLE: Project Memory\n\n* Architecture decisions\n\n* Pitfalls and lessons\n\n* Notes\n")
    (my/ai--write-if-missing
     (expand-file-name "decisions.org" dir)
     "#+TITLE: Architecture Decision Records\n\n* ADR-001 Example\n  :PROPERTIES:\n  :STATUS:    proposed\n  :END:\n\n  Context:\n\n  Decision:\n\n  Consequences:\n")
    (my/ai--write-if-missing
     (expand-file-name "profiles/planner.md" dir)
     "# Planner\n\nAnalyze requirements, break down tasks, propose design.\nAvoid editing code unless asked.\n")
    (my/ai--write-if-missing
     (expand-file-name "profiles/coder.md" dir)
     "# Coder\n\nImplement changes in the codebase.\nPrefer minimal diffs and match project conventions.\n")
    (my/ai--write-if-missing
     (expand-file-name "profiles/reviewer.md" dir)
     "# Reviewer\n\nReview diffs for bugs, design, tests, and style.\nBe specific; cite file and line when possible.\n")
    dir))

(defun my/ai-log (message)
  "Append MESSAGE to `my/ai--log-buffer' with timestamp."
  (let ((buf (get-buffer-create my/ai--log-buffer)))
    (with-current-buffer buf
      (goto-char (point-max))
      (insert (format "[%s] %s\n"
                      (format-time-string "%F %T")
                      message))
      (when (> (buffer-size) 500000)
        (goto-char (point-min))
        (forward-line 200)
        (delete-region (point-min) (point))))))

(defun my/ai-show-buffer (buffer-name content &optional major-mode)
  "Show CONTENT in BUFFER-NAME using MAJOR-MODE (default `markdown-mode')."
  (let ((buf (get-buffer-create buffer-name)))
    (with-current-buffer buf
      (let ((inhibit-read-only t))
        (erase-buffer)
        (insert content)
        (when major-mode (funcall major-mode))
        (unless major-mode (require 'markdown-mode) (markdown-mode))
        (read-only-mode 1)
        (goto-char (point-min))))
    (display-buffer buf
                    '((display-buffer-reuse-window display-buffer-in-side-window)
                      (side . right) (slot . 2) (window-width . 0.4)))
    buf))

(defun my/ai-send-buffer-to-agent (buffer-name)
  "Insert contents of BUFFER-NAME into agent-shell (no auto submit)."
  (require 'config-agent)
  (with-current-buffer (get-buffer buffer-name)
    (my/agent-shell-send-text
     (buffer-substring-no-properties (point-min) (point-max))
     nil)))

(defun my/ai-with-project-default-directory (fn)
  "Run FN with `default-directory' at project root."
  (let ((root (my/ai-project-root)))
    (unless root
      (user-error "Not in a project"))
    (let ((default-directory root))
      (funcall fn))))

(add-hook 'org-capture-after-finalize-hook
          (lambda ()
            (when my/ai--post-capture-hook
              (funcall my/ai--post-capture-hook)
              (setq my/ai--post-capture-hook nil))))

(provide 'config-ai-core)
;;; config-ai-core.el ends here
