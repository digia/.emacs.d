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

;; Rename a file & its buffer - source: http://steve.yegge.googlepages.com/my-dot-emacs-file
(defun rename-file-and-buffer (new-name)
  "Renames both current buffer and file it's visiting to NEW-NAME."
  (interactive "sNew name: ")
  (let ((name (buffer-name))
        (filename (buffer-file-name)))
    (if (not filename)
        (message "Buffer '%s' is not visiting a file!" name)
      (if (get-buffer new-name)
          (message "A buffer named '%s' already exists!" new-name)
        (progn
          (rename-file name new-name 1)
          (rename-buffer new-name)
          (set-visited-file-name new-name)
          (set-buffer-modified-p nil))))))

(provide 'defuns)
