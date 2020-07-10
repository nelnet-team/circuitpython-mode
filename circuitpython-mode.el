;;; circuitpython-mode.el --- Minor mode for CircuitPython

;; Author: Lee Nelson <lnelson@nelnet.org>
;; Version: 0.3
;; Keywords: circuitpython, adafruit
;; URL: https://github.com/nelnet-team/circuitpython-mode

;;; Commentary:
;; #circuitpython-mode.el
;; This package provides a minor mode called circuitpython-mode
;; This mode is intended to help with the workflow in circuitpython
;; development. It is invoked by typing:
;; ```
;; M-x circuitpython-mode
;; ```
;; When invoked, each time the buffer is saved (after-save-hook),
;; the new command `circuitpython-compile-copy` will set
;; the compile-command (which is usually bound to **[C-c c]**)
;; is updated to be a shell command that will copy the
;; current file to a different directory (ie the board).
;; The destination directory needs to be defined as a
;; *file-local* or *dir-local* variable.
;; After each file save (**[C-x C-s]**, **[C-x w]**, etc), the default
;; compile-command will be something like:
;; ```
;; cp filename.py /some/path/some/where/
;; ```

;; Additionally, a new command, `circuitpython-mpy-compile`, is added and
;; bound to **[C-c m]**.  If the variable `mpy-compiler` is defined (ie as
;; file-local or dir-local), then that command will be used.  Otherwise
;; the command "cross-mpy" is used.  One potentional reason to specify
;; the mpy-compiler is if it is not in $PATH. This will define the
;; default compile-command to be something like:
;; ```
;; mpy-cross filename.py
;; ```
;; After this is defined, `compile` is called, after which
;; `circuitpython-compile-copy` (see above) is called.

(defun circuitpython-compile-copy ()
  "Set up compile-command to copy script to board.
This should set compile-command to something like:
cp somefile.py /mnt/foo/bar/CIRCPY/"
    (set (make-variable-buffer-local 'compile-command)
         (concat
	  "cp "
	  (file-name-nondirectory (buffer-file-name (current-buffer)))
	  " "
	  circuitpython-copy-path)))

(defun get-mpy-compiler ()
  "Return value for the mpy compiler.
If the variable is already defined (maybe file-local
or dir-local) then return that value.
Otherwise, return the value 'mpy-cross'"
  (if (boundp 'mpy-compiler)
      mpy-compiler
    ("mpy-cross")))

(defun circuitpython-mpy-compile ()
  "Alternate compile for circuitpython. Sets compile-command
to use mpy-cross then calls compile after which it calls
circuitpython-compile-copy to restore the original form.
This should set compile-command to be something like:
mpy-cross filename.py
It assumed this will be bound to something C-c m"
    (set (make-variable-buffer-local 'compile-command)
         (concat
	  (get-mpy-compiler)
	  " "
	  (file-name-nondirectory (buffer-file-name (current-buffer)))))
    (compile)
    (circuitpython-compile-copy))

;;;###autoload
(define-minor-mode circuitpython-mode
  "Minor mode for CircuitPython"
  :lighter " circpy"
  :keymap (let ((map (make-sparse-keymap)))
            (define-key map (kbd "C-c m") 'circuitpython-mpy-compile)
            map))


;; If the variable circuitpython-copy-path is defined
;; (usually as a file-local or dir-local variable), then
;; add a hook to set the compile command after each save
;;;###autoload
(if (boundp 'circuitpython-copy-path)
    (add-hook 'after-save-hook (circuitpython-compile-copy))
  nil)

(provide 'circuitpython-mode)
