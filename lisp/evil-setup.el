;;; evil-setup.el --- Modal editing and leader keys -*- lexical-binding: t; -*-

;; Evil + evil-collection + evil-surround + general.el
;; Mirrors keybindings from ~/Code/digia/nvim/lua/digia/keymaps.lua

;;; Pre-evil variable declarations — MUST be set before evil loads
(setq evil-want-integration t)
(setq evil-want-keybinding nil)
(setq evil-want-C-u-scroll t)
(setq evil-want-C-u-delete t)
(setq evil-want-Y-yank-to-eol t)

;;; Evil
(use-package evil
  :demand t
  :config
  (evil-mode 1)
  (setq evil-undo-system 'undo-redo)
  (setq evil-ex-search-case 'smart)
  (setq evil-vsplit-window-right t)
  (setq evil-split-window-below t)
  (setq evil-shift-width 4)

  ;; Cursor shape per state — matches Neovim guicursor
  ;; Evil internal cursor types (affects Emacs TUI rendering)
  (setq evil-normal-state-cursor 'box)
  (setq evil-visual-state-cursor 'box)
  (setq evil-motion-state-cursor 'box)
  (setq evil-insert-state-cursor 'bar)
  (setq evil-replace-state-cursor 'hbar)
  (setq evil-operator-state-cursor 'hollow)

  ;; Terminal cursor shape via DECSCUSR escape sequences
  ;; Sends actual cursor changes to the terminal emulator
  (unless (display-graphic-p)
    (add-hook 'evil-normal-state-entry-hook
              (lambda () (send-string-to-terminal "\e[2 q")))   ;; steady block
    (add-hook 'evil-visual-state-entry-hook
              (lambda () (send-string-to-terminal "\e[2 q")))   ;; steady block
    (add-hook 'evil-insert-state-entry-hook
              (lambda () (send-string-to-terminal "\e[6 q")))   ;; steady bar
    (add-hook 'evil-replace-state-entry-hook
              (lambda () (send-string-to-terminal "\e[4 q")))   ;; steady underline
    (add-hook 'evil-operator-state-entry-hook
              (lambda () (send-string-to-terminal "\e[0 q"))))  ;; default

  ;; Re-send cursor shape when a new emacsclient frame connects (daemon mode)
  (add-hook 'server-after-make-frame-hook #'evil-refresh-cursor)

  ;; C-c as Escape in insert mode
  (define-key evil-insert-state-map (kbd "C-c") #'evil-normal-state)

  ;; Window navigation — C-h/j/k/l in normal and motion states only
  ;; (preserves C-h help prefix in non-Evil contexts)
  (dolist (map (list evil-normal-state-map evil-motion-state-map))
    (define-key map (kbd "C-h") #'evil-window-left)
    (define-key map (kbd "C-j") #'evil-window-down)
    (define-key map (kbd "C-k") #'evil-window-up)
    (define-key map (kbd "C-l") #'evil-window-right))

  ;; Redirect help to F1
  (global-set-key (kbd "<f1>") #'help-command)

  ;; K — describe symbol at point (global fallback for non-LSP buffers)
  ;; Eglot-managed buffers override this in lsp.el with eldoc-doc-buffer.
  (evil-define-key 'normal 'global "K"
    (lambda ()
      (interactive)
      (let ((sym (thing-at-point 'symbol)))
        (if sym
            (describe-symbol (intern sym))
          (call-interactively #'describe-symbol)))))

  ;; Clear search highlight — most terminals send C-_ for C-/
  (define-key evil-normal-state-map (kbd "C-_") #'evil-ex-nohighlight)

  ;; Reselect visual block after indent
  (define-key evil-visual-state-map "<"
    (lambda ()
      (interactive)
      (call-interactively #'evil-shift-left)
      (evil-visual-restore)))
  (define-key evil-visual-state-map ">"
    (lambda ()
      (interactive)
      (call-interactively #'evil-shift-right)
      (evil-visual-restore)))

  ;; Centered search results via advice (handles wrapscan, counts, macros)
  (advice-add 'evil-ex-search-next :after
              (lambda (&rest _) (evil-scroll-line-to-center nil)))
  (advice-add 'evil-ex-search-previous :after
              (lambda (&rest _) (evil-scroll-line-to-center nil))))

;;; Evil Collection — broad Evil bindings for Emacs modes
(use-package evil-collection
  :after evil
  :demand t
  :config
  (evil-collection-init))

;;; Evil Surround — cs'" ds" ysiw)
(use-package evil-surround
  :after evil
  :demand t
  :config
  (global-evil-surround-mode 1))

;;; General — leader key framework
;; :ensure (:wait t) forces synchronous install because my-leader-def
;; is used in this file and in all subsequent modules
(use-package general
  :ensure (:wait t)
  :demand t
  :config
  (general-evil-setup)

  ;; SPC leader definer
  (general-create-definer my-leader-def
    :states '(normal visual motion)
    :keymaps 'override
    :prefix "SPC"
    :non-normal-prefix "M-SPC")

  ;; Double-leader prefix
  (general-create-definer my-leader-leader-def
    :states '(normal visual motion)
    :keymaps 'override
    :prefix "SPC SPC"))

;;; Leader keybindings — core mappings from keymaps.lua

;; Clipboard yank — SPC y is a prefix so SPC y s (filename copy) can coexist
;; SPC y y — yank to clipboard (composable with motions in normal mode)
;; SPC y Y — yank line to clipboard
;; SPC y s — copy filename / filename:lines (Claude Code workflow)
;; Note: "+y still works natively in Evil for direct register yank
(my-leader-def
  "y" '(:ignore t :which-key "yank/clipboard"))

(my-leader-def
  :states '(normal)
  "y y" '((lambda ()
            (interactive)
            (let ((evil-this-register ?+))
              (call-interactively #'evil-yank)))
          :which-key "yank to clipboard")
  "y Y" '((lambda ()
            (interactive)
            (evil-yank (line-beginning-position) (line-end-position) 'line ?+))
          :which-key "yank line to clipboard"))

(my-leader-def
  :states '(visual)
  "y y" '((lambda ()
            (interactive)
            (evil-yank (region-beginning) (region-end) (evil-visual-type) ?+)
            (evil-normal-state))
          :which-key "yank to clipboard"))

;; Copy filename / filename:lines to clipboard (Claude Code workflow)
(my-leader-def
  :states '(normal)
  "y s" '((lambda ()
            (interactive)
            (let ((path (and buffer-file-name
                             (file-relative-name buffer-file-name
                                                 (or (when-let* ((proj (project-current)))
                                                       (project-root proj))
                                                     default-directory)))))
              (if path
                  (progn (kill-new path)
                         (message "Copied: %s" path))
                (message "No filename"))))
          :which-key "copy filename"))

(my-leader-def
  :states '(visual)
  "y s" '((lambda ()
            (interactive)
            (let* ((path (and buffer-file-name
                              (file-relative-name buffer-file-name
                                                  (or (when-let* ((proj (project-current)))
                                                        (project-root proj))
                                                      default-directory))))
                   (start (line-number-at-pos (region-beginning)))
                   (end (line-number-at-pos (region-end)))
                   (result (if (= start end)
                               (format "%s:%d" path start)
                             (format "%s:%d-%d" path start end))))
              (kill-new result)
              (evil-normal-state)
              (message "Copied: %s" result)))
          :which-key "copy filename:lines"))

;; Repeat command and reload config
(my-leader-leader-def
  "c" '(repeat-complex-command :which-key "repeat command")
  "r" '((lambda ()
          (interactive)
          (load-file user-init-file)
          (message "Config reloaded"))
        :which-key "reload config"))

;; :BD — kill buffer without closing the window (shows previous buffer)
(evil-define-command my/buffer-delete ()
  "Kill current buffer, keep the window, show previous buffer."
  (let ((buf (current-buffer)))
    (previous-buffer)
    (kill-buffer buf)))
(evil-ex-define-cmd "BD" #'my/buffer-delete)

(provide 'evil-setup)
;;; evil-setup.el ends here
