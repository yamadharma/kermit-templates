# MACRO_FORMAT
# latex | xelatex | lualatex
MACRO_FORMAT = latex

# Indicate which generation procedure to use. One in:
# pdf | dvi | ps | pspdf
LATEX_GENERATION_PROCEDURE = pdf

#HAS_MULTIPLE_BIB = yes
# For multbib
#MULTIPLE_BIB_FILES = default rec
# For bibunits
#MULTIPLE_BIB_FILES = bu*

# Shell command used to launch MakeIndex
# makeindex | xindy | upmendex
MAKEINDEX_CMD = upmendex

# Style file for MakeIndex
MAKEINDEX_STYLEFILE = index.xdy

#MAKEINDEX_FULL_CMD = ./scripts/t2a2utf ${IDXFILE}; recode UTF8..CP1251 ${IDXFILE} ; ${MAKEINDEX_CMD} ${MAKEINDEX_FLAGS} ${IDXFILE}; enca -c default.ind

# Shell command used to make glossary
# makeindex | xindy | upmendex
MAKEGLOS_CMD = xindy

# Style file for glossary
#MAKEGLOS_STYLEFILE = index.xdy

#TEX4HT_FINAL_POST_CMD = scripts/html-fix

# Image directory
AUTO_GENERATE_IMAGE_DIRECTORY = image

# Listing directory
#AUTO_GENERATE_LST_DIRECTORY = lst

# BibTeX command
# bibtex | pybtex | bibtexu -l ru | bibtex8 -W -c utf8cyrillic | biber
#BIBTEX_CMD = bibtex

# Pre LaTeX command
#PRE_LATEX_CMD = scripts/pre_latex_cmd

# Post LaTeX command
#POST_LATEX_CMD = scripts/post_latex_cmd ; scripts/pre_bibtex_cmd
#FINAL_POST_LATEX_CMD = scripts/final_post_latex_cmd

# Pre BibTeX command
#PRE_BIBTEX_CMD = scripts/pre_bibtex_cmd

# Post BibTeX command
#POST_BIBTEX_CMD = scripts/post_bibtex_cmd

# Additional temporary files
#TMPFILES_LOCAL = *.tac *.loa default.titlelist.* split-paper.tex default.xml default.html default*.png *.4o[mftsy]
#TMPDIRS_LOCAL = split-paper.d default.htmld
