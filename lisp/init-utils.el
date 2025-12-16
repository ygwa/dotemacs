;;; init-utils.el --- Initialization utilities
;;; 初始化工具函数

;;; Code:

;; 添加配置目录到加载路径
(defun add-config-path (subdir)
  "添加配置子目录到加载路径
SUBDIR 是相对于 user-emacs-directory 的子目录"
  (add-to-list 'load-path (expand-file-name subdir user-emacs-directory)))

(provide 'init-utils)
