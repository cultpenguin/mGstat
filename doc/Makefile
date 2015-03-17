# Make file for validating/converting mGstat.xml
#
#

validate:

	date +"%Y" > yearnow.xml	
	date "+%b %d, %Y" > pubdate.xml	
	xmllint --valid --noout mGstat.xml

dblatex:
	dblatex mGstat.xml


saxon:
	saxon-xslt mGstat.xml mgstat.xsl

pdf_old:
	make validate
	xsltproc  --output mGstat.fo \
	--stringparam fop.extensions 1 \
	file:///usr/share/xml/docbook/stylesheet/nwalsh/fo/docbook.xsl mGstat.xml
	fop  -fo  mGstat.fo  -pdf  mGstat.pdf

pdf_ldp:
	fop -xml mGstat.xml -xsl /usr/share/xml/docbook/stylesheet/ldp/fo/tldp-print.xsl  -pdf mGstat_ldp.pdf

fo:
	xsltproc -o mGstat.fo /usr/share/xml/docbook/stylesheet/nwalsh/fo/docbook.xsl mGstat.xml


pdf:fo
	fop -pdf mGstat.pdf -fo mGstat.fo

rtf:fo
	fop -rtf mGstat.rtf -fo mGstat.fo


html:
	make validate
	mkdir -p htmldoc
	mkdir -p htmldoc/figures
#	mkdir -p htmldoc/data
	cp figures/*.png htmldoc/figures/.
#	cp data/*.* htmldoc/data/.
	cp style.css htmldoc/.
	xsltproc --xinclude --stringparam html.stylesheet style.css -o htmldoc mgstat.xsl mGstat.xml
	mv *.html htmldoc/.
#xsltproc -o mybook.fo docbook.xsl mybook.xml
linkbook:
	ln -s mGstatBook.xml mGstat.xml
linkarticle:
	ln -s mGstatArticle.xml mGstat.xml
validateall:
	xmllint --valid --noout mGstatBook.xml
	xmllint --valid --noout mGstatArticle.xml




htmlall:
	xsltproc  --output \
	mGstatArticle.html\
	file:///usr/share/xml/docbook/stylesheet/nwalsh/xhtml/docbook.xsl mGstatArticle.xml

	xsltproc  --output \
	mGstatBook.html\
	file:///usr/share/xml/docbook/stylesheet/nwalsh/xhtml/docbook.xsl mGstatBook.xml

allpdf:
	xsltproc  --output mGstatBook.fo \
	--stringparam fop.extensions 1 \
	file:///usr/share/xml/docbook/stylesheet/nwalsh/fo/docbook.xsl mGstatBook.xml

	fop  -fo  mGstatBook.fo  -pdf  mGstatBook.pdf

	xsltproc  --output mGstatArticle.fo \
	--stringparam fop.extensions 1 \
	file:///usr/share/xml/docbook/stylesheet/nwalsh/fo/docbook.xsl mGstatArticle.xml

	fop  -fo  mGstatArticle.fo  -pdf  mGstatArticle.pdf

clean:
	rm -f *.htmldoc
	rm -fr htmldoc
	rm -f *.op
	rm -f *.pdf

all:html dblatex



help:
	# USAGE
	# make linkbook: Use booklayout 
