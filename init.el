;; Package management
(add-to-list 'load-path "~/.emacs.d")
(add-to-list 'load-path "~/.emacs.d/el-get/el-get")

(require 'defuns)
(require 'bootstrap)

;; UTF-8 Encoding
(prefer-coding-system       'utf-8)
(set-default-coding-systems 'utf-8)
(set-terminal-coding-system 'utf-8)
(set-keyboard-coding-system 'utf-8)

(define-key global-map (kbd "C-x p") 'switch-to-previous-buffer)

;; Set backup file location
(setq 
 backup-directory-alist `((".*" . "~/.emacs-tmp"))
 auto-save-file-name-transforms `((".*" "~/.emacs-tmp" t)))

;; better scrolling
(setq 
 scroll-conservatively 9999
 scroll-preserve-screen-position t)

;; NO BELL
(setq
 bell-volume 0
 ring-bell-function 'ignore)

;; No need for the initial splash screen
(setq 
 inhibit-splash-screen t
 inhibit-startup-echo-area-message t
 inhibit-startup-message t)

(xterm-mouse-mode t)

(el-get 'sync my-packages) ;; Load el-get packages
(require 'display)

;; Always ask for y/n keypress instead of typing out 'yes' or 'no'
(defalias 'yes-or-no-p 'y-or-n-p)

(require 'ido)
(ido-mode t)
