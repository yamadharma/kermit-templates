# dia2pdf.mk

ifeq ("$(call isTranslatorLoaded,dia2pdf)","false")

# If the images must be auto-generated, the following lines
# permits to change the generators
#   xxx_BIN is the command to launch
#   xxx_FLAGS are the command line options to pass to the converter
#   xxx_INPUT_FLAGS are the options which must appear just before
#                   then input filename
#   xxx_OUTPUT_FLAGS are the options which must appear just before
#                    then input filename
#   xxx_POST_FLAGS are the options which must appear just after
#                  all the rest
#   xxx_OUTPUT_INPUT switch the order of the output options and the
#                    input option. If set to yes, the output options
#                    will appear before the input options. if set to
#                    no, the input options will appear before the
#                    output options.
#   xxx_OUTPUT_STDOUT if set to yes, the output options will be ignored
#                     and the command's standard output will be sent
#                     to the target file.


# Command definition.
# Required synoptics of the command:
# <binfile> <flags> <inputflags> <input.dia> <outputflags> <output.eps>
DIA2EPS_BIN           = dia
DIA2EPS_FLAGS         = --nosplash -t eps-pango
DIA2EPS_INPUT_FLAGS   =
DIA2EPS_OUTPUT_FLAGS  = --export=
DIA2EPS_POST_FLAGS    =
DIA2EPS_OUTPUT_INPUT  = yes
DIA2EPS_OUTPUT_STDOUT = no

#-----------------------------------
#----------- DO NOT CHANGE BELOW
#-----------------------------------

# The commands to convert an EPS file into PDF are required
ifeq ("$(call isTranslatorLoaded,eps2pdf)","false")
include $(call getTranslatorMkfile,eps2pdf)
endif

# The commands to convert an PDF file into SVG are required
#ifeq ("$(call isTranslatorLoaded,pdf2svg)","false")
#include $(call getTranslatorMkfile,pdf2svg)
#endif

# Notify of the loading of this module
LOADED_TRANSLATORS += dia2pdf

DIA_FIG = $(call launchShell, ${FIND_CMD} ${AUTO_GENERATE_IMAGE_DIRECTORY} -name "*.dia")

EPS_DIA = $(addsuffix .eps,          $(basename ${DIA_FIG}))
PDF_DIA = $(addsuffix .pdf,          $(basename ${DIA_FIG}))
# SVG_DIA = $(addsuffix .svg,          $(basename ${DIA_FIG}))

SOURCE_IMAGES += ${DIA_FIG}
TMPIMAGES     += ${EPS_DIA}
IMAGES        += ${PDF_DIA}
# IMAGES        += ${SVG_DIA}

# Compile the convertion parameters
ifeq ("-$(findstring =,$(DIA2EPS_INPUT_FLAGS))","-")
DIA2EPS_INPUT_FLAGS_EX = $(DIA2EPS_INPUT_FLAGS) "$<"
else
DIA2EPS_INPUT_FLAGS_EX = "$(DIA2EPS_INPUT_FLAGS)$<"
endif
ifeq ("-$(findstring =,$(DIA2EPS_OUTPUT_FLAGS))","-")
DIA2EPS_OUTPUT_FLAGS_EX = $(DIA2EPS_OUTPUT_FLAGS) "$@"
else
DIA2EPS_OUTPUT_FLAGS_EX = "$(DIA2EPS_OUTPUT_FLAGS)$@"
endif

# Compile the convertion commands
ifeq ("${DIA2EPS_OUTPUT_STDOUT}","yes")
DIA2EPS_SHELL_CMD = LANG="C" $(DIA2EPS_BIN) $(DIA2EPS_FLAGS) $(DIA2EPS_INPUT_FLAGS_EX) $(DIA2EPS_POST_FLAGS) > "$@"
else
ifeq ("${DIA2EPS_OUTPUT_INPUT}","yes")
DIA2EPS_SHELL_CMD = LANG="C" $(DIA2EPS_BIN) $(DIA2EPS_FLAGS) $(DIA2EPS_OUTPUT_FLAGS_EX) $(DIA2EPS_INPUT_FLAGS_EX) $(DIA2EPS_POST_FLAGS)
else
DIA2EPS_SHELL_CMD = LANG="C" $(DIA2EPS_BIN) $(DIA2EPS_FLAGS) $(DIA2EPS_INPUT_FLAGS_EX) $(DIA2EPS_OUTPUT_FLAGS_EX) $(DIA2EPS_POST_FLAGS)
endif
endif



$(EPS_DIA): %.eps: %.dia
	@ ${ECHO_CMD} "$< -> $@" && $(DIA2EPS_SHELL_CMD)

$(PDF_DIA): %.pdf: %.eps
	@ ${ECHO_CMD} "$< -> $@" && $(EPS2PDF_SHELL_CMD)

$(SVG_DIA): %.svg: %.pdf
	@ ${ECHO_CMD} "$< -> $@" && $(PDF2SVG_SHELL_CMD)

endif
