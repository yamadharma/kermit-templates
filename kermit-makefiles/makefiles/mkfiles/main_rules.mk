# -*- mode: make -*-

# Update the makeindex flags with the style file
ifeq ("${MAKEINDEX_CMD}","makeindex")
ifneq ("-${MAKEINDEX_STYLEFILE}","-")
    MAKEINDEX_FLAGS += -s "${MAKEINDEX_STYLEFILE}"
endif
endif

ifeq ("${MAKEINDEX_CMD}","upmendex")
ifneq ("-${MAKEINDEX_STYLEFILE}","-")
    MAKEINDEX_FLAGS += -s "${MAKEINDEX_STYLEFILE}"
endif
endif # END upmendex

ifeq ("${MAKEINDEX_CMD}","xindy")
    MAKEINDEX_FLAGS += -o ${INDFILE} "${MAKEINDEX_STYLEFILE}"
endif # END xindy

ifndef MAKEINDEX_FULL_CMD

ifeq ("${MAKEINDEX_CMD}","makeindex")
    MAKEINDEX_FULL_CMD = ${MAKEINDEX_CMD} ${MAKEINDEX_FLAGS} ${IDXFILE}
endif # END makeindex

ifeq ("${MAKEINDEX_CMD}","xindy")
    # MAKEINDEX_FULL_CMD = ${TEX2XINDY} < ${IDXFILE} > index.raw ; ${MAKEINDEX_CMD} ${MAKEINDEX_FLAGS} index.raw
    MAKEINDEX_FULL_CMD = ${MAKEINDEX_CMD} -I latex -M ${MAKEINDEX_STYLEFILE} ${IDXFILE}
endif # END xindy

ifeq ("${MAKEINDEX_CMD}","upmendex")
    MAKEINDEX_FULL_CMD = ${MAKEINDEX_CMD} ${MAKEINDEX_FLAGS} ${IDXFILE}
endif # END upmendex

endif # END MAKEINDEX_FULL_CMD

TEX4HT_MAKEINDEX_FULL_CMD = tex '\def\filename{{default}{idx}{4dx}{ind}} \input  idxmake.4ht';	makeindex -o default.ind default.4dx


# Update the glossary flags with the style file
ifeq ("${MAKEGLOS_CMD}","makeindex")
ifneq ("-${MAKEGLOS_STYLEFILE}","-")
    MAKEGLOS_FLAGS += -s "${MAKEGLOS_STYLEFILE}"
endif
else
    MAKEIGLOS_FLAGS += -o ${GLSFILE} "${MAKEGLOS_STYLEFILE}"
endif

ifeq ("${MAKEGLOS_CMD}","makeindex")
    MAKEGLOS_FULL_CMD = ${MAKEGLOS_CMD} ${MAKEGLOS_FLAGS} -o ${GLSFILE} -t ${GLGFILE} ${GLOFILE}
else
ifeq ("${MAKEGLOS_CMD}","xindy")
#    MAKEGLOS_FULL_CMD = ${TEX2XINDY} < ${GLOFILE} > glossary.raw ; ${MAKEGLOS_CMD} ${MAKEINDEX_FLAGS} -t ${GLGFILE} glossary.raw
    MAKEGLOS_FULL_CMD = ${MAKEGLOS_CMD} ${MAKEGLOS_FLAGS} -M ${MAKEGLOS_STYLEFILE} -o ${GLSFILE} -t ${GLGFILE} ${GLOFILE}
endif
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

clean::	## Clean working directory
	@ ${RM} ${TMPFILES}
	@ ${RM} -rf ${TMPDIRS}
	@ if [ -d "${TEX4HT_TEX_OUT_DIR}" ]; then ${RM} -rf ${TEX4HT_TEX_OUT_DIR} ; fi

cleanall:: clean	## Hard clean working directory
	@ ${RM} ${DESINTEGRABLEFILES}

images:: ${PRIVATE_IMAGES}

showimages::
	@ ${ECHO_CMD} "DETECTED: ${SOURCE_IMAGES}"
ifeq ("-${AUTO_GENERATE_IMAGES}","-yes")
	@ ${ECHO_CMD} "TEMP: ${PRIVATE_TMPIMAGES}"
	@ ${ECHO_CMD} "AUTO-GENERATED: ${PRIVATE_IMAGES}"
else
	@ ${ECHO_CMD} "WARNING: auto generation of the images is disabled"
endif

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

