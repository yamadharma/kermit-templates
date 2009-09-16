# plot2pdf+tex.mk

ifeq ("$(call isTranslatorLoaded,plot2pdf+tex)","false")

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


# Command definition to generated the Postscript part.
# Required synoptics of the command:
# <binfile> <flags> <inputflags> <input.ltx.plot> <outputflags> <output.eps>
PLOT2PSTEX_BIN           = gnuplot2pstex
PLOT2PSTEX_FLAGS         = 
PLOT2PSTEX_INPUT_FLAGS   =
PLOT2PSTEX_OUTPUT_FLAGS  =
PLOT2PSTEX_POST_FLAGS    =
PLOT2PSTEX_OUTPUT_INPUT  = no
PLOT2PSTEX_OUTPUT_STDOUT = no

# Command definition to generated the TeX part.
# Required synoptics of the command:
# <binfile> <flags> <inputflags> <input.ltx.plot> <outputflags> <output.eps>
PLOT2PSTEX_T_BIN           = gnuplot2pstex
PLOT2PSTEX_T_FLAGS         = 
PLOT2PSTEX_T_INPUT_FLAGS   =
PLOT2PSTEX_T_OUTPUT_FLAGS  =
PLOT2PSTEX_T_POST_FLAGS    =
PLOT2PSTEX_T_OUTPUT_INPUT  = no
PLOT2PSTEX_T_OUTPUT_STDOUT = no

#-----------------------------------
#----------- DO NOT CHANGE BELOW
#-----------------------------------

# The commands to convert an EPS file into PDF are required
ifeq ("$(call isTranslatorLoaded,eps2pdf)","false")
include $(call getTranslatorMkfile,eps2pdf)
endif

# Notify of the loading of this module
LOADED_TRANSLATORS += plot2pdf+tex

PSTEX_PLOT_FIG = $(call launchShell, ${FIND_CMD} ${AUTO_GENERATE_IMAGE_DIRECTORY} -name "*.ltx.plot")

PSTEX_PLOT     = $(addsuffix .pstex,        $(basename $(basename ${PSTEX_PLOT_FIG})))
PSTEX_T_PLOT   = $(addsuffix .pstex_t,      $(basename $(basename ${PSTEX_PLOT_FIG})))
PDF_PSTEX_PLOT = $(addsuffix .pdf,          $(basename ${PSTEX_PLOT}))

SOURCE_IMAGES += ${PSTEX_PLOT_FIG}
TMPIMAGES     += ${PSTEX_PLOT}
IMAGES        += ${PSTEX_T_PLOT} ${PDF_PSTEX_PLOT}

# Compile the convertion parameters
ifeq ("-$(findstring =,$(PLOT2PSTEX_INPUT_FLAGS))","-")
PLOT2PSTEX_INPUT_FLAGS_EX = $(PLOT2PSTEX_INPUT_FLAGS) "$<"
else
PLOT2PSTEX_INPUT_FLAGS_EX = "$(PLOT2PSTEX_INPUT_FLAGS)$<"
endif
ifeq ("-$(findstring =,$(PLOT2PSTEX_OUTPUT_FLAGS))","-")
PLOT2PSTEX_OUTPUT_FLAGS_EX = $(PLOT2PSTEX_OUTPUT_FLAGS) "$@"
else
PLOT2PSTEX_OUTPUT_FLAGS_EX = "$(PLOT2PSTEX_OUTPUT_FLAGS)$@"
endif

ifeq ("-$(findstring =,$(PLOT2PSTEX_T_INPUT_FLAGS))","-")
PLOT2PSTEX_T_INPUT_FLAGS_EX = $(PLOT2PSTEX_T_INPUT_FLAGS) "$<"
else
PLOT2PSTEX_T_INPUT_FLAGS_EX = "$(PLOT2PSTEX_T_INPUT_FLAGS)$<"
endif
ifeq ("-$(findstring =,$(PLOT2PSTEX_T_OUTPUT_FLAGS))","-")
PLOT2PSTEX_T_OUTPUT_FLAGS_EX = $(PLOT2PSTEX_T_OUTPUT_FLAGS) "$@"
else
PLOT2PSTEX_T_OUTPUT_FLAGS_EX = "$(PLOT2PSTEX_T_OUTPUT_FLAGS)$@"
endif

# Compile the convertion commands
ifeq ("${PLOT2PSTEX_OUTPUT_STDOUT}","yes")
PLOT2PSTEX_SHELL_CMD = $(PLOT2PSTEX_BIN) $(PLOT2PSTEX_FLAGS) $(PLOT2PSTEX_INPUT_FLAGS_EX) $(PLOT2PSTEX_POST_FLAGS) > "$@"
else
ifeq ("${PLOT2PSTEX_OUTPUT_INPUT}","yes")
PLOT2PSTEX_SHELL_CMD = $(PLOT2PSTEX_BIN) $(PLOT2PSTEX_FLAGS) $(PLOT2PSTEX_OUTPUT_FLAGS_EX) $(PLOT2PSTEX_INPUT_FLAGS_EX) $(PLOT2PSTEX_POST_FLAGS)
else
PLOT2PSTEX_SHELL_CMD = $(PLOT2PSTEX_BIN) $(PLOT2PSTEX_FLAGS) $(PLOT2PSTEX_INPUT_FLAGS_EX) $(PLOT2PSTEX_OUTPUT_FLAGS_EX) $(PLOT2PSTEX_POST_FLAGS)
endif
endif

ifeq ("${PLOT2PSTEX_T_OUTPUT_STDOUT}","yes")
PLOT2PSTEX_T_SHELL_CMD = $(PLOT2PSTEX_T_BIN) $(PLOT2PSTEX_T_FLAGS) $(PLOT2PSTEX_T_INPUT_FLAGS_EX) $(PLOT2PSTEX_T_POST_FLAGS) > "$@"
else
ifeq ("${PLOT2PSTEX_T_OUTPUT_INPUT}","yes")
PLOT2PSTEX_T_SHELL_CMD = $(PLOT2PSTEX_T_BIN) $(PLOT2PSTEX_T_FLAGS) $(PLOT2PSTEX_T_OUTPUT_FLAGS_EX) $(PLOT2PSTEX_T_INPUT_FLAGS_EX) $(PLOT2PSTEX_T_POST_FLAGS)
else
PLOT2PSTEX_T_SHELL_CMD = $(PLOT2PSTEX_T_BIN) $(PLOT2PSTEX_T_FLAGS) $(PLOT2PSTEX_T_INPUT_FLAGS_EX) $(PLOT2PSTEX_T_OUTPUT_FLAGS_EX) $(PLOT2PSTEX_T_POST_FLAGS)
endif
endif


$(PSTEX_T_PLOT): %.pstex_t: %.ltx.plot
	@ ${ECHO_CMD} "$< -> $@" && $(PLOT2PSTEX_T_SHELL_CMD)

$(PSTEX_PLOT): %.pstex: %.ltx.plot
	@ ${ECHO_CMD} "$< -> $@" && $(PLOT2PSTEX_SHELL_CMD)

$(PDF_PSTEX_PLOT): %.pdf: %.pstex
	@ ${ECHO_CMD} "$< -> $@" && $(EPS2PDF_SHELL_CMD)

endif
