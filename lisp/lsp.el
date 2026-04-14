;;; lsp.el --- LSP, completion, and diagnostics -*- lexical-binding: t; -*-

;; Eglot (built-in) for LSP, Corfu for in-buffer completion, Cape for
;; extra completion sources. Keybindings mirror ~/Code/digia/nvim/lua/digia/plugin/lsp.lua

;;; Eglot — built-in LSP client (Emacs 29+)
;; Language servers must be installed separately (e.g. gopls, pyright, ts_ls).
;; Eglot auto-detects them on PATH. Run M-x eglot to start manually,
;; or use the hooks below for automatic startup.
(use-package eglot :ensure nil
  :hook ((go-mode . eglot-ensure)
         (go-ts-mode . eglot-ensure)
         (python-mode . eglot-ensure)
         (python-ts-mode . eglot-ensure)
         (js-mode . eglot-ensure)
         (js-ts-mode . eglot-ensure)
         (typescript-mode . eglot-ensure)
         (typescript-ts-mode . eglot-ensure)
         (tsx-ts-mode . eglot-ensure)
         (rust-mode . eglot-ensure)
         (rust-ts-mode . eglot-ensure)
         (bash-ts-mode . eglot-ensure)
         (sh-mode . eglot-ensure)
         (css-mode . eglot-ensure)
         (html-mode . eglot-ensure)
         (json-mode . eglot-ensure)
         (json-ts-mode . eglot-ensure)
         (yaml-mode . eglot-ensure)
         (yaml-ts-mode . eglot-ensure)
         (dockerfile-mode . eglot-ensure)
         (dockerfile-ts-mode . eglot-ensure)
         (elixir-mode . eglot-ensure)
         (elixir-ts-mode . eglot-ensure)
         (terraform-mode . eglot-ensure))
  :config
  ;; Performance — don't log every LSP event
  (fset #'jsonrpc--log-event #'ignore)

  ;; Register terraform-ls for terraform-mode
  (add-to-list 'eglot-server-programs
               '(terraform-mode . ("terraform-ls" "serve")))

  ;; Eldoc — show hover docs in the echo area (single line, not intrusive)
  (setq eldoc-echo-area-use-multiline-p nil)

  ;; K — hover documentation at point
  ;; Shows in a dedicated buffer without stealing focus; press q to dismiss.
  (evil-define-key 'normal eglot-mode-map "K"
    (lambda ()
      (interactive)
      (if (eglot-managed-p)
          (eldoc-doc-buffer t)
        ;; Fallback to describe-symbol when no LSP is active
        (let ((sym (thing-at-point 'symbol)))
          (if sym
              (describe-symbol (intern sym))
            (call-interactively #'describe-symbol))))))

  ;; Diagnostic navigation — ]d/[d and ]e/[e
  (evil-define-key 'normal eglot-mode-map
    "]d" #'flymake-goto-next-error
    "[d" #'flymake-goto-prev-error
    "]e" (lambda () (interactive)
           (flymake-goto-next-error nil '(:error) t))
    "[e" (lambda () (interactive)
           (flymake-goto-prev-error nil '(:error) t))))

;;; Flymake — built-in diagnostics (used by Eglot)
(use-package flymake :ensure nil
  :hook (eglot-managed-mode . flymake-mode))

;;; Corfu — in-buffer completion popup
(use-package corfu
  :custom
  (corfu-auto t)           ;; auto-popup after typing
  (corfu-auto-delay 0.2)   ;; slight delay before popup
  (corfu-auto-prefix 2)    ;; popup after 2 characters
  (corfu-cycle t)           ;; cycle through candidates
  (corfu-preselect 'prompt) ;; don't preselect first candidate
  (corfu-quit-no-match 'separator)
  :config
  (global-corfu-mode 1)
  ;; TAB confirms selection (matches Neovim cmp config)
  (define-key corfu-map (kbd "TAB") #'corfu-complete)
  (define-key corfu-map [tab] #'corfu-complete)
  ;; C-n/C-p to navigate (matches Neovim cmp config)
  (define-key corfu-map (kbd "C-n") #'corfu-next)
  (define-key corfu-map (kbd "C-p") #'corfu-previous))

;;; Cape — extra completion-at-point backends
(use-package cape
  :config
  ;; Add useful completion sources to the default capf list
  (add-hook 'completion-at-point-functions #'cape-dabbrev)
  (add-hook 'completion-at-point-functions #'cape-file))

;;; LSP leader keybindings — from lsp.lua
(my-leader-def
  "v" '(:ignore t :which-key "lsp")
  "v s" '(xref-find-apropos :which-key "workspace symbol")
  "v d" '(flymake-show-buffer-diagnostics :which-key "diagnostics")
  "v r" '(xref-find-references :which-key "references")
  "v h" '(eldoc :which-key "signature help")
  "v a" '(eglot-code-actions :which-key "code actions")
  "v n" '(eglot-rename :which-key "rename"))

(provide 'lsp)
;;; lsp.el ends here
