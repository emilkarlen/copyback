## Process this file with automake to produce Makefile.in

bin_SCRIPTS = copyback
CLEANFILES  = $(bin_SCRIPTS) TAGS
EXTRA_DIST  = copyback.sh

copyback: copyback.sh constants.sh
	rm -f copyback
	cat constants.sh > copyback
	$(SED) '1,6d' copyback.sh >> copyback
	chmod ugo+x copyback

TAGS: *.sh
	$(TAGS) *.sh
