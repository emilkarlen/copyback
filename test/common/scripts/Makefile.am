## Process this file with automake to produce Makefile.in

SUFFIXES = .sh



check_SCRIPTS = backup-is-locked stdin-is-backupname
CLEANFILES    = $(check_SCRIPTS)
EXTRA_DIST    = backup-is-locked.sh stdin-is-backupname.sh

.sh:
	rm -f $@
	echo "#! " $(BASH) > $@
	$(SED) 1d $< >> $@
	chmod ugo+x $@
