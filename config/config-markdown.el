;;; config-markdown.el --- Minimal Markdown configuration  -*- lexical-binding: t; -*-

;; ============================================
;; 1. markdown-mode 基础
;; ============================================
;; 用 markdown-mode 自带的 markdown-view-mode 做 TUI 渲染
;; 切换: M-x markdown-view-mode (或 M-x gfm-view-mode)
;; 退出: 同样命令再按一次

(use-package markdown-mode
  :ensure t
  :mode (("\\.md\\'"       . markdown-mode)
         ("\\.markdown\\'" . markdown-mode))
  :init
  ;; 有 pandoc 就用 (用于 export), 没有也能编辑/查看
  (when (executable-find "pandoc")
    (setq markdown-command "pandoc -f gfm -t html5 --standalone"))
  :hook
  (markdown-mode . (lambda ()
                     "Markdown 打开时的本地设置。"
                     (visual-line-mode 1)))
  :config
  ;; ============================================
  ;; 编辑期增强
  ;; ============================================

  ;; 代码块原生高亮 (```python ... ```)
  (setq markdown-fontify-code-blocks-natively t
        ;; 折行: visual-line-mode 已在 hook 里开
        markdown-list-indent-width 2
        markdown-electric-pair-angles t
        ;; 隐藏 markup 标记 (打开 file 时看着干净)
        markdown-hide-markup t)

  ;; ============================================
  ;; TUI 渲染 (markdown-mode 自带, 无需 pandoc)
  ;; ============================================
  ;; markdown-view-mode / gfm-view-mode 是 read-only 渲染视图
  ;;   n / p / f / b / u   跳转标题
  ;;   SPC / DEL           滚动
  ;;   q                   退出 view 模式
  ;; 在 TUI 下直接用 Emacs 的 font-lock + 隐藏 markup, 不需要外部工具

  ;; ============================================
  ;; 键绑定 — 只覆盖导出/查看, 不抢 C-c C-c (view-mode 默认)
  ;; ============================================

  (define-key markdown-mode-map (kbd "C-c C-p") #'my/markdown-preview-dwim)
  (define-key markdown-mode-map (kbd "C-c C-e") #'markdown-export)
  (define-key markdown-mode-map (kbd "C-c C-d") #'my/markdown-send-to-agent))

;; ============================================
;; 2. Markdown lint (Phase 2 — flymake + markdownlint-cli)
;; ============================================
;; 依赖: brew install markdownlint-cli  (或 npm i -g markdownlint-cli)
;; 未安装时静默跳过, 不影响编辑.

(use-package flymake-markdownlint
  :ensure t
  :defer t
  :when (executable-find "markdownlint")
  :hook (markdown-mode . flymake-markdownlint-setup)
  :config
  (add-hook 'markdown-mode-hook #'flymake-mode 90))

;; ============================================
;; Tree-sitter 增强 (Emacs 30+)
;; ============================================

(when (and (>= emacs-major-version 30)
           (fboundp 'treesit-ready-p)
           (treesit-ready-p 'markdown t))
  (add-to-list 'major-mode-remap-alist '(markdown-mode . markdown-ts-mode)))

(provide 'config-markdown)
;;; config-markdown.el ends here
