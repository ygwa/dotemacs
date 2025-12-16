;;; init.el --- Main initialization file for Emacs 30.2
;;; 主初始化文件

;; 添加自定义函数目录到加载路径
(add-to-list 'load-path (expand-file-name "lisp" user-emacs-directory))

;; 加载初始化工具函数（如果失败，使用备用方法）
(condition-case err
    (require 'init-utils)
  (error
   ;; 备用方法：直接定义函数
   (defun add-config-path (subdir)
     (add-to-list 'load-path (expand-file-name subdir user-emacs-directory)))))

;; 添加配置目录到加载路径
(add-config-path "config")

;; 配置包源（必须在 package-initialize 之前）
(require 'package)

;; 使用 HTTPS 包源（Emacs 30 推荐）
;; 添加官方和镜像源以确保包可用性
;; 注意：包源顺序很重要，MELPA 应该在前
(setq package-archives '(("melpa"     . "https://melpa.org/packages/")
                         ("nongnu"    . "https://elpa.nongnu.org/nongnu/")
                         ("gnu"       . "https://elpa.gnu.org/packages/")
                         ("org"       . "https://orgmode.org/elpa/")
                         ("melpa-cn"  . "https://elpa.emacs-china.org/melpa/")))

;; 初始化包管理器
(package-initialize)

;; Emacs 30: 确保包列表已加载（如果为空则刷新）
(when (not package-archive-contents)
  (message "包列表为空，建议手动执行: M-x package-refresh-contents"))

;; 确保 use-package 已安装
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

;; 确保 use-package 已加载
(require 'use-package)

;; Emacs 30: 配置 use-package 以自动安装缺失的包
(setq use-package-always-ensure t)

;; 加载包管理工具函数（如果失败，使用备用方法）
(condition-case err
    (require 'package-utils)
  (error
   ;; 备用方法：直接定义关键函数
   (defun fix-critical-packages ()
     (when (>= emacs-major-version 30)
       (run-with-idle-timer
        2 nil
        (lambda ()
          ;; 注意：company 已被 Corfu 替代，ivy 已被 Vertico 替代
          (dolist (pkg '("queue"))
            (when (package-installed-p (intern pkg))
              nil))))))
   (defun check-system-tools ()
     (when (memq system-type '(darwin mac))
       (let ((brew-path "/opt/homebrew/bin"))
         (when (file-directory-p brew-path)
           (add-to-list 'exec-path brew-path)
           (setenv "PATH" (concat brew-path ":" (or (getenv "PATH") "")))))))))

;; 修复关键包（在后台异步执行，避免阻塞启动）
(fix-critical-packages)

;; 检查系统工具（延迟执行，确保 exec-path-from-shell 已初始化）
(when (>= emacs-major-version 30)
  (run-with-idle-timer 3 nil 'check-system-tools))

;; 加载配置文件
(require 'config-default)
(require 'config-gui)
(require 'config-org)
(require 'config-hugo)
(require 'config-package)

;; Emacs 30: 性能优化配置
;; 启用垃圾回收优化（在 early-init.el 中已设置初始值）
(when (>= emacs-major-version 30)
  (setq read-process-output-max (* 1024 1024)) ; 1MB，提升子进程输出性能
  ;; 延迟垃圾回收，提升启动速度
  (add-hook 'after-init-hook
            (lambda ()
              (setq gc-cons-threshold (* 100 1024 1024))))) ; 100MB

;; 加载自定义文件
(when (file-exists-p custom-file)
  (load custom-file))

;;; init.el ends here
