;;; config-preview-gui.el --- GUI rich preview defaults -*- lexical-binding: t; -*-
;; 加载顺序: config-gui 之后; DWIM 命令定义在 my-display.el

;; 浏览器预览用系统默认 handler
(setq browse-url-browser-function #'browse-url-default-browser)

(provide 'config-preview-gui)
;;; config-preview-gui.el ends here
