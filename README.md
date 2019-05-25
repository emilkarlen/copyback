Simple backup utility - stores backups as copies, using rsync

Tries to be clever at managing backups using the directory layout of
the source file/dir.


# Documentation


There is a [Users Guide](https://emilkarlen.github.io/copyback/copyback-UsersGuide-en.html).


Installation of `copyback` installs this Users Guide,
and also a man page.


# Dependencies


`copyback` is a shell script, that relies heavily on the

 - OS environment
 - command line utilities
 - syntax of file names

See [configure.ac](https://github.com/emilkarlen/copyback/blob/master/configure.ac)
for dependencies on programs in PATH.

Should run in a GNU/Linux environment. Not BSD, though.


# Tests


`copyback` is tested by a program (`simptest`), which is also written
in shell script.

Neither `copyback` itself or the tests are portable!

Tested on Ubuntu Linux. Bash v4.3.


# History


`copyback` was developed while learning shell script (around 2007).


The test program `simptest`, was developed for the purpose of
testing `copyback`,
also while learning shell script.


[Exactly](https://emilkarlen.github.io) is a robust test tool,
inspired by `simptest`.
