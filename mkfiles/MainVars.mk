# autolatex - MainVars.mk
# Copyright (C) 1998-07  Stephane Galland <galland@arakhne.org>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; see the file COPYING.  If not, write to
# the Free Software Foundation, Inc., 59 Temple Place - Suite 330,
# Boston, MA 02111-1307, USA.


# Name of the main TeX file (without extension and path)
FILE = Main

# Indicate if the PDF document must be opened
OPEN_PDF = yes

# Indicate if the images should be automatically generated
AUTO_GENERATE_IMAGES = yes

# Indicate which generation procedure to use. One in:
# pdf, dvi, ps, pspdf
LATEX_GENERATION_PROCEDURE = pdf

# Force the PDF viewer (could be defined in your shell environment).
# If not specified, make will search for acroread, evince and xpdf
;PDF_VIEWER := /usr/bin/evince

# Shell command used to update the document from a SCM (CVS or SVN)
;SCM_UPDATE_CMD = cvs update

# Shell command used to commit the document into a SCM (CVS or SVN)
;SCM_COMMIT_CMD = cvs commit

# Shell command used to compile the LaTeX document
ifeq ("-${LATEX_GENERATION_PROCEDURE}","-pdf")
LATEX_CMD = pdflatex
else
LATEX_CMD = latex
endif

# LaTeX flags which must be passed when the document
# must be compiled in draft mode
ifeq ("-${LATEX_GENERATION_PROCEDURE}","-pdf")
LATEX_DRAFT_FLAGS = --draftmode # since pdflatex 1.40
else
LATEX_DRAFT_FLAGS =
endif

# LaTeX flags which must be passed when the document
# must be compiled not in draft mode
LATEX_FLAGS = 

# Shell command used to launch BibTeX
BIBTEX_CMD = bibtex

# bibtex flags
BIBTEX_FLAGS =

# Shell command used to translate DVI to PS
DVIPS_CMD = dvips

# dvips flags
DVIPS_FLAGS = 

# Shell command used to translate PS to PDF
PS2PDF_CMD = ps2pdf

# ps2pdf flags
PS2PDF_FLAGS = 

# Program that permits to touch a file
TOUCH_CMD = autolatex_touch

# Shell command used to launch MakeIndex
MAKEINDEX_CMD = makeindex

# Style file for MakeIndex
MAKEINDEX_STYLEFILE =

# MakeIndex flags
MAKEINDEX_FLAGS =

# Program that permits to display a message in stdout
ECHO_CMD = autolatex_echo

# Program that permits to display a message in stderr
ECHO_ERR_CMD = autolatex_echo_err

#-----------------------------------
#----------- DO NOT CHANGE BELOW
#-----------------------------------

TEXFILE=${FILE}.tex
DVIFILE=${FILE}.dvi
PDFFILE=${FILE}.pdf
PSFILE=${FILE}.ps
BBLFILE=${FILE}.bbl
AUXFILE=${FILE}.aux
IDXFILE=${FILE}.idx
INDFILE=${FILE}.ind

ADDITIONALTEXFILES = $(shell find . -name "*.tex" -path "./*/*")
ADDITIONALAUXFILES = $(addsuffix .aux, $(basename ${ADDITIONALTEXFILES}))
TEXFILES = ${TEXFILE} ${ADDITIONALTEXFILES}
BIBFILES = $(shell find . -name "*.bib")
STYFILES = $(shell find . -name "*.sty" -o -name "*.cls")

TMPIMAGES =
IMAGES =
SOURCE_IMAGES =

MAKEFILE_FILENAME = Makefile

TMPFILES = autolatex_bibtex.stamp ${AUXFILE} *.log ${BBLFILE} *.blg \
	   *.cb *.toc *.out *.lof *.lot *.los \
           *.lom *.tmp *.loa ${IDXFILE} *.ilg ${INDFILE} \
           *.mtc *.mtc[0-9] *.mtc[0-9][0-9] *.bmt *.thlodef \
	   $(shell find . -name "auto") \
           autolatex_makeindex.stamp ${ADDITIONALAUXFILES} \
           ${PDFFILE} ${DVIFILE} ${PSFILE}

DESINTEGRABLEFILES = ${PRIVATE_IMAGES} ${PRIVATE_TMPIMAGES} ${BACKUPFILES} ${MAKEFILE_FILENAME}

BACKUPFILES = $(shell find . -name "*~") \
	      $(shell find . -name "*.bak") \
	      $(shell find . -name "*.backup")

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

