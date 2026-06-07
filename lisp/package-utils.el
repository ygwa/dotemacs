;;; package-utils.el --- Package management utilities
;;; 包管理工具函数

;;; Code:

;; 修复损坏的包（重新安装）
(defun fix-broken-package (package-name)
  "修复损坏的包（重新安装）
PACKAGE-NAME 是要修复的包名（字符串）"
  (let ((pkg-sym (intern package-name)))
    (when (package-installed-p pkg-sym)
      (let ((pkg-desc (cadr (assq pkg-sym package-alist))))
        (when pkg-desc
          (let ((pkg-dir (package-desc-dir pkg-desc)))
            (when (and pkg-dir (file-directory-p pkg-dir))
              (let ((autoloads-file (expand-file-name (format "%s-autoloads.el" package-name) pkg-dir)))
                (when (not (file-exists-p autoloads-file))
                  (message "检测到 %s 的 autoloads 文件缺失，尝试重新安装..." package-name)
                  (condition-case err
                      (progn
                        (package-delete pkg-desc)
                        (package-install pkg-sym))
                    (error (message "重新安装 %s 失败: %s" package-name err))))))))))))

;; 修复关键包（在后台异步执行，避免阻塞启动）
;; 注意：company 已被 Corfu 替代，ivy 已被 Vertico 替代
(defun fix-critical-packages ()
  "修复关键包（异步执行）"
  (when (>= emacs-major-version 30)
    (run-with-idle-timer
     2 nil  ; 2秒后执行
     (lambda ()
       ;; 只修复仍然使用的关键包
       (dolist (pkg '("queue"))
         (fix-broken-package pkg))))))

;; 检查系统工具是否安装
(defun check-system-tools ()
  "检查必需的系统工具是否安装
在 exec-path-from-shell 初始化后调用"
  ;; 检查工具（不重复初始化 exec-path-from-shell）
  (let ((tools '("rg" "ripgrep"))
        (found nil))
    (dolist (tool tools)
      (let ((path (executable-find tool)))
        (if path
            (progn
              (setq found t)
              (message "✓ 找到 %s: %s" tool path))
          (when (not found)
            (message "警告: 未找到 %s" tool)))))
    
    ;; 如果都没找到，提供通用包管理器安装建议
    (when (not found)
      (let ((install-hint
             (pcase system-type
               ('darwin "brew install ripgrep")
               ('gnu/linux (concat "apt install ripgrep"
                                   " / dnf install ripgrep"
                                   " / pacman -S ripgrep"))
               (_ "请参照系统文档安装 ripgrep"))))
        (message "提示: 未找到 ripgrep。安装方式: %s" install-hint)))))

(provide 'package-utils)

