
;; .emacs

(setq load-path (cons "~/.emacs.d/lisp" load-path))
(setq load-path (cons "~/.emacs.d/elpa" load-path))

;; split this file into sections
(setq myconfig-packages          t)
(setq myconfig-ui-settings       t)
(setq myconfig-misc              t)
(setq myconfig-dart              t)
(setq myconfig-tramp             t)
(setq myconfig-ido-settings      t)
(setq myconfig-autoinsert        t)
(setq myconfig-hippie-expand     t)
(setq myconfig-cperl-settings    t)
(setq myconfig-js2-mode-settings t)
(setq myconfig-diff-related      t)
(setq myconfig-yaml              t)
(setq myconfig-custom-lisp       t)
(setq myconfig-ll-debug          t)
(setq myconfig-hs-minor-mode     t)
(setq myconfig-tex               t)
(setq myconfig-r-stuff           t)
(setq myconfig-nxml              t)
(setq myconfig-auto-backup       t)
(setq myconfig-magit             t)
(setq myconfig-catalyst          t)
(setq myconfig-edit-server       nil)
(setq myconfig-dired             t)
(setq myconfig-recentf           t)
(setq myconfig-custom-variables  t)
(setq myconfig-launch-terminal   t)
(setq myconfig-maxima            t)
(setq myconfig-selinux           t)
(setq myconfig-orgmode           t)
(setq myconfig-web-beautify      t)
(setq myconfig-csv               t)
(setq myconfig-adjust-parens     t)
(setq myconfig-sql               t)
(setq myconfig-goto-last-chg     t)
(setq myconfig-csharp-mode       t)
(setq myconfig-auto-save         t)
(setq myconfig-gittimemachine    t)
(setq myconfig-coffeescript      t)
(setq myconfig-theme             t)
(setq myconfig-raku-mode         t)
(setq myconfig-python-mode       t)
(setq myconfig-dot-mode          t)
(setq myconfig-markdown-mode     t)
(setq myconfig-rmarkdown-mode    t)
(setq myconfig-typescript        t)
(setq myconfig-ox-reveal         t)
(setq myconfig-editorconfig      t)


