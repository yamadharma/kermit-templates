# plot2pdf.mk

ifeq ("$(call isTranslatorLoaded,gxl2pdf)","false")

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
GXL2DOT_BIN           = gxl2dot
GXL2DOT_FLAGS         = -d
GXL2DOT_INPUT_FLAGS   =
GXL2DOT_OUTPUT_FLAGS  = -o
GXL2DOT_POST_FLAGS    =
GXL2DOT_OUTPUT_INPUT  = yes
GXL2DOT_OUTPUT_STDOUT = no

#-----------------------------------
#----------- DO NOT CHANGE BELOW
#-----------------------------------

# The commands to convert an DOT file into PDF are required
ifeq ("$(call isTranslatorLoaded,dot2pdf)","false")
include $(call getTranslatorMkfile,dot2pdf)
endif

# Notify of the loading of this module
LOADED_TRANSLATORS += gxl2pdf

GXL_FIG = $(call launchShell, ${FIND_CMD} ${AUTO_GENERATE_IMAGE_DIRECTORY} -name "*.gxl" -a -not -name "*.gxl.plot")

DOT_GXL = $(addsuffix .gxl,          $(basename ${GXL_FIG}))
PDF_GXL = $(addsuffix .pdf,          $(basename ${GXL_FIG}))

SOURCE_IMAGES += ${GXL_FIG}
TMPIMAGES     += ${DOT_GXL}
IMAGES        += ${PDF_GXL}

# Compile the convertion parameters
ifeq ("-$(findstring =,$(GXL2DOT_INPUT_FLAGS))","-")
GXL2DOT_INPUT_FLAGS_EX = $(GXL2DOT_INPUT_FLAGS) "$<"
else
GXL2DOT_INPUT_FLAGS_EX = "$(GXL2DOT_INPUT_FLAGS)$<"
endif
ifeq ("-$(findstring =,$(GXL2DOT_OUTPUT_FLAGS))","-")
GXL2DOT_OUTPUT_FLAGS_EX = $(GXL2DOT_OUTPUT_FLAGS) "$@"
else
GXL2DOT_OUTPUT_FLAGS_EX = "$(GXL2DOT_OUTPUT_FLAGS)$@"
endif

# Compile the convertion commands
ifeq ("${GXL2DOT_OUTPUT_STDOUT}","yes")
GXL2DOT_SHELL_CMD = $(GXL2DOT_BIN) $(GXL2DOT_FLAGS) $(GXL2DOT_INPUT_FLAGS_EX) $(GXL2DOT_POST_FLAGS) > "$@"
else
ifeq ("${GXL2DOT_OUTPUT_INPUT}","yes")
GXL2DOT_SHELL_CMD = $(GXL2DOT_BIN) $(GXL2DOT_FLAGS) $(GXL2DOT_OUTPUT_FLAGS_EX) $(GXL2DOT_INPUT_FLAGS_EX) $(GXL2DOT_POST_FLAGS)
else
GXL2DOT_SHELL_CMD = $(GXL2DOT_BIN) $(GXL2DOT_FLAGS) $(GXL2DOT_INPUT_FLAGS_EX) $(GXL2DOT_OUTPUT_FLAGS_EX) $(GXL2DOT_POST_FLAGS)
endif
endif




$(DOT_GXL): %.dot: %.gxl
	@ ${ECHO_CMD} "$< -> $@" && $(GXL2DOT_SHELL_CMD)

$(PDF_GXL): %.pdf: %.dot
	@ ${ECHO_CMD} "$< -> $@" && $(DOT2PDF_SHELL_CMD)

endif
