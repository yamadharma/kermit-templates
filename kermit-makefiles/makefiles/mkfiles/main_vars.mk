# -*- mode: make -*-

# Name of the main TeX file (without extension and path)
ifndef FILE
FILE = default
endif

# Indicate if the PDF document must be opened
OPEN_PDF = yes

# Indicate if the images should be automatically generated
AUTO_GENERATE_IMAGES = yes

# Give the directory where to search for the images to
# auto-generate. The path is relative to the project directory.
ifndef AUTO_GENERATE_IMAGE_DIRECTORY
AUTO_GENERATE_IMAGE_DIRECTORY = .
endif

ifndef AUTO_GENERATE_LST_DIRECTORY
AUTO_GENERATE_LST_DIRECTORY = lst
endif

# Indicate which generation procedure to use. One in:
# pdf, dvi, ps, pspdf
ifeq ("${LATEX_GENERATION_PROCEDURE}","")
LATEX_GENERATION_PROCEDURE = dvi
endif

# Force the PDF viewer (could be defined in your shell environment).
# If not specified, make will search for acroread, evince and xpdf
;PDF_VIEWER := /usr/bin/evince

# Shell command used to update the document from a SCM (CVS or SVN)
SCM_UPDATE_CMD = bzr update

# Shell command used to commit the document into a SCM (CVS or SVN)
SCM_COMMIT_CMD = bzr commit

# Use local texmf.cnf
TEXMFCNF := .:$(shell kpsewhich --expand-path '$$TEXMFCNF')

# Macro format used
# latex by default
ifeq ("${MACRO_FORMAT}","")
MACRO_FORMAT = latex
endif

# Shell command used to compile the LaTeX document
ifeq ("-${LATEX_GENERATION_PROCEDURE}","-pdf")
LATEX_CMD_MAIN = pdflatex
else
LATEX_CMD_MAIN = latex
endif

# LaTeX flags which must be passed when the document
# must be compiled in draft mode
ifeq ("-${LATEX_GENERATION_PROCEDURE}","-pdf")
LATEX_DRAFT_FLAGS = -draftmode -shell-escape # since pdflatex 1.40
else
LATEX_DRAFT_FLAGS =
endif

# Redefine for XeLaTeX
ifeq ("${MACRO_FORMAT}","xelatex")
LATEX_GENERATION_PROCEDURE = pdf
LATEX_CMD_MAIN = xelatex
LATEX_DRAFT_FLAGS = --no-pdf
endif

# Redefine for LuaLaTeX
ifeq ("${MACRO_FORMAT}","lualatex")
LATEX_GENERATION_PROCEDURE = pdf
LATEX_CMD_MAIN = lualatex
LATEX_DRAFT_FLAGS = 
endif

LATEX_CMD = TEXMFCNF=${TEXMFCNF} ${LATEX_CMD_MAIN}

# LaTeX flags which must be passed when the document
# must be compiled not in draft mode
LATEX_FLAGS = -shell-escape

# Pre latex command
ifndef PRE_LATEX_CMD
PRE_LATEX_CMD = echo "No pre-latex command"
endif

# Post latex command
ifndef POST_LATEX_CMD
POST_LATEX_CMD = echo "No post-latex command"
endif

ifndef FINAL_POST_LATEX_CMD
FINAL_POST_LATEX_CMD =
endif

# Shell command used to launch BibTeX
ifndef BIBTEX_CMD
BIBTEX_CMD = bibtex
#BIBTEX_CMD = mkfiles/scripts/rubibtex.utf8
endif

# bibtex flags
BIBTEX_FLAGS =

# Shell command used to fix BibTeX files
# FIX_BBL_CMD = mkfiles/scripts/fixbbl.py
FIX_BBL_CMD =

# Check if has bibtex citation
HAS_BIBTEX_CITATION_CMD = mkfiles/scripts/has_bibtex_citation

# Multiple bibliography
# z.B for  multibib, bibunits, chapterbib
ifdef HAS_MULTIPLE_BIB
MULTIPLE_BIB="yes"
endif

# List of needed bib-files
ifeq ("${MULTIPLE_BIB_FILES}","")
MULTIPLE_BIB_FILES=${FILE}
endif

# Pre bibtex command
ifndef PRE_BIBTEX_CMD
PRE_BIBTEX_CMD = echo "No pre-bibtex command"
endif

# Post bibtex command
ifndef POST_BIBTEX_CMD
POST_BIBTEX_CMD = echo "No post-bibtex command"
endif

# Shell command used to translate DVI to PS
DVIPS_CMD = dvips

