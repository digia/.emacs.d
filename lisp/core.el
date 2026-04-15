;;; core.el --- Editor options -*- lexical-binding: t; -*-

;; All built-in settings. No external packages.
;; Mirrors ~/Code/digia/nvim/lua/digia/options.lua

;;; Encoding
(set-language-environment "UTF-8")
(prefer-coding-system 'utf-8)
(set-default-coding-systems 'utf-8)

;;; Local variables — apply safe ones silently, ignore risky
;; Prevents prompts from package README.org files (e.g. org-super-agenda)
(setq enable-local-variables :safe)

;;; Line numbers — relative, only in code/text buffers
(setq display-line-numbers-type 'relative)
(add-hook 'prog-mode-hook #'display-line-numbers-mode)
(add-hook 'text-mode-hook #'display-line-numbers-mode)

;;; Indentation
(setq-default tab-width 4)
(setq-default indent-tabs-mode nil)

;;; No line wrapping
(setq-default truncate-lines t)

;;; No backup/swap/lock files
(setq make-backup-files nil)
(setq auto-save-default nil)
(setq create-lockfiles nil)

;;; Scroll behavior — matches scrolloff=5, sidescrolloff=5
(setq scroll-margin 5)
(setq hscroll-margin 5)
(setq hscroll-step 1) ;; single-column scroll (Neovim default) vs Emacs recentering

;;; Cursor line highlight
(global-hl-line-mode 1)

;;; Fill column indicator at 80
(setq-default fill-column 80)
(global-display-fill-column-indicator-mode 1)

;;; Show trailing whitespace in code/text buffers
;; TODO: Circle back — replace background highlight with middot (·) in comment color
;;       to match Neovim trail:· (whitespace-mode space-mark affects all spaces, not just trailing)
(setq-default show-trailing-whitespace nil)
(add-hook 'prog-mode-hook (lambda () (setq show-trailing-whitespace t)))
(add-hook 'text-mode-hook (lambda () (setq show-trailing-whitespace t)))

;;; Grep — use ripgrep
(setq grep-program "rg")
(setq grep-command "rg -nH --no-heading -e ")
(setq grep-find-command '("rg -nH --no-heading -e '' ." . 27))

;;; Smooth scroll — GUI only (no-op in terminal)
;; (when (display-graphic-p)
;;   (pixel-scroll-precision-mode 1))

;;; UX improvements
(setq use-short-answers t)
(setq ring-bell-function 'ignore)
(setq inhibit-startup-screen t)
(setq inhibit-startup-echo-area-message user-login-name)

;;; Mouse support in terminal
(xterm-mouse-mode 1)
(global-set-key (kbd "<wheel-down>") #'scroll-up-line)
(global-set-key (kbd "<wheel-up>") #'scroll-down-line)

;;; Auto-revert buffers on external file changes
(global-auto-revert-mode 1)
(setq auto-revert-avoid-polling t)

;;; Recent files
(use-package recentf :ensure nil
  :config
  (setq recentf-max-saved-items 200)
  (recentf-mode 1))

;;; Command history persistence
(use-package savehist :ensure nil
  :config
  (savehist-mode 1))

;;; Paren matching
(use-package paren :ensure nil
  :config
  (setq show-paren-delay 0)
  (show-paren-mode 1))

;;; Column number in mode line
(column-number-mode 1)

;;; System clipboard integration for terminal Emacs on macOS
;; Every kill/yank syncs with the system clipboard via pbcopy/pbpaste
(when (and (eq system-type 'darwin)
           (not (display-graphic-p)))
  (setq interprogram-cut-function
        (lambda (text &optional _push)
          (let ((process-connection-type nil))
            (let ((proc (start-process "pbcopy" nil "pbcopy")))
              (process-send-string proc text)
              (process-send-eof proc)))))
  (setq interprogram-paste-function
        (lambda ()
          (shell-command-to-string "pbpaste"))))

;;; Repeat mode — repeat multi-key sequences with single key
(repeat-mode 1)

(provide 'core)
;;; core.el ends here
