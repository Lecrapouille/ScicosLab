
all:	Texte.pdf

%.pdf : %.tex
	latex $*.tex
	latex $*.tex
	dvips -Ppdf $*.dvi
	ps2pdf $*.ps
	$(RM) $*.dvi $*.ps


clean:
	rm -f  Texte.pdf
	rm -f *.aux *.log *.toc *.bbl *.pdf *.blg

ignore:
	svn propset svn:ignore -F .cvsignore .