# dvips flags
DVIPS_FLAGS =

# Shell command used to translate PS to PDF
PS2PDF_CMD = ps2pdf

# ps2pdf flags
PS2PDF_FLAGS = 

# Program that permits to touch a file
TOUCH_CMD = mkfiles/scripts/touch

# Check if has index exist
HAS_INDEX_CMD = mkfiles/scripts/has_index

# Shell command used to launch MakeIndex
# makeindex | xindy | upmendex
ifeq ("${MAKEINDEX_CMD}","")
MAKEINDEX_CMD = makeindex
endif

# tex2xindy
TEX2XINDY = tex2xindy 

# Style file for MakeIndex
ifndef MAKEINDEX_STYLEFILE
MAKEINDEX_STYLEFILE = 
endif

# MakeIndex flags
MAKEINDEX_FLAGS = 

# Check if has glossary exist
HAS_GLOS_CMD = mkfiles/scripts/has_glossary

# Shell command used to make glossary
# makeindex | xindy
ifeq ("${MAKEGLOS_CMD}","")
MAKEGLOS_CMD = makeindex
endif

# Style file for glossary
ifndef MAKEGLOS_STYLEFILE
ifeq ("${MAKEGLOS_CMD}","makeindex")
MAKEGLOS_STYLEFILE = ${FILE}.ist
endif
ifeq ("${MAKEGLOS_CMD}","xindy")
MAKEGLOS_STYLEFILE = ${FILE}.xdy
else
MAKEGLOS_STYLEFILE = ${FILE}
endif
endif

# makeglos flags
ifndef MAKEGLOS_FLAGS
ifeq ("${MAKEGLOS_CMD}","makeindex")
MAKEGLOS_FLAGS =
endif
ifeq ("${MAKEGLOS_CMD}","xindy")
MAKEGLOS_FLAGS = -I xindy -L russian -C utf8
else
MAKEGLOS_FLAGS =
endif
endif

# Program that permits to display a message in stdout
ECHO_CMD = mkfiles/scripts/echo

# Program that permits to display a message in stderr
ECHO_ERR_CMD = mkfiles/scripts/echo_err

# Program that permits to find a file
# FIND_CMD = mkfiles/scripts/script_find
FIND_CMD = find -L

# Convertion to HTML

# HTML extenstiom
ifeq ("${HTML_EXT}","")
HTML_EXT = html
endif

# TeX to HTML command
TEX4HT_TEX_CMD = latex

# Out directory for HTML
TEX4HT_TEX_OUT_DIR=${FILE}.htmld

# Arguments for TeX to HTML command
TEX4HT_TEX_ARG_1 = default,charset=utf-8
TEX4HT_TEX_ARG_2 = -cunihtf -utf8
# TEX4HT_TEX_ARG_3 = -p -cvalidate
TEX4HT_TEX_ARG_3 = -cvalidate
TEX4HT_TEX_ARG_4 = 
TEX4HT_TEX_ARG_5 = -d./${TEX4HT_TEX_OUT_DIR}/ -m644 

# For MathML
ifneq ("${HTML_MATHML}","")
HTML_EXT = xht
TEX4HT_TEX_ARG_1 += ,xhtml,mozilla,xht
TEX4HT_TEX_ARG_2 += -cmozhtf
endif

ifndef TEX4HT_TEX_POST_CMD
TEX4HT_TEX_POST_CMD = ./bin/t2_utf8.sh default.xref 
endif

ifndef TEX4HT_POST_CMD
TEX4HT_POST_CMD = cd ${TEX4HT_TEX_OUT_DIR} ; for i in *.${HTML_EXT} ; do ../bin/t2_utf8.sh $$i ; done
endif

ifndef TEX4HT_FINAL_POST_CMD
TEX4HT_FINAL_POST_CMD = 
endif

SRC_DIR=`pwd`

#-----------------------------------
#----------- DO NOT CHANGE BELOW
#-----------------------------------

#
# External Script
#
# Launch a shell command
launchShell = $(shell PATH="$$PATH:${PATH}" $1)



TEXFILE=${FILE}.tex
DVIFILE=${FILE}.dvi
PDFFILE=${FILE}.pdf
PSFILE=${FILE}.ps
BBLFILE=${FILE}.bbl
AUXFILE=${FILE}.aux

ifndef IDXFILE
IDXFILE=${FILE}.idx
endif

INDFILE=${FILE}.ind
GLOFILE=${FILE}.glo
GLSFILE=${FILE}.gls
GLGFILE=${FILE}.glg		# Log for glossary


