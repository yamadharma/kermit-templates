# main_rules.mk

#-----------------------------------
#----------- DO NOT CHANGE BELOW
#-----------------------------------

# Update the makeindex flags with the style file
ifneq ("-${MAKEINDEX_STYLEFILE}","-")
MAKEINDEX_FLAGS += -s "${MAKEINDEX_STYLEFILE}"
endif

#.PHONY:: all view gen_doc bibtex makeindex clean cleanall images showimages showpath showvars update commit

#all:: gen_doc

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
	  if "${HAS_BIBTEX_CITATION_CMD}" "${TEXFILE}" "${AUXFILE}" "${BBLFILE}" ${BIBFILES}; then \
	    COMPBIBTEX="yes"; \
	  fi && \
	  unset COMPMAKEINDEX && \
	  if ${HAS_INDEX_CMD} "${IDXFILE}" "${MAKEINDEX_STYLEFILE}"; then \
	    COMPMAKEINDEX="yes"; \
	  fi && \
	  if test -n "$$COMPBIBTEX" -o -n "$$CMPMAKEINDEX"; then \
	    if test -n "$$COMPBIBTEX"; then \
	      ${BIBTEX_CMD} ${BIBTEX_FLAGS} ${FILE} && \
	      ${FIX_BBL_CMD} ${BBLFILE} && \
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
	  ${BIBTEX_CMD} ${BIBTEX_FLAGS} ${FILE} && \
	  ${FIX_BBL_CMD} ${BBLFILE}

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

