rm -rf autom4te.cache
aclocal
autoconf
mkdir -p auxiliary
automake -a
