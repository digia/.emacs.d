;;; completion.el --- Vertico completion stack -*- lexical-binding: t; -*-

;; Replaces Telescope (~/Code/digia/nvim/lua/digia/plugin/telescope.lua)
;; Vertico + Orderless + Consult + Marginalia + Embark

;;; Vertico — vertical minibuffer completion
(use-package vertico
  :demand t
  :custom
  (vertico-cycle t)
  (vertico-resize nil)
  :config
  (vertico-mode 1)
  ;; C-c closes the minibuffer (standard terminal quit convention)
  (define-key vertico-map (kbd "C-c") #'abort-recursive-edit))

;;; Orderless — fuzzy/out-of-order matching
(use-package orderless
  :demand t
  :custom
  (completion-styles '(orderless basic))
  (completion-category-overrides '((file (styles basic partial-completion)))))

;;; Marginalia — rich annotations on candidates
(use-package marginalia
  :demand t
  :config
  (marginalia-mode 1))

;;; Consult — rich search commands (ripgrep, find, buffer, etc.)
(use-package consult
  :demand t
  :config
  (setq consult-preview-key 'any)      ;; live preview as you navigate (like Telescope)
  (setq consult-narrow-key "<"))       ;; filter by type in consult-buffer

;;; Embark — actions on candidates + export to buffer
(use-package embark
  :bind
  (("C-." . embark-act)
   ("C-;" . embark-dwim))
  :config
  (setq prefix-help-command #'embark-prefix-help-command))

;;; Embark-Consult — bridge between embark and consult
(use-package embark-consult
  :after (embark consult)
  :hook
  (embark-collect-mode . consult-preview-at-point-mode))

;;; Helper functions

(defun my/find-all-files ()
  "Find files including hidden and ignored (fd --hidden --no-ignore)."
  (interactive)
  (let ((consult-fd-args '("fd" "--hidden" "--no-ignore" "--exclude" ".git" "--type" "f")))
    (consult-fd)))

(defun my/consult-ripgrep-word ()
  "Search for word at point with ripgrep."
  (interactive)
  (consult-ripgrep nil (thing-at-point 'word)))

;;; Leader keybindings — mapped from telescope.lua

(my-leader-def
  ;; Buffer search
  "/" '(consult-line :which-key "search buffer")

  ;; File operations
  "f" '(:ignore t :which-key "find")
  "f /" '(consult-ripgrep :which-key "search workspace")
  "f p" '(project-find-file :which-key "find files")
  ;; "f p" '(consult-fd :which-key "find files (with preview)")
  "f P" '(my/find-all-files :which-key "find files (all)")
  "f g" '(consult-git-grep :which-key "find files (git)")
  "f r" '(consult-recent-file :which-key "recent files")

  ;; Search operations
  "s" '(:ignore t :which-key "search")
  "s r" '(consult-resume :which-key "resume")
  "s s" '(consult-imenu :which-key "document symbols")
  "s S" '(consult-imenu-multi :which-key "workspace symbols")
  "s b" '(consult-buffer :which-key "buffers")
  "s R" '(consult-register :which-key "registers")
  "s c" '(consult-history :which-key "command history")
  "s h" '(describe-symbol :which-key "help")
  "s j" '(consult-global-mark :which-key "jumplist")
  "s k" '(describe-bindings :which-key "keymaps")
  "s m" '(consult-mark :which-key "marks")
  "s M" '(consult-man :which-key "man pages")
  "s w" '(my/consult-ripgrep-word :which-key "word at point")

  ;; Git search (complements git.el leader bindings)
  "s g" '(:ignore t :which-key "git")
  "s g c" '(magit-log-all :which-key "git commits")
  "s g s" '(magit-status :which-key "git status"))

(provide 'completion)
;;; completion.el ends here
