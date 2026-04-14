;;; git.el --- Git integration -*- lexical-binding: t; -*-

;; Mirrors ~/Code/digia/nvim/lua/digia/plugin/git.lua
;; Magit (replaces vim-fugitive) + diff-hl (replaces gitsigns.nvim)

;;; Transient — Emacs 30 ships 0.7.x but magit requires >= 0.12
(use-package transient)

;;; Magit
(use-package magit
  :commands (magit-status magit-blame-addition magit-log-current
             magit-diff-dwim magit-commit magit-push-current
             magit-log-all)
  :config
  (setq magit-display-buffer-function
        #'magit-display-buffer-same-window-except-diff-v1))

;;; diff-hl — fringe indicators for git changes
(use-package diff-hl
  :demand t
  :config
  (global-diff-hl-mode 1)
  (add-hook 'magit-pre-refresh-hook #'diff-hl-magit-pre-refresh)
  (add-hook 'magit-post-refresh-hook #'diff-hl-magit-post-refresh)
  ;; Hunk navigation — ]g / [g (matches gitsigns.nvim)
  (evil-define-key 'normal 'global
    "]g" #'diff-hl-next-hunk
    "[g" #'diff-hl-previous-hunk))

;;; Leader keybindings — from git.lua
(my-leader-def
  "g" '(:ignore t :which-key "git")
  "g s" '(magit-status :which-key "status")
  "g b" '(magit-blame-addition :which-key "blame")
  "g l" '(magit-log-current :which-key "log")
  "g d" '(magit-diff-dwim :which-key "diff")
  "g c" '(magit-commit :which-key "commit")
  "g p" '(magit-push-current :which-key "push"))

(provide 'git)
;;; git.el ends here
