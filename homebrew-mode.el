;;; homebrew-mode.el --- minor mode for editing Homebrew formulae

;; Copyright (C) 2015 Alex Dunn

;; Author: Alex Dunn <dunn.alex@gmail.com>
;; URL:
;; Version: 0.1.0
;; Package-Requires: ()
;; Keywords: homebrew brew ruby
;; Prefix: homebrew

;;; Commentary:

;; minor mode for editing Homebrew formula!

;;; Code:

(defconst homebrew-mode-version "0.1.0")

;; Customization

(defgroup homebrew-mode nil
  "Minor mode for editing Homebrew formulae."
  :group 'ruby)

;; Most of the keymap stuff discovered through studying flycheck.el,
;; so ty lunaryorn."
(defcustom homebrew-mode-keymap-prefix (kbd "C-c h")
  "Prefix for homebrew-mode key bindings."
  :group 'homebrew-mode
  :type 'string
  :risky t)

(defcustom homebrew-mode-command-map
  (let ((map (make-sparse-keymap)))
    (define-key map "a"         #'homebrew-autotools)
    map)
  "Keymap for `homebrew-mode` commands prefixed by homebrew-mode-keymap-prefix."
  :group 'homebrew-mode
  :type 'string
  :risky t)

(defvar homebrew-mode-map
  ;; define-key doesn't return the map, so we need a `let`
  (let ((map (make-sparse-keymap)))
    (define-key map homebrew-mode-keymap-prefix homebrew-mode-command-map)
    map)
  "Keymap for `homebrew-mode`.")

(defcustom homebrew-formula-file-patterns
  '( ".*\/homebrew-[^\/]*\/[^\/]*\.rb$"
     ".*\/Formula\/[^\/]*\.rb$"
     ".*\/HomebrewFormula\/[^\/]*\.rb$" )
  "Regular expressions matching Homebrew formulae files.

If you edit this variable, make sure the new value passes the formula-detection tests."
  :group 'homebrew-mode
  :risky t)

(defun homebrew--formula-file-p (buffer-or-string)
  "Return true if BUFFER-OR-STRING is:

1. A buffer visiting a formula file;
2. The filename (a string) of a formula file.

Otherwise return nil."
  ;; If thing is a buffer, convert it to a filename string
  (if (bufferp buffer-or-string)
    (setq buffer-or-string (buffer-file-name buffer-or-string)))
  ;; Now if thing isn't a string we can return nil
  (if (not (stringp buffer-or-string))
      nil
    (let (match)
      (dolist (elem homebrew-formula-file-patterns match)
        (if (string-match elem buffer-or-string)
          (setq match t))))))

(defun homebrew-autotools ()
  "For HEAD builds."
  ;; TODO: search source dir for autogen.sh/bootstrap and check if
  ;; libtool is required or not.
  (interactive)
  (insert "depends_on \"automake\" => :build\n"
    "    depends_on \"autoconf\" => :build\n"
    "    depends_on \"libtool\" => :build"))

;;;###autoload
(defun homebrew-mode-start ()
  "Activate homebrew-mode."
  (interactive)
  (homebrew-mode 1))

;;;###autoload
(defun homebrew-mode-default-hooks ()
  "Register hooks for homebrew-mode."
  (add-hook 'find-file-hook
    (lambda ()
      (if (homebrew--formula-file-p (current-buffer))
        (homebrew-mode 1)))))

;;;###autoload
(define-minor-mode homebrew-mode
  "Helper functions for editing Homebrew formulae"
  :lighter "Brew"
  :keymap homebrew-mode-map)

(provide 'homebrew-mode)

;;; homebrew-mode.el ends here