;;; config-ai-review.el --- Local diff review workflow  -*- lexical-binding: t; -*-

(require 'config-ai-core)

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

(provide 'config-ai-review)
;;; config-ai-review.el ends here
