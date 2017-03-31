# eps2pdf_.mk

ifeq ("$(call isTranslatorLoaded,eps2pdf_)","false")

#-----------------------------------
#----------- DO NOT CHANGE BELOW
#-----------------------------------

# The commands to convert an EPS file into PDF are required
ifeq ("$(call isTranslatorLoaded,eps2pdf)","false")
include $(call getTranslatorMkfile,eps2pdf)
endif

# Notify of the loading of this module
LOADED_TRANSLATORS += eps2pdf_

EPS_FIG = $(call launchShell, ${FIND_CMD} ${AUTO_GENERATE_IMAGE_DIRECTORY} -name "*.eps")

PDF_EPS = $(addsuffix .pdf,          $(basename ${EPS_FIG}))

SOURCE_IMAGES += ${EPS_FIG}
IMAGES        += ${PDF_EPS}

$(PDF_EPS): %.pdf: %.eps
	@ ${ECHO_CMD} "$< -> $@" && $(EPS2PDF_SHELL_CMD)

endif
