# autolatex - fig2pdf+tex.mk
# Copyright (C) 1998-08  Stephane Galland <galland@arakhne.org>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; see the file COPYING.  If not, write to
# the Free Software Foundation, Inc., 59 Temple Place - Suite 330,
# Boston, MA 02111-1307, USA.

ifeq ("$(call isTranslatorLoaded,fig2pdf+tex)","false")

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
# <binfile> <flags> <inputflags> <input.ltx.fig> <outputflags> <output.pstex>
FIG2PSTEX_BIN            = fig2dev
FIG2PSTEX_FLAGS          = -L pstex
FIG2PSTEX_INPUT_FLAGS    =
FIG2PSTEX_OUTPUT_FLAGS   = 
FIG2PSTEX_POST_FLAGS     = 
FIG2EPSTEX_OUTPUT_INPUT  = no
FIG2EPSTEX_OUTPUT_STDOUT = no

# Command definition to generated the TeX part.
# Required synoptics of the command:
# <binfile> <flags> <inputflags> <input.ltx.fig> <outputflags> <output.pstex_t>
FIG2PSTEXT_BIN           = fig2pstex_t
FIG2PSTEXT_FLAGS         = 
FIG2PSTEXT_INPUT_FLAGS   =
FIG2PSTEXT_OUTPUT_FLAGS  =
FIG2PSTEXTPOST_FLAGS     =
FIG2PSTEXT_OUTPUT_INPUT  = no
FIG2PSTEXT_OUTPUT_STDOUT = no

#-----------------------------------
#----------- DO NOT CHANGE BELOW
#-----------------------------------

# The commands to convert an EPS file into PDF are required
ifeq ("$(call isTranslatorLoaded,eps2pdf)","false")
include $(call getTranslatorMkfile,eps2pdf)
endif

# Notify of the loading of this module
LOADED_TRANSLATORS += fig2pdf+tex

PSTEX_FIG    = $(call launchShell, ${FIND_CMD} . -name "*.ltx.fig")

PSTEX_XFIG     = $(addsuffix .pstex,        $(basename $(basename ${PSTEX_FIG})))
PSTEX_T_XFIG   = $(addsuffix .pstex_t,      $(basename $(basename ${PSTEX_FIG})))
PDF_PSTEX_XFIG = $(addsuffix .pdf,          $(basename ${PSTEX_XFIG}))

SOURCE_IMAGES += ${PSTEX_FIG}
TMPIMAGES     += ${PSTEX_XFIG}
IMAGES        += ${PSTEX_T_XFIG} ${PDF_PSTEX_XFIG}

# Compile the convertion parameters
ifeq ("-$(findstring =,$(FIG2PSTEX_INPUT_FLAGS))","-")
FIG2PSTEX_INPUT_FLAGS_EX = $(FIG2PSTEX_INPUT_FLAGS) "$<"
else
FIG2PSTEX_INPUT_FLAGS_EX = "$(FIG2PSTEX_INPUT_FLAGS)$<"
endif
ifeq ("-$(findstring =,$(FIG2PSTEX_OUTPUT_FLAGS))","-")
FIG2PSTEX_OUTPUT_FLAGS_EX = $(FIG2PSTEX_OUTPUT_FLAGS) "$@"
else
FIG2PSTEX_OUTPUT_FLAGS_EX = "$(FIG2PSTEX_OUTPUT_FLAGS)$@"
endif

ifeq ("-$(findstring =,$(FIG2PSTEX_T_INPUT_FLAGS))","-")
FIG2PSTEX_T_INPUT_FLAGS_EX = $(FIG2PSTEX_T_INPUT_FLAGS) "$<"
else
FIG2PSTEX_T_INPUT_FLAGS_EX = "$(FIG2PSTEX_T_INPUT_FLAGS)$<"
endif
ifeq ("-$(findstring =,$(FIG2PSTEX_T_OUTPUT_FLAGS))","-")
FIG2PSTEX_T_OUTPUT_FLAGS_EX = $(FIG2PSTEX_T_OUTPUT_FLAGS) "$@"
else
FIG2PSTEX_T_OUTPUT_FLAGS_EX = "$(FIG2PSTEX_T_OUTPUT_FLAGS)$@"
endif

# Compile the convertion commands
ifeq ("${FIG2PSTEX_OUTPUT_STDOUT}","yes")
FIG2PSTEX_SHELL_CMD = $(FIG2PSTEX_BIN) $(FIG2PSTEX_FLAGS) $(FIG2PSTEX_INPUT_FLAGS_EX) $(FIG2PSTEX_POST_FLAGS) > "$@"
else
ifeq ("${FIG2PSTEX_OUTPUT_INPUT}","yes")
FIG2PSTEX_SHELL_CMD = $(FIG2PSTEX_BIN) $(FIG2PSTEX_FLAGS) $(FIG2PSTEX_OUTPUT_FLAGS_EX) $(FIG2PSTEX_INPUT_FLAGS_EX) $(FIG2PSTEX_POST_FLAGS)
else
FIG2PSTEX_SHELL_CMD = $(FIG2PSTEX_BIN) $(FIG2PSTEX_FLAGS) $(FIG2PSTEX_INPUT_FLAGS_EX) $(FIG2PSTEX_OUTPUT_FLAGS_EX) $(FIG2PSTEX_POST_FLAGS)
endif
endif

ifeq ("${FIG2PSTEX_T_OUTPUT_STDOUT}","yes")
FIG2PSTEX_T_SHELL_CMD = $(FIG2PSTEX_T_BIN) $(FIG2PSTEX_T_FLAGS) $(FIG2PSTEX_T_INPUT_FLAGS_EX) $(FIG2PSTEX_T_POST_FLAGS) > "$@"
else
ifeq ("${FIG2PSTEX_T_OUTPUT_INPUT}","yes")
FIG2PSTEX_T_SHELL_CMD = $(FIG2PSTEX_T_BIN) $(FIG2PSTEX_T_FLAGS) $(FIG2PSTEX_T_OUTPUT_FLAGS_EX) $(FIG2PSTEX_T_INPUT_FLAGS_EX) $(FIG2PSTEX_T_POST_FLAGS)
else
FIG2PSTEX_T_SHELL_CMD = $(FIG2PSTEX_T_BIN) $(FIG2PSTEX_T_FLAGS) $(FIG2PSTEX_T_INPUT_FLAGS_EX) $(FIG2PSTEX_T_OUTPUT_FLAGS_EX) $(FIG2PSTEX_T_POST_FLAGS)
endif
endif


$(PSTEX_T_XFIG): %.pstex_t: %.ltx.fig
	@ ${ECHO_CMD} "$< -> $@" && $(FIG2PSTEX_T_SHELL_CMD)

$(PSTEX_XFIG): %.pstex: %.ltx.fig
	@ ${ECHO_CMD} "$< -> $@" && $(FIG2PSTEX_SHELL_CMD)

$(PDF_PSTEX_XFIG): %.pdf: %.pstex
	@ ${ECHO_CMD} "$< -> $@" && $(EPS2PDF_SHELL_CMD)

endif
