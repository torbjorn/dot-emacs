;; Generic emacs things

;; Borrowed from: https://github.com/higham/dot-emacs/blob/master/.emacs

;; The default is 800 kilobytes.  Measured in bytes.
(setq gc-cons-threshold (* 50 1000 1000))

(setq inhibit-splash-screen t)       ; Don't want splash screen.
(setq inhibit-startup-message t)     ; Don't want any startup message.
(scroll-bar-mode 0 )                 ; Turn off scrollbars.
(tool-bar-mode 0)                    ; Turn off toolbars.
(fringe-mode 0)                      ; Turn off left and right fringe cols.
(size-indication-mode)               ; Show file size in status line.
(put 'dired-find-alternate-file 'disabled nil)
(mouse-avoidance-mode 'exile)        ; Move mouse pointer out of way of cursor.
(setq visible-bell 1)                ; Turn off sound.
;; (context-menu-mode)                  ; Right click instead of middle button.

;; No menus, but can turn back on with keypress.
(menu-bar-mode 0)
(global-set-key (kbd "<C-M-f2>") 'menu-bar-mode)

(setq confirm-nonexistent-file-or-buffer nil)
(fset 'yes-or-no-p 'y-or-n-p)        ; Change yes/no questions to y/n type.
(setq default-input-method 'TeX)     ; For C-\.

;;; * Package initialization
(require 'package)

;; Package archives

(setq package-archives
      '(
        ("gnu-elpa" . "https://elpa.gnu.org/packages/")
        ("melpa" . "http://melpa.org/packages/")
        ("melpa-stable" . "http://stable.melpa.org/packages/")
        )
      )