ADDITIONALTEXFILES = $(call launchShell, ${FIND_CMD} . -name "*.tex" -path "./*/*")
ADDITIONALAUXFILES = $(call launchShell, ${FIND_CMD} . -name "*.aux" -path "./*/*")
TEXFILES = ${TEXFILE} ${ADDITIONALTEXFILES}
BIBFILES = $(call launchShell, ${FIND_CMD} . -name "*.bib")
STYFILES = $(call launchShell, ${FIND_CMD} . -name "*.sty" -o -name "*.cls")
EMACSFILES = $(call launchShell, ${FIND_CMD} . -name "*.rel")
EPS_CONVERTED_TO_PDF = $(call launchShell, ${FIND_CMD} . -name "*-eps-converted-to.pdf")

TMPIMAGES =
IMAGES =
SOURCE_IMAGES =

MAKEFILE_FILENAME = Makefile



TMPFILES = bibtex.stamp ${AUXFILE} *.log ${BBLFILE} *.blg \
           *.cb *.toc *.out *.lof *.lot *.los *.maf *.snm *.nav \
           *.fot \
           *.lom *.tmp *.loa ${IDXFILE} *.ilg ${INDFILE} \
           *.mtc *.mtc[0-9] *.mtc[0-9][0-9] *.mtc[0-9][0-9][0-9] \
           *.mtf *.mtf[0-9] *.mtf[0-9][0-9] *.mtf[0-9][0-9][0-9] \
           *.mtl *.mtl[0-9] *.mtl[0-9][0-9] *.mtl[0-9][0-9][0-9] \
           *.bmt *.thlodef *.lbl *.brf *.vrb *.spl \
           *.thm *.xdv *.aux *.bbl \
           ${GLOFILE} ${GLSFILE} ${GLGFILE} makeglossary.stamp \
           *.idx *.glo *.raw \
           makeindex.stamp ${ADDITIONALAUXFILES} \
           ${PDFFILE} ${DVIFILE} ${PSFILE} \
           VARIABLES \
           *.css ${FILE}-js.* *.pfg lst.tex \
           *.4tc *.4ct *.idv *.${HTML_EXT} *.lg *.xref *.4dx *.4ix *.dvi \
           *.bak *.pyg \
           *.bbl *.bcf *.blg *-blx.aux *-blx.bib *.brf *.run.xml \
           ${EPS_CONVERTED_TO_PDF} \
           ${TMPFILES_LOCAL}

TMPDIRS = _minted-* ${TMPDIRS_LOCAL}

# $(call launchShell, ${FIND_CMD} . -name "auto") \

DESINTEGRABLEFILES = ${PRIVATE_IMAGES} ${PRIVATE_TMPIMAGES} ${BACKUPFILES} ${EMACSFILES}

BACKUPFILES = $(call launchShell, ${FIND_CMD} . -name "*~") \
	      $(call launchShell, ${FIND_CMD} . -name "*.bak") \
	      $(call launchShell, ${FIND_CMD} . -name "*.backup")

ifdef HAS_MULTIPLE_BIB
BBLFILE = $(addsuffix .bbl,${MULTIPLE_BIB_FILES})
endif

ifeq ("-${AUTO_GENERATE_IMAGES}","-yes")
PRIVATE_TMPIMAGES = ${TMPIMAGES}
PRIVATE_IMAGES = ${IMAGES}
else
PRIVATE_TMPIMAGES =
PRIVATE_IMAGES =
endif

# Detect the name of the file that the compilation must generate
ifeq ("-${LATEX_GENERATION_PROCEDURE}","-dvi")
COMPILATION_TARGET_FILE = ${DVIFILE}
else
ifeq ("-${LATEX_GENERATION_PROCEDURE}","-ps")
COMPILATION_TARGET_FILE = ${DVIFILE}
else
ifeq ("-${LATEX_GENERATION_PROCEDURE}","-pspdf")
COMPILATION_TARGET_FILE = ${DVIFILE}
else
COMPILATION_TARGET_FILE = ${PDFFILE}
endif
endif
endif

#
# Translator management is here
#
# List of loaded packages
LOADED_TRANSLATORS = 

# Replies if the specified translator is loaded
isTranslatorLoaded = $(if $(filter $1,${LOADED_TRANSLATORS}),true,false)

# Replies the mkfile of a translator.
getTranslatorMkfile = $(if ${TRANSLATOR_MKFILE_$1}, ${TRANSLATOR_MKFILE_$1}, mkfiles/$1.mk)
