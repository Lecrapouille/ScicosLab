
all:	all.pdf

%.pdf : %.tex
	pdflatex $*.tex
	pdflatex $*.tex

clean:
	rm -f  all.pdf
	rm -f *.aux *.log *.toc *.bbl *.pdf *.blg

ignore:
	svn propset svn:ignore -F .cvsignore .
