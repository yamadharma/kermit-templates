# dot2png.mk

ifeq ("$(call isTranslatorLoaded,dot2png)","false")

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
# <binfile> <input.dot> <output.png>
DOT2PNG_BIN           = dot2png
DOT2PNG_FLAGS         =
DOT2PNG_INPUT_FLAGS   =
DOT2PNG_OUTPUT_FLAGS  =
DOT2PNG_POST_FLAGS    =
DOT2PNG_OUTPUT_INPUT  = no
DOT2PNG_OUTPUT_STDOUT = no

#-----------------------------------
#----------- DO NOT CHANGE BELOW
#-----------------------------------

# Notify of the loading of this module
LOADED_TRANSLATORS += dot2png

DOT_FIG = $(call launchShell, ${FIND_CMD} ${AUTO_GENERATE_IMAGE_DIRECTORY} -name "*.dot" -a -not -name "*.ltx.dot")

PNG_DOT = $(addsuffix .png,          $(basename ${DOT_FIG}))

SOURCE_IMAGES += ${DOT_FIG}
IMAGES        += ${PNG_DOT}

# Compile the convertion parameters
ifeq ("-$(findstring =,$(DOT2PNG_INPUT_FLAGS))","-")
DOT2PNG_INPUT_FLAGS_EX = $(DOT2PNG_INPUT_FLAGS) "$<"
else
DOT2PNG_INPUT_FLAGS_EX = "$(DOT2PNG_INPUT_FLAGS)$<"
endif
ifeq ("-$(findstring =,$(DOT2PNG_OUTPUT_FLAGS))","-")
DOT2PNG_OUTPUT_FLAGS_EX = $(DOT2PNG_OUTPUT_FLAGS) "$@"
else
DOT2PNG_OUTPUT_FLAGS_EX = "$(DOT2PNG_OUTPUT_FLAGS)$@"
endif

# Compile the convertion commands
ifeq ("${DOT2PNG_OUTPUT_STDOUT}","yes")
DOT2PNG_SHELL_CMD = $(DOT2PNG_BIN) $(DOT2PNG_FLAGS) $(DOT2PNG_INPUT_FLAGS_EX) $(DOT2PNG_POST_FLAGS) > "$@"
else
ifeq ("${DOT2PNG_OUTPUT_INPUT}","yes")
DOT2PNG_SHELL_CMD = $(DOT2PNG_BIN) $(DOT2PNG_FLAGS) $(DOT2PNG_OUTPUT_FLAGS_EX) $(DOT2PNG_INPUT_FLAGS_EX) $(DOT2PNG_POST_FLAGS)
else
DOT2PNG_SHELL_CMD = $(DOT2PNG_BIN) $(DOT2PNG_FLAGS) $(DOT2PNG_INPUT_FLAGS_EX) $(DOT2PNG_OUTPUT_FLAGS_EX) $(DOT2PNG_POST_FLAGS)
endif
endif



$(PNG_DOT): %.png: %.dot
	@ ${ECHO_CMD} "$< -> $@" && $(DOT2PNG_SHELL_CMD)

endif
