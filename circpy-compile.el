
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

;; If the variable circuitpython-copy-path is defined
;; (usually as a file-local or dir-local variable), then
;; add a hook to set the compile command after each save
(if (boundp 'circuitpython-copy-path)
    (add-hook 'after-save-hook (circuitpython-compile-copy))
  nil)

