# autolatex - xmi2pdf_umbrello.mk
# Copyright (C) 2010  Stephane Galland <galland@arakhne.org>
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

ifeq ("$(call isTranslatorLoaded,java2tex)","false")

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
JAVA2TEX_TEXT_WIDTH ?= 60
JAVA2TEX_TAB_SIZE   ?= 2

# Command definition.
# Required synoptics of the command:
# <binfile> <flags> <inputflags> <input.java> <outputflags> <output.tex>
JAVA2TEX_BIN           = texifyjava
JAVA2TEX_FLAGS         = -l ${JAVA2TEX_TEXT_WIDTH} -t ${JAVA2TEX_TAB_SIZE}
JAVA2TEX_INPUT_FLAGS   = -i
JAVA2TEX_OUTPUT_FLAGS  = -o
JAVA2TEX_POST_FLAGS    = >/dev/null 2>/dev/null
JAVA2TEX_OUTPUT_INPUT  = no
JAVA2TEX_OUTPUT_STDOUT = no

#-----------------------------------
#----------- DO NOT CHANGE BELOW
#-----------------------------------

# Notify of the loading of this module
LOADED_TRANSLATORS += java2tex

JAVA_FIG = $(call launchShell, ${FIND_CMD} ${AUTO_GENERATE_IMAGE_DIRECTORY} -name "*.java")

TEX_JAVA = $(addsuffix .tex,          $(basename ${JAVA_FIG}))

SOURCE_IMAGES += ${JAVA_FIG}
IMAGES        += ${TEX_JAVA}

# Compile the convertion parameters
ifeq ("-$(findstring =,$(JAVA2TEX_INPUT_FLAGS))","-")
JAVA2TEX_INPUT_FLAGS_EX = $(strip $(JAVA2TEX_INPUT_FLAGS)) "$<"
else
JAVA2TEX_INPUT_FLAGS_EX = $(strip $(JAVA2TEX_INPUT_FLAGS))"$<"
endif
ifeq ("-$(findstring =,$(JAVA2TEX_OUTPUT_FLAGS))","-")
JAVA2TEX_OUTPUT_FLAGS_EX = $(strip $(JAVA2TEX_OUTPUT_FLAGS)) "$@"
else
JAVA2TEX_OUTPUT_FLAGS_EX = $(strip $(JAVA2TEX_OUTPUT_FLAGS))"$@"
endif

# Compile the convertion commands
ifeq ("${JAVA2TEX_OUTPUT_STDOUT}","yes")
JAVA2TEX_SHELL_CMD = $(JAVA2TEX_BIN) $(JAVA2TEX_FLAGS) $(JAVA2TEX_INPUT_FLAGS_EX) $(JAVA2TEX_POST_FLAGS) > "$@"
else
ifeq ("${JAVA2TEX_OUTPUT_INPUT}","yes")
JAVA2TEX_SHELL_CMD = $(JAVA2TEX_BIN) $(JAVA2TEX_FLAGS) $(JAVA2TEX_OUTPUT_FLAGS_EX) $(JAVA2TEX_INPUT_FLAGS_EX) $(JAVA2TEX_POST_FLAGS)
else
JAVA2TEX_SHELL_CMD = $(JAVA2TEX_BIN) $(JAVA2TEX_FLAGS) $(JAVA2TEX_INPUT_FLAGS_EX) $(JAVA2TEX_OUTPUT_FLAGS_EX) $(JAVA2TEX_POST_FLAGS)
endif
endif


$(TEX_JAVA): %.tex: %.java
	@ ${ECHO_CMD} "$< -> $@" && $(JAVA2TEX_SHELL_CMD)

endif
