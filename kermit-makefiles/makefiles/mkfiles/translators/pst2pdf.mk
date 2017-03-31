# pst2pdf.mk

ifeq ("$(call isTranslatorLoaded,pst2pdf)","false")

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
# <binfile> <flags> <inputflags> <input.dia> <outputflags> <output.eps>
PST2PDF_BIN           = mkfiles/scripts/pst2pdf
PST2PDF_FLAGS         = 
PST2PDF_INPUT_FLAGS   =
PST2PDF_OUTPUT_FLAGS  = 
PST2PDF_POST_FLAGS    =
PST2PDF_OUTPUT_INPUT  = yes
PST2PDF_OUTPUT_STDOUT = yes

#-----------------------------------
#----------- DO NOT CHANGE BELOW
#-----------------------------------

# The commands to convert an EPS file into PDF are required
#ifeq ("$(call isTranslatorLoaded,eps2pdf)","false")
##include $(call getTranslatorMkfile,eps2pdf)
#endif

# Notify of the loading of this module
LOADED_TRANSLATORS += pst2pdf

PST_FIG = $(call launchShell, ${FIND_CMD} ${AUTO_GENERATE_IMAGE_DIRECTORY} -name "*.pst")

EPS_PST = $(addsuffix .eps,          $(basename ${PST_FIG}))
PDF_PST = $(addsuffix .pdf,          $(basename ${PST_FIG}))

SOURCE_IMAGES += ${PST_FIG}
TMPIMAGES     += ${EPS_PST}
IMAGES        += ${PDF_PST}

# Compile the convertion parameters
ifeq ("-$(findstring =,$(PST2PDF_INPUT_FLAGS))","-")
PST2PDF_INPUT_FLAGS_EX = $(PST2PDF_INPUT_FLAGS) "$<"
else
PST2PDF_INPUT_FLAGS_EX = "$(PST2PDF_INPUT_FLAGS)$<"
endif
ifeq ("-$(findstring =,$(PST2PDF_OUTPUT_FLAGS))","-")
PST2PDF_OUTPUT_FLAGS_EX = $(PST2PDF_OUTPUT_FLAGS) "$@"
else
PST2PDF_OUTPUT_FLAGS_EX = "$(PST2PDF_OUTPUT_FLAGS)$@"
endif

# Compile the convertion commands
ifeq ("${PST2PDF_OUTPUT_STDOUT}","yes")
PST2PDF_SHELL_CMD = LANG="C" $(PST2PDF_BIN) $(PST2PDF_FLAGS) $(PST2PDF_INPUT_FLAGS_EX) $(PST2PDF_POST_FLAGS)
#PST2PDF_SHELL_CMD = LANG="C" $(PST2PDF_BIN) $(PST2PDF_FLAGS) $(PST2PDF_INPUT_FLAGS_EX) $(PST2PDF_POST_FLAGS) > "$@"
else
ifeq ("${PST2PDF_OUTPUT_INPUT}","yes")
PST2PDF_SHELL_CMD = LANG="C" $(PST2PDF_BIN) $(PST2PDF_FLAGS) $(PST2PDF_OUTPUT_FLAGS_EX) $(PST2PDF_INPUT_FLAGS_EX) $(PST2PDF_POST_FLAGS)
else
PST2PDF_SHELL_CMD = LANG="C" $(PST2PDF_BIN) $(PST2PDF_FLAGS) $(PST2PDF_INPUT_FLAGS_EX) $(PST2PDF_OUTPUT_FLAGS_EX) $(PST2PDF_POST_FLAGS)
endif
endif


$(EPS_PST): %.eps: %.pst
	@ ${ECHO_CMD} "$< -> $@" && $(PST2PDF_SHELL_CMD)

$(PDF_PST): %.pdf: %.pst
	@ ${ECHO_CMD} "$< -> $@" && $(PST2PDF_SHELL_CMD)

#$(PDF_PST): %.pdf: %.eps
#	@ ${ECHO_CMD} "$< -> $@" && $(EPS2PDF_SHELL_CMD)

endif
