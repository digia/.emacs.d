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

(provide 'defuns)
