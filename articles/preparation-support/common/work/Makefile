FILE = `cat NAME`
LATEX=pdflatex
LATEX_FLAGS=-shell-escape
BIBTEX=bibtexu


all:
	$(LATEX) $(LATEX_FLAGS) $(FILE)
	$(LATEX) $(LATEX_FLAGS) $(FILE)
	-$(BIBTEX) $(FILE)
	$(LATEX) $(LATEX_FLAGS) $(FILE)
	$(LATEX) $(LATEX_FLAGS) $(FILE)
	mkdir -p out
	mv $(FILE).pdf out

fixbib:
	find . -name "*.bib" -exec \
	sed -i -e "s:^\([[:space:]]*\)url =:\1OPTurl =:g" \
	    -e "s:^\([[:space:]]*\)issn =:\1OPTissn =:g" \
	    -e "s:^\([[:space:]]*\)isbn =:\1OPTisbn =:g" "{}" \;

clean:
	-rm -f *.{log,toc,tac,aux,dvi,ps,bbl,blg,tmp,nav,out,snm,vrb,rel,*~} $(FILE).pdf
	rm -rf out _minted*
	for i in $(ALLSUBDIRS); do \
	    (cd $$i; make clean) || exit 1; \
	done

cleanall: clean