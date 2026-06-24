;;; config-ai.el --- AI workbench: Agent OS layer (consolidated)  -*- lexical-binding: t; -*-
;;
;; 合并自 5 个旧文件, 按职责分 5 节:
;;   §1 Core        — .agent/ 目录, 专用 buffer, 日志
;;   §2 Review      — 本地 diff review workflow
;;   §3 PR Review   — GitHub PR (gh) & GitLab MR (glab)
;;   §4 Memory      — 项目 memory (.agent/memory.org) + decisions
;;   §5 Workbench   — 顶层 keymap, tools, profiles, Org task 编排
;;
;; 模块内调用通过显式函数引用, 不再跨文件 require.

;; ============================================
;; §1 Core — Agent OS 层基础设施
;; ============================================

(require 'my-project)

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

(defun my/ai-agent-dir (&optional root)
  "Return `.agent/' directory for ROOT or current project."
  (expand-file-name ".agent" (or root (my/project-root) default-directory)))

(defun my/ai-ensure-agent-dir (&optional root)
  "Create `.agent/' and standard subdirs; return directory path."
  (let* ((root (or root (my/project-root) default-directory))
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
  "Show CONTENT in BUFFER-NAME using MAJOR-MODE (default `my/markdown-activate')."
  (let ((buf (get-buffer-create buffer-name)))
    (with-current-buffer buf
      (let ((inhibit-read-only t))
        (erase-buffer)
        (insert content)
        (funcall (or major-mode #'my/markdown-activate))
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
  (let ((root (my/project-root)))
    (unless root
      (user-error "Not in a project"))
    (let ((default-directory root))
      (funcall fn))))

(add-hook 'org-capture-after-finalize-hook
          (lambda ()
            (when my/ai--post-capture-hook
              (funcall my/ai--post-capture-hook)
              (setq my/ai--post-capture-hook nil))))

;; ============================================
;; §2 Review — 本地 diff review workflow
;; ============================================

(defvar my/ai-review-mode-map
  (let ((map (make-sparse-keymap)))
    (define-key map (kbd "C-c C-w a") #'my/ai-send-active-to-agent)
    (define-key map (kbd "C-c C-w S") #'my/ai-review-save)
    map)
  "Keymap for `my/ai-review-mode'.")

(define-derived-mode my/ai-review-mode markdown-mode "AI-Review"
  "Major mode for *AI-Review* buffers."
  :group 'my-ai
  (setq buffer-read-only t)
  (use-local-map my/ai-review-mode-map))

(defun my/ai-review--local-diff-text ()
  "Return `git diff HEAD' text for current project."
  (my/ai-with-project-default-directory
   (lambda ()
     (require 'magit)
     (or (magit-git-string "diff" "HEAD")
         (user-error "No diff to review")))))

(defun my/ai-review-local ()
  "Collect local git diff into *AI-Review* (no preset prompt)."
  (interactive)
  (my/ai-bootstrap-project)
  (let* ((root (my/project-root))
         (diff (my/ai-review--local-diff-text))
         (content (format "# Local review\n\nProject: `%s`\n\n```diff\n%s\n```"
                          (file-name-nondirectory (directory-file-name root))
                          diff)))
    (with-current-buffer (my/ai-show-buffer my/ai--review-buffer content #'my/ai-review-mode)
      (put-text-property (point-min) (point-max) 'my/ai-review-source 'local))
    (my/ai-log "Local diff loaded into *AI-Review*")))

(defun my/ai-review-send-to-agent ()
  "Send *AI-Review* buffer to agent-shell."
  (interactive)
  (unless (get-buffer my/ai--review-buffer)
    (user-error "No *AI-Review* buffer"))
  (my/ai-send-buffer-to-agent my/ai--review-buffer)
  (my/ai-log "Sent *AI-Review* to agent"))

(defun my/ai-review-save ()
  "Save *AI-Review* buffer to `.agent/reviews/TIMESTAMP.review.md'."
  (interactive)
  (unless (get-buffer my/ai--review-buffer)
    (user-error "No *AI-Review* buffer"))
  (my/ai-bootstrap-project)
  (let ((file (expand-file-name
               (format-time-string "%Y-%m-%d-%H%M%S.review.md")
               (my/ai-agent-file "reviews"))))
    (with-current-buffer my/ai--review-buffer
      (write-region (point-min) (point-max) file nil nil nil t))
    (my/ai-log (format "Review saved: %s" file))
    (message "Review saved: %s" file)))

;; ============================================
;; §3 PR Review — GitHub (gh) & GitLab (glab)
;; ============================================

(defcustom my/ai-pr-list-limit 30
  "Max PR/MR entries to fetch from gh/glab."
  :type 'integer
  :group 'my-ai)

(defun my/ai--git-remote-url ()
  "Return origin URL for current project, or nil."
  (condition-case nil
      (my/ai-with-project-default-directory
       (lambda ()
         (require 'magit)
         (magit-get "remote.origin.url")))
    (error nil)))

(defun my/ai--forge-kind ()
  "Return `github', `gitlab', or nil from origin URL."
  (when-let ((url (my/ai--git-remote-url)))
    (cond
     ((or (string-match "github\\.com" url)
          (string-match "github:" url))
      'github)
     ((string-match "gitlab" url)
      'gitlab)
     (t nil))))

(defun my/ai--require-cmd (cmd)
  (or (executable-find cmd)
      (user-error "%s not found in PATH" cmd)))

(defun my/ai--shell-output (program &rest args)
  "Run PROGRAM with ARGS; return stdout or signal error."
  (with-temp-buffer
    (let ((status (apply #'call-process program nil t nil args)))
      (unless (zerop status)
        (user-error "Command failed (%s): %s %s\n%s"
                    status program (string-join args " ")
                    (buffer-string)))
      (buffer-string))))

(defun my/ai--completing-read-id (prompt items)
  "Pick (ID . TITLE) from ITEMS alist."
  (let* ((strings
          (mapcar (lambda (pair)
                    (format "%s  %s" (car pair) (cdr pair)))
                  items))
         (choice (completing-read prompt strings nil t)))
    (car (split-string choice "  " t))))

;; ---- GitHub (gh) ----

(defun my/ai--github-pr-list ()
  (my/ai--require-cmd "gh")
  (my/ai-with-project-default-directory
   (lambda ()
     (let ((out (my/ai--shell-output
                 "gh" "pr" "list"
                 "--limit" (number-to-string my/ai-pr-list-limit)
                 "--json" "number,title"
                 "--jq" ".[] | \"\\(.number)\\t\\(.title)\"")))
       (cl-loop for line in (split-string out "\n" t)
                when (string-match "\\`\\([^\\t]+\\)\\t\\(.+\\)\\'" line)
                collect (cons (match-string 1 line)
                              (match-string 2 line)))))))

(defun my/ai--github-pr-fetch (number)
  (my/ai--require-cmd "gh")
  (my/ai-with-project-default-directory
   (lambda ()
     (list
      (cons 'meta (my/ai--shell-output "gh" "pr" "view" number))
      (cons 'diff (my/ai--shell-output "gh" "pr" "diff" number))))))

(defun my/ai-pr-review-github ()
  "Review a GitHub PR via `gh' into *AI-Review*."
  (interactive)
  (my/ai-bootstrap-project)
  (my/ai-with-project-default-directory
   (lambda ()
     (let* ((items (my/ai--github-pr-list))
            (id (unless items (user-error "No open GitHub PRs"))
                  (my/ai--completing-read-id "GitHub PR: " items))
            (data (my/ai--github-pr-fetch id))
            (content (format "# GitHub PR %s\n\n%s\n\n---\n\n```diff\n%s\n```"
                             id (cdr (assq 'meta data)) (cdr (assq 'diff data)))))
       (with-current-buffer (my/ai-show-buffer my/ai--review-buffer content #'my/ai-review-mode)
         (put-text-property (point-min) (point-max)
                            'my/ai-review-source (list 'github id)))
       (my/ai-log (format "GitHub PR %s loaded" id))
       (message "GitHub PR %s → *AI-Review*" id)))))

;; ---- GitLab (glab) ----

(defun my/ai--gitlab-mr-list ()
  (my/ai--require-cmd "glab")
  (my/ai-with-project-default-directory
   (lambda ()
     (require 'json)
     (let ((raw (my/ai--shell-output
                 "glab" "mr" "list"
                 "--per-page" (number-to-string my/ai-pr-list-limit)
                 "--output" "json")))
       (cl-loop for obj in (json-read-from-string raw)
                collect (cons (number-to-string (alist-get 'iid obj))
                              (or (alist-get 'title obj) "")))))))

(defun my/ai--gitlab-mr-fetch (iid)
  (my/ai--require-cmd "glab")
  (my/ai-with-project-default-directory
   (lambda ()
     (list
      (cons 'meta (my/ai--shell-output "glab" "mr" "view" iid "--comments"))
      (cons 'diff (my/ai--shell-output "glab" "mr" "diff" iid))))))

(defun my/ai-pr-review-gitlab ()
  "Review a GitLab MR via `glab' into *AI-Review*."
  (interactive)
  (my/ai-bootstrap-project)
  (my/ai-with-project-default-directory
   (lambda ()
     (let* ((items (my/ai--gitlab-mr-list))
            (id (unless items (user-error "No open GitLab MRs"))
                  (my/ai--completing-read-id "GitLab MR: " items))
            (data (my/ai--gitlab-mr-fetch id))
            (content (format "# GitLab MR %s\n\n%s\n\n---\n\n```diff\n%s\n```"
                             id (cdr (assq 'meta data)) (cdr (assq 'diff data)))))
       (with-current-buffer (my/ai-show-buffer my/ai--review-buffer content #'my/ai-review-mode)
         (put-text-property (point-min) (point-max)
                            'my/ai-review-source (list 'gitlab id)))
       (my/ai-log (format "GitLab MR %s loaded" id))
       (message "GitLab MR %s → *AI-Review*" id)))))

(defun my/ai-pr-review ()
  "Review PR/MR: auto-detect forge or ask GitHub vs GitLab."
  (interactive)
  (my/ai-bootstrap-project)
  (let ((kind (my/ai--forge-kind))
        (has-gh (executable-find "gh"))
        (has-glab (executable-find "glab")))
    (cond
     ((and (eq kind 'github) has-gh)
      (my/ai-pr-review-github))
     ((and (eq kind 'gitlab) has-glab)
      (my/ai-pr-review-gitlab))
     ((and has-gh has-glab)
      (pcase (completing-read "Review: " '("GitHub PR" "GitLab MR") nil t)
        ("GitHub PR" (my/ai-pr-review-github))
        ("GitLab MR" (my/ai-pr-review-gitlab))))
     (has-gh (my/ai-pr-review-github))
     (has-glab (my/ai-pr-review-gitlab))
     (t (user-error "Install `gh' (GitHub) and/or `glab' (GitLab)")))))

(defun my/ai-pr-review-send-to-agent ()
  "Send *AI-Review* to agent; run `my/ai-pr-review' first if empty."
  (interactive)
  (if (and (get-buffer my/ai--review-buffer)
           (> (buffer-size (get-buffer my/ai--review-buffer)) 0))
      (my/ai-review-send-to-agent)
    (my/ai-pr-review)
    (when (get-buffer my/ai--review-buffer)
      (my/ai-review-send-to-agent))))

;; ============================================
;; §4 Memory — 项目 memory & ADR
;; ============================================

(defun my/ai-memory-open ()
  "Open `.agent/memory.org' for current project."
  (interactive)
  (my/ai-bootstrap-project)
  (find-file (my/ai-agent-file "memory.org")))

(defun my/ai-decisions-open ()
  "Open `.agent/decisions.org' for current project."
  (interactive)
  (my/ai-bootstrap-project)
  (find-file (my/ai-agent-file "decisions.org")))

(defun my/ai-memory-capture ()
  "Append a timestamped note to `.agent/memory.org'."
  (interactive)
  (my/ai-bootstrap-project)
  (let ((file (my/ai-agent-file "memory.org"))
        (note (read-string "Memory note: ")))
    (unless (string-empty-p (string-trim note))
      (with-current-buffer (find-file-noselect file)
        (goto-char (point-max))
        (insert (format "\n* %s %s\n  %s\n"
                        (format-time-string "<%F %T>")
                        (file-name-nondirectory (or buffer-file-name "note"))
                        note))
        (save-buffer))
      (my/ai-log (format "Memory captured: %s" note))
      (message "Appended to %s" file))))

(defun my/ai-memory-send-to-agent ()
  "Send `.agent/memory.org' and `decisions.org' excerpts to agent-shell."
  (interactive)
  (my/ai-bootstrap-project)
  (let ((parts nil))
    (dolist (file '("memory.org" "decisions.org"))
      (let ((path (my/ai-agent-file file)))
        (when (file-exists-p path)
          (push (format "## %s\n\n%s"
                         file
                         (with-temp-buffer
                           (insert-file-contents path)
                           (buffer-string)))
                parts))))
    (unless parts
      (user-error "No memory files in %s" (my/ai-agent-dir)))
    (require 'config-agent)
    (my/agent-shell-send-text (string-join (nreverse parts) "\n\n---\n\n") nil)
    (my/ai-log "Sent project memory to agent")))

;; ============================================
;; §5 Workbench — 顶层 keymap, tools, profiles, Org task
;; ============================================

(defun my/ai-profile-list ()
  "Return profile names available under `.agent/profiles/'."
  (my/ai-bootstrap-project)
  (let ((dir (my/ai-agent-file "profiles")))
    (mapcar #'file-name-base
            (directory-files dir "\\.md\\'" t))))

(defun my/ai-profile-load (name)
  "Return contents of profile NAME, or nil."
  (let ((file (my/ai-agent-file (format "profiles/%s.md" name))))
    (when (file-exists-p file)
      (with-temp-buffer
        (insert-file-contents file)
        (buffer-string)))))

(defun my/ai-start-with-profile (&optional profile)
  "Ensure agent-shell is open and insert PROFILE markdown (no submit)."
  (interactive
   (list (completing-read "Agent profile: " (my/ai-profile-list) nil t)))
  (my/ai-bootstrap-project)
  (let ((text (my/ai-profile-load profile)))
    (unless text
      (user-error "Profile not found: %s" profile))
    (require 'config-agent)
    (my/agent-shell-send-text (format "# Profile: %s\n\n%s" profile text) nil)
    (my/ai-log (format "Loaded profile: %s" profile))
    (message "Profile %s → agent input" profile)))

;; ---- Org + AI task ----

(defun my/ai--org-subtree-text ()
  "Return Org subtree at point as string."
  (org-back-to-heading t)
  (let ((beg (point))
        (end (org-entry-end-position)))
    (buffer-substring-no-properties beg end)))

(defun my/ai-plan-from-org ()
  "Show Org heading subtree in *AI-Plan* and optionally send to agent."
  (interactive)
  (unless (derived-mode-p 'org-mode)
    (user-error "Must be in Org mode"))
  (unless (org-at-heading-p)
    (user-error "Point must be at an Org heading"))
  (my/ai-bootstrap-project)
  (let ((text (my/ai--org-subtree-text)))
    (with-current-buffer (my/ai-show-buffer my/ai--plan-buffer text nil)
      (read-only-mode 1))
    (my/ai-log "Org task loaded into *AI-Plan*")
    (message "Task → *AI-Plan* (C-c C-w a to send to agent)")))

(defun my/ai-plan-send-to-agent ()
  "Send *AI-Plan* buffer to agent-shell."
  (interactive)
  (unless (get-buffer my/ai--plan-buffer)
    (user-error "No *AI-Plan* buffer; use C-c C-w p first"))
  (my/ai-send-buffer-to-agent my/ai--plan-buffer)
  (my/ai-log "Sent *AI-Plan* to agent"))

(defun my/ai-send-active-to-agent ()
  "Send *AI-Review* or *AI-Plan* buffer to agent-shell."
  (interactive)
  (cond
   ((and (get-buffer my/ai--review-buffer)
         (> (buffer-size (get-buffer my/ai--review-buffer)) 0))
    (my/ai-review-send-to-agent))
   ((and (get-buffer my/ai--plan-buffer)
         (> (buffer-size (get-buffer my/ai--plan-buffer)) 0))
    (my/ai-plan-send-to-agent))
   (t (user-error "Open *AI-Review* (C-c C-w r/g) or *AI-Plan* (C-c C-w p) first"))))

(defun my/ai-new-task ()
  "Capture AI Org task, open workbench layout, then show agent."
  (interactive)
  (my/ai-bootstrap-project)
  (require 'config-workflow)
  (my/workflow-layout)
  (setq my/ai--post-capture-hook
        (lambda ()
          (my/ai-log "AI task captured")
          (require 'agent-shell)
          (agent-shell-toggle)))
  (org-capture nil "a"))

;; ---- Tool registry ----

(defvar my/ai-tool-registry
  '(("git-diff" . my/ai-tool--git-diff)
    ("git-log" . my/ai-tool--git-log)
    ("search-code" . my/ai-tool--search-code)
    ("run-shell" . my/ai-tool--run-shell)
    ("open-memory" . my/ai-tool--open-memory))
  "Agent tool name → function mapping.")

(defun my/ai-tool--git-diff ()
  (my/ai-review--local-diff-text))

(defun my/ai-tool--git-log ()
  (my/ai-with-project-default-directory
   (lambda ()
     (require 'magit)
     (magit-git-string "log" "--oneline" "-n" "20"))))

(defun my/ai-tool--search-code (pattern)
  (unless pattern
    (setq pattern (read-string "Search pattern: ")))
  (my/ai-with-project-default-directory
   (lambda ()
     (if (executable-find "rg")
         (shell-command-to-string (format "rg -n --no-heading %s" (shell-quote-argument pattern)))
       (require 'magit)
       (magit-git-string "grep" "-n" pattern)))))

(defun my/ai-tool--run-shell (command)
  (unless command
    (setq command (read-shell-command "Run in project: ")))
  (unless (y-or-n-p (format "Run in project root? %s" command))
    (user-error "Cancelled"))
  (my/ai-with-project-default-directory
   (lambda ()
     (shell-command-to-string command))))

(defun my/ai-tool--open-memory ()
  (with-temp-buffer
    (insert-file-contents (my/ai-agent-file "memory.org"))
    (buffer-string)))

(defun my/ai-tool-run (tool &optional arg)
  "Run registered TOOL; show result in *AI-Log* and offer send to agent."
  (interactive
   (list (completing-read "AI tool: "
                          (mapcar #'car my/ai-tool-registry)
                          nil t)
         nil))
  (let* ((fn (cdr (assoc-string tool my/ai-tool-registry)))
         (result (if arg (funcall fn arg) (funcall fn))))
    (when (and (stringp result) (not (string-empty-p result)))
      (my/ai-log (format "Tool %s (%d chars)" tool (length result)))
      (my/ai-show-buffer my/ai--log-buffer
                         (format "# Tool: %s\n\n```\n%s\n```" tool result)
                         #'markdown-mode)
      (when (y-or-n-p "Send tool output to agent? ")
        (require 'config-agent)
        (my/agent-shell-send-text result nil)))))

;; ---- Workbench keymap (C-c C-w) ----

(defvar my/ai-workbench-map
  (let ((map (make-sparse-keymap "AI-Workbench")))
    (define-key map (kbd "n") #'my/ai-new-task)
    (define-key map (kbd "p") #'my/ai-plan-from-org)
    (define-key map (kbd "a") #'my/ai-send-active-to-agent)
    (define-key map (kbd "r") #'my/ai-review-local)
    (define-key map (kbd "R") #'my/ai-review-send-to-agent)
    (define-key map (kbd "S") #'my/ai-review-save)
    (define-key map (kbd "g") #'my/ai-pr-review)
    (define-key map (kbd "h") #'my/ai-pr-review-github)
    (define-key map (kbd "L") #'my/ai-pr-review-gitlab)
    (define-key map (kbd "G") #'my/ai-pr-review-send-to-agent)
    (define-key map (kbd "l") #'my/ai-log-show)
    (define-key map (kbd "P") #'my/ai-start-with-profile)
    (define-key map (kbd "M") #'my/ai-memory-capture)
    (define-key map (kbd "m") #'my/ai-memory-send-to-agent)
    (define-key map (kbd "o") #'my/ai-memory-open)
    (define-key map (kbd "d") #'my/ai-decisions-open)
    (define-key map (kbd "t") #'my/ai-tool-run)
    (define-key map (kbd "?") (lambda ()
                                (interactive)
                                (describe-buffer)))
    map)
  "AI workbench prefix (`C-c C-w').")

(defun my/ai-log-show ()
  "Show *AI-Log* buffer."
  (interactive)
  (display-buffer (get-buffer-create my/ai--log-buffer)
                  '((display-buffer-reuse-window display-buffer-in-side-window)
                    (side . bottom) (slot . 0) (window-height . 0.25))))

(global-set-key (kbd "C-c C-w") my/ai-workbench-map)

(with-eval-after-load 'embark
  (add-to-list 'embark-general-alt-commands
               '(my/ai-review-local . "AI review local diff"))
  (add-to-list 'embark-general-alt-commands
               '(my/ai-pr-review . "AI review PR/MR (gh/glab)")))

(when (fboundp 'my/markdown-setup-keys)
  (my/markdown-setup-keys))

(provide 'config-ai)
;;; config-ai.el ends here
