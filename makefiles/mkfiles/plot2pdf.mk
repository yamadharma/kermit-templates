# plot2pdf.mk

ifeq ("$(call isTranslatorLoaded,plot2pdf)","false")

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
# <binfile> <flags> <inputflags> <input.plot> <outputflags> <output.eps>
PLOT2EPS_BIN           = gnuplot2eps
PLOT2EPS_FLAGS         = 
PLOT2EPS_INPUT_FLAGS   =
PLOT2EPS_OUTPUT_FLAGS  =
PLOT2EPS_POST_FLAGS    =
PLOT2EPS_OUTPUT_INPUT  = no
PLOT2EPS_OUTPUT_STDOUT = yes

#-----------------------------------
#----------- DO NOT CHANGE BELOW
#-----------------------------------

# The commands to convert an EPS file into PDF are required
ifeq ("$(call isTranslatorLoaded,eps2pdf)","false")
include $(call getTranslatorMkfile,eps2pdf)
endif

# Notify of the loading of this module
LOADED_TRANSLATORS += plot2pdf

PLOT_FIG = $(call launchShell, ${FIND_CMD} ${AUTO_GENERATE_IMAGE_DIRECTORY} -name "*.plot" -a -not -name "*.ltx.plot")

EPS_PLOT = $(addsuffix .eps,          $(basename ${PLOT_FIG}))
PDF_PLOT = $(addsuffix .pdf,          $(basename ${PLOT_FIG}))

SOURCE_IMAGES += ${PLOT_FIG}
TMPIMAGES     += ${EPS_PLOT}
IMAGES        += ${PDF_PLOT}

# Compile the convertion parameters
ifeq ("-$(findstring =,$(PLOT2EPS_INPUT_FLAGS))","-")
PLOT2EPS_INPUT_FLAGS_EX = $(PLOT2EPS_INPUT_FLAGS) "$<"
else
PLOT2EPS_INPUT_FLAGS_EX = "$(PLOT2EPS_INPUT_FLAGS)$<"
endif
ifeq ("-$(findstring =,$(PLOT2EPS_OUTPUT_FLAGS))","-")
PLOT2EPS_OUTPUT_FLAGS_EX = $(PLOT2EPS_OUTPUT_FLAGS) "$@"
else
PLOT2EPS_OUTPUT_FLAGS_EX = "$(PLOT2EPS_OUTPUT_FLAGS)$@"
endif

# Compile the convertion commands
ifeq ("${PLOT2EPS_OUTPUT_STDOUT}","yes")
PLOT2EPS_SHELL_CMD = $(PLOT2EPS_BIN) $(PLOT2EPS_FLAGS) $(PLOT2EPS_INPUT_FLAGS_EX) $(PLOT2EPS_POST_FLAGS) > "$@"
else
ifeq ("${PLOT2EPS_OUTPUT_INPUT}","yes")
PLOT2EPS_SHELL_CMD = $(PLOT2EPS_BIN) $(PLOT2EPS_FLAGS) $(PLOT2EPS_OUTPUT_FLAGS_EX) $(PLOT2EPS_INPUT_FLAGS_EX) $(PLOT2EPS_POST_FLAGS)
else
PLOT2EPS_SHELL_CMD = $(PLOT2EPS_BIN) $(PLOT2EPS_FLAGS) $(PLOT2EPS_INPUT_FLAGS_EX) $(PLOT2EPS_OUTPUT_FLAGS_EX) $(PLOT2EPS_POST_FLAGS)
endif
endif




$(EPS_PLOT): %.eps: %.plot
	@ ${ECHO_CMD} "$< -> $@" && $(PLOT2EPS_SHELL_CMD)

$(PDF_PLOT): %.pdf: %.eps
	@ ${ECHO_CMD} "$< -> $@" && $(EPS2PDF_SHELL_CMD)

endif
