# xmi2pdf_umbrello.mk

ifeq ("$(call isTranslatorLoaded,xmi2pdf)","false")

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
# <binfile> <flags> <inputflags> <input.xmi> <outputflags> <output.eps>
XMI2EPS_BIN           = xmi2eps_umbrello
XMI2EPS_FLAGS         = eps
XMI2EPS_INPUT_FLAGS   =
XMI2EPS_OUTPUT_FLAGS  =
XMI2EPS_POST_FLAGS    = >/dev/null 2>/dev/null
XMI2EPS_OUTPUT_INPUT  = no
XMI2EPS_OUTPUT_STDOUT = no

#-----------------------------------
#----------- DO NOT CHANGE BELOW
#-----------------------------------

# The commands to convert an EPS file into PDF are required
ifeq ("$(call isTranslatorLoaded,eps2pdf)","false")
include $(call getTranslatorMkfile,eps2pdf)
endif

# Notify of the loading of this module
LOADED_TRANSLATORS += xmi2pdf

XMI_FIG = $(call launchShell, ${FIND_CMD} ${AUTO_GENERATE_IMAGE_DIRECTORY} -name "*.xmi")

EPS_XMI = $(addsuffix .eps,          $(basename ${XMI_FIG}))
PDF_XMI = $(addsuffix .pdf,          $(basename ${XMI_FIG}))

SOURCE_IMAGES += ${XMI_FIG}
TMPIMAGES     += ${EPS_XMI}
IMAGES        += ${PDF_XMI}

# Compile the convertion parameters
ifeq ("-$(findstring =,$(XMI2EPS_INPUT_FLAGS))","-")
XMI2EPS_INPUT_FLAGS_EX = $(strip $(XMI2EPS_INPUT_FLAGS)) "$<"
else
XMI2EPS_INPUT_FLAGS_EX = $(strip $(XMI2EPS_INPUT_FLAGS))"$<"
endif
ifeq ("-$(findstring =,$(XMI2EPS_OUTPUT_FLAGS))","-")
XMI2EPS_OUTPUT_FLAGS_EX = $(strip $(XMI2EPS_OUTPUT_FLAGS)) "$@"
else
XMI2EPS_OUTPUT_FLAGS_EX = $(strip $(XMI2EPS_OUTPUT_FLAGS))"$@"
endif

# Compile the convertion commands
ifeq ("${XMI2EPS_OUTPUT_STDOUT}","yes")
XMI2EPS_SHELL_CMD = $(XMI2EPS_BIN) $(XMI2EPS_FLAGS) $(XMI2EPS_INPUT_FLAGS_EX) $(XMI2EPS_POST_FLAGS) > "$@"
else
ifeq ("${XMI2EPS_OUTPUT_INPUT}","yes")
XMI2EPS_SHELL_CMD = $(XMI2EPS_BIN) $(XMI2EPS_FLAGS) $(XMI2EPS_OUTPUT_FLAGS_EX) $(XMI2EPS_INPUT_FLAGS_EX) $(XMI2EPS_POST_FLAGS)
else
XMI2EPS_SHELL_CMD = $(XMI2EPS_BIN) $(XMI2EPS_FLAGS) $(XMI2EPS_INPUT_FLAGS_EX) $(XMI2EPS_OUTPUT_FLAGS_EX) $(XMI2EPS_POST_FLAGS)
endif
endif


$(EPS_XMI): %.eps: %.xmi
	@ ${ECHO_CMD} "$< -> $@" && $(XMI2EPS_SHELL_CMD)

$(PDF_XMI): %.pdf: %.eps
	@ ${ECHO_CMD} "$< -> $@" && $(EPS2PDF_SHELL_CMD)

endif