VARIABLES::
	if [ -f "VARIABLES" ]; then rm VARIABLES; fi
	@ ${ECHO_CMD} "HTML_EXT="${HTML_EXT} >> VARIABLES
	@ ${ECHO_CMD} "TEX4HT_TEX_OUT_DIR="${TEX4HT_TEX_OUT_DIR} >> VARIABLES
	@ ${ECHO_CMD} "SRC_DIR="${SRC_DIR} >> VARIABLES

${COMPILATION_TARGET_FILE}:: ${TEXFILES} ${PRIVATE_IMAGES} ${BIBFILES} ${MAKEINDEX_STYLEFILE} ${STYFILES}
	@ ${LATEX_CMD} ${LATEX_DRAFT_FLAGS} ${LATEX_FLAGS} ${FILE} && \
	  ${POST_LATEX_CMD} && \
	  unset COMPBIBTEX && \
	  if "${HAS_BIBTEX_CITATION_CMD}" "${TEXFILE}" "${AUXFILE}" "${BBLFILE}" ${BIBFILES}; then \
	    COMPBIBTEX="yes"; \
	  fi && \
	  if test -n "${MULTIPLE_BIB}"; then \
	    COMPBIBTEX="yes"; \
	  fi && \
	  unset COMPMAKEINDEX && \
	  if ${HAS_INDEX_CMD} "${IDXFILE}" "${MAKEINDEX_STYLEFILE}"; then \
	    COMPMAKEINDEX="yes"; \
	  fi && \
	  unset COMPMAKEGLOS && \
	  if ${HAS_GLOS_CMD} "${GLOFILE}" "${MAKEGLOS_STYLEFILE}"; then \
	    COMPMAKEGLOS="yes"; \
	  fi && \
		echo !!!!!!!!!! ${MAKEGLOS_FULL_CMD}; \
	  if test -n "$$COMPBIBTEX" -o -n "$$COMPMAKEINDEX" -o -n "$$COMPMAKEGLOS"; then \
	    if test -n "$$COMPBIBTEX"; then \
	      if test -n "${MULTIPLE_BIB}"; then \
	        ${PRE_BIBTEX_CMD}; \
		for i in $(basename ${MULTIPLE_BIB_FILES}); do \
		  ${BIBTEX_CMD} ${BIBTEX_FLAGS} $$i && \
	          ${FIX_BBL_CMD}  $$i.bbl && \
	          ${TOUCH_CMD} $$i.bbl; \
	        done; \
	        ${POST_BIBTEX_CMD}; \
	      else \
		  ${PRE_BIBTEX_CMD}; \
	          ${BIBTEX_CMD} ${BIBTEX_FLAGS} ${FILE} && \
	          ${FIX_BBL_CMD} ${BBLFILE} && \
	          ${TOUCH_CMD} ${BBLFILE}; \
	          ${POST_BIBTEX_CMD}; \
	      fi ; \
	    fi && \
	    if test -n "$$COMPMAKEINDEX"; then \
	      ${MAKEINDEX_FULL_CMD} && \
	      ${TOUCH_CMD} ${INDFILE}; \
	    fi && \
	    ${LATEX_CMD} ${LATEX_DRAFT_FLAGS} ${LATEX_FLAGS} ${FILE}; \
	    ${POST_LATEX_CMD}; \
	    if test -n "$$COMPMAKEGLOS"; then \
	      ${MAKEGLOS_FULL_CMD} && \
	      ${TOUCH_CMD} ${GLSFILE}; \
	    fi ; \
	  fi && \
	  ${LATEX_CMD} ${LATEX_DRAFT_FLAGS} ${LATEX_FLAGS} ${FILE}; \
	  ${POST_LATEX_CMD}; \
	    if test -n "$$COMPMAKEINDEX"; then \
	      ${MAKEINDEX_FULL_CMD} && \
	      ${TOUCH_CMD} ${INDFILE}; \
	    fi ; \
	  ${LATEX_CMD} ${LATEX_FLAGS} ${FILE}; \
	  ${POST_LATEX_CMD}
	  ${FINAL_POST_LATEX_CMD}


ifdef HAS_MULTIPLE_BIB
$(BBLFILE): ${BIBFILES} ${TEXFILES} ${PRIVATE_IMAGES}
	${LATEX_CMD} ${LATEX_DRAFT_FLAGS} ${LATEX_FLAGS} ${FILE} && \
	${POST_LATEX_CMD} && \
	for i in ${MULTIPLE_BIB_FILES}; do \
	  ${BIBTEX_CMD} ${BIBTEX_FLAGS} $$i && \
	  ${FIX_BBL_CMD}  $$i.bbl && \
	  ${TOUCH_CMD} $$i.bbl; \
	done
