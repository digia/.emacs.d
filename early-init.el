;;; early-init.el --- Pre-initialization -*- lexical-binding: t; -*-

;; Runs before init.el and before the first frame is created.
;; Use for GC tuning, UI suppression, and disabling package.el.

;;; GC — set extremely high during startup, restored in init.el
(setq gc-cons-threshold most-positive-fixnum)
(setq gc-cons-percentage 0.6)

;;; Avoid regex matching on every file load during startup
(defvar my/file-name-handler-alist file-name-handler-alist)
(setq file-name-handler-alist nil)
(add-hook 'emacs-startup-hook
          (lambda () (setq file-name-handler-alist my/file-name-handler-alist)))

;;; Disable package.el — Elpaca replaces it
(setq package-enable-at-startup nil)

;;; Suppress native-comp warnings
(setq native-comp-async-report-warnings-errors 'silent)

;;; Suppress UI elements before frame creation
(push '(menu-bar-lines . 0) default-frame-alist)
(push '(tool-bar-lines . 0) default-frame-alist)
(push '(vertical-scroll-bars) default-frame-alist)

(menu-bar-mode -1)
(when (fboundp 'tool-bar-mode) (tool-bar-mode -1))
(when (fboundp 'scroll-bar-mode) (scroll-bar-mode -1))
(when (fboundp 'tooltip-mode) (tooltip-mode -1))

;; GUI-only settings (no-op in terminal, here for future use)
;; (when (display-graphic-p)
;;   (push '(undecorated-round . t) default-frame-alist)
;;   (pixel-scroll-precision-mode 1))

;;; Inhibit redisplay during startup
(setq-default inhibit-redisplay t)
(add-hook 'after-init-hook
          (lambda () (setq-default inhibit-redisplay nil)))

;;; early-init.el ends here
