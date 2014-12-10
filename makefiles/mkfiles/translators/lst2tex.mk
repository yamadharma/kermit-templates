# lst2tex.mk
# Use pygment (http://pygments.org/)

ifeq ("$(call isTranslatorLoaded,lst2tex)","false")

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
# <binfile> <flags> <inputflags> <input.lst> <outputflags> <output.tex>
LST2TEX_BIN           = pygmentize
LST2TEX_FLAGS         = -f latex
LST2TEX_INPUT_FLAGS   = 
LST2TEX_OUTPUT_FLAGS  = -o
LST2TEX_POST_FLAGS    =
LST2TEX_OUTPUT_INPUT  = yes
LST2TEX_OUTPUT_STDOUT = no

#-----------------------------------
#----------- DO NOT CHANGE BELOW
#-----------------------------------

LST_FIG = $(call launchShell, ${FIND_CMD} -L ${AUTO_GENERATE_LST_DIRECTORY} -regextype posix-extended -regex ".*\.(c|h)")

LST_TEX = $(addsuffix .tex,          ${LST_FIG})

SOURCE_IMAGES += ${LST_FIG}
IMAGES        += ${LST_TEX}

# Compile the convertion parameters
ifeq ("-$(findstring =,$(LST2TEX_INPUT_FLAGS))","-")
LST2TEX_INPUT_FLAGS_EX = $(LST2TEX_INPUT_FLAGS) "$<"
else
LST2TEX_INPUT_FLAGS_EX = "$(LST2TEX_INPUT_FLAGS)$<"
endif
ifeq ("-$(findstring =,$(LST2TEX_OUTPUT_FLAGS))","-")
LST2TEX_OUTPUT_FLAGS_EX = $(LST2TEX_OUTPUT_FLAGS) "$@"
else
LST2TEX_OUTPUT_FLAGS_EX = "$(LST2TEX_OUTPUT_FLAGS)$@"
endif

# Compile the convertion commands
ifeq ("${LST2TEX_OUTPUT_STDOUT}","yes")
LST2TEX_SHELL_CMD = $(LST2TEX_BIN) $(LST2TEX_FLAGS) $(LST2TEX_INPUT_FLAGS_EX) $(LST2TEX_POST_FLAGS) > "$@"
else
ifeq ("${LST2TEX_OUTPUT_INPUT}","yes")
LST2TEX_SHELL_CMD = $(LST2TEX_BIN) $(LST2TEX_FLAGS) $(LST2TEX_OUTPUT_FLAGS_EX) $(LST2TEX_INPUT_FLAGS_EX) $(LST2TEX_POST_FLAGS)
else
LST2TEX_SHELL_CMD = $(LST2TEX_BIN) $(LST2TEX_FLAGS) $(LST2TEX_INPUT_FLAGS_EX) $(LST2TEX_OUTPUT_FLAGS_EX) $(LST2TEX_POST_FLAGS)
endif
endif

LST2TEX_CHECK_CMD = if [ -f "lst.tex" ] ; then echo "lst.tex exist" ; else pygmentize -S bw -f latex > lst.tex ; fi

%.c.tex: %.c
	@ ${ECHO_CMD} "Check: lst.tex" && $(LST2TEX_CHECK_CMD)
	@ ${ECHO_CMD} "$< -> $@" && $(LST2TEX_SHELL_CMD)

%.h.tex: %.h
	@ ${ECHO_CMD} "Check: lst.tex" && $(LST2TEX_CHECK_CMD)
	@ ${ECHO_CMD} "$< -> $@" && $(LST2TEX_SHELL_CMD)

endif
