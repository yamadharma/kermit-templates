# svg2png.mk

ifeq ("$(call isTranslatorLoaded,svg2png)","false")

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
# <binfile> <flags> <inputflags> <input.svg> <outputflags> <output.png>
SVG2PNG_BIN           = inkscape
SVG2PNG_FLAGS         = --without-gui --export-background-opacity=0.0 --export-dpi=160
SVG2PNG_INPUT_FLAGS   =
SVG2PNG_OUTPUT_FLAGS  = --export-png=
SVG2PNG_POST_FLAGS    =
SVG2PNG_OUTPUT_INPUT  = no
SVG2PNG_OUTPUT_STDOUT = no

#-----------------------------------
#----------- DO NOT CHANGE BELOW
#-----------------------------------

# Notify of the loading of this module
LOADED_TRANSLATORS += svg2png

SVG_FIG = $(call launchShell, ${FIND_CMD} ${AUTO_GENERATE_IMAGE_DIRECTORY} -name "*.svg")

PNG_SVG = $(addsuffix .png,          $(basename ${SVG_FIG}))

SOURCE_IMAGES += ${SVG_FIG}
IMAGES        += ${PNG_SVG}

# Compile the convertion parameters
ifeq ("-$(findstring =,$(SVG2PNG_INPUT_FLAGS))","-")
SVG2PNG_INPUT_FLAGS_EX = $(strip $(SVG2PNG_INPUT_FLAGS)) "$<"
else
SVG2PNG_INPUT_FLAGS_EX = $(strip $(SVG2PNG_INPUT_FLAGS))"$<"
endif
ifeq ("-$(findstring =,$(SVG2PNG_OUTPUT_FLAGS))","-")
SVG2PNG_OUTPUT_FLAGS_EX = $(strip $(SVG2PNG_OUTPUT_FLAGS)) "$@"
else
SVG2PNG_OUTPUT_FLAGS_EX = $(strip $(SVG2PNG_OUTPUT_FLAGS))"$@"
endif

# Compile the convertion commands
ifeq ("${SVG2PNG_OUTPUT_STDOUT}","yes")
SVG2PNG_SHELL_CMD = $(SVG2PNG_BIN) $(SVG2PNG_FLAGS) $(SVG2PNG_INPUT_FLAGS_EX) $(SVG2PNG_POST_FLAGS) > "$@"
else
ifeq ("${SVG2PNG_OUTPUT_INPUT}","yes")
SVG2PNG_SHELL_CMD = $(SVG2PNG_BIN) $(SVG2PNG_FLAGS) $(SVG2PNG_OUTPUT_FLAGS_EX) $(SVG2PNG_INPUT_FLAGS_EX) $(SVG2PNG_POST_FLAGS)
else
SVG2PNG_SHELL_CMD = $(SVG2PNG_BIN) $(SVG2PNG_FLAGS) $(SVG2PNG_INPUT_FLAGS_EX) $(SVG2PNG_OUTPUT_FLAGS_EX) $(SVG2PNG_POST_FLAGS)
endif
endif


$(PNG_SVG): %.png: %.svg
	@ ${ECHO_CMD} "$< -> $@" && $(SVG2PNG_SHELL_CMD)

endif
