;;; config-git-review.el --- Git review: diff-hl, delta, forge  -*- lexical-binding: t; -*-

;; Phase 1: diff-hl — 行内未提交改动标记
;; Phase 3: magit-delta + forge (GitHub / GitLab)

;; ============================================
;; 1. diff-hl — 编程 buffer 行内 diff 标记
;; ============================================

(use-package diff-hl
  :ensure t
  :defer t
  :hook (prog-mode . diff-hl-mode)
  :config
  (setq diff-hl-show-staged-only nil)
  (with-eval-after-load 'magit
    (add-hook 'magit-post-refresh-buffer-hook #'diff-hl-magit-post-refresh)))

;; ============================================
;; 2. magit-delta — 更可读的 Magit diff (需 delta 二进制)
;; ============================================

(use-package magit-delta
  :ensure t
  :after magit
  :defer t
  :config
  (when (executable-find "delta")
    (add-hook 'magit-mode-hook #'magit-delta-mode)))

;; ============================================
;; 3. Forge — GitHub / GitLab PR & Issue (Magit 扩展)
;; ============================================
;;
;; 首次 setup (一次性):
;;   GitHub:  git config --global github.user YOUR_USER
;;            ~/.authinfo: machine api.github.com login YOUR_USER^forge password TOKEN
;;   GitLab:  git config --global gitlab.user YOUR_USER
;;            ~/.authinfo: machine gitlab.com login YOUR_USER^forge password TOKEN
;;   自托管 GitLab: 填 my/forge-extra-gitlab-instances, 并
;;            git config --global gitlab.HOST.user YOUR_USER
;;            ~/.authinfo: machine HOST login YOUR_USER^forge password TOKEN
;;   然后在 magit-status 里 M-x forge-add-repository
;;
;; Magit 内入口: ' (forge-dispatch) 或 N (forge menu)

(defcustom my/forge-extra-gitlab-instances nil
  "自托管 GitLab 实例, 每项 (GITHOST APIHOST WEBHOST CLASS).
示例:
  ((\"gitlab.example.com\"
    \"gitlab.example.com/api/v4\"
    \"gitlab.example.com\"
    forge-gitlab-repository))"
  :type '(repeat (list string string string symbol))
  :group 'my-config)

(use-package forge
  :ensure t
  :after magit
  :defer t
  :config
  (setq forge-dispatch-post-prefix "-")
  (dolist (entry my/forge-extra-gitlab-instances)
    (add-to-list 'forge-alist entry)))

;; ============================================
;; 4. Magit → agent-shell 快捷键 (无 preset prompt)
;; ============================================
;; C-c C-d  在当前 magit buffer 把 diff / commit 插入 agent 输入区

(with-eval-after-load 'magit
  (dolist (mode '(magit-status-mode magit-log-mode magit-diff-mode
                   magit-reflog-mode magit-revision-mode))
    (when-let ((map (symbol-value (intern-soft (format "%s-map" mode)))))
      (define-key map (kbd "C-c C-d") #'my/magit-send-diff-to-agent))))

(provide 'config-git-review)
;;; config-git-review.el ends here
