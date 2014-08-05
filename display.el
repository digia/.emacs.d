;; Solarized theme
(add-to-list 'custom-theme-load-path "~/.emacs.d/el-get/emacs-color-theme-solarized")
(load-theme 'solarized-dark t)
;; Note: Setting the background color to a non-existant - in this case string nil - will display the correct BG color
(custom-set-faces  '(default ((t (:background "nil"))) t))
;; Note: "Black" is the magic color to fix the light blue bg color. This seems to be unique to iTerm2 and Emacs solarized
(set-face-foreground 'mode-line "black")
(set-face-background 'mode-line "blue")
(set-face-background 'hl-line "black")
(set-face-background 'linum "black") 
(set-default-font "Ubuntu Mono 13")

;; Tab
(setq-default
 indent-tabs-mode nil
 trucate-lines t
 tab-width 2)

;; UI configuration
(show-paren-mode 1) ;; Show open and close parens
(require 'fill-column-indicator)
(setq 
 fci-mode 1
 fci-rule-width 1
 fci-rule-column 80
 fci-rule-color "darkblue")
(global-hl-line-mode 1)
;; (set-face-background 'hl-line "blue")
(set-face-foreground 'highlight nil)

;; Line number 
(global-linum-mode 1)

(unless window-system
  (add-hook 'linum-before-numbering-hook
                (lambda ()
                        (setq-local linum-format-fmt
                                      (let ((w (length (number-to-string
                                                            (count-lines (point-min) (point-max))))))
                                            (concat "%" (number-to-string w) "d"))))))

(defun linum-format-func (line)
  (concat
   (propertize (format linum-format-fmt line) 'face 'linum)
   (propertize " " 'face 'mode-line)))

(unless window-system
  (setq linum-format 'linum-format-func))



;; Remove elements
(menu-bar-mode -1) ;; Remove the top menu

(provide 'display)
