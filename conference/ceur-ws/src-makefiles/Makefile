FILE = `cat NAME`
OUTNAME = `basename \`pwd\``
LATEX=pdflatex
BIBTEX=bibtexu -l ru

all: 
	$(LATEX) $(FILE)
	$(LATEX) $(FILE)
	-$(BIBTEX) $(FILE)
	$(LATEX) $(FILE)
	$(LATEX) $(FILE)
	mkdir -p out
	mv $(FILE).pdf out

rename:
	mkdir -p ../../pdf
	cp out/$(FILE).pdf ../../pdf/$(OUTNAME).pdf

clean:
	-rm -f *.{log,toc,tac,aux,dvi,ps,bbl,blg,tmp,nav,out,snm,vrb,rel,thm,rel,idx,*~} $(FILE).pdf *eps-converted-to.pdf *.synctex.gz *.synctex .compiled
	-rm -f split*
	rm -rf out auto
	for i in $(ALLSUBDIRS); do \
	    (cd $$i; make clean) || exit 1; \
	done

cleanall: clean
