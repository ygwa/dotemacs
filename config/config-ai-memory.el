;;; config-ai-memory.el --- Project memory (.agent/memory.org)  -*- lexical-binding: t; -*-

(require 'config-ai-core)

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

(provide 'config-ai-memory)
;;; config-ai-memory.el ends here