else
${BBLFILE}: ${BIBFILES} ${TEXFILES} ${PRIVATE_IMAGES}
	@ ${TOUCH_CMD} ${BBLFILE} && \
	  ${LATEX_CMD} ${LATEX_DRAFT_FLAGS} ${LATEX_FLAGS} ${FILE} && \
	  ${POST_LATEX_CMD} && \
	  ${BIBTEX_CMD} ${BIBTEX_FLAGS} ${FILE} && \
	  ${FIX_BBL_CMD} ${BBLFILE}
endif

${IDXFILE}: ${TEXFILES} ${PRIVATE_IMAGES}
	@ ${TOUCH_CMD} ${IDXFILE} && \
          ${LATEX_CMD} ${LATEX_DRAFT_FLAGS} ${LATEX_FLAGS} ${FILE} && \
          ${POST_LATEX_CMD}

${INDFILE}: ${IDXFILE}
	@ ${TOUCH_CMD} ${INDFILE} && \
          ${MAKEINDEX_FULL_CMD}

${GLOFILE}: ${TEXFILES} ${PRIVATE_IMAGES}
	@ ${TOUCH_CMD} ${GLOFILE} && \
          ${LATEX_CMD} ${LATEX_DRAFT_FLAGS} ${LATEX_FLAGS} ${FILE} && \
          ${POST_LATEX_CMD}

${GLSFILE}: ${GLOFILE}
	@ ${TOUCH_CMD} ${GLSFILE} && \
          ${MAKEGLOS_FULL_CMD}

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

