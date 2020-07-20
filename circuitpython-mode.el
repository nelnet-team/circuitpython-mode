;;; circuitpython-mode.el --- Minor mode for CircuitPython

;; Author: Lee Nelson <lnelson@nelnet.org>
;; Version: 0.6
;; Keywords: circuitpython, adafruit
;; URL: https://github.com/nelnet-team/circuitpython-mode

;;; Commentary:
;; 1 circuitpython-mode.el
;; ═══════════════════════

;; 1.1 This is in early development.
;; ─────────────────────────────────

;;   Only working code will be committed to MELPA Stable, but the current
;;   functionality is limited


;; 1.2 Description
;; ───────────────

;;   This package provides a minor mode called `circuitpython-mode'.  This
;;   mode is intended to help with the workflow in circuitpython
;;   development.  It is invoked by typing:

;;   ┌────
;;   │ M-x circuitpython-mode
;;   └────


;; 1.3 Usage
;; ─────────

;; 1.3.1 Compile (copy file to board)
;; ╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌

;;   A function, `circuitpython-compile-copy', is added that is invoked
;;   each time the buffer is saved (after-save-hook).  When invoked, the new
;;   command will update the compile-command to be a shell command that
;;   will copy the current file to a different directory (ie the board).
;;   The destination directory needs to be defined as a *file-local* or
;;   *dir-local* variable.  After each file save (**[C-x C-s]**, **[C-x
;;   w]**, etc), the default compile-command will be something like:

;;   ┌────
;;   │ cp filename.py /some/path/some/where/
;;   └────

;;   This does not modify the behavior of `compile' itself, it only changes
;;   the command that will presented as the default compile command when
;;   invoking `compile' (usually **[C-c c]** )


;; 1.3.2 Compile .mpy
;; ╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌

;;   Additionally, a new command, `circuitpython-mpy-compile', is added and
;;   bound to **[C-c m]**.  If the variable `mpy-compiler' is defined (ie
;;   as file-local or dir-local), then that command will be used.
;;   Otherwise the command "mpy-cross" is used.  One potentional reason to
;;   specify the mpy-compiler is if it is not in $PATH.  This will define
;;   the compile-command to be something like:

;;   ┌────
;;   │ mpy-cross filename.py
;;   └────

;;   There is also a command, `circuitpython-set-mpy-compiler', bound to
;;   **[C-c n]** that allows the user to override the process described
;;   above and provide an alternative command.

;;   After the mpy compile command is defined, `compile' is called, after
;;   which `circuitpython-compile-copy' (see above) is called.  This means
;;   that after compiling an .mpy, the compile command will revert back to
;;   being the command to copy the file to the board.


;; 1.4 Example directory local variables
;; ─────────────────────────────────────

;;   `.dir-locals.el'

;;   ┌────
;;   │ ((nil . ((circuitpython-copy-path . "/mnt/chromeos/removable/CIRCPY/"))))
;;   └────

;;; Code:

(setq circuitpython-current-mpy-compiler "mpy-cross")

(defun circuitpython-compile-copy ()
  "Set up 'compile-command' to copy script to board.
This should set 'compile-command' to something like:
cp somefile.py /mnt/foo/bar/CIRCPY/"
    (set (make-variable-buffer-local 'compile-command)
         (concat
	  "cp "
	  (file-name-nondirectory (buffer-file-name (current-buffer)))
	  " "
	  circuitpython-copy-path)))

(defun circuitpython-set-mpy-compiler (newcommand)
  "Allow the user to interactively set the mpy compiler.
This will provide the existing value of 'circuitpython-current-mpy-compiler'
as a suggestion.  NEWCOMMAND is the actual compile command that will be set"
  (interactive (list
		(read-string
		 (format "New mpy compile command (%s): "
			 (symbol-value 'circuitpython-current-mpy-compiler))
		 nil nil
		 (symbol-value 'circuitpython-current-mpy-compiler))))
  (setq circuitpython-current-mpy-compiler newcommand)
  (message "mpy compile command set to %s" circuitpython-current-mpy-compiler))

(defun circuitpython-get-mpy-compiler ()
  "Return value for the mpy compiler.
If the variable is already defined (maybe file-local
or dir-local) then return that value.
Otherwise, return the value 'mpy-cross'"
  (if (boundp 'mpy-compiler)
      (symbol-value 'mpy-compiler)
    (symbol-value 'circuitpython-current-mpy-compiler)))

(defun circuitpython-mpy-compile ()
  "Alternate compile for circuitpython.
Sets 'compile-command' to use mpy-cross then calls compile
after which it calls 'circuitpython-compile-copy' to restore
the original form.  This should set 'compile-command' to be
Something like:
mpy-cross filename.py"
  (interactive)
    (set (make-variable-buffer-local 'compile-command)
         (concat
	  (circuitpython-get-mpy-compiler)
	  " "
	  (file-name-nondirectory (buffer-file-name (current-buffer)))))
    (compile compile-command)
    (circuitpython-compile-copy))

;;;###autoload
(define-minor-mode circuitpython-mode
  "Minor mode for CircuitPython"
  :lighter " circpy"
  :keymap (let ((map (make-sparse-keymap)))
            (define-key map (kbd "C-c m") 'circuitpython-mpy-compile)
            (define-key map (kbd "C-c n") 'circuitpython-set-mpy-compiler)
            map))


;; If the variable circuitpython-copy-path is defined
;; (usually as a file-local or dir-local variable), then
;; add a hook to set the compile command after each save
;;;###autoload
(if (boundp 'circuitpython-copy-path)
    (add-hook 'after-save-hook 'circuitpython-compile-copy)
  nil)

(provide 'circuitpython-mode)

;;; circuitpython-mode.el ends here
