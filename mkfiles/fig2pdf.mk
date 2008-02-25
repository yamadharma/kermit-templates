# autolatex - fig2pdf.mk
# Copyright (C) 1998-07  Stephane Galland <galland@arakhne.org>
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

ifeq ("$(call isTranslatorLoaded,fig2pdf)","false")

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
# <binfile> <flags> <inputflags> <input.fig> <outputflags> <output.eps>
FIG2EPS_BIN           = fig2dev
FIG2EPS_FLAGS         = -L eps
FIG2EPS_INPUT_FLAGS   =
FIG2EPS_OUTPUT_FLAGS  =
FIG2EPS_POST_FLAGS    =
FIG2EPS_OUTPUT_INPUT  = no
FIG2EPS_OUTPUT_STDOUT = no

#-----------------------------------
#----------- DO NOT CHANGE BELOW
#-----------------------------------

# The commands to convert an EPS file into PDF are required
ifeq ("$(call isTranslatorLoaded,eps2pdf)","false")
include $(call getTranslatorMkfile,eps2pdf)
endif

# Notify of the loading of this module
LOADED_TRANSLATORS += fig2pdf

XFIG_FIG = $(call launchShell, ${FIND_CMD} . -name "*.fig" -a -not -name "*.ltx.fig")

EPS_XFIG = $(addsuffix .eps,          $(basename ${XFIG_FIG}))
PDF_XFIG = $(addsuffix .pdf,          $(basename ${XFIG_FIG}))

SOURCE_IMAGES += ${XFIG_FIG}
TMPIMAGES     += ${EPS_XFIG}
IMAGES        += ${PDF_XFIG}

# Compile the convertion parameters
ifeq ("-$(findstring =,$(FIG2EPS_INPUT_FLAGS))","-")
FIG2EPS_INPUT_FLAGS_EX = $(FIG2EPS_INPUT_FLAGS) "$<"
else
FIG2EPS_INPUT_FLAGS_EX = "$(FIG2EPS_INPUT_FLAGS)$<"
endif
ifeq ("-$(findstring =,$(FIG2EPS_OUTPUT_FLAGS))","-")
FIG2EPS_OUTPUT_FLAGS_EX = $(FIG2EPS_OUTPUT_FLAGS) "$@"
else
FIG2EPS_OUTPUT_FLAGS_EX = "$(FIG2EPS_OUTPUT_FLAGS)$@"
endif

# Compile the convertion commands
ifeq ("${FIG2EPS_OUTPUT_STDOUT}","yes")
FIG2EPS_SHELL_CMD = $(FIG2EPS_BIN) $(FIG2EPS_FLAGS) $(FIG2EPS_INPUT_FLAGS_EX) $(FIG2EPS_POST_FLAGS) > "$@"
else
ifeq ("${FIG2EPS_OUTPUT_INPUT}","yes")
FIG2EPS_SHELL_CMD = $(FIG2EPS_BIN) $(FIG2EPS_FLAGS) $(FIG2EPS_OUTPUT_FLAGS_EX) $(FIG2EPS_INPUT_FLAGS_EX) $(FIG2EPS_POST_FLAGS)
else
FIG2EPS_SHELL_CMD = $(FIG2EPS_BIN) $(FIG2EPS_FLAGS) $(FIG2EPS_INPUT_FLAGS_EX) $(FIG2EPS_OUTPUT_FLAGS_EX) $(FIG2EPS_POST_FLAGS)
endif
endif



$(EPS_XFIG): %.eps: %.fig
	@ ${ECHO_CMD} "$< -> $@" && $(FIG2EPS_SHELL_CMD)

$(PDF_XFIG): %.pdf: %.eps
	@ ${ECHO_CMD} "$< -> $@" && $(EPS2PDF_SHELL_CMD)

endif
