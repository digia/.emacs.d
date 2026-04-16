;;; org-config.el --- Org-mode, org-roam, capture, agenda -*- lexical-binding: t; -*-

;; Org-mode second brain: org-roam for linked notes, org-capture for quick
;; entry, org-agenda + org-super-agenda for task management.
;;
;; Vault-agnostic — org-roam-directory is based on default-directory at
;; startup. Navigate to a brain directory before launching Emacs.

;;; Vault detection — only activate org-roam when CWD looks like a vault
;; Heuristic: directory has .org files in root or a daily/ subdirectory.
;; Prevents org-roam.db from being dropped in random directories.

(defvar my/org-vault-p
  (let ((dir (file-truename default-directory)))
    (or (file-directory-p (expand-file-name "daily" dir))
        (directory-files dir nil "\\.org$" t)))
  "Non-nil when the current directory appears to be an org-roam vault.")

;;; Helper functions

(defun my/org-daily-file ()
  "Return path to today's daily org file."
  (expand-file-name (format-time-string "daily/%Y-%m-%d.org")
                    org-roam-directory))

(defun my/org-inbox-file ()
  "Return path to inbox capture file."
  (expand-file-name "scratch/inbox.org" org-roam-directory))

(defun my/org-agenda-files-refresh (&rest _)
  "Refresh agenda files by scanning org-roam-directory recursively."
  (when (and (boundp 'org-roam-directory)
             (file-directory-p org-roam-directory))
    (setq org-agenda-files
          (directory-files-recursively org-roam-directory "\\.org$"))))

;;; Org-mode base (built-in)
(use-package org
  :ensure nil
  :defer t
  :custom
  (org-directory default-directory)
  (org-todo-keywords
   '((sequence "TODO(t)" "INPROGRESS(p!)" "WAITING(w@/!)" "|" "DONE(d!)" "CANCELLED(c@)")))
  (org-log-into-drawer "LOGBOOK")
  (org-log-done 'time)
  (org-startup-folded 'content)
  (org-startup-indented nil)
  (org-hide-emphasis-markers nil)
  (org-ellipsis " ▾")
  (org-return-follows-link t)
  (org-src-preserve-indentation t)
  (org-edit-src-content-indentation 0)
  ;; Babel — execute code blocks with C-c C-c. Confirm prompt disabled because
  ;; vault content is self-authored, not untrusted third-party files.
  (org-confirm-babel-evaluate nil)
  (org-agenda-skip-scheduled-if-done t)
  (org-agenda-skip-deadline-if-done t)
  (org-capture-templates
   '(("t" "TODO" entry (file my/org-daily-file)
      "* TODO %?\n" :empty-lines 1)
     ("n" "Note" entry (file my/org-inbox-file)
      "* %?\n%U\n" :empty-lines 1)
     ("m" "Meeting" entry (file my/org-daily-file)
      "* MEETING %?\n%U\n" :empty-lines 1)))
  (org-agenda-custom-commands
   '(("d" "Daily dashboard"
      ((agenda "" ((org-agenda-span 'day)
                   (org-super-agenda-groups
                    '((:name "Schedule" :time-grid t)
                      (:name "Due Today" :deadline today)
                      (:name "Overdue" :deadline past)
                      (:discard (:anything t))))))
       (todo "INPROGRESS" ((org-agenda-overriding-header "In Progress")))
       (todo "WAITING" ((org-agenda-overriding-header "Waiting")))))
     ("w" "Weekly review"
      ((agenda "" ((org-agenda-span 'week)))
       (alltodo "" ((org-agenda-overriding-header "All TODOs")
                    (org-super-agenda-groups
                     '((:name "High Priority" :priority "A")
                       (:name "In Progress" :todo "INPROGRESS")
                       (:name "Waiting" :todo "WAITING")
                       (:name "TODO" :todo "TODO")))))))
     ("t" "All TODOs"
      ((alltodo "" ((org-super-agenda-groups
                     '((:name "High Priority" :priority "A")
                       (:name "In Progress" :todo "INPROGRESS")
                       (:name "Waiting" :todo "WAITING")
                       (:name "TODO" :todo "TODO")))))))))
  :config
  (advice-add 'org-agenda :before #'my/org-agenda-files-refresh)
  ;; Languages available for babel execution (C-c C-c on a src block).
  ;; Built-in to org — no external packages needed.
  (org-babel-do-load-languages
   'org-babel-load-languages
   '((emacs-lisp . t)
     (shell . t)
     (python . t)
     (js . t)))
)

