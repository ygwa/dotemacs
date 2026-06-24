;;; config-ai-workbench.el --- Agent OS: tasks, profiles, tools, keys  -*- lexical-binding: t; -*-

(require 'config-ai-core)
(require 'config-ai-memory)
(require 'config-ai-review)
(require 'config-ai-pr-review)

;; ============================================
;; Agent profiles
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

;; ============================================
;; Org + AI task
;; ============================================

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
    (with-current-buffer (my/ai-show-buffer my/ai--plan-buffer text #'markdown-mode)
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

;; ============================================
;; Tool registry
;; ============================================

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

;; ============================================
;; Workbench keymap  (C-c C-w)
;; ============================================

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

(provide 'config-ai-workbench)
;;; config-ai-workbench.el ends here