html:: ${TEXFILES} ${PRIVATE_IMAGES} ${BIBFILES} ${MAKEINDEX_STYLEFILE} ${STYFILES} VARIABLES
	if [ ! -d "${TEX4HT_TEX_OUT_DIR}" ] ; then mkdir -p ${TEX4HT_TEX_OUT_DIR} ; fi
	@ ${TEX4HT_TEX_CMD} ${TEX4HT_TEX_ARG_4} '\makeatletter\def\HCode{\futurelet\HCode\HChar}\def\HChar{\ifx"\HCode\def\HCode"##1"{\Link##1}\expandafter\HCode\else\expandafter\Link\fi}\def\Link#1.a.b.c.{\g@addto@macro\@documentclasshook{\RequirePackage[#1,html]{tex4ht}}\let\HCode\documentstyle\def\documentstyle{\let\documentstyle\HCode\expandafter\def\csname tex4ht\endcsname{#1,html}\def\HCode####1{\documentstyle[tex4ht,}\@ifnextchar[{\HCode}{\documentstyle[tex4ht]}}}\makeatother\HCode '${TEX4HT_TEX_ARG_1}'.a.b.c.\input ' ${FILE}
	${TEX4HT_TEX_POST_CMD}
	  unset COMPBIBTEX && \
	  if "${HAS_BIBTEX_CITATION_CMD}" "${TEXFILE}" "${AUXFILE}" "${BBLFILE}" ${BIBFILES}; then \
	    COMPBIBTEX="yes"; \
	  fi && \
	  unset COMPMAKEINDEX && \
	  if ${HAS_INDEX_CMD} "${IDXFILE}" "${MAKEINDEX_STYLEFILE}"; then \
	    COMPMAKEINDEX="yes"; \
	  fi && \
	  unset COMPMAKEGLOS && \
	  if ${HAS_GLOS_CMD} "${GLOFILE}" "${MAKEGLOS_STYLEFILE}"; then \
	    COMPMAKEGLOS="yes"; \
	  fi && \
	  if test -n "$$COMPBIBTEX" -o -n "$$CMPMAKEINDEX" -o -n "$$CMPMAKEGLOS"; then \
	    if test -n "$$COMPBIBTEX"; then \
	      if test -n "${MULTIPLE_BIB}"; then \
	    	for i in ${MULTIPLE_BIB_FILES}; do \
	    	  ${BIBTEX_CMD} ${BIBTEX_FLAGS} $$i && \
	          ${FIX_BBL_CMD}  $$i.bbl && \
	          ${TOUCH_CMD} $$i.bbl; \
	        done \
	      else \
	    	  ${BIBTEX_CMD} ${BIBTEX_FLAGS} ${FILE} && \
	          ${FIX_BBL_CMD} ${BBLFILE} && \
	          ${TOUCH_CMD} ${BBLFILE}; \
	      fi ; \
	    fi && \
	    if test -n "$$COMPMAKEINDEX"; then \
	      ${TEX4HT_MAKEINDEX_FULL_CMD} && \
	      ${TOUCH_CMD} ${INDFILE}; \
	    fi && \
	    ${TEX4HT_TEX_CMD} ${TEX4HT_TEX_ARG_4} '\makeatletter\def\HCode{\futurelet\HCode\HChar}\def\HChar{\ifx"\HCode\def\HCode"##1"{\Link##1}\expandafter\HCode\else\expandafter\Link\fi}\def\Link#1.a.b.c.{\g@addto@macro\@documentclasshook{\RequirePackage[#1,html]{tex4ht}}\let\HCode\documentstyle\def\documentstyle{\let\documentstyle\HCode\expandafter\def\csname tex4ht\endcsname{#1,html}\def\HCode####1{\documentstyle[tex4ht,}\@ifnextchar[{\HCode}{\documentstyle[tex4ht]}}}\makeatother\HCode '${TEX4HT_TEX_ARG_1}'.a.b.c.\input ' ${FILE} ; \
	    ${TEX4HT_TEX_POST_CMD} ; \
	    if test -n "$$COMPMAKEGLOS"; then \
	      ${MAKEGLOS_FULL_CMD} && \
	      ${TOUCH_CMD} ${GLSFILE}; \
	    fi ; \
	  fi && \
	${TEX4HT_TEX_CMD} ${TEX4HT_TEX_ARG_4} '\makeatletter\def\HCode{\futurelet\HCode\HChar}\def\HChar{\ifx"\HCode\def\HCode"##1"{\Link##1}\expandafter\HCode\else\expandafter\Link\fi}\def\Link#1.a.b.c.{\g@addto@macro\@documentclasshook{\RequirePackage[#1,html]{tex4ht}}\let\HCode\documentstyle\def\documentstyle{\let\documentstyle\HCode\expandafter\def\csname tex4ht\endcsname{#1,html}\def\HCode####1{\documentstyle[tex4ht,}\@ifnextchar[{\HCode}{\documentstyle[tex4ht]}}}\makeatother\HCode '${TEX4HT_TEX_ARG_1}'.a.b.c.\input ' ${FILE}
	${TEX4HT_TEX_POST_CMD}
	${TEX4HT_TEX_CMD} ${TEX4HT_TEX_ARG_4} '\makeatletter\def\HCode{\futurelet\HCode\HChar}\def\HChar{\ifx"\HCode\def\HCode"##1"{\Link##1}\expandafter\HCode\else\expandafter\Link\fi}\def\Link#1.a.b.c.{\g@addto@macro\@documentclasshook{\RequirePackage[#1,html]{tex4ht}}\let\HCode\documentstyle\def\documentstyle{\let\documentstyle\HCode\expandafter\def\csname tex4ht\endcsname{#1,html}\def\HCode####1{\documentstyle[tex4ht,}\@ifnextchar[{\HCode}{\documentstyle[tex4ht]}}}\makeatother\HCode '${TEX4HT_TEX_ARG_1}'.a.b.c.\input ' ${FILE}
	${TEX4HT_TEX_POST_CMD} 
	${TEX4HT_TEX_CMD} ${TEX4HT_TEX_ARG_4} '\makeatletter\def\HCode{\futurelet\HCode\HChar}\def\HChar{\ifx"\HCode\def\HCode"##1"{\Link##1}\expandafter\HCode\else\expandafter\Link\fi}\def\Link#1.a.b.c.{\g@addto@macro\@documentclasshook{\RequirePackage[#1,html]{tex4ht}}\let\HCode\documentstyle\def\documentstyle{\let\documentstyle\HCode\expandafter\def\csname tex4ht\endcsname{#1,html}\def\HCode####1{\documentstyle[tex4ht,}\@ifnextchar[{\HCode}{\documentstyle[tex4ht]}}}\makeatother\HCode '${TEX4HT_TEX_ARG_1}'.a.b.c.\input ' ${FILE}
	${TEX4HT_TEX_POST_CMD} 
	tex4ht -f/${FILE}  -i~/tex4ht.dir/texmf/tex4ht/ht-fonts/ ${TEX4HT_TEX_ARG_2}
	t4ht -f/${FILE} ${TEX4HT_TEX_ARG_3} ${TEX4HT_TEX_ARG_5}
	${TEX4HT_POST_CMD}
	${TEX4HT_FINAL_POST_CMD}
