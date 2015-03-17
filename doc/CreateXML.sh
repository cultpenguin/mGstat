xmllint --valid --noout mGstat.xml

xsltproc file:///usr/share/xml/docbook/stylesheet/nwalsh/xhtml/docbook.xsl mGstat.xml > mGstat.xhtml

xsltproc --output mGstat.fo  --stringparam fop.extensions 1 file:///usr/share/xml/docbook/stylesheet/nwalsh/fo/docbook.xsl mGstat.xml

fop -fo mGstat.fo -pdf mGstat.pdf