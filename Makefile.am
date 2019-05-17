## Process this file with automake to produce Makefile.in

.PHONY: maintainer-clean

doc_DATA = COPYING

SUBDIRS = src bin test/common/scripts help

TESTS=bin/run_tests

EXTRA_DIST = tests reconf.sh

uninstall-hook:
	rm -rf $(pkgdatadir)

maintainer-clean:
	make -C help maintainer-clean
