## Process this file with automake to produce Makefile.in

# Tools used for testing.  Theses must be available for "make check".
# The following tools must be included in the distribution.
# simptest/reconf creates them from the versions installed on the system.

SUFFIXES = .sh

check_SCRIPTS = simptest simptestcase
CLEANFILES  = $(check_SCRIPTS)
EXTRA_DIST  = simptest.sh simptestcase.sh

.sh:
	rm -f $@
	echo "#! " $(BASH) > $@
	$(SED) 1d $< >> $@
	chmod ugo+x $@
