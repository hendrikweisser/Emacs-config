;(message "%s" "This is init.el")

(require 'server)
(unless (server-running-p) (server-start))

(setq gc-cons-threshold 100000000) ; less frequent garbage collection
(tool-bar-mode -1) ; set this early on

;; system-specific settings
(if (eq system-type 'windows-nt) ; Windows
    (progn
      (setq w32-apps-modifier 'meta)
      (add-to-list 'default-frame-alist '(font . "Consolas-12"))
      (setenv "WORKON_HOME" "C:/Users/hendrik.weisser/.conda/envs"))
  ; else: Linux
  (setq load-path (cons "/home/hendrik.weisser/.emacs.d/c-ide" load-path)
        ;; window (frame) size:
        default-frame-alist '((width . 80) (height . 56) (top . 1))
        x-super-keysym 'meta)
        ;; external programs:
        ; inferior-R-program-name "/software/R-3.3.0/bin/R"
	; py-python-command "/software/bin/python-2.7.6"
  (add-to-list 'default-frame-alist '(font . "Inconsolata-12")))

;; variables that have to be set by calling functions
(set-scroll-bar-mode 'right)
(show-paren-mode t)
(global-font-lock-mode 1) ; always use syntax highlighting
(if (fboundp 'global-subword-mode)
    (global-subword-mode 1)) ; for camelCase editing

;; pairing of braces
(if (fboundp 'electric-pair-mode)
    (electric-pair-mode 1)
  ;; else: older Emacs version
  (require 'autopair)
  (autopair-global-mode))

;; customized variables
(setq-default inhibit-startup-screen t
              frame-title-format (list "%b - Emacs") ; window title
              visible-bell t ; no beeping
              column-number-mode t
              transient-mark-mode t
              size-indication-mode t
              x-select-enable-clipboard t
              tab-width 4
              ;; use spaces for identation (use "C-q <tab>" to force a tab):
              indent-tabs-mode nil
              sentence-end-double-space nil
              search-whitespace-regexp nil ; space means space and nothing else
              dired-dwim-target t ; guess paths in dired
              fill-column 80)

(require 'package)
(add-to-list 'package-archives
             '("melpa" . "http://melpa.org/packages/"))
(package-initialize)
;; packages to install: buffer-move, sr-speedbar, pager, cmake-mode, ess


;; always accept "y"/"n" instead of "yes"/"no"
(defalias 'yes-or-no-p 'y-or-n-p)

;; from http://steve.yegge.googlepages.com/effective-emacs
(defalias 'qrr 'query-replace-regexp)

;; familiar binding for undo
(global-set-key [(control z)] 'undo)

;; go to beginning/end of buffer
(global-set-key (kbd "C-S-a") 'beginning-of-buffer) ; alternative to "C-home"
(global-set-key (kbd "C-S-e") 'end-of-buffer) ; alternative to "C-end"

;; "C-M-..." combinations don't work in X2Go
(global-set-key (kbd "M-F") 'forward-sexp)
(global-set-key (kbd "M-B") 'backward-sexp)

;; switch to previous buffer
(defun switch-to-previous-buffer ()
  "Show the buffer that was previously displayed in this window."
  (interactive)
  (switch-to-buffer (other-buffer)))

(global-set-key "\C-xp" 'switch-to-previous-buffer) ; in analogy to "C-x o"
(fset 'previous-buffer-other-window "\C-xo\C-xp\C-xO")
(global-set-key (kbd "C-x 4 p") 'previous-buffer-other-window)

;; move between windows ("C-x o" is already "other-frame")
(global-set-key "\C-xO" (lambda () (interactive) (other-window -1)))
(global-set-key "\C-xw" 'next-multiframe-window)
(global-set-key "\C-xW" 'previous-multiframe-window)
(require 'windmove)
(global-set-key (kbd "C-c <left>") 'windmove-left)
(global-set-key (kbd "C-c <right>") 'windmove-right)
(global-set-key (kbd "C-c <up>") 'windmove-up)
(global-set-key (kbd "C-c <down>") 'windmove-down)
;; "C-c C-b/f/p/n" are reserved by ESS
(global-set-key (kbd "C-c b") 'windmove-left) ; overwrites "org-iswitchb"
(global-set-key (kbd "C-c f") 'windmove-right)
(global-set-key (kbd "C-c p") 'windmove-up)
(global-set-key (kbd "C-c n") 'windmove-down)
(setq-default windmove-wrap-around t)

;; window configuration
(require 'buffer-move)
(global-set-key (kbd "C-c <S-left>") 'buf-move-left)
(global-set-key (kbd "C-c <S-right>") 'buf-move-right)
(global-set-key (kbd "C-c <S-up>") 'buf-move-up)
(global-set-key (kbd "C-c <S-down>") 'buf-move-down)

(setq winner-dont-bind-my-keys t) ; needs to happen before the "require"!
(require 'winner)
(global-set-key (kbd "C-c <M-left>") 'winner-undo)
(global-set-key (kbd "C-c <M-right>") 'winner-redo)
(winner-mode 1)

;; follow-mode
(defun split-and-follow ()
  "Split window vertically and enter follow-mode."
  (interactive)
  (split-window-horizontally)
  (follow-mode))

(global-set-key (kbd "C-x C-3") 'split-and-follow) ; in analogy to "C-x 3"

;; kill current buffer and close window (delete frame)
(global-set-key (kbd "C-x K") 'kill-buffer-and-window) ; in analogy to "C-x k"

(defun kill-all-dired-buffers ()
  "Kill all dired buffers."
  (interactive)
  (save-excursion
    (let ((count 0))
      (dolist (buffer (buffer-list))
        (set-buffer buffer)
        (when (equal major-mode 'dired-mode)
          (setq count (1+ count))
          (kill-buffer buffer)))
      (message "Killed %i dired buffer(s)." count))))

(defalias 'kad 'kill-all-dired-buffers)


;; speedbar in the same frame (showing directory contents)
(require 'sr-speedbar)
(global-set-key "\C-cs" 'sr-speedbar-select-window)
(global-set-key "\C-cS" 'sr-speedbar-close)
(setq-default speedbar-show-unknown-files t) ; show all files
;; re-enable case-insensitive searching in the speedbar:
(add-hook 'speedbar-mode-hook (lambda () (setq case-fold-search t)))


;; 1.-10. from http://www.zafar.se/bkz/Articles/EmacsTips

(require 'cl) ; for "cadar" in "point-stack-pop"

;; 1. Moving around (using isearch)
(global-set-key [(control s)] 'isearch-forward-regexp)
(global-set-key [(control r)] 'isearch-backward-regexp)

;; Always end searches at the beginning of the matching expression.
(add-hook 'isearch-mode-end-hook 'custom-goto-match-beginning)

(defun custom-goto-match-beginning ()
  "Use with isearch hook to end search at first char of match."
  (when isearch-forward (goto-char isearch-other-end)))


;; 2. Completions
(require 'ido)
(ido-mode t)


;; 3. Pairwise insertion using "skeleton-pair"
;; replaced by "autopair.el" above


;; 4. Fix broken pageup/pagedown behaviour (using pager.el)
(require 'pager)
(global-set-key [next] 'pager-page-down)
(global-set-key [prior] 'pager-page-up)


;; 5. Moving lines
(global-set-key [(meta up)] 'move-line-up)
(global-set-key [(meta down)] 'move-line-down)

(defun move-line (&optional n)
  "Move current line N (1) lines up/down leaving point in place."
  (interactive "p")
  (when (null n)
    (setq n 1))
  (let ((col (current-column)))
    (beginning-of-line)
    (next-line 1)
    (transpose-lines n)
    (previous-line 1)
    (forward-char col)))

(defun move-line-up (n)
  "Moves current line N (1) lines up leaving point in place."
  (interactive "p")
  (move-line (if (null n) -1 (- n))))

(defun move-line-down (n)
  "Moves current line N (1) lines down leaving point in place."
  (interactive "p")
  (move-line (if (null n) 1 n)))


;; 6. Copying the current line
(defadvice kill-ring-save (before slickcopy activate compile)
  "When called interactively with no active region, copy a single line instead."
  (interactive
   (if mark-active (list (region-beginning) (region-end))
     (list (line-beginning-position)
		   (line-beginning-position 2)))))

(defadvice kill-region (before slickcut activate compile)
  "When called interactively with no active region, kill a single line instead."
  (interactive
   (if mark-active (list (region-beginning) (region-end))
     (list (line-beginning-position)
		   (line-beginning-position 2)))))


;; 7. Search at point
(global-set-key [f5] 'isearch-backward-current-word-keep-offset)
(global-set-key [f6] 'isearch-forward-current-word-keep-offset)

(defun isearch-forward-current-word-keep-offset ()
  "Mimic vi search foward at point feature."
  (interactive)
  (let ((re-curword) (curword) (offset (point))
        (old-case-fold-search case-fold-search))
    (setq curword (thing-at-point 'symbol))
    (setq re-curword (concat "\\<" (thing-at-point 'symbol) "\\>") )
    (beginning-of-thing 'symbol)
    (setq offset (- offset (point)))	; offset from start of symbol/word
    (setq offset (- (length curword) offset)) ; offset from end
    (forward-char)
    (setq case-fold-search nil)
    (if (re-search-forward re-curword nil t)
		(backward-char offset)
      ;; else
      (progn (goto-char (point-min))
			 (if (re-search-forward re-curword nil t)
				 (progn (message "Searching from top. %s" (what-line))
                        (backward-char offset))
			   ;; else
			   (message "Searching from top: Not found"))))
    (setq case-fold-search old-case-fold-search)))

(defun isearch-backward-current-word-keep-offset ()
  "Mimic vi search backwards at point feature."
  (interactive)
  (let ((re-curword) (curword) (offset (point))
        (old-case-fold-search case-fold-search))
    (setq curword (thing-at-point 'symbol))
    (setq re-curword (concat "\\<" curword "\\>") )
    (beginning-of-thing 'symbol)
    (setq offset (- offset (point)))	; offset from start of symbol/word
    (forward-char)
    (setq case-fold-search nil)
    (if (re-search-backward re-curword nil t)
		(forward-char offset)
      ;; else
      (progn (goto-char (point-max))
			 (if (re-search-backward re-curword nil t)
				 (progn (message "Searching from bottom. %s" (what-line))
                        (forward-char offset))
			   ;; else
			   (message "Searching from bottom: Not found"))))
    (setq case-fold-search old-case-fold-search)))


;; 8. Open new line
(global-set-key [S-return] 'open-next-line)

(defun open-next-line (arg)
  "Move to the next line (like vi) and then open a line."
  (interactive "p")
  (end-of-line)
  (open-line arg)
  (next-line 1)
  (indent-according-to-mode))


;; 9. Find matching parentheses
(global-set-key [(control \;)] 'match-paren)

(defun match-paren (arg)
  "Go to the matching parenthesis if on parenthesis."
  (interactive "p")
  (cond ((looking-at "\\s\(") (forward-list 1) (backward-char 1))
        ((looking-at "\\s\)") (forward-char 1) (backward-list 1))))


;; 10. Bookmarking - history stack
(global-set-key [f7] 'point-stack-push)
(global-set-key [f8] 'point-stack-pop)

(defvar point-stack nil)

(defun point-stack-push ()
  "Push current location and buffer info onto stack."
  (interactive)
  (message "Location marked.")
  (setq point-stack (cons (list (current-buffer) (point)) point-stack)))

(defun point-stack-pop ()
  "Pop a location off the stack and move to buffer"
  (interactive)
  (if (null point-stack)
      (message "Stack is empty.")
    (switch-to-buffer (caar point-stack))
    (goto-char (cadar point-stack))
    (setq point-stack (cdr point-stack))))


;; resize window or frame to 80 columns wide (from http://dse.livejournal.com/67732.html)
(defun fix-frame-horizontal-size (width)
  "Set the frame's size to `fill-column' (or prefix arg WIDTH) columns wide."
  (interactive "P")
  (if window-system
	  ;; changing the width reduces height by two - WTF?
	  ;; (set-frame-width (selected-frame) (or width 80))
	  (let ((width (or width fill-column)))
		(if (/= width (frame-width))
			(set-frame-size (selected-frame) width (+ 2 (frame-height)))))
    (error "Cannot resize the frame horizontally in a text terminal")))

(defun fix-window-horizontal-size (width)
  "Set the window's size to `fill-column' (or prefix arg WIDTH) columns wide."
  (interactive "P")
  (enlarge-window (- (or width fill-column) (window-width)) 'horizontal))

(defun fix-horizontal-size (width)
  "Set the window's or frame's width to 80 (or prefix arg WIDTH)."
  (interactive "P")
  (condition-case nil
      (fix-window-horizontal-size width)
    (error
     (condition-case nil
	 (fix-frame-horizontal-size width)
       (error
	(error "Cannot resize window or frame horizontally"))))))

(global-set-key (kbd "C-x f") 'fix-horizontal-size) ; formerly "set-fill-column"


;; hippie expand (from http://trey-jackson.blogspot.com/2007/12/emacs-tip-5-hippie-expand.html)
(global-set-key (kbd "C-<tab>") 'hippie-expand)

(setq hippie-expand-try-functions-list '(try-expand-dabbrev
                                         try-expand-dabbrev-all-buffers
                                         try-expand-dabbrev-from-kill
                                         try-complete-file-name-partially
                                         try-complete-file-name
                                         try-expand-all-abbrevs
                                         try-expand-list
                                         try-expand-line
                                         try-complete-lisp-symbol-partially
                                         try-complete-lisp-symbol))


;; colour for the shell
(autoload 'ansi-color-for-comint-mode-on "ansi-color" nil t)
(add-hook 'shell-mode-hook 'ansi-color-for-comint-mode-on)


;; force saving a file (e.g. to overwrite after it has changed on disk; from http://stackoverflow.com/a/3217206/1149840 and http://stackoverflow.com/a/2284921/1149840)
(defun save-buffer-always ()
  "Save the buffer even if it is not modified"
  (interactive)
  (cl-flet ((ask-user-about-supersession-threat (fn))) ; suppress "really edit?"
	(set-buffer-modified-p t)
	(save-buffer)))

(global-set-key "\C-x\M-s" 'save-buffer-always) ; in analogy to "C-x C-s"


;; interactive C
;(add-hook 'c-mode-hook 'turn-on-font-lock)
(setq auto-mode-alist
      (append '(("\\.h\\'" . c++-mode)
				("\\.t\\'" . c++-mode))
			  auto-mode-alist))

(defun my-c-mode-common-hook ()
  (c-set-style "k&r")
  (setq c-basic-offset 2)
  (c-subword-mode 1)
  (setq tab-width c-basic-offset)) ; alwys use tabs for indentation
(add-hook 'c-mode-common-hook 'my-c-mode-common-hook)


;; C/C++ IDE (from https://tuhdo.github.io/c-ide.html, https://github.com/tuhdo/emacs-c-ide-demo)
;; (unless (package-installed-p 'use-package)
;;   (package-install 'use-package))

(require 'use-package)
(setq use-package-always-ensure t)

(require 'setup-general)
(require 'setup-ggtags)
(require 'setup-cedet)
(require 'setup-editing)


;; R/ESS: easy evaluation of R code (from http://www.emacswiki.org/cgi-bin/wiki/EmacsSpeaksStatistics)
(setq ess-default-style 'GNU)
(setq ess-ask-for-ess-directory nil)
(setq ess-local-process-name "R")
(setq ansi-color-for-comint-mode 'filter)
(setq comint-prompt-read-only t)
(setq comint-scroll-to-bottom-on-input t)
(setq comint-scroll-to-bottom-on-output t)
(setq comint-move-point-for-output t)

(defun my-ess-start-R ()
  (interactive)
  (if (not (member "*R*" (mapcar (function buffer-name) (buffer-list))))
      (let (w1 w1name w2)
		(delete-other-windows)
		(setq w1 (selected-window))
		(setq w1name (buffer-name))
		(setq w2 (split-window w1))
		(R)
		(set-window-buffer w2 "*R*")
		(set-window-buffer w1 w1name))))

(defun my-ess-eval ()
  (interactive)
  (my-ess-start-R)
  (if (and transient-mark-mode mark-active)
	  (call-interactively 'ess-eval-region)
	(call-interactively 'ess-eval-line-and-step)))

(add-hook 'ess-mode-hook
		  '(lambda()
             (load "ess-r-args.el")
             (define-key ess-mode-map "\C-ci" 'ess-r-args-insert)
			 (local-set-key [(control return)] 'my-ess-eval)))

(defun my-ess-adjust-width ()
  "Silently adjust the \"width\" option to the window width, if that has changed."
  (interactive)
  (if (string= ess-language "S")
	  (let ((width (window-width)))
		(if (/= width my-ess-window-width)
			(progn ; (message "Adjusting \"width\" option")
				   (setq my-ess-window-width width)
				   (ess-eval-linewise (format "options(width=%d)" width)
									  t nil nil 'wait-prompt))))))

(add-hook 'inferior-ess-mode-hook
		  '(lambda()
			 (local-set-key [C-up] 'comint-previous-input)
			 (local-set-key [C-down] 'comint-next-input)
			 ;; adjust R output width based on window width:
			 (set (make-local-variable 'my-ess-window-width) 0)
			 (add-hook 'window-configuration-change-hook
					   'my-ess-adjust-width nil 'local)))

;; show help in Emacs, not in browser
(add-hook 'ess-r-post-run-hook
          '(lambda() (ess-eval-linewise "options(help_type=\"text\")\n")))

(require 'ess-site)


;; CSV support
(add-to-list 'auto-mode-alist '("\\.[Cc][Ss][Vv]\\'" . csv-mode))
(autoload 'csv-mode "csv-mode"
  "Major mode for editing comma-separated value files." t)


;; org-mode
(add-to-list 'auto-mode-alist '("\\.org\\'" . org-mode))
(global-set-key "\C-cl" 'org-store-link)
(global-set-key "\C-ca" 'org-agenda)
(global-set-key "\C-cb" 'org-iswitchb)
(setq org-log-done 'time)

;; (require 'org-expiry)
;; (org-expiry-insinuate)
;; (setq org-expiry-inactive-timestamps t)


;; Python
(add-to-list 'auto-mode-alist '("\\.pyx\\'" . python-mode)) ; for Cython
(add-to-list 'auto-mode-alist '("\\.pxd\\'" . python-mode)) ; for autowrap
;; suppress warning when starting the interpreter:
(setq python-shell-completion-native-enable nil)
;; virtual environments (Anaconda):
;; (require 'pyvenv)
;; ;; (setenv "WORKON_HOME" ...) ; OS-specific, done above
;; (pyvenv-mode 1)
;; (pyvenv-tracking-mode 1)
;; (add-hook 'python-mode-hook
;; 		  '(lambda()
;; 			 "Reset tab width (python.el sets it buffer-locally to 8)"
;; 			 (setq tab-width 4)
;; 			 (setq python-guess-indent nil)))


;; web development
;; (require 'web-mode)
;; (add-to-list 'auto-mode-alist '("\\.html?\\'" . web-mode))
;; (add-to-list 'auto-mode-alist '("\\.css\\'" . web-mode))
;; (setq web-mode-engines-alist '(("django" . "\\.html?\\'")))
;; (defun my-web-mode-hook ()
;;   "Hooks for Web Mode."
;;   (setq web-mode-markup-indent-offset 2)
;;   (setq web-mode-css-indent-offset 2)
;;   ; (setq web-mode-code-indent-offset 2)
;;   (setq web-mode-enable-auto-pairing nil))
;; (add-hook 'web-mode-hook 'my-web-mode-hook)


;; CMake
(require 'cmake-mode)
(setq auto-mode-alist
      (append '(("CMakeLists\\.txt\\'" . cmake-mode)
                ("\\.cmake\\'" . cmake-mode))
              auto-mode-alist))


(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(ansi-color-faces-vector
   [default default default italic underline success warning error])
 '(ansi-color-names-vector
   ["#242424" "#e5786d" "#95e454" "#cae682" "#8ac6f2" "#333366" "#ccaa8f" "#f6f3e8"])
 '(package-selected-packages
   (quote
    (ggtags use-package web-mode pyvenv sr-speedbar pager ess cmake-mode buffer-move))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(default ((t (:inherit nil :stipple nil :background "white" :foreground "#4c4c4c" :inverse-video nil :box nil :strike-through nil :overline nil :underline nil :slant normal :weight normal :height 120 :width normal :foundry "PfEd" :family "Inconsolata")))))
