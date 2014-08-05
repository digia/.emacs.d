;; Package management
(add-to-list 'load-path "~/.emacs.d")
(add-to-list 'load-path "~/.emacs.d/el-get/el-get")

(require 'bootstrap)
(require 'defuns)

;; UTF-8 Encoding
(prefer-coding-system       'utf-8)
(set-default-coding-systems 'utf-8)
(set-terminal-coding-system 'utf-8)
(set-keyboard-coding-system 'utf-8)

(define-key global-map (kbd "C-x p") 'switch-to-previous-buffer)

;; Set backup file location
(setq 
 backup-directory-alist `((".*" . "~/.emacs-tmp"))
 auto-save-file-name-transforms `((".*" "~/.emacs-tmp" t))
 bell-volume 0
 ring-bell-function 'ignore)

(el-get 'sync my-packages) ;; Load el-get packages
(require 'display)

;; Always ask for y/n keypress instead of typing out 'yes' or 'no'
(defalias 'yes-or-no-p 'y-or-n-p)

(require 'ido)
(ido-mode t)
