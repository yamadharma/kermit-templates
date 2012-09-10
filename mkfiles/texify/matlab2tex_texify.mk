# autolatex - matlab2tex_texify.mk
# Copyright (C) 2012  Stephane Galland <galland@arakhne.org>
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

ifeq ("$(call isTranslatorLoaded,matlab2tex)","false")

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

# Constant definitions
MATLAB2TEX_TEXT_WIDTH ?= 60
MATLAB2TEX_TAB_SIZE   ?= 2

# Command definition.
# Required synoptics of the command:
# <binfile> <flags> <inputflags> <input.rb> <outputflags> <output.tex>
MATLAB2TEX_BIN           = texifymatlab
MATLAB2TEX_FLAGS         = -l ${MATLAB2TEX_TEXT_WIDTH} -t ${MATLAB2TEX_TAB_SIZE}
MATLAB2TEX_INPUT_FLAGS   = -i
MATLAB2TEX_OUTPUT_FLAGS  = -o
MATLAB2TEX_POST_FLAGS    = >/dev/null 2>/dev/null
MATLAB2TEX_OUTPUT_INPUT  = no
MATLAB2TEX_OUTPUT_STDOUT = no

#-----------------------------------
#----------- DO NOT CHANGE BELOW
#-----------------------------------

# Notify of the loading of this module
LOADED_TRANSLATORS += matlab2tex

MATLAB_FIG = $(call launchShell, ${FIND_CMD} ${AUTO_GENERATE_IMAGE_DIRECTORY} -name "*.m")

TEX_MATLAB = $(addsuffix .tex,          $(basename ${MATLAB_FIG}))

SOURCE_IMAGES += ${MATLAB_FIG}
IMAGES        += ${TEX_MATLAB}

# Compile the convertion parameters
ifeq ("-$(findstring =,$(MATLAB2TEX_INPUT_FLAGS))","-")
MATLAB2TEX_INPUT_FLAGS_EX = $(strip $(MATLAB2TEX_INPUT_FLAGS)) "$<"
else
MATLAB2TEX_INPUT_FLAGS_EX = $(strip $(MATLAB2TEX_INPUT_FLAGS))"$<"
endif
ifeq ("-$(findstring =,$(MATLAB2TEX_OUTPUT_FLAGS))","-")
MATLAB2TEX_OUTPUT_FLAGS_EX = $(strip $(MATLAB2TEX_OUTPUT_FLAGS)) "$@"
else
MATLAB2TEX_OUTPUT_FLAGS_EX = $(strip $(MATLAB2TEX_OUTPUT_FLAGS))"$@"
endif

# Compile the convertion commands
ifeq ("${MATLAB2TEX_OUTPUT_STDOUT}","yes")
MATLAB2TEX_SHELL_CMD = $(MATLAB2TEX_BIN) $(MATLAB2TEX_FLAGS) $(MATLAB2TEX_INPUT_FLAGS_EX) $(MATLAB2TEX_POST_FLAGS) > "$@"
else
ifeq ("${MATLAB2TEX_OUTPUT_INPUT}","yes")
MATLAB2TEX_SHELL_CMD = $(MATLAB2TEX_BIN) $(MATLAB2TEX_FLAGS) $(MATLAB2TEX_OUTPUT_FLAGS_EX) $(MATLAB2TEX_INPUT_FLAGS_EX) $(MATLAB2TEX_POST_FLAGS)
else
MATLAB2TEX_SHELL_CMD = $(MATLAB2TEX_BIN) $(MATLAB2TEX_FLAGS) $(MATLAB2TEX_INPUT_FLAGS_EX) $(MATLAB2TEX_OUTPUT_FLAGS_EX) $(MATLAB2TEX_POST_FLAGS)
endif
endif


$(TEX_MATLAB): %.tex: %.m
	@ ${ECHO_CMD} "$< -> $@" && $(MATLAB2TEX_SHELL_CMD)

endif
