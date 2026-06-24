;;; config-vcs.el --- VCS: project, magit, eat, git review (diff-hl/delta/forge)  -*- lexical-binding: t; -*-
;;
;; 合并自 config-vcs-terminal + config-git-review.
;; 按职责分 3 节:
;;   §1 Project / recentf — project.el 内置 + recentf
;;   §2 Magit / Eat       — git + 项目作用域终端
;;   §3 Git review        — diff-hl / magit-delta / forge (默认开, 无 feature flag)
;;
;; 注: 原 `git-review' feature flag 已废弃. diff-hl / delta / forge 都是
;; `:after magit :defer t', 不增加启动开销, 但仍然依赖外部二进制 (delta/gh/glab).

;; ============================================
;; §1 Project / recentf
;; ============================================

(recentf-mode 1)
(setq recentf-max-saved-items 512)

(use-package project
  :ensure nil
  :bind (("C-c p b" . project-switch-to-buffer)
         ("C-c p d" . project-dired)
         ("C-c p v" . project-vc-dir))
  :config
  (setq project-vc-extra-root-markers
        '("package.json" "requirements.txt" ".project")))

(add-hook 'shell-mode-hook 'ansi-color-for-comint-mode-on)

(use-package rainbow-delimiters
  :ensure t
  :defer t
  :hook (prog-mode . rainbow-delimiters-mode)
  :init
  (add-hook 'emacs-lisp-mode-hook #'rainbow-mode))

;; ============================================
;; §2 Magit / Eat
;; ============================================

(use-package magit
  :ensure t
  :defer t
  :bind ("C-x g" . magit-status)
  :config
  (setq magit-push-always-verify nil
        magit-revert-buffers t))

(use-package git-timemachine
  :ensure t
  :defer t
  :bind (("C-c g t" . git-timemachine)))

(defun my/eat-toggle ()
  "Toggle Eat terminal for current project (show/hide project-scoped buffer)."
  (interactive)
  (require 'eat)
  (require 'project)
  (let* ((name (project-prefixed-buffer-name "eat"))
         (buf (get-buffer name)))
    (if (and buf (get-buffer-window buf))
        (delete-window (get-buffer-window buf))
      (eat-project))))

(use-package eat
  :ensure t
  :defer t
  :custom
  (eat-term-scrollback-size 10000)
  (eat-enable-directory-tracking t)
  :config
  (global-set-key (kbd "C-`") #'my/eat-toggle))

(with-eval-after-load 'project
  (define-key project-prefix-map (kbd "s") #'eat-project))

;; ============================================
;; §3 Git review — diff-hl, magit-delta, forge
;; ============================================

;; diff-hl — 编程 buffer 行内未提交改动标记
(use-package diff-hl
  :ensure t
  :defer t
  :hook (prog-mode . diff-hl-mode)
  :config
  (setq diff-hl-show-staged-only nil)
  (with-eval-after-load 'magit
    (add-hook 'magit-post-refresh-buffer-hook #'diff-hl-magit-post-refresh)))

;; magit-delta — 更可读的 Magit diff (需 delta 二进制)
(use-package magit-delta
  :ensure t
  :after magit
  :defer t
  :config
  (when (executable-find "delta")
    (add-hook 'magit-mode-hook #'magit-delta-mode)))

;; Forge — GitHub / GitLab PR & Issue (Magit 扩展)
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
;; 自托管 GitLab: `my/forge-extra-gitlab-instances' (M-x customize-group my-config)

(use-package forge
  :ensure t
  :after magit
  :defer t
  :config
  (setq forge-dispatch-post-prefix "-")
  (dolist (entry my/forge-extra-gitlab-instances)
    (add-to-list 'forge-alist entry)))

;; Magit → agent-shell 快捷键 (无 preset prompt)
;; C-c C-d 在当前 magit buffer 把 diff / commit 插入 agent 输入区
(with-eval-after-load 'magit
  (dolist (mode '(magit-status-mode magit-log-mode magit-diff-mode
                   magit-reflog-mode magit-revision-mode))
    (when-let ((map (symbol-value (intern-soft (format "%s-map" mode)))))
      (define-key map (kbd "C-c C-d") #'my/magit-send-diff-to-agent))))

(provide 'config-vcs)
;;; config-vcs.el ends here
