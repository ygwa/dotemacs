;;; config-markdown.el --- Markdown editing and preview  -*- lexical-binding: t; -*-

;; ============================================
;; Markdown 编辑：语法高亮 + 渲染预览
;; ============================================

(use-package markdown-mode
  :ensure t
  :mode (("\\.md\\'" . markdown-mode)
         ("\\.markdown\\'" . markdown-mode)
         ;; 项目内的 SKILL.md, CHANGELOG.md 等也会自动匹配
         )
  :init
  ;; 使用 pandoc 渲染（支持 GFM 表格/任务列表/数学公式）
  (when (executable-find "pandoc")
    (setq markdown-command "pandoc -f gfm -t html5 --mathjax --standalone"))
  :hook
  (markdown-mode . my/markdown-setup)
  :config
  ;; ============================================
  ;; 语法高亮增强
  ;; ============================================

  ;; 代码块内部原生高亮（```python ... ``` 等）
  (setq markdown-fontify-code-blocks-natively t)

  ;; 标题使用不同字号显示（视觉层次更清晰）
  (setq markdown-header-scaling t)

  ;; 打开折叠支持
  (setq markdown-hide-markup t)

  ;; 列表缩进感知
  (setq markdown-list-indent-width 2)

  ;; 自动补全标记符号
  (setq markdown-electric-pair-angles t)

  ;; GFM 支持
  (setq markdown-enable-math t)
  (setq markdown-enable-html t)
  (setq markdown-enable-wiki-links t)

  ;; ============================================
  ;; 渲染预览（使用 pandoc + eww 内联浏览器）
  ;; ============================================

  (defun my/markdown-preview-eww ()
    "用 pandoc 将当前 Markdown 渲染为 HTML，在 eww 中预览。"
    (interactive)
    (let* ((input-file (buffer-file-name))
           (output-file (concat (file-name-sans-extension input-file)
                                "-preview.html"))
           (cmd (format "%s %s -o %s"
                        markdown-command
                        (shell-quote-argument input-file)
                        (shell-quote-argument output-file))))
      (shell-command cmd)
      (eww-open-file output-file)))

  ;; 启动时自动设置
  (defun my/markdown-setup ()
    "Markdown 打开时的本地设置。"
    ;; 折行显示
    (visual-line-mode 1)
    ;; 根据标题折叠大纲
    (outline-minor-mode 1))

  ;; ============================================
  ;; 键绑定
  ;; ============================================

  (define-key markdown-mode-map (kbd "C-c C-p") #'my/markdown-preview-eww)
  (define-key markdown-mode-map (kbd "C-c C-c") #'markdown-other-window)
  (define-key markdown-mode-map (kbd "M-RET")   #'markdown-insert-list-item))

;; ============================================
;; Tree-sitter 增强（Emacs 30+ 内置）
;; 如果有 markdown tree-sitter 语法，用 ts 模式补充
;; ============================================

(when (and (>= emacs-major-version 30)
           (treesit-ready-p 'markdown t))
  ;; markdown-ts-mode 提供更精确的语法高亮
  (add-to-list 'major-mode-remap-alist '(markdown-mode . markdown-ts-mode)))

(provide 'config-markdown)
;;; config-markdown.el ends here
