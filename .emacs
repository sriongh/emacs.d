;; Added by Package.el.  This must come before configurations of
;; installed packages.  Don't delete this line.  If you don't want it,
;; just comment it out by adding a semicolon to the start of the line.
;; You may delete these explanatory comments.
;; ____________________________________________________________________________
;; Aquamacs custom-file warning:
;; Warning: After loading this .emacs file, Aquamacs will also load
;; customizations from `custom-file' (customizations.el). Any settings there
;; will override those made here.
;; Consider moving your startup settings to the Preferences.el file, which
;; is loaded after `custom-file':
;; ~/Library/Preferences/Aquamacs Emacs/Preferences
;; _____________________________________________________________________________
(require 'package)
(require 'password-cache)

;(setq package-archives 
;      '(("gnu" . "http://elpa.gnu.org/packages/")
;	("marmalade" . "http://marmalade-repo.org/packages/")
;	("melpa" . "http://melpa.org/packages/")))

(add-to-list 'package-archives
             '("melpa" . "https://melpa.org/packages/"))
(package-initialize)
(global-linum-mode t)

;; set default font
(set-default-font "Monaco 14")
(setq-default indent-tabs-mode nil)

;; add all load-paths before require
(add-to-list 'load-path "~/.emacs.d/llvm/")

;; auto insert
(require 'auto-complete)

;; required for auto-inserting LLVM header
(require 'autoinsert)
(require 'yasnippet)

;; llvm, mlir and tablegen modes
(require 'mlir-mode)
(require 'llvm-mode)
(require 'tablegen-mode)

;; cscope
(require 'xcscope)


;; autocomplete
(global-auto-complete-mode t)
(setq ac-modes
      '(c++-mode
	c-mode
	makefile-mode
        mlir-mode))

;; (yas-global-mode 1)

(defun my-autoinsert-yas-expand()
  "Replace text in yasnippet template."
  (yas-expand-snippet (buffer-string) (point-min) (point-max)))

;; llvm and mlir settings
(custom-set-variables
 '(auto-insert 'llvm)
 '(auto-insert-directory "~/.emacs.d/templates")
 )

(add-to-list 'auto-insert-alist '(("\\.\\([Hh]\\|hh\\|hpp\\)\\'" . "C / C++ header") . 
                                  ["llvm-template.h" my-autoinsert-yas-expand]))

(add-to-list 'auto-insert-alist '(("\\.\\([Cc]\\|cc\\|cpp\\)\\'" . "C / C++ program") .
                                  ["llvm-template.h" my-autoinsert-yas-expand]))


;; LLVM Style Editing
;; LLVM coding style guidelines in emacs
;; Maintainer: LLVM Team, http://llvm.org/

(defun llvm-lineup-statement (langelem)
  (let ((in-assign (c-lineup-assignments langelem)))
    (if (not in-assign)
        '++
      (aset in-assign 0
            (+ (aref in-assign 0)
               (* 2 c-basic-offset)))
      in-assign)))

;; Add a cc-mode style for editing LLVM C and C++ code
(c-add-style "llvm.org"
             '("gnu"
	       (fill-column . 80)
	       (c++-indent-level . 2)
	       (c-basic-offset . 2)
	       (indent-tabs-mode . nil)
	       (c-offsets-alist . ((arglist-intro . ++)
				   (innamespace . 0)
				   (member-init-intro . ++)
				   (statement-cont . llvm-lineup-statement)))))

;; Files with "llvm" in their names will automatically be set to the
;; llvm.org coding style.
(add-hook 'c-mode-common-hook
	  (function
	   (lambda nil 
	     (if (string-match "llvm" buffer-file-name)
		 (progn
		   (c-set-style "llvm.org"))))))


;; org mode auto-fill
(add-hook 'org-mode-hook 'turn-on-auto-fill)
;; (add-to-list 'org-emphasis-alist
;;         '("*" (:foreground "red")))

(eval-after-load "org"
  '(require 'ox-gfm nil t))

;; asm mode hook
(add-hook 'asm-mode-hook 'toggle-truncate-lines)
(put 'erase-buffer 'disabled nil)

;; calendar work week
(setq calendar-week-start-day 1)

(setq calendar-intermonth-text
      '(propertize
        (format "%2d"
                (car
                 (calendar-iso-from-absolute
                  (calendar-absolute-from-gregorian (list month day year)))))
        'font-lock-face 'font-lock-warning-face))

(setq calendar-intermonth-header
      (propertize "Wk"                  ; or e.g. "KW" in Germany
                  'font-lock-face 'font-lock-keyword-face))

;; mlir mode hook
(defun mlir-tabs ()  
  (setq indent-tabs-mode nil)
  (setq tab-width 2)
  (setq indent-line-function 'insert-tab))

(add-hook 'mlir-mode-hook 'mlir-tabs)

;; dot graphviz mode
(require 'use-package)
(use-package graphviz-dot-mode
  :ensure t
  :config
  (setq graphviz-dot-indent-width 4))
