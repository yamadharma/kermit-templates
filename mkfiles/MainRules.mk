# autolatex - MainRules.mk
# Copyright (C) 1998-08  Stephane Galland <galland@arakhne.org>
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

#-----------------------------------
#----------- DO NOT CHANGE BELOW
#-----------------------------------

# Update the makeindex flags with the style file
ifneq ("-${MAKEINDEX_STYLEFILE}","-")
MAKEINDEX_FLAGS += -s "${MAKEINDEX_STYLEFILE}"
endif

.PHONY:: all view gen_doc bibtex makeindex clean cleanall images showimages showpath showvars update commit

view:: gen_doc
ifeq ("${OPEN_PDF}","yes")
ifeq ("${PDF_VIEWER}","")
	@ if `which acroread 2>/dev/null >/dev/null`; \
	then \
		${ECHO_CMD} "${I18N_LAUNCH_ACROREAD}" && \
		acroread ${PDFFILE}; \
	elif `which kpdf 2>/dev/null >/dev/null`; \
	then \
		${ECHO_CMD} "${I18N_LAUNCH_KPDF}" && \
		kpdf ${PDFFILE}; \
	elif `which evince 2>/dev/null >/dev/null`; \
	then \
		${ECHO_CMD} "${I18N_LAUNCH_EVINCE}" && \
		evince ${PDFFILE}; \
	elif `which xpdf 2>/dev/null >/dev/null`; \
	then \
		${ECHO_CMD} "${I18N_LAUNCH_XPDF}" && \
		xpdf ${PDFFILE}; \
	elif `which gv 2>/dev/null >/dev/null`; \
	then \
		${ECHO_CMD} "${I18N_LAUNCH_GHOSTVIEW}" && \
		gv ${PDFFILE}; \
	else \
		${ECHO_ERR_CMD} "${I18N_NO_VIEWER_DETECTED}"; \
	fi	
else
	${PDF_VIEWER} ${PDFFILE}
endif
endif

ifeq ("-${LATEX_GENERATION_PROCEDURE}","-dvi")
gen_doc:: ${DVIFILE}
else
ifeq ("-${LATEX_GENERATION_PROCEDURE}","-ps")
gen_doc:: ${PSFILE}
else
gen_doc:: ${PDFFILE}
endif
endif

bibtex:: ${BBLFILE}

makeindex:: ${INDFILE}

clean::
	@ ${RM} ${TMPFILES}

cleanall:: clean
	@ ${RM} ${DESINTEGRABLEFILES}

images:: ${PRIVATE_IMAGES}

showimages::
	@ ${ECHO_CMD} "DETECTED: ${SOURCE_IMAGES}"
	@ ${ECHO_CMD} "AUTO-GENERATED: ${PRIVATE_IMAGES}"

showpath::
	@ ${ECHO_CMD} "$$PATH"

showvars::
	@ ${ECHO_CMD} "OPEN_PDF: ${OPEN_PDF}"
	@ ${ECHO_CMD} "AUTO_GENERATE_IMAGES: ${AUTO_GENERATE_IMAGES}"
	@ ${ECHO_CMD} "LATEX_GENERATION_PROCEDURE: ${LATEX_GENERATION_PROCEDURE}"
	@ ${ECHO_CMD} "PDF_VIEWER: ${PDF_VIEWER}"
	@ ${ECHO_CMD} "FILE: ${FILE}"
	@ ${ECHO_CMD} "TEXFILE: ${TEXFILE}"

update:: cleanall
ifeq ("${SCM_UPDATE_CMD}","")
	@ ${ECHO_ERR_CMD} "${I18N_NO_SCM_UPDATE}"
else
	@ ${SCM_UPDATE_CMD}
endif

commit:: cleanall
ifeq ("${SCM_COMMIT_CMD}","")
	@ ${ECHO_ERR_CMD} "${I18N_NO_SCM_COMMIT}"
else
	@ ${SCM_COMMIT_CMD}
endif

${COMPILATION_TARGET_FILE}:: ${TEXFILES} ${PRIVATE_IMAGES} ${BIBFILES} ${MAKEINDEX_STYLEFILE} ${STYFILES}
	@ ${LATEX_CMD} ${LATEX_DRAFT_FLAGS} ${LATEX_FLAGS} ${FILE} && \
	  unset COMPBIBTEX && \
	  if autolatex_has_bibtex_citation "${TEXFILE}" "${AUXFILE}" "${BBLFILE}" ${BIBFILES}; then \
	    COMPBIBTEX="yes"; \
	  fi && \
	  unset COMPMAKEINDEX && \
	  if autolatex_has_index "${IDXFILE}" "${MAKEINDEX_STYLEFILE}"; then \
	    COMPMAKEINDEX="yes"; \
	  fi && \
	  if test -n "$$COMPBIBTEX" -o -n "$$CMPMAKEINDEX"; then \
	    if test -n "$$COMPBIBTEX"; then \
	      ${BIBTEX_CMD} ${BIBTEX_FLAGS} ${FILE} && \
	      ${TOUCH_CMD} ${BBLFILE}; \
	    fi && \
	    if test -n "$$COMPMAKEINDEX"; then \
	      ${MAKEINDEX_CMD} ${MAKEINDEX_FLAGS} ${IDXFILE} && \
	      ${TOUCH_CMD} ${INDFILE}; \
	    fi && \
	    ${LATEX_CMD} ${LATEX_DRAFT_FLAGS} ${LATEX_FLAGS} ${FILE}; \
	  fi && \
	  ${LATEX_CMD} ${LATEX_DRAFT_FLAGS} ${LATEX_FLAGS} ${FILE} && \
	  ${LATEX_CMD} ${LATEX_FLAGS} ${FILE}

${BBLFILE}: ${BIBFILES} ${TEXFILES} ${PRIVATE_IMAGES}
	@ ${TOUCH_CMD} ${BBLFILE} && \
          ${LATEX_CMD} ${LATEX_DRAFT_FLAGS} ${LATEX_FLAGS} ${FILE} && \
          ${BIBTEX_CMD} ${BIBTEX_FLAGS} ${FILE}

${IDXFILE}: ${TEXFILES} ${PRIVATE_IMAGES}
	@ ${TOUCH_CMD} ${IDXFILE} && \
          ${LATEX_CMD} ${LATEX_DRAFT_FLAGS} ${LATEX_FLAGS} ${FILE}

${INDFILE}: ${IDXFILE}
	@ ${TOUCH_CMD} ${INDFILE} && \
          ${MAKEINDEX_CMD} ${MAKEINDEX_FLAGS} ${IDXFILE}

# Additional rules for old LaTeX compilation procedure
ifeq ("-${LATEX_GENERATION_PROCEDURE}","-ps")
${PSFILE}: ${COMPILATION_TARGET_FILE}
	@ ${DVIPS_CMD} ${DVIPS_FLAGS} ${DVIFILE}
else
ifeq ("-${LATEX_GENERATION_PROCEDURE}","-pspdf")
${PSFILE}: ${COMPILATION_TARGET_FILE}
	@ ${DVIPS_CMD} ${DVIPS_FLAGS} ${DVIFILE}

${PDFFILE}: ${PSFILE}
	@ ${PS2PDF_CMD} ${PS2PDF_FLAGS} ${PSFILE} ${PDFFILE}
endif
endif

