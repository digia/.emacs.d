;;; tools.el --- Utilities -*- lexical-binding: t; -*-

;; vterm, undo-fu-session, auto-mkdir, and misc tools.
;; evil-collection unimpaired is initialized in evil-setup.el.

;;; vterm — terminal emulator for Claude Code CLI
(use-package vterm
  :commands vterm
  :config
  (setq vterm-max-scrollback 10000
        vterm-timer-delay 0.01)
  ;; Terminal-mode window navigation (C-h/C-l only, matching Neovim keymaps.lua)
  (setq vterm-keymap-exceptions
        (append vterm-keymap-exceptions '("C-h" "C-l")))
  (define-key vterm-mode-map (kbd "C-h") #'evil-window-left)
  (define-key vterm-mode-map (kbd "C-l") #'evil-window-right))

;;; undo-fu-session — persistent undo across sessions (replaces Neovim undofile)
(use-package undo-fu-session
  :demand t
  :config
  (undo-fu-session-global-mode 1))

;;; Auto-create parent directories on save (mirrors vim-automkdir)
(add-hook 'before-save-hook
          (lambda ()
            (when buffer-file-name
              (let ((dir (file-name-directory buffer-file-name)))
                (when (and dir (not (file-exists-p dir)))
                  (make-directory dir t))))))

;;; Markdown
(use-package markdown-mode
  :mode (("\\.md\\'" . markdown-mode)
         ("\\.markdown\\'" . markdown-mode))
  :custom
  (markdown-fontify-code-blocks-natively t))

;;; Terraform / HCL
(use-package terraform-mode
  :mode ("\\.tf\\'" "\\.tfvars\\'"))

;;; Kubernetes
(use-package kubel
  :commands kubel)
(use-package kubel-evil
  :after kubel)

;; Note: evil-collection unimpaired (initialized in evil-setup.el) provides:
;;   [SPC / ]SPC — blank lines above/below
;;   [e / ]e     — move line up/down
;;   [b / ]b     — previous/next buffer
;;   [l / ]l     — previous/next error (flymake)
;;   [n / ]n     — previous/next conflict marker
;;
;; Stage 2 conflict: [e/]e is move-text in unimpaired but diagnostic-error
;; navigation in the Neovim LSP config. Will need resolution when adding LSP.

(provide 'tools)
;;; tools.el ends here
