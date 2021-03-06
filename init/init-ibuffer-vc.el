(global-set-key (kbd "C-x C-b") 'ibuffer)
(autoload 'ibuffer "ibuffer" "List buffers." t)
   (add-hook 'ibuffer-hook
     (lambda ()
       (ibuffer-vc-set-filter-groups-by-vc-root)
      (unless (eq ibuffer-sorting-mode 'alphabetic)
         (ibuffer-do-sort-by-alphabetic))))

(setq
 ibuffer-never-show-predicates '("\\*Completions\\*"
                                 "\\*Tramp*"
                                 "\\*Compile-log*"
                                 "\\*Ediff*"
                                 "\\*buffer-selection\\*"
                                 "\\*Buffer List\\*"
                                 "\\*Help\\*"
                                 "\\*Packages\\*"))

;; Switching to ibuffer puts the cursor on the most recent buffer
(defadvice ibuffer (around ibuffer-point-to-most-recent) ()
  "Open ibuffer with cursor pointed to most recent buffer name"
  (let ((recent-buffer-name (buffer-name)))
    ad-do-it
    (ibuffer-jump-to-buffer recent-buffer-name)))
(ad-activate 'ibuffer)
