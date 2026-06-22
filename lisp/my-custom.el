;;; my-custom.el --- Personal customization group  -*- lexical-binding: t; -*-
;;;
;;; 用户通过 M-x customize-group my-config 一次性看/改所有 my/* 变量.
;;; init.el 已通过 (add-subdirs-to-load-path "lisp") 加载本目录.

(defgroup my-config nil
  "Personal Emacs configuration customizations."
  :group 'convenience
  :prefix "my/")

(provide 'my-custom)
;;; my-custom.el ends here