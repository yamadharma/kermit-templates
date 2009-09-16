# dia2svg.mk

ifeq ("$(call isTranslatorLoaded,dia2svg)","false")

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
# <binfile> <flags> <inputflags> <input.dia> <outputflags> <output.svg>
DIA2SVG_BIN           = inkscape
DIA2SVG_FLAGS         = --without-gui
DIA2SVG_INPUT_FLAGS   =
DIA2SVG_OUTPUT_FLAGS  = --export-plain-svg=
DIA2SVG_POST_FLAGS    =
DIA2SVG_OUTPUT_INPUT  = no
DIA2SVG_OUTPUT_STDOUT = no

#-----------------------------------
#----------- DO NOT CHANGE BELOW
#-----------------------------------

# Notify of the loading of this module
LOADED_TRANSLATORS += dia2svg

DIA_FIG = $(call launchShell, ${FIND_CMD} ${AUTO_GENERATE_IMAGE_DIRECTORY} -name "*.dia")

SVG_DIA = $(addsuffix .svg,          $(basename ${DIA_FIG}))

SOURCE_IMAGES += ${DIA_FIG}
IMAGES        += ${SVG_DIA}

# Compile the convertion parameters
ifeq ("-$(findstring =,$(DIA2SVG_INPUT_FLAGS))","-")
DIA2SVG_INPUT_FLAGS_EX = $(strip $(DIA2SVG_INPUT_FLAGS)) "$<"
else
DIA2SVG_INPUT_FLAGS_EX = $(strip $(DIA2SVG_INPUT_FLAGS))"$<"
endif
ifeq ("-$(findstring =,$(DIA2SVG_OUTPUT_FLAGS))","-")
DIA2SVG_OUTPUT_FLAGS_EX = $(strip $(DIA2SVG_OUTPUT_FLAGS)) "$@"
else
DIA2SVG_OUTPUT_FLAGS_EX = $(strip $(DIA2SVG_OUTPUT_FLAGS))"$@"
endif

# Compile the convertion commands
ifeq ("${DIA2SVG_OUTPUT_STDOUT}","yes")
DIA2SVG_SHELL_CMD = $(DIA2SVG_BIN) $(DIA2SVG_FLAGS) $(DIA2SVG_INPUT_FLAGS_EX) $(DIA2SVG_POST_FLAGS) > "$@"
else
ifeq ("${DIA2SVG_OUTPUT_INPUT}","yes")
DIA2SVG_SHELL_CMD = $(DIA2SVG_BIN) $(DIA2SVG_FLAGS) $(DIA2SVG_OUTPUT_FLAGS_EX) $(DIA2SVG_INPUT_FLAGS_EX) $(DIA2SVG_POST_FLAGS)
else
DIA2SVG_SHELL_CMD = $(DIA2SVG_BIN) $(DIA2SVG_FLAGS) $(DIA2SVG_INPUT_FLAGS_EX) $(DIA2SVG_OUTPUT_FLAGS_EX) $(DIA2SVG_POST_FLAGS)
endif
endif


$(SVG_DIA): %.svg: %.dia
	@ ${ECHO_CMD} "$< -> $@" && $(DIA2SVG_SHELL_CMD)

endif
