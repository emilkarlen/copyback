.PHONY: maintainer-clean

dist_man_MANS = copyback.1

dist_html_DATA = copyback-UsersGuide-en.html html.css

EXTRA_DIST = copyback.refentry.docbook.xml \
	     copyback-UsersGuide-en.docbook.xml

XSL_DB2MAN=http://docbook.sourceforge.net/release/xsl/current/manpages/docbook.xsl

copyback.1: copyback.refentry.docbook.xml
	xsltproc $(XSL_DB2MAN) $<

maintainer-clean:
	rm -f $(MAINTAINER_TARGETS)

copyback-UsersGuide-en.html: copyback-UsersGuide-en.docbook.xml
	xsltproc --output copyback-UsersGuide-en.html customization-html.xsl copyback-UsersGuide-en.docbook.xml

copyback-UsersGuide-en.pdf: copyback-UsersGuide-en.docbook.xml
	xmlto --output copyback-UsersGuide-en.pdf --skip-validation -m db2fo-parameters.xsl pdf $<