;;; org-roam — linked notes with per-vault database
;; Only configured when CWD looks like a vault (my/org-vault-p).
(when my/org-vault-p
  (use-package org-roam
    :custom
    (org-roam-directory (file-truename default-directory))
    (org-roam-db-location (expand-file-name "org-roam.db" (file-truename default-directory)))
    (org-roam-dailies-directory "daily/")
    (org-roam-dailies-capture-templates
     '(("d" "default" entry
        "* %?"
        :target (file+head "%<%Y-%m-%d>.org"
                            "#+title: %<%Y-%m-%d, %a - Daily>\n"))))
    :config
    (unless noninteractive
      (org-roam-db-autosync-mode))))

;;; org-super-agenda — grouped agenda views
(use-package org-super-agenda
  :after org
  :config
  (org-super-agenda-mode))

;;; Keybindings — SPC n (notes)
(my-leader-def
  "n" '(:ignore t :which-key "notes"))

(my-leader-def
  "n f" '(org-roam-node-find :which-key "find note")
  "n i" '(org-roam-node-insert :which-key "insert link")
  "n b" '(org-roam-buffer-toggle :which-key "backlinks")
  "n c" '(org-capture :which-key "capture")
  "n a" '(org-agenda :which-key "agenda")
  "n l" '(org-store-link :which-key "store link")
  "n t" '(org-todo :which-key "TODO cycle"))

;; TODO: Leader alternatives for C-c commands once muscle memory settles.
;; C-c C-c as "execute" clashes with the terminal C-c = abort instinct.
;; (my-leader-def
;;   "n x" '(org-babel-execute-src-block :which-key "execute block")
;;   "n e" '(org-export-dispatch :which-key "export"))

(my-leader-def
  "n d" '(:ignore t :which-key "dailies"))

(my-leader-def
  "n d t" '(org-roam-dailies-goto-today :which-key "today")
  "n d y" '(org-roam-dailies-goto-yesterday :which-key "yesterday")
  "n d d" '(org-roam-dailies-goto-date :which-key "pick date"))

;;; Reader mode — hide emphasis markers and raw links for distraction-free reading.
;; Default is markers visible (org-hide-emphasis-markers nil) for markdown-like
;; editing. Toggle into reader mode when you want clean rendered output.
(defun my/org-reader-mode ()
  "Toggle reader mode: hide/show emphasis markers and raw link URLs."
  (interactive)
  (if org-hide-emphasis-markers
      (progn
        (setq-local org-hide-emphasis-markers nil)
        (when org-link-descriptive (org-toggle-link-display))
        (font-lock-flush)
        (message "Reader mode: off"))
    (progn
      (setq-local org-hide-emphasis-markers t)
      (unless org-link-descriptive (org-toggle-link-display))
      (font-lock-flush)
      (message "Reader mode: on"))))

(my-leader-def
  :keymaps 'org-mode-map
  "r" '(:ignore t :which-key "render")
  "r p" '(my/org-reader-mode :which-key "reader mode"))

;;; Terminal key fixes for org-mode
;; evil-collection binds <tab> and <S-tab> (GUI function keys), but terminals
;; send TAB (C-i) and S-TAB which are different key events. Without these,
;; TAB falls through to evil-jump-forward and heading cycling breaks.
(evil-define-key 'normal org-mode-map
  (kbd "TAB") #'org-cycle
  (kbd "<backtab>") #'org-shifttab)

;; Evil binds RET → evil-ret (move down) in normal state, shadowing org's
;; link-following. Open links in a vertical split so C-h/C-l navigate between
;; source and target. Scoped — doesn't change split behavior elsewhere.
(defun my/org-open-at-point-vsplit ()
  "Follow org link at point in a vertical split."
  (interactive)
  (let ((org-link-frame-setup (cons '(file . find-file-other-window)
                                    org-link-frame-setup))
        (split-height-threshold nil)
        (split-width-threshold 0))
    (org-open-at-point)))

(evil-define-key 'normal org-mode-map (kbd "RET") #'my/org-open-at-point-vsplit)

;; org-capture opens in normal state — drop into insert so you can type
;; immediately. Finalize with ZZ, abort with q or C-c.
(add-hook 'org-capture-mode-hook #'evil-insert-state)

;;; Quit bindings for org contexts
;; org-agenda: native q → org-agenda-quit works now that Evil's q is unbound.
;; C-c as additional escape hatch (mirrors C-c → normal-state in insert mode).
(evil-define-key 'normal org-agenda-mode-map
  (kbd "C-c") #'org-agenda-quit)

;; org-capture: no native q binding, so add both q and C-c to abort.
(evil-define-key 'normal org-capture-mode-map
  "q" #'org-capture-kill
  (kbd "C-c") #'org-capture-kill)

(provide 'org-config)
;;; org-config.el ends here
