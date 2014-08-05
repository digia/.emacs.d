(global-evil-leader-mode t)

(evil-leader/set-leader ",")

(evil-leader/set-key
  "b" 'ibuffer
  "f" 'fiplr-find-file
  "s" '(lambda ()
         (interactive)
         (split-window-horizontally)
         (switch-to-buffer "*scratch*")
         (balance-windows))
  "gs" 'magit-status)
