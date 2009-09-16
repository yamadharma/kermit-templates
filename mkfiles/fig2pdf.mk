# fig2pdf.mk

ifeq ("$(call isTranslatorLoaded,fig2pdf)","false")

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
# <binfile> <flags> <inputflags> <input.fig> <outputflags> <output.eps>
FIG2EPS_BIN           = fig2dev
FIG2EPS_FLAGS         = -L eps
FIG2EPS_INPUT_FLAGS   =
FIG2EPS_OUTPUT_FLAGS  =
FIG2EPS_POST_FLAGS    =
FIG2EPS_OUTPUT_INPUT  = no
FIG2EPS_OUTPUT_STDOUT = no

#-----------------------------------
#----------- DO NOT CHANGE BELOW
#-----------------------------------

# The commands to convert an EPS file into PDF are required
ifeq ("$(call isTranslatorLoaded,eps2pdf)","false")
include $(call getTranslatorMkfile,eps2pdf)
endif

# Notify of the loading of this module
LOADED_TRANSLATORS += fig2pdf

XFIG_FIG = $(call launchShell, ${FIND_CMD} ${AUTO_GENERATE_IMAGE_DIRECTORY} -name "*.fig" -a -not -name "*.ltx.fig")

EPS_XFIG = $(addsuffix .eps,          $(basename ${XFIG_FIG}))
PDF_XFIG = $(addsuffix .pdf,          $(basename ${XFIG_FIG}))

SOURCE_IMAGES += ${XFIG_FIG}
TMPIMAGES     += ${EPS_XFIG}
IMAGES        += ${PDF_XFIG}

# Compile the convertion parameters
ifeq ("-$(findstring =,$(FIG2EPS_INPUT_FLAGS))","-")
FIG2EPS_INPUT_FLAGS_EX = $(FIG2EPS_INPUT_FLAGS) "$<"
else
FIG2EPS_INPUT_FLAGS_EX = "$(FIG2EPS_INPUT_FLAGS)$<"
endif
ifeq ("-$(findstring =,$(FIG2EPS_OUTPUT_FLAGS))","-")
FIG2EPS_OUTPUT_FLAGS_EX = $(FIG2EPS_OUTPUT_FLAGS) "$@"
else
FIG2EPS_OUTPUT_FLAGS_EX = "$(FIG2EPS_OUTPUT_FLAGS)$@"
endif

# Compile the convertion commands
ifeq ("${FIG2EPS_OUTPUT_STDOUT}","yes")
FIG2EPS_SHELL_CMD = $(FIG2EPS_BIN) $(FIG2EPS_FLAGS) $(FIG2EPS_INPUT_FLAGS_EX) $(FIG2EPS_POST_FLAGS) > "$@"
else
ifeq ("${FIG2EPS_OUTPUT_INPUT}","yes")
FIG2EPS_SHELL_CMD = $(FIG2EPS_BIN) $(FIG2EPS_FLAGS) $(FIG2EPS_OUTPUT_FLAGS_EX) $(FIG2EPS_INPUT_FLAGS_EX) $(FIG2EPS_POST_FLAGS)
else
FIG2EPS_SHELL_CMD = $(FIG2EPS_BIN) $(FIG2EPS_FLAGS) $(FIG2EPS_INPUT_FLAGS_EX) $(FIG2EPS_OUTPUT_FLAGS_EX) $(FIG2EPS_POST_FLAGS)
endif
endif



$(EPS_XFIG): %.eps: %.fig
	@ ${ECHO_CMD} "$< -> $@" && $(FIG2EPS_SHELL_CMD)

$(PDF_XFIG): %.pdf: %.eps
	@ ${ECHO_CMD} "$< -> $@" && $(EPS2PDF_SHELL_CMD)

endif
