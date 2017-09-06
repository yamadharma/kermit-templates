FILE = `cat NAME`
LATEX=pdflatex
BIBTEX=bibtex

all:
	$(LATEX) $(FILE)
	$(LATEX) $(FILE)
	-$(BIBTEX) $(FILE)
	$(LATEX) $(FILE)
	$(LATEX) $(FILE)
	mkdir -p out
	mv $(FILE).pdf out

fixbib:
	find . -name "*.bib" -exec \
	sed -i -e "s:^\([[:space:]]*\)url =:\1OPTurl =:g" \
	    -e "s:^\([[:space:]]*\)issn =:\1OPTissn =:g" \
	    -e "s:^\([[:space:]]*\)isbn =:\1OPTisbn =:g" "{}" \;

clean:
	-rm -f *.{log,toc,tac,aux,dvi,ps,bbl,blg,tmp,nav,out,snm,vrb,rel,*~} $(FILE).pdf
	rm -rf out
	for i in $(ALLSUBDIRS); do \
	    (cd $$i; make clean) || exit 1; \
	done

cleanall: clean