;;; config-ai-pr-review.el --- GitHub PR (gh) & GitLab MR (glab) review  -*- lexical-binding: t; -*-

(require 'config-ai-core)
(require 'config-ai-review)

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

(provide 'config-ai-pr-review)
;;; config-ai-pr-review.el ends here
