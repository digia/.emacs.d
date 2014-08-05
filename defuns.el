(defun open-init-file () 
  "Open default init file"
  (interactive)
  (find-file "~/.emacs.d/init.el") nil)

 (defun switch-to-previous-buffer ()
      (interactive)
      (switch-to-buffer (other-buffer (current-buffer) 1)))

(defun kill-current-buffer ()
  (interactive)
  (kill-buffer (current-buffer)))

(defun my-send-string-to-terminal (string)
    (unless (display-graphic-p) (send-string-to-terminal string)))

(provide 'defuns)