;; melpa needs to go first so its libraries are available to load
(when myconfig-packages

 ;;; * Package initialization
  (require 'package)
  (setq package-archives
	'(
          ("gnu-elpa" . "https://elpa.gnu.org/packages/")
          ("melpa" . "http://melpa.org/packages/")
          ("melpa-stable" . "http://stable.melpa.org/packages/")
          )
	)

  (setq package-pinned-packages
	'(
          (org2blog . "melpa-stable")
	  ))

  ;; (setq package-quickstart t)
  (when (< emacs-major-version 27)
    (package-initialize))

  ;; Install automatically if not already present.
  (require 'use-package-ensure)
  (setq use-package-always-ensure t)

  (setq use-package-enable-imenu-support t)

  (eval-when-compile
    (setq use-package-enable-imenu-support t)
    (require 'use-package))
  (require 'diminish)
  (require 'bind-key)
  (setq use-package-verbose t)


  )
(when myconfig-ui-settings
  (progn
    ;; Turn off mouse interface early in startup to avoid momentary display
    (if (fboundp 'menu-bar-mode) (menu-bar-mode 0))
    (if (fboundp 'tool-bar-mode) (tool-bar-mode 0))
    (if (fboundp 'scroll-bar-mode) (scroll-bar-mode 0))
    ;;
    (setq message-log-max t)
    ;;
    ))

(when myconfig-misc
  (progn

    (defun refill-paragraphs-to-be-one-line ()
      "fill individual paragraphs with large fill column"
      (interactive)
      (let ((fill-column 100000))
        (fill-individual-paragraphs (point-min) (point-max))))

    (setq confirm-nonexistent-file-or-buffer nil)
    (fset 'yes-or-no-p 'y-or-n-p)        ; Change yes/no questions to y/n type.

    ;; decode html entities
    (use-package web-mode)
    (defun html-unescape-buffer ()
      (interactive)
      (web-mode-dom-entities-replace)
      )

    (setq w32-lwindow-modifier 'super) ; Left Windows key
    (global-set-key (kbd "s-o") 'other-window)

    ;; dont prompt for comint kills
    (remove-hook 'kill-buffer-query-functions
                 'process-kill-buffer-query-function)
    ;; TODO: make it specific to *R*, perhaps *SQL, see also:
    ;; set-process-query-on-exit-flag ? tricky since it requires a
    ;; running process as an argument

    (setq split-width-threshold nil) ;; for vertical split.

    (use-package imenu-anywhere
		 :init (global-set-key (kbd "C-c =") 'imenu-anywhere)
		 )

    (use-package paredit)

    (setf user-full-name "Torbjørn Lindahl") ;; nice for org-mode exports

    (load-library "change_case")

    (defun ajs-decimal-escapes-to-unicode (start end)
      "Convert escapes like '&#955;' to Unicode like 'λ'.
Operates on the active region or the whole buffer."
      (interactive (list (point) (mark)))
      (or (use-region-p)
          (setq start (point-min) end (point-max)))
      (insert (replace-regexp-in-string
               "&#[0-9]*;"
               (lambda (match)
                 (format "%c" (string-to-number (substring match 2 -1))))
               (filter-buffer-substring start end t))))

    (defun uniquify-all-lines-region (start end)
      "Find duplicate lines in region START to END keeping first occurrence."
      (interactive "*r")
      (save-excursion
        (let ((end (copy-marker end)))
          (while
              (progn
                (goto-char start)
                (re-search-forward "^\\(.*\\)\n\\(\\(.*\n\\)*\\)\\1\n" end t))
            (replace-match "\\1\n\\2")))))

    (defun uniquify-all-lines-buffer ()
      "Delete duplicate lines in buffer and keep first occurrence."
      (interactive "*")
      (uniquify-all-lines-region (point-min) (point-max)))

    (defun my-just-one-space()
      (interactive)
      "Calls just-one-space with -1"
      (just-one-space -1)
      )

    (global-set-key (kbd "M-s") 'my-just-one-space)

    (defun djcb-duplicate-line (&optional commentfirst)
      "comment line at point; if COMMENTFIRST is non-nil, comment the original"
      (interactive)
      (beginning-of-line)
      (push-mark)
      (end-of-line)
      (let ((str (buffer-substring (region-beginning) (region-end))))
        (when commentfirst
          (comment-region (region-beginning) (region-end)))
        (insert
         (concat (if (= 0 (forward-line 1)) "" "\n") str "\n"))
        (forward-line -1)))

    (global-set-key (kbd "C-c j") (lambda( &optional dont_comment ) (interactive "P")
                                    (djcb-duplicate-line (not dont_comment))))

    (electric-indent-mode 1)

    (defun insert-date (prefix)
      "Insert the current date. With prefix-argument, use ISO format. With
   two prefix arguments, write out the day and month name."
      (interactive "P")
      (let ((format (cond
                      ((not prefix) "%Y-%m-%d")
                      ((equal prefix '(4)) "%Y-%m-%d %T")
                      ;; ((equal prefix '(16)) "%A, %d. %B %Y")))
                      ((equal prefix '(16)) "%d.%m.%Y %T")))
            (system-time-locale "en_US"))
        (insert (format-time-string format))))
    (global-set-key (kbd "C-c d") 'insert-date)

    (require 'uniquify)
    (setq uniquify-buffer-name-style (quote forward))

    (global-set-key (kbd "C-2") 'set-mark-command)

    (setq inhibit-startup-screen t)

    (setq-default c-basic-offset 2)

    (setq auto-mode-alist
          (cons '("emacs" . lisp-mode) auto-mode-alist))

    (setq auto-mode-alist
          (cons '("\\.css\\'" . css-mode) auto-mode-alist))

    (setq auto-mode-alist
          (cons '("\\.cgi\\'" . cperl-mode) auto-mode-alist))

    (setq auto-mode-alist
          (cons '("\\.xml\\'" . nxml-mode) auto-mode-alist))

    (setq auto-mode-alist
          (append '(("\\.tt2?$" . tt-mode))  auto-mode-alist ))

    ;; (require 'dash)

    (setq auto-mode-alist
          (cons '("\\.t\\'" . cperl-mode) auto-mode-alist))

    (autoload 'tt-mode "tt-mode")

    (when (fboundp 'global-font-lock-mode)
      (global-font-lock-mode t))
    (setq transient-mark-mode t)
    (setq frame-title-format
          (concat  "%b - emacs@" system-name))

    ;; reload the config file easily
    (defun reload-config-file ()
      "load users .emacs"
      (interactive)
      (load-file "~/.emacs"))

    ;; Save point position between sessions
    (require 'saveplace)
    (setq-default save-place t)
    (setq save-place-file (expand-file-name ".places" user-emacs-directory))

    ;; Auto refresh buffers
    (global-auto-revert-mode 1)

    ;; Also auto refresh dired, but be quiet about it
    (setq global-auto-revert-non-file-buffers t)
    (setq auto-revert-verbose nil)

    (add-hook 'before-save-hook 'delete-trailing-whitespace)
    (remove-hook 'before-save-hook 'delete-trailing-whitespace 1)
    (defun locally-remove-before-save-hook ()
      "take away the remove ws before save hoook locally"
      (interactive)
      (remove-hook 'before-save-hook 'delete-trailing-whitespace)
      )

    (defun split-window-and-load-other-buffer ()
      "split window and load other buffer"
      (interactive)
      (split-window-below)
      (switch-to-buffer (other-buffer) )
      )
    (global-set-key (kbd "C-c w") 'locally-remove-before-save-hook)
    (global-set-key (kbd "M-<up>") 'split-window-and-load-other-buffer )
    (define-key help-map "a" 'apropos)

    (global-set-key (kbd "C-c r") 'reload-config-file)
    (global-set-key (kbd "C-x w") 'delete-trailing-whitespace)
    (global-set-key (kbd "C-c s") 'append-to-buffer)

    (global-set-key (kbd "C-x C-b") 'ibuffer)

    (custom-set-faces
     '(ansi-color-names-vector ["#212526" "#ff4b4b" "#b4fa70" "#fce94f" "#729fcf" "#ad7fa8" "#8cc4ff" "#eeeeec"])
     '(custom-enabled-themes nil)
     '(nxhtml-autoload-web nil t)
     ;; '(safe-local-variable-values (quote ((collapse . true) (tex-main-file . "minutes.tex") (TeX-master . minutes\.tex) (tex-main-file . "Minutes.tex") (TeX-master . t) (tex-main-file . "Main.tex"))))
     '(scroll-bar-mode nil)
     '(spice-output-local "Gnucap")
     '(spice-simulator "Gnucap")
     '(spice-waveform-viewer "Gwave")
     '(text-mode-hook (quote (turn-on-auto-fill text-mode-hook-identify)))
     '(vc-follow-symlinks t))

    (setq-default indent-tabs-mode nil)

    (defun toggle-comment-on-line ()
      "comment or uncomment current line"
      (interactive)
      (comment-or-uncomment-region (line-beginning-position) (line-end-position)))

    (defun toggle-comment-on-line-or-region ()
      "comment out region or active line"
      (interactive)
      (if (region-active-p)
          (comment-or-uncomment-region (region-beginning) (region-end) )
          (comment-or-uncomment-region (line-beginning-position) (line-end-position))
          )
      )

    (global-set-key (kbd "M-,") 'toggle-comment-on-line-or-region)
    ;; (global-set-key (kbd "M-3") 'digit-argument)

    (put 'upcase-region 'disabled nil)
    (put 'downcase-region 'disabled nil)

    (defun chmod-buffer-file (mode)
      "chmods the file of the current buffer to MODE"
      (interactive "sFile modes (octal): ")

      (if (not (buffer-file-name))
          (error "Buffer '%s' is not visiting a file!" (buffer-name))
          )

      (unless (file-exists-p (buffer-file-name))
        (save-buffer))

      (or (string-match "[0-3]?[0-7][0-7][0-7]" mode)
          (error "mode should be numeric")
          )

      (setq mode-value (string-to-number mode 8))

      (when (file-exists-p (buffer-file-name))
        (set-file-modes (buffer-file-name) mode-value)
        (message "chmod'ed %s to %s" (file-name-nondirectory (buffer-file-name)) mode)
        )
      )

    (put 'narrow-to-region 'disabled nil)

    (defun make-buffer-file-executable ()
      "run chmod 755 on buffer-file"
      (interactive)

      (if (not (buffer-file-name))
          (error "Buffer '%s' is not visiting a file!" (buffer-name))
          )

      (unless (file-exists-p (buffer-file-name))
        (save-buffer))

      (let* (
             (mode "755")
             (mode-value (string-to-number mode 8))
             )

        (when (file-exists-p (buffer-file-name))
          (set-file-modes (buffer-file-name) mode-value)
          (message "chmod'ed %s to %s" (file-name-nondirectory (buffer-file-name)) mode))))

    (global-set-key (kbd "M-j")
                    (lambda ()
                      (interactive)
                      (join-line -1)))


    (defun rotate-windows ()
      "Rotate your windows"
      (interactive)
      (cond ((not (> (count-windows)1))
             (message "You can't rotate a single window!"))
            (t
             (setq i 1)
             (setq numWindows (count-windows))
             (while  (< i numWindows)
               (let* (
                      (w1 (elt (window-list) i))
                      (w2 (elt (window-list) (+ (% i numWindows) 1)))

                      (b1 (window-buffer w1))
                      (b2 (window-buffer w2))

                      (s1 (window-start w1))
                      (s2 (window-start w2))
                      )
                 (set-window-buffer w1  b2)
                 (set-window-buffer w2 b1)
                 (set-window-start w1 s2)
                 (set-window-start w2 s1)
                 (setq i (1+ i)))))))
    (global-set-key (kbd "<s-return>") 'rotate-windows)

    (add-hook 'bookmark-after-jump-hook
              (lambda ()
                (kill-buffer "*Bookmark List*")))

    (put 'scroll-left 'disabled nil)



    (setq calendar-week-start-day 1
          calendar-intermonth-text
          '(propertize
            (format "%2d"
             (car
              (calendar-iso-from-absolute
               (calendar-absolute-from-gregorian (list month day year)))))
            'font-lock-face 'font-lock-function-name-face))

    (defun msg-buffer-file-name ()
      (interactive)
      (message buffer-file-name)
      )
    ;; (msg-buffer-file-name)
    (global-set-key (kbd "C-c f") 'msg-buffer-file-name)


    ;; to allow url decode region:
    (defun func-region (start end func)
      "run a function over the region between START and END in current buffer."
      (save-excursion
        (let ((text (delete-and-extract-region start end)))
          (insert (funcall func text)))))

    (defun hex-region (start end)
      "urlencode the region between START and END in current buffer."
      (interactive "r")
      (func-region start end #'url-hexify-string))

    (defun unhex-region (start end)
      "de-urlencode the region between START and END in current buffer."
      (interactive "r")
      (func-region start end #'url-unhex-string))

    ))
(when myconfig-dart
  (progn

    (require 'dart-mode)
    (setq auto-mode-alist
          (append '(("\\.dart$" . dart-mode))  auto-mode-alist ))

  ))
(when myconfig-tramp
  (progn

    (with-eval-after-load 'tramp-sh
      (add-to-list 'tramp-remote-path 'tramp-own-remote-path))

    ;; tramp
    (setq tramp-default-method "ssh")
    (setq tramp-remote-process-environment ())
    (add-to-list 'tramp-remote-process-environment "LC_ALL=en_US.utf8" 'append)
    (add-to-list 'tramp-remote-process-environment "HISTCONTROL=erasedups")
    (add-to-list 'tramp-remote-process-environment "HISTFILE=$HOME/.tramp_history")

    ))
(when myconfig-ido-settings
  (progn
    (add-hook 'ido-setup-hook
              (lambda ()
                ;; Go straight home
                (define-key ido-file-completion-map
                    (kbd "~")
                  (lambda ()
                    (interactive)
                    (if (looking-back "/")
                        (insert "~/")
                        (call-interactively 'self-insert-command))))))

    (setq ido-use-virtual-buffers t)

    ;;(ido-create-new-buffer (quote never))
    ;;(ido-enable-flex-matching t)
    ;;(ido-enable-last-directory-history nil)
    ;;(ido-enable-regexp nil)
    ;;(ido-max-directory-size 300000)
    ;;(ido-max-file-prompt-width 0.1)
    ;;(ido-use-filename-at-point (quote guess))
    ;;(ido-use-url-at-point t)
    ;;(ido-use-virtual-buffers t)

    (setq ido-auto-merge-work-directories-length -1)

    (defvar ido-enable-replace-completing-read t
      "If t, use ido-completing-read instead of completing-read if possible.

    Set it to nil using let in around-advice for functions where the
    original completing-read is required.  For example, if a function
    foo absolutely must use the original completing-read, define some
    advice like this:

    (defadvice foo (around original-completing-read-only activate)
      (let (ido-enable-replace-completing-read) ad-do-it))")

    ;; Replace completing-read wherever possible, unless directed otherwise
    ;; (defadvice completing-read
    ;;   (around use-ido-when-possible activate)
    ;;   (if (or (not ido-enable-replace-completing-read) ; Manual override disable ido
    ;;           (and (boundp 'ido-cur-list)
    ;;                ido-cur-list)) ; Avoid infinite loop from ido calling this
    ;;       ad-do-it
    ;;     (let ((allcomp (all-completions "" collection predicate)))
    ;;       (if allcomp
    ;;           (setq ad-return-value
    ;;                 (ido-completing-read prompt
    ;;                                      allcomp
    ;;                                      nil require-match initial-input hist def))
    ;;         ad-do-it))))

    (defadvice LaTeX-section (around original-completing-read-only activate)
      (let (ido-enable-replace-completing-read) ad-do-it))


    (custom-set-variables
     '(ido-mode (quote both) nil (ido))
     )

    (ido-everywhere 1)

    ))
(when myconfig-autoinsert
  (progn
    (setq auto-insert-directory nil)
    (setq auto-insert-alist nil)
    ;;
    (setq auto-insert-directory "~/.emacs.d/templates/")
    (define-auto-insert  "\.pl" "perl-utf8-template.pl")
    (eval-after-load 'autoinsert
      '(add-to-list
        'auto-insert-alist
        '(("\\.r\\'" . "R skeleton")
          nil
          (replace-regexp-in-string "_" "."
           (file-name-sans-extension
            (file-name-nondirectory (buffer-file-name))))
          " <- function() {" \n
          _ \n
          "}" \n)))
    (eval-after-load 'autoinsert
      '(add-to-list
        'auto-insert-alist
        '(("\\.pm\\'" . "auto package name")
          nil
          "package " (find-module-name-from-file buffer-file-name) ";" \n
          "" \n
          "use 5.016;" \n
          "use warnings;" \n
          "use utf8;" \n
          "use Carp;" \n
          "" \n
          "" \n
          "" \n
          "1;" \n
          "" \n
          "=encoding utf8" \n
          ""
          )))
    (eval-after-load 'autoinsert
      '(add-to-list
        'auto-insert-alist
        '(("trigger\\.sql\\'" . "psql trigger")
          nil
          "-- a descriptive line here" \n
          "CREATE OR REPLACE FUNCTION func_name()" \n
          "RETURNS \"trigger\" AS $$" \n
          "" \n
          "DECLARE" \n
          "" \n
          "BEGIN" \n
          _ \n
          "RETURN NEW;" \n
          "" \n
          "END;" \n
          "$$ LANGUAGE 'plpgsql';" \n
          "" \n
          "DROP TRIGGER IF EXISTS trigger_name ON table_name;"
          "" \n
          "CREATE TRIGGER trigger_name" \n
          "BEFORE UPDATE OR INSERT" \n
          "ON table_name FOR EACH ROW" \n
          "EXECUTE PROCEDURE func_name();" \n
          )))
    (eval-after-load 'autoinsert
      '(add-to-list
        'auto-insert-alist
        '(("\\.t\\'" . "Perl skeleton")
          nil
          "#!/usr/bin/perl" \n
          "" \n
          "use Test2::V0;" \n
          "use Test2::Tools::Explain;" \n
          "use Test2::Plugin::NoWarnings;" \n
          "" \n
          "" \n
          "" \n
          "done_testing;" \n _
          )))
    (eval-after-load 'autoinsert
      '(add-to-list
        'auto-insert-alist
        '(("\\.py\\'" . "Python skeleton")
          nil
          "#!/usr/bin/python" \n
          "# -*- coding: utf-8 -*-" \n
          "" \n
          "import os" \n
          "import sys" \n
          "" \n _
          )))
    (eval-after-load 'autoinsert
      '(add-to-list
        'auto-insert-alist
        '(("\\.sh\\'" . "Sh skeleton")
          nil
          "#!/bin/sh" \n
          "" \n
          "set -euf -o pipefail" \n
          "shopt -s nullglob" \n
          "" \n _
          )))
    (eval-after-load 'autoinsert
      '(add-to-list
        'auto-insert-alist
        '(("\\.org\\'" . "org mode")
          nil
          "#    -*- mode: org -*-" \n
          "" \n _
          )))
    (global-set-key (kbd "C-c i") 'auto-insert)
    ))
(when myconfig-hippie-expand
  (progn
    (global-set-key (kbd "<backtab>") 'hippie-expand )

    (defadvice he-substitute-string (after he-paredit-fix)
      "remove extra paren when expanding line in paredit"
      (if (and paredit-mode (equal (substring str -1) ")"))
          (progn (backward-delete-char 1) (forward-char))))

    ))
(when myconfig-js2-mode-settings
  (progn

    (use-package js2-mode)

    (add-to-list 'auto-mode-alist '("\\.js$" . js2-mode))
    (custom-set-variables
     '(js2-basic-offset 4)
     )

    (setq js2-strict-missing-semi-warning nil)

    ))
(when myconfig-cperl-settings
  (progn
    (defalias 'perl-mode 'cperl-mode)

    (setq cperl-hairy t)
    (setq cperl-indent-level 4)

    (custom-set-variables
     '(cperl-close-paren-offset -4)
     '(cperl-continued-statement-offset 4)
     '(cperl-indent-level 4)
     '(cperl-indent-parens-as-block t)
     '(cperl-tab-always-indent t)
     )



    ))
(when myconfig-diff-related
  (progn
    (setq diff-switches "-u")
    ))
(when myconfig-yaml
  (progn
    (autoload 'yaml-mode "yaml-mode")
    (add-to-list 'auto-mode-alist '("\\.yml$" . yaml-mode))
    (setq yaml-indent-offset 2)
    ))
(when myconfig-custom-lisp
  (progn
    (load-file "~/.emacs.d/lisp/rename-file-and-buffer.el")

    ;; (load-file "~/.emacs.d/lisp/perlmod-utils.el")
    ;; (require 'perlmod-utils)

    ;; (load-file "~/.emacs.d/lisp/myess-utils.el")
    ;; (require 'myess-utils)

    ;; (defun my-perl-run-hook ()
    ;;   (local-set-key (kbd "C-c p") 'run-perl)
    ;;   (local-set-key (kbd "C-c t") 'test-project))
    ;; (add-hook 'cperl-mode-hook 'my-perl-run-hook)

    (defun set-vnc-display ()
      "set DISPLAY to :8 (nice for vnc)"
      (interactive)
      (ess-command "Sys.setenv(DISPLAY=':8')\n")
      )

    (defun my-ess-post-run-hook ()
      ;;   (ess-execute-screen-options)
      ;;   (local-set-key (kbd "C-x x") 'myess-utils-X11)
      (local-set-key "\C-cw" 'ess-execute-screen-options)
      (local-set-key "\C-xp" 'set-vnc-display)
      )

    (add-hook 'ess-post-run-hook 'my-ess-post-run-hook)

    ;; (defun my-r-mode-hook ()
    ;;   ;; (local-set-key (kbd "C-c t") 'myess-utils-handle-test-action)
    ;;   ;; (setq ess-indent-level 4)
    ;;   (local-set-key (kbd "C-x x") 'myess-utils-X11)
    ;;   (local-set-key "\C-cs" 'myess-insert-template)
    ;;   (ess-set-style 'C++ 'quiet)
    ;;   (setq ess-fancy-comments nil)
    ;;   )

    ;; (add-hook 'ess-mode-hook 'my-r-mode-hook)

    ;; COULD TRY TO MAKE THIS WORK:
    ;; (use-package xterm-color
    ;;              :load-path "/home/lindahl/git/github/xterm-color/"

    ;;              :init
    ;;              (setq comint-output-filter-functions
    ;;                    (remove 'ansi-color-process-output comint-output-filter-functions))

    ;;              (add-hook 'inferior-ess-mode-hook
    ;;                        (lambda () (add-hook 'comint-preoutput-filter-functions #'xterm-color-filter nil t)))

    ;;              :config
    ;;              (setq xterm-color-use-bold t))

    (defun my-inferior-ess-init ()
      (setq-local ansi-color-for-comint-mode 'filter)
      (smartparens-mode 1))
    (add-hook 'inferior-ess-mode-hook 'my-inferior-ess-init)

    ))
(when myconfig-ll-debug
  (progn
    (use-package ll-debug)
    ))
(when myconfig-hs-minor-mode
  (progn
    (add-hook 'ess-mode-hook        'hs-minor-mode)
    (add-hook 'css-mode-hook        'hs-minor-mode)
    (add-hook 'js-mode-hook         'hs-minor-mode)
    (add-hook 'js2-mode-hook        'hs-minor-mode)
    (add-hook 'json-mode-hook       'hs-minor-mode)
    (add-hook 'perl-mode-hook       'hs-minor-mode)
    (add-hook 'cperl-mode-hook      'hs-minor-mode)
    (add-hook 'c-mode-common-hook   'hs-minor-mode)
    (add-hook 'emacs-lisp-mode-hook 'hs-minor-mode)
    (add-hook 'java-mode-hook       'hs-minor-mode)
    (add-hook 'lisp-mode-hook       'hs-minor-mode)
    (add-hook 'sh-mode-hook         'hs-minor-mode)
    (add-hook 'python-mode-hook     'hs-minor-mode)
    (add-hook 'nxml-mode-hook       'hs-minor-mode)
    (add-hook 'coffee-mode-hook     'hs-minor-mode)
    (add-hook 'typescript-mode      'hs-minor-mode)

    (global-set-key (kbd "C-c C-c") 'hs-toggle-hiding)

    (global-set-key (kbd "C-c <up>") 'hs-hide-all)
    (global-set-key (kbd "C-c <down>") 'hs-show-all)
    (global-set-key (kbd "C-c <left>") 'hs-hide-block)
    (global-set-key (kbd "C-c <right>") 'hs-show-block)
    ;; new:
    (global-set-key (kbd "C-h <left>") 'hs-hide-level)
    ))
(when myconfig-tex
  (progn

    (defun my-latex-compile () (interactive) (save-buffer)
           (if (boundp 'TeX-master-file)
               (TeX-command "LaTeX" 'TeX-master-file nil)
               (TeX-command "LaTeX" 'buffer-file-name)
               ))

    (defun my-index-word()
      (interactive)
      (let ((cw (current-word)))
        (if (region-active-p)
            (setq cw (buffer-substring (mark) (point))))
        (backward-char)
        (forward-word)
        (insert "\\index{" cw "}")
        ;; (insert "\\index{" (downcase cw) "}")
        (fill-paragraph)
        (forward-word)
        )
      )

    (add-hook 'LaTeX-mode-hook
              (lambda ()
                (setq TeX-auto-save t)
                (setq TeX-parse-self t)
                (setq TeX-save-query nil)
                (setq TeX-command-default "LaTeX")
                ;; (local-set-key (kbd "C-c C-c") 'my-latex-compile )
                (local-set-key (kbd "M-n") 'my-index-word )
                ))

    (setq TeX-output-view-style
          (quote
           (("^pdf$" "." "xdg-open %o")
            ("^html?$" "." "firefox %o"))))
    (setq LaTeX-command-style '(("" "%(PDF)%(latex) -shell-escape %S%(PDFout)")))
    (setq TeX-PDF-mode t)

    ))
(when myconfig-r-stuff
  (progn

    (setq ess-indent-with-fancy-comments nil)

    (require 'ess-site)

    ;; (setq ac-auto-start nil)
    ;; (define-key ac-mode-map (kbd "TAB") 'ess-indent-or-complete)
    ;; (define-key ac-completing-map [return] nil)
    ;; (setq ac-quick-help-delay 0.1)

    (add-hook 'r-mode
              (lambda ()
                (local-set-key (kbd "<home>" 'comint-bol ))
                (setq comint-prompt-regexp "^[]a-zA-Z0-9.[]*\\(?:[>+.] \\)*[+>] ")
                (local-set-key (kbd "C-x x") 'myess-utils-X11)
                ;; (setq skeleton-pair t)
                ;; (global-set-key (kbd "(") 'skeleton-pair-insert-maybe)
                ;; (global-set-key (kbd "[") 'skeleton-pair-insert-maybe)
                ;; (global-set-key (kbd "{") 'skeleton-pair-insert-maybe)
                ;; (global-set-key (kbd "\"") 'skeleton-pair-insert-maybe)
                ;; (global-set-key (kbd "\'") 'skeleton-pair-insert-maybe)
                ;; (global-set-key (kbd "\`") 'skeleton-pair-insert-maybe)
                ;; (global-set-key (kbd "<") 'skeleton-pair-insert-maybe)
                )
              )

    (add-hook 'ess-r-package-mode
              (lambda ()
                (setq ess-r-package-auto-set-evaluation-env t)
                ;; (ess-r-set-evaluation-env "*none*")
                )
              )

    (eval-after-load "comint"
      '(progn
        ;; (define-key comint-mode-map [up]
        ;;   'comint-previous-matching-input-from-input)
        (define-key comint-mode-map [up]
         'comint-previous-input)
        ;; (define-key comint-mode-map [down]
        ;;   'comint-next-matching-input-from-input)
        (define-key comint-mode-map [down]
         'comint-next-input)
        (define-key comint-mode-map [home]
         'comint-bol)
        ;; also recommended for ESS use --
        (setq comint-scroll-to-bottom-on-output 'others)
        (setq comint-scroll-show-maximum-output t)
        ;; somewhat extreme, almost disabling writing in *R*, *shell* buffers above prompt:
        (setq comint-scroll-to-bottom-on-input 'this)
        ))
    (setq comint-prompt-read-only t)
    (setq comint-scroll-to-bottom-on-input t)
    (setq comint-scroll-to-bottom-on-output t)
    (setq comint-move-point-for-output t)

    ;; consider doing stuff to ac-use-quick-help when man page issues

    ;; (custom-set-variables
    ;;  '(ac-use-quick-help nil)
    ;;  )

    (setenv "HISTFILE" "/dev/null")

    )

  '(ess-R-font-lock-keywords
    (quote
     ((ess-R-fl-keyword:modifiers . t)
      (ess-R-fl-keyword:fun-defs . t)
      (ess-R-fl-keyword:keywords . t)
      (ess-R-fl-keyword:assign-ops . t)
      (ess-R-fl-keyword:constants . t)
      (ess-fl-keyword:fun-calls)
      (ess-fl-keyword:numbers)
      (ess-fl-keyword:operators . t)
      (ess-fl-keyword:delimiters . t)
      (ess-fl-keyword:=)
      (ess-R-fl-keyword:F&T . t)
      (ess-R-fl-keyword:%op% . t))))

  )
(when myconfig-nxml
  (progn

    (require 'hideshow)
    (require 'sgml-mode)
    (require 'nxml-mode)

    (add-to-list 'hs-special-modes-alist
                 '(nxml-mode
                   "<!--\\|<[^/>]>\\|<[^/][^>]*[^/]>"
                   ""
                   "<!--" ;; won't work on its own; uses syntax table
                   (lambda (arg) (my-nxml-forward-element))
                   nil))

    (add-to-list 'hs-special-modes-alist
                 '(nxml-mode
                   "<!--\\|<[^/>]*[^/]>"
                   "-->\\|</[^/>]*[^/]>"

                   "<!--"
                   sgml-skip-tag-forward
                   nil))

    (add-hook 'nxml-mode-hook 'hs-minor-mode)

    (defun my-nxml-forward-element ()
      (let ((nxml-sexp-element-flag))
        (setq nxml-sexp-element-flag (not (looking-at "<!--")))
        (unless (looking-at outline-regexp)
          (condition-case nil
              (nxml-forward-balanced-item 1)
            (error nil)))))

    (setq nxml-sexp-element-flag t)



    (defun nxml-where ()
      "Display the hierarchy of XML elements the point is on as a path."
      (interactive)
      (let ((path nil))
        (save-excursion
          (save-restriction
            (widen)
            (while (and (< (point-min) (point)) ;; Doesn't error if point is at beginning of buffer
                        (condition-case nil
                            (progn
                              (nxml-backward-up-element) ; always returns nil
                              t)
                          (error nil)))
              (setq path (cons (xmltok-start-tag-local-name) path)))
            (if (called-interactively-p t)
                (message "/%s" (mapconcat 'identity path "/"))
                (format "/%s" (mapconcat 'identity path "/")))))))

    (add-hook 'nxml-mode-hook (lambda()
                                (local-set-key
                                 (kbd "C-x x") 'nxml-where)))

    ))
(when myconfig-auto-backup
  (progn
    (setq auto-backup-dir "~/.emacs.d/emacs-backups")
    (when (file-directory-p auto-backup-dir)
      (setq
       backup-by-copying t      ; don't clobber symlinks
       backup-directory-alist
       '(("." . "~/.emacs.d/emacs-backups"))    ; don't litter my fs tree
       delete-old-versions t
       kept-new-versions 6
       kept-old-versions 2
       version-control t)    ; use versioned backups
      )
    ))
(when myconfig-magit
  (progn

    (use-package magit)

    (global-set-key (kbd "C-c g") 'magit-push)

    (add-hook 'magit-post-refresh-hook 'diff-hl-magit-post-refresh)

    (defun magit-just-amend ()
      (interactive)
      (save-window-excursion
        (magit-with-refresh
         (shell-command "git --no-pager commit --amend --reuse-message=HEAD"))))

    (eval-after-load "magit"
      '(define-key magit-status-mode-map (kbd "C-c C-a") 'magit-just-amend))

    ;; (eval-after-load "magit"
    ;;   '(diff-hl-mode))

    ))
(when myconfig-catalyst
  (progn
    (when (file-exists-p "~/.emacs.d/lisp/catalyst-server.el")
      (load-library "catalyst-server")
      (global-set-key (kbd "C-c y") 'catalyst-server-start-or-show-process)
      )
    ))
(when myconfig-edit-server
  (progn
    (require 'edit-server)
    (edit-server-start)
    ))
(when myconfig-dired
  (progn
    (add-hook 'dired-load-hook '(lambda () (require 'dired-x)))

    (defun my-dired-up-directory ()
      (interactive)
      (dired-up-directory)
      (kill-buffer (other-buffer))
      )

    (add-hook 'dired-mode-hook '(lambda ()
                                 (local-set-key (kbd "C-<up>") 'my-dired-up-directory)
                                 ))

    (setq dired-omit-mode t)
    (load-library "dired")

    (setq dired-omit-files "^\\.?#\\|^\\.$\\|^\\.\\.$\\|^\\..*\\|^\\.git$")

    (put 'dired-find-alternate-file 'disabled nil)

    ;; make enter in dired-mode do what a does
    (define-key dired-mode-map (kbd "RET") 'dired-find-alternate-file )

    (defun dired-back-to-top ()
      (interactive)
      (beginning-of-buffer)
      (dired-next-line 2))

    (define-key dired-mode-map
        (vector 'remap 'beginning-of-buffer) 'dired-back-to-top)

    (defun dired-jump-to-bottom ()
      (interactive)
      (end-of-buffer)
      (dired-next-line -1))

    (define-key dired-mode-map
        (vector 'remap 'end-of-buffer) 'dired-jump-to-bottom)

    ))
(when myconfig-recentf
  (progn
    (require 'recentf)
    (setq recentf-auto-cleanup 'never) ;; disable before we start recentf!
    (recentf-mode 1)
    (setq recentf-max-menu-items 25)
    (global-set-key "\C-x\ \C-r" 'recentf-open-files)
    (add-hook 'server-visit-hook 'recentf-save-list)
    ))
(when myconfig-custom-variables
  (progn
    ;; (setq enable-remote-dir-locals t)
    (setq vc-follow-symlinks t)
    ;; (put 'ess-directory-function 'risky-local-variable nil)
    (setq enable-local-eval t)
    (setq enable-local-variables :all)

    ;; '(safe-local-variable-values (quote ((ess-directory-function . (lambda () (concatenate 'string (file-remote-p buffer-file-name) "~/GA/"))) ) ) )

    ))
(when myconfig-launch-terminal

  (global-set-key (kbd "C-c e")
                  (lambda ()
                    (interactive)
                    (start-process "gnome-terminal" nil "gnome-terminal")))

  )
(when myconfig-maxima
  (add-to-list 'load-path "/usr/local/share/maxima/5.18.1/emacs/")
  (autoload 'maxima-mode "maxima" "Maxima mode" t)
  (autoload 'imaxima "imaxima" "Frontend for maxima with Image support" t)
  (autoload 'maxima "maxima" "Maxima interaction" t)
  (autoload 'imath-mode "imath" "Imath mode for math formula input" t)
  (setq imaxima-use-maxima-mode-flag t)
  (add-to-list 'auto-mode-alist '("\\.ma[cx]" . maxima-mode))
  )
(when myconfig-selinux
  (load-library "selinux-mode")

  (setq auto-mode-alist
        (cons '("\\.te\\'" . selinux-te-mode) auto-mode-alist))
  )
(when myconfig-orgmode
  (setq org-insert-mode-line-in-empty-file t)

  (custom-set-variables
   '(org-todo-keywords (quote ((sequence "TODO" "WAIT" "DONE")))))

  (setq org-todo-keyword-faces
        '(("WAIT" . (:foreground "cyan" :weight bold))))

  (add-hook 'org-mode-hook
            (lambda ()
              (set (make-local-variable 'electric-indent-functions)
                   (list (lambda (arg) 'no-indent)))))

  (defun orgmode-mode-fn ()
    (local-set-key (kbd "<backtab>") 'hippie-expand )
    )
  (add-hook  'coffee-mode-hook 'orgmode-mode-fn t)


  ;; (orgstruct-mode)
  ;; (orgtbl-mode)

  )
(when myconfig-web-beautify
  (use-package web-beautify) ;; Not necessary if using ELPA package
  (eval-after-load 'js-mode
    '(define-key js2-mode-map (kbd "C-c b") 'web-beautify-js))
  (eval-after-load 'js2-mode
    '(define-key js2-mode-map (kbd "C-c b") 'web-beautify-js))
  (eval-after-load 'json-mode
    '(define-key json-mode-map (kbd "C-c b") 'web-beautify-js))
  (eval-after-load 'sgml-mode
    '(define-key html-mode-map (kbd "C-c b") 'web-beautify-html))
  (eval-after-load 'css-mode
    '(define-key css-mode-map (kbd "C-c b") 'web-beautify-css))
  )
(when myconfig-csv
  (use-package csv-mode)
  (setq auto-mode-alist
        (cons '("\\.csv\\'" . csv-mode) auto-mode-alist))
  )
(when myconfig-sql

  (load-library "sql")

  (add-to-list 'auto-mode-alist
               '("\\.sql$" . (lambda ()
                               (sql-mode)
                               (sql-set-sqli-buffer)
                               (sql-highlight-postgres-keywords))))

  (sql-set-product "postgres")

  ;; (defalias 'sql-get-login 'ignore)

  ;; (defvar sql-last-prompt-pos 1
  ;;   "position of last prompt when added recording started")
  ;; (make-variable-buffer-local 'sql-last-prompt-pos)
  ;; (put 'sql-last-prompt-pos 'permanent-local t)

  ;; (defun sql-add-newline-first (output)
  ;;   "Add newline to beginning of OUTPUT for `comint-preoutput-filter-functions'
  ;; This fixes up the display of queries sent to the inferior buffer
  ;; programatically."
  ;;   (let ((begin-of-prompt
  ;;          (or (and comint-last-prompt-overlay
  ;;                   ;; sometimes this overlay is not on prompt
  ;;                   (save-excursion
  ;;                     (goto-char (overlay-start comint-last-prompt-overlay))
  ;;                     (looking-at-p comint-prompt-regexp)
  ;;                     (point)))
  ;;              1)))
  ;;     (if (> begin-of-prompt sql-last-prompt-pos)
  ;;         (progn
  ;;           (setq sql-last-prompt-pos begin-of-prompt)
  ;;           (concat "\n" output))
  ;;       output)))

  ;; (defun sqli-add-hooks ()
  ;;   "Add hooks to `sql-interactive-mode-hook'."
  ;;   (add-hook
  ;;    'comint-preoutput-filter-functions
  ;;    ;; 'sql-add-newline-first
  ;;    )
  ;;   )

  ;; (add-hook 'sql-interactive-mode-hook 'sqli-add-hooks)

  )
(when myconfig-adjust-parens
  ;; (load-library "~/.emacs.d/elpa/adjust-parens-3.0/adjust-parens")
  (use-package adjust-parens)
  (add-hook 'emacs-lisp-mode-hook #'adjust-parens-mode)
  (add-hook 'clojure-mode-hook #'adjust-parens-mode)
  )
(when myconfig-goto-last-chg
  (use-package goto-chg)
  (global-set-key (kbd "C-c l") 'goto-last-change )
  )
(when myconfig-csharp-mode

  (use-package csharp-mode)
  ;; (autoload 'csharp-mode "csharp-mode" "Major mode for editing C# code." t)

  (setq auto-mode-alist
        (append '(("\\.cs$" . csharp-mode)) auto-mode-alist))

  (defun my-csharp-mode-fn ()
    "function that runs when csharp-mode is initialized for a buffer."
    (turn-on-auto-revert-mode)
    (setq indent-tabs-mode nil)
    (setq c-basic-offset 4)
    )

  (add-hook  'csharp-mode-hook 'my-csharp-mode-fn t)


  )
(when myconfig-auto-save

  (setq auto-save-file-name-transforms
        '(("\\`/[^/]*:\\([^/]*/\\)*\\([^/]*\\)\\'" "/tmp/\\2" t)
          ("\\`/?\\([^/]*/\\)*\\([^/]*\\)\\'" "/usr/local/sacha-backup/\\2" t)))

  ;; Save all tempfiles in $TMPDIR/emacs$UID/
  (defconst emacs-tmp-dir (format "%s/%s%s/" temporary-file-directory "emacs" (user-uid)))
  (setq backup-directory-alist
        `((".*" . ,emacs-tmp-dir)))
  (setq auto-save-file-name-transforms
        `((".*" ,emacs-tmp-dir t)))
  (setq auto-save-list-file-prefix
        emacs-tmp-dir)

  )
(when myconfig-gittimemachine

  (defun my-git-timemachine (orig-fun)
    "Enable git timemachine for file of current buffer."
    (interactive)
    (setq git-timemachine--revisions-cache nil)
    (git-timemachine-validate (buffer-file-name))
    (let ((git-directory (expand-file-name (vc-git-root (buffer-file-name))))
          (file-name (buffer-file-name))
          (timemachine-buffer (format "timemachine:%s" (buffer-name)))
          (cur-line (line-number-at-pos))
          (mode major-mode))
      (with-current-buffer (get-buffer-create timemachine-buffer)
        (switch-to-buffer timemachine-buffer)
        (setq buffer-file-name file-name)
        (if (equal mode 'ess-mode)
            (funcall mode ess-customize-alist)
            (funcall mode))
        (setq git-timemachine-directory git-directory
              git-timemachine-file (file-relative-name file-name git-directory)
              git-timemachine-revision nil)
        (git-timemachine-show-current-revision)
        (goto-char (point-min))
        (forward-line (1- cur-line))
        (git-timemachine-mode))))

  (if (>= (+ emacs-major-version (/ (float emacs-minor-version) 10)) 24.4)
      (advice-add 'git-timemachine :around #'my-git-timemachine))

  (defun my-git-wip-timemachine (orig-fun)
    "Enable git-wip timemachine for file of current buffer."
    (interactive)
    (git-wip-timemachine--validate (buffer-file-name))
    (let* ((file-name (buffer-file-name))
           (git-directory (git-wip-timemachine--directory file-name))
           (current-branch (git-wip-timemachine--branch))
           (merge-base (git-wip-timemachine--merge-base current-branch))
           (timemachine-buffer (git-wip-timemachine--buffer))
           (current-position (point))
           (current-mode major-mode))
      (with-current-buffer (get-buffer-create timemachine-buffer)
        (setq buffer-file-name file-name)
        (if (equal current-mode 'ess-mode)
            (funcall current-mode ess-customize-alist)
            (funcall current-mode))
        (git-wip-timemachine-mode)
        (setq git-wip-timemachine-directory git-directory
              git-wip-timemachine-file (file-relative-name file-name
                                                           git-directory)
              git-wip-timemachine-revision nil
              git-wip-timemachine-branch current-branch
              git-wip-timemachine-merge-base merge-base
              git-wip-timemachine-revisions (git-wip-timemachine--revisions))
        (git-wip-timemachine-show-current-revision))
      (switch-to-buffer timemachine-buffer)
      (goto-char current-position)))

  (if (>= (+ emacs-major-version (/ (float emacs-minor-version) 10)) 24.4)
      (advice-add 'git-wip-timemachine :around #'my-git-wip-timemachine))

  )
(when myconfig-coffeescript

  (use-package coffee-mode)

  (defun coffee-mode-fn ()
    (local-set-key (kbd "<backtab>") 'hippie-expand )
    )
  (add-hook  'coffee-mode-hook 'coffee-mode-fn t)

  (setq auto-mode-alist
        (cons '("\\.coffee$" . coffee-mode) auto-mode-alist))

  (custom-set-variables '(coffee-tab-width 4))

  )
(when myconfig-theme

  (when (or (window-system) (daemonp) )
    ;; (require 'color-theme)
    ;; (color-theme-initialize)
    ;; (color-theme-dark-laptop)
    ;; (add-hook 'after-make-frame-functions
    ;;           (lambda (frame)
    ;;             (color-theme-dark-laptop)
    ;;             )
    ;;           )

    ;; (load-file "~/.emacs.d/elpa/color-theme-modern-20151109.1906/color-theme-modern-autoloads.el")
    ;; (add-to-list 'custom-theme-load-path
    ;;              (file-name-as-directory "~/.emacs.d/replace-colorthemes/"))
    ;; (load-theme 'dark-laptop t t)
    ;; (enable-theme 'dark-laptop)
    ;; )

    (use-package color-theme-modern)
    (load-theme 'dark-laptop t t)
    (enable-theme 'dark-laptop)

    ;;

    )
  )
(when myconfig-raku-mode
  (progn

    (use-package raku-mode)

    (setq auto-mode-alist
	  (cons '("\\.p6\\'" . raku-mode) auto-mode-alist))
    (setq auto-mode-alist
          (cons '("\\.pl6\\'" . raku-mode) auto-mode-alist))
    (setq auto-mode-alist
          (cons '("\\.pm6\\'" . raku-mode) auto-mode-alist))
    (setq auto-mode-alist
          (cons '("\\.t6\\'" . raku-mode) auto-mode-alist))

    (add-hook 'raku-mode-hook       'hs-minor-mode)

    ))
(when myconfig-python-mode
  (progn

    (load-library "python")

    (defun my-python-mode-hook ()
      (local-set-key (kbd "<backtab>") 'hippie-expand )
      )

    (add-hook 'python-mode-hook       'my-python-mode-hook)

    ))
(when myconfig-dot-mode
  (progn
    (use-package graphviz-dot-mode)

    (setq auto-mode-alist
	  (cons '("\\.dot\\'" . graphviz-dot-mode) auto-mode-alist))

    ))
(when myconfig-markdown-mode
  ;; (load-file "~/git/markdown-mode/markdown-mode.el")
  ;; (load-library "markdown-mode")
  (use-package markdown-mode)
  )

(when myconfig-rmarkdown-mode

  (defun rmd-mode ()
    (load-file "~/git/polymode/polymode.el")
    (load-file "~/git/poly-markdown/poly-markdown.el")
    (load-file "~/git/poly-R/poly-R.el")
    (require 'polymode)
    (require 'poly-markdown)
    (require 'poly-R)
    (poly-markdown+r-mode)

    "ESS Markdown mode for rmd files"
    (interactive)
    (setq load-path
          (append (list "~/git/polymode/" "~/git/poly-markdown/" "~/git/poly-R/" "~/git/markdown-mode")
                  load-path))
    )

  (setq auto-mode-alist
        (append '(("\\.Rmd$" . rmd-mode))  auto-mode-alist ))

  )
(when myconfig-typescript

  (use-package typescript-mode)

  (setq auto-mode-alist
        (append '(("\\.ts$" . typescript-mode))  auto-mode-alist ))

  )
(when myconfig-ox-reveal

  (use-package ox-reveal)
  (setq Org-Reveal-root "file:///home/lindahl/.local/share/reveal/dist/reveal.js")
  (setq Org-Reveal-title-slide nil)


  )
(when myconfig-editorconfig
  (use-package editorconfig)
  )


;; done


;; (custom-set-variables
;;  '(custom-theme-load-path
;;    (quote
;;     ("~/.emacs.d/themes/emacs-color-theme-solarized" custom-theme-directory t)))
;;  )


;; (load-theme 'solarized t)


;; (add-hook 'after-make-frame-functions
;;           (lambda (frame)
;;             (set-frame-parameter frame
;;                                  'background-mode
;;                                  (if (display-graphic-p frame) 'dark 'dark))
;;             (enable-theme 'solarized)))
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(ac-use-quick-help nil)
 '(coffee-tab-width 4)
 '(cperl-close-paren-offset -4)
 '(cperl-continued-statement-offset 4)
 '(cperl-indent-level 4 t)
 '(cperl-indent-parens-as-block t)
 '(cperl-tab-always-indent t)
 '(custom-safe-themes
   '("b4fd44f653c69fb95d3f34f071b223ae705bb691fb9abaf2ffca3351e92aa374" "9dc64d345811d74b5cd0dac92e5717e1016573417b23811b2c37bb985da41da2" "011d4421eedbf1a871d1a1b3a4d61f4d0a2be516d4c94e111dfbdc121da0b043" "cc2f32f5ee19cbd7c139fc821ec653804fcab5fcbf140723752156dc23cdb89f" "f831c1716ebc909abe3c851569a402782b01074e665a4c140e3e52214f7504a0" "9bc1eec9b485726318efd9341df6da8b53fa684931d33beba57ed7207f2090d6" "9a3c51c59edfefd53e5de64c9da248c24b628d4e78cc808611abd15b3e58858f" "af4cfe7f2de40f19e0798d46057aae0bccfbc87a85a2d4100339eaf91a1f202a" "fc89666d6de5e1d75e6fe4210bd20be560a68982da7f352bd19c1033fb7583ba" "6c57adb4d3da69cfb559e103e555905c9eec48616104e217502d0a372e63dcea" "3a0248176bf115cd53e0f15e30bb338b55e2a09f1f9508794fcd3c623725c8bd" "beeb4fbb490f1a420ea5acc6f589b72c6f0c31dd55943859fc9b60b0c1091468" "06a610f234492f78a6311304adffa54285b062b3859ad74eb13ca5d74119aef9" "0058b7d3e399b6f7681b7e44496ea835e635b1501223797bad7dd5f5d55bb450" "ad97202c92f426a867e83060801938acf035921d5d7e78da3041a999082fb565" "55573f69249d1cfdd795dacf1680e56c31fdaab4c0ed334b28de96c20eec01a3" "ec0c9d1715065a594af90e19e596e737c7b2cdaa18eb1b71baf7ef696adbefb0" "31772cd378fd8267d6427cec2d02d599eee14a1b60e9b2b894dd5487bd30978e" "f07583bdbcca020adecb151868c33820dfe3ad5076ca96f6d51b1da3f0db7105" default))
 '(find-file-visit-truename t)
 '(ido-default-buffer-method 'selected-window)
 '(ido-default-file-method 'selected-window)
 '(ido-mode 'both nil (ido))
 '(js2-basic-offset 4)
 '(org-odt-preferred-output-format "docx")
 '(org-todo-keywords '((sequence "TODO" "WAIT" "DONE")))
 '(package-selected-packages
   '(smartparens web-beautify tt-mode paredit goto-chg magit-lfs magit-find-file magit multi-web-mode rpm-spec-mode editorconfig-generate editorconfig js2-mode yaml-mode indent-tools flymake-yaml flycheck-yamllint python-black docker csharp-mode dockerfile-mode json-mode lua-mode poly-R typescript-mode helm poly-markdown poly-noweb polymode dart-mode flycheck csv-mode color-theme-modern adjust-parens))
 '(spice-output-local "Gnucap")
 '(spice-simulator "Gnucap")
 '(spice-waveform-viewer "Gwave")
 '(yaml-indent-offset 4 t))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(ansi-color-names-vector ["#212526" "#ff4b4b" "#b4fa70" "#fce94f" "#729fcf" "#ad7fa8" "#8cc4ff" "#eeeeec"])
 '(spice-output-local "Gnucap")
 '(spice-simulator "Gnucap")
 '(spice-waveform-viewer "Gwave")
 '(text-mode-hook '(turn-on-auto-fill text-mode-hook-identify))
 '(vc-follow-symlinks t))


;; TODO:
;; http://stackoverflow.com/questions/2177687/open-file-via-ssh-and-sudo-with-emacs
;; C-xC-f /ssh:you@remotehost|sudo:remotehost:/path/to/file RET

;; (fset 'sudo-gamap
;;    (lambda (&optional arg) "Keyboard macro." (interactive "p") (kmacro-exec-ring-item (quote ([24 6 47 115 115 104 58 103 97 109 return backspace 124 115 117 100 111 58 103 97 109 97 112 return 47 4] 0 "%d")) arg))) ;; didnt work
