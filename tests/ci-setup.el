;;; ci-setup.el --- Common setup for GitHub Actions tests

(setq debug-on-error t)
(add-to-list 'load-path "~/.emacs.d/lisp")

;; Disable network-dependent sections for CI
(setq myconfig-straight nil)
(setq myconfig-secret-service nil)
(setq myconfig-magit nil)