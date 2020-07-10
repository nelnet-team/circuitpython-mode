#circuitpython-mode.el
This package provides a minor mode called circuitpython-mode
This mode is intended to help with the workflow in circuitpython
development. It is invoked by typing:
```
M-x circuitpython-mode
```
When invoked, each time the buffer is saved (after-save-hook),
the new command `circuitpython-compile-copy` will set
the compile-command (which is usually bound to **[C-c c]**)
is updated to be a shell command that will copy the
current file to a different directory (ie the board).
The destination directory needs to be defined as a
*file-local* or *dir-local* variable.
After each file save (**[C-x C-s]**, **[C-x w]**, etc), the default
compile-command will be something like:
```
cp filename.py /some/path/some/where/
```

Additionally, a new command, `circuitpython-mpy-compile`, is added and
bound to **[C-c m]**.  If the variable `mpy-compiler` is defined (ie as
file-local or dir-local), then that command will be used.  Otherwise
the command "cross-mpy" is used.  One potentional reason to specify
the mpy-compiler is if it is not in $PATH. This will define the
default compile-command to be something like:
```
mpy-cross filename.py
```
After this is defined, `compile` is called, after which
`circuitpython-compile-copy` (see above) is called.


