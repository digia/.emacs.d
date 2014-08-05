;; El-Get
(unless (require 'el-get nil 'noerror)
  (with-current-buffer
      (url-retrieve-synchronously
       "https://raw.github.com/dimitri/el-get/master/el-get-install.el")
    (goto-char (point-max))
    (eval-print-last-sexp)))

;; Add package archives sources
(setq package-archives '(("gnu" . "http://elpa.gnu.org/packages/")
                         ("marmalade" . "http://marmalade-repo.org/packages/")
                         ("melpa" . "http://melpa.milkbox.net/packages/")
                         ("org" . "http://orgmode.org/elpa/")
                         ("melpa" . "http://melpa.milkbox.net/packages/")))

(require 'package)
(package-initialize)

;; Configure El-Get
(add-to-list 'el-get-recipe-path "~/.emacs.d/recipe")
(setq 
 el-get-verbose t
 el-get-user-package-directory "~/.emacs.d/init"
 evil-want-C-u-scroll t
 my-packages '(evil-leader
               evil
               evil-surround
               evil-matchit
               ibuffer-vc
               fiplr
               auto-complete
               dash ;; Required for solarized-emacs
               solarized-emacs
               fill-column-indicator
               php-mode-improved
               php-completion
               web-mode
               css-mode
               scss-mode
               emmet-mode)) 

(provide 'bootstrap)
