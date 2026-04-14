;;; ui.el --- Theme, modeline, and visual aids -*- lexical-binding: t; -*-

;; Mirrors ~/Code/digia/nvim/lua/digia/plugin/ui.lua
;; Tokyo Night Storm + custom modeline + which-key + hl-todo + indent-bars

;;; Tokyo Night Storm theme
;; Not on MELPA — install from GitHub
(use-package tokyonight-themes
  :ensure (:host github :repo "xuchengpeng/tokyonight-themes")
  :demand t
  :config
  (load-theme 'tokyonight-storm t)
  ;; No italic keywords (matches Neovim: styles.keywords.italic = false)
  (set-face-attribute 'font-lock-keyword-face nil :slant 'normal)

  ;; Line number colors — non-current uses muted blue-gray, current uses bright fg
  (set-face-attribute 'line-number nil :foreground "#3B4261")
  (set-face-attribute 'line-number-current-line nil :foreground "#FF9D65")

  ;; Fill column indicator — darker than bg, matching Neovim colorcolumn
  (set-face-attribute 'fill-column-indicator nil :foreground "#1E202F")

  ;; Mode-line background
  (set-face-attribute 'mode-line nil :background "#1F2335")
  (set-face-attribute 'mode-line-inactive nil :background "#1F2335"))

;;; Which-key — built-in to Emacs 30.2, do NOT install from MELPA
(use-package which-key
  :ensure nil
  :demand t
  :custom
  (which-key-idle-delay 1.25)
  (which-key-idle-secondary-delay 0.0)
  :config
  (which-key-mode 1))

;;; hl-todo — highlight TODO/HACK/BUG/FIX/PERF/NOTE
(use-package hl-todo
  :hook ((prog-mode . hl-todo-mode)
         (text-mode . hl-todo-mode))
  :custom
  (hl-todo-keyword-faces
   '(("TODO"  . "#e0af68")
     ("HACK"  . "#ff9e64")
     ("BUG"   . "#f7768e")
     ("FIX"   . "#f7768e")
     ("FIXME" . "#f7768e")
     ("PERF"  . "#9ece6a")
     ("NOTE"  . "#7aa2f7")))
  :config
  (evil-define-key 'normal 'global
    "]t" #'hl-todo-next
    "[t" #'hl-todo-previous))

;;; indent-bars — indent guides (replaces unmaintained highlight-indent-guides)
(use-package indent-bars
  :ensure (:host github :repo "jdtsmith/indent-bars")
  :hook (prog-mode . indent-bars-mode)
  :custom
  (indent-bars-color '("#3B4261" :face-bg nil :blend 1.0))
  (indent-bars-color-by-depth nil)
  (indent-bars-highlight-current-depth '(:face default :blend 0.15)))

;;; Custom mode-line — mirrors lualine with Tokyonight Storm colors
(add-hook 'prog-mode-hook #'which-function-mode)
(setq which-func-unknown "")

;; Faces for mode-dependent filename section
(defface my/modeline-normal
  '((t :foreground "#1a1b26" :background "#7AA2F7" :weight bold))
  "Mode-line face for Evil normal state.")
(defface my/modeline-insert
  '((t :foreground "#1a1b26" :background "#9ECE6A" :weight bold))
  "Mode-line face for Evil insert state.")
(defface my/modeline-visual
  '((t :foreground "#1a1b26" :background "#BB9AF7" :weight bold))
  "Mode-line face for Evil visual state.")
(defface my/modeline-replace
  '((t :foreground "#1a1b26" :background "#f7768e" :weight bold))
  "Mode-line face for Evil replace state.")
(defface my/modeline-operator
  '((t :foreground "#1a1b26" :background "#ff9e64" :weight bold))
  "Mode-line face for Evil operator state.")
(defface my/modeline-inactive
  '((t :foreground "#565f89" :background nil))
  "Mode-line face for inactive windows.")
(defface my/modeline-mode-section
  '((t :foreground "#a9b1d6" :background "#292e42"))
  "Mode-line face for the major-mode section.")

(defun my/modeline-evil-face ()
  "Return the face for the current Evil state."
  (if (mode-line-window-selected-p)
      (cond
       ((and (bound-and-true-p evil-mode)
             (eq evil-state 'insert)) 'my/modeline-insert)
       ((and (bound-and-true-p evil-mode)
             (memq evil-state '(visual))) 'my/modeline-visual)
       ((and (bound-and-true-p evil-mode)
             (eq evil-state 'replace)) 'my/modeline-replace)
       ((and (bound-and-true-p evil-mode)
             (eq evil-state 'operator)) 'my/modeline-operator)
       (t 'my/modeline-normal))
    'my/modeline-inactive))

(defun my/modeline-file-info ()
  "Return filename:line:col with modified/readonly indicator.
Path is relative to project root."
  (let* ((file (or buffer-file-name (buffer-name)))
         (path (if buffer-file-name
                   (file-relative-name file
                     (or (when-let* ((proj (project-current)))
                           (project-root proj))
                         default-directory))
                 file))
         (status (cond (buffer-read-only " [-]")
                       ((buffer-modified-p) " [+]")
                       (t ""))))
    (format " %s:%d:%d%s " path (line-number-at-pos) (current-column) status)))

(setq-default mode-line-format
  '("%e"
    ;; Section A: filename:line:col — mode-dependent background
    (:eval (propertize (my/modeline-file-info) 'face (my/modeline-evil-face)))
    ;; Section B: major-mode name — subtle background
    (:eval (let ((name (format " %s " (symbol-name major-mode))))
             (if (mode-line-window-selected-p)
                 (propertize name 'face 'my/modeline-mode-section)
               (propertize name 'face 'my/modeline-inactive))))
    ;; Right-aligned sections
    mode-line-format-right-align
    (which-function-mode ("" which-func-format))
    "  "
    flymake-mode-line-format
    " "))

;;; Toggle bindings (from snacks.nvim toggles)
(my-leader-def
  "u" '(:ignore t :which-key "toggle")
  "u s" '(flyspell-mode :which-key "spell check")
  "u w" '(toggle-truncate-lines :which-key "line wrap"))

(provide 'ui)
;;; ui.el ends here
