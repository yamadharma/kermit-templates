# pdf2svg.mk

ifeq ("$(call isTranslatorLoaded,pdf2svg)","false")

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
# <binfile> <flags> <inputflags> <input.pdf> <outputflags> <output.svg>
PDF2SVG_BIN           = pdf2svg
PDF2SVG_FLAGS         = 
PDF2SVG_INPUT_FLAGS   =
PDF2SVG_OUTPUT_FLAGS  = 
PDF2SVG_POST_FLAGS    =
PDF2SVG_OUTPUT_INPUT  = no
PDF2SVG_OUTPUT_STDOUT = no

#-----------------------------------
#----------- DO NOT CHANGE BELOW
#-----------------------------------

# Notify of the loading of this module
LOADED_TRANSLATORS += pdf2svg

PDF_FIG = $(call launchShell, ${FIND_CMD} ${AUTO_GENERATE_IMAGE_DIRECTORY} -name "*.pdf")

SVG_PDF = $(addsuffix .svg,          $(basename ${PDF_FIG}))

SOURCE_IMAGES += ${PDF_FIG}
IMAGES        += ${SVG_PDF}

# Compile the convertion parameters
ifeq ("-$(findstring =,$(PDF2SVG_INPUT_FLAGS))","-")
PDF2SVG_INPUT_FLAGS_EX = $(strip $(PDF2SVG_INPUT_FLAGS)) "$<"
else
PDF2SVG_INPUT_FLAGS_EX = $(strip $(PDF2SVG_INPUT_FLAGS))"$<"
endif
ifeq ("-$(findstring =,$(PDF2SVG_OUTPUT_FLAGS))","-")
PDF2SVG_OUTPUT_FLAGS_EX = $(strip $(PDF2SVG_OUTPUT_FLAGS)) "$@"
else
PDF2SVG_OUTPUT_FLAGS_EX = $(strip $(PDF2SVG_OUTPUT_FLAGS))"$@"
endif

# Compile the convertion commands
ifeq ("${PDF2SVG_OUTPUT_STDOUT}","yes")
PDF2SVG_SHELL_CMD = $(PDF2SVG_BIN) $(PDF2SVG_FLAGS) $(PDF2SVG_INPUT_FLAGS_EX) $(PDF2SVG_POST_FLAGS) > "$@"
else
ifeq ("${PDF2SVG_OUTPUT_INPUT}","yes")
PDF2SVG_SHELL_CMD = $(PDF2SVG_BIN) $(PDF2SVG_FLAGS) $(PDF2SVG_OUTPUT_FLAGS_EX) $(PDF2SVG_INPUT_FLAGS_EX) $(PDF2SVG_POST_FLAGS)
else
PDF2SVG_SHELL_CMD = $(PDF2SVG_BIN) $(PDF2SVG_FLAGS) $(PDF2SVG_INPUT_FLAGS_EX) $(PDF2SVG_OUTPUT_FLAGS_EX) $(PDF2SVG_POST_FLAGS)
endif
endif

$(SVG_PDF): %.svg: %.pdf
	@ ${ECHO_CMD} "$< -> $@" && $(PDF2SVG_SHELL_CMD)

endif
