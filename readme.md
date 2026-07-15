## ora_db_func_anno

A small file with oracle database function annotations. This is the result of a private database that consists of function annotations found in blogs and during research.

Use the 'sf.sh' script to query the functions. The script uses sqlite3, use the sqlite rpm package to add this.

This is how to use sf.sh (search function):
```
$ ./sf.sh kglGetMutex
kglGetMutex -- kernel generic lock management
---
```

This shows the sf.sh script could find the first 3 letters (underlined), which probably mean kernel generic lock management. It couldn't find 'GetMutex' however that is so self-explanatory that it doesn't need annotation.

This is how a full function annotation looks like:
```
$ ./sf.sh qercoFetch
qercoFetch -- query execute rowsource count fetch
----------
```

Here the full function is underlined, which means the entire function is found.

You can also use -w for 'wildcard', of which the SQL equivalent would be to add a % at the end of the search argument:
```
$ ./sf.sh -w ktb
ktb  block
ktbapundo  apply undo
ktbchg2  (header) change
ktbt  table
```

Because the letters in the function names are hierarchical, I also added -l for level, in order to investigate if there are function groups at a certain mnemonic level:
```
$ ./sf.sh -l 3 kc
kc  kernel cache
kcb  buffers
kcc  controlfile
kcf  file management
kck  compatibility
kcl  lock manager
kcm  miscellaneous
kco  operation
kcr  redo
kcs  service
kct  threads
kcv  recovery
```

**Forked from GitLab repository https://gitlab.com/FritsHoogland/ora_functions**

**Credits to Frits Hoogland for his amazing work**
