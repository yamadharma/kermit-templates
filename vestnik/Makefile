# MACRO_FORMAT
# latex | xelatex
MACRO_FORMAT = latex

# Indicate which generation procedure to use. One in:
# pdf | dvi | ps | pspdf
LATEX_GENERATION_PROCEDURE = pdf

HAS_MULTIPLE_BIB = yes
# For multbib
#MULTIPLE_BIB_FILES = default rec
# For bibunits
MULTIPLE_BIB_FILES = bu*

# Shell command used to launch MakeIndex
# makeindex | xindy
MAKEINDEX_CMD = xindy

# Style file for MakeIndex
MAKEINDEX_STYLEFILE = index.xdy

#TEX4HT_FINAL_POST_CMD = scripts/html-fix

# Image directory
AUTO_GENERATE_IMAGE_DIRECTORY = image

# Listing directory
#AUTO_GENERATE_LST_DIRECTORY = lst

# BibTeX command
#BIBTEX_CMD = bibtex

# Post LaTeX command
POST_LATEX_CMD = scripts/post_latex_cmd
FINAL_POST_LATEX_CMD = scripts/final_post_latex_cmd

# Post BibTeX command
POST_BIBTEX_CMD = scripts/post_bibtex_cmd

# Additional temporary files
TMPFILES_LOCAL = *.tac *.loa default.titlelist.* split-paper.tex default.xml default.html default*.png
TMPDIRS_LOCAL = split-paper.d default.htmld

include mkfiles/main.mk

include Makefile.postamble

## Основные правила
include mkfiles/main_rules.mk

titlelist: default.titlelist.tex
	./scripts/tex2html

split: default.pdf
	./scripts/split-paper

default.html: default.pdf
	./scripts/tex2html2 default "default,xhtml,mathml" " -cunihtf" "-cvalidate"
