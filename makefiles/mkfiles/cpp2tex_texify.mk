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

ifeq ("$(call isTranslatorLoaded,cpp2tex)","false")

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
CPP2TEX_TEXT_WIDTH ?= 60
CPP2TEX_TAB_SIZE   ?= 2

# Command definition.
# Required synoptics of the command:
# <binfile> <flags> <inputflags> <input.cpp> <outputflags> <output.tex>
CPP2TEX_BIN           = texifyc++
CPP2TEX_FLAGS         = -l ${CPP2TEX_TEXT_WIDTH} -t ${CPP2TEX_TAB_SIZE}
CPP2TEX_INPUT_FLAGS   = -i
CPP2TEX_OUTPUT_FLAGS  = -o
CPP2TEX_POST_FLAGS    = >/dev/null 2>/dev/null
CPP2TEX_OUTPUT_INPUT  = no
CPP2TEX_OUTPUT_STDOUT = no

#-----------------------------------
#----------- DO NOT CHANGE BELOW
#-----------------------------------

# Notify of the loading of this module
LOADED_TRANSLATORS += cpp2tex

CPP_FIG = $(call launchShell, ${FIND_CMD} ${AUTO_GENERATE_IMAGE_DIRECTORY} -name "*.cpp")
HPP_FIG = $(call launchShell, ${FIND_CMD} ${AUTO_GENERATE_IMAGE_DIRECTORY} -name "*.hpp")
C_FIG = $(call launchShell, ${FIND_CMD} ${AUTO_GENERATE_IMAGE_DIRECTORY} -name "*.c")
H_FIG = $(call launchShell, ${FIND_CMD} ${AUTO_GENERATE_IMAGE_DIRECTORY} -name "*.h")

TEX_CPP = $(addsuffix .tex,          $(basename ${CPP_FIG}))
TEX_HPP = $(addsuffix .tex,          $(basename ${HPP_FIG}))
TEX_C = $(addsuffix .tex,          $(basename ${C_FIG}))
TEX_H = $(addsuffix .tex,          $(basename ${H_FIG}))

SOURCE_IMAGES += ${CPP_FIG} ${HPP_FIG} ${C_FIG} ${H_FIG}
IMAGES        += ${TEX_CPP} ${TEX_HPP} ${TEX_C} ${TEX_H}

# Compile the convertion parameters
ifeq ("-$(findstring =,$(CPP2TEX_INPUT_FLAGS))","-")
CPP2TEX_INPUT_FLAGS_EX = $(strip $(CPP2TEX_INPUT_FLAGS)) "$<"
else
CPP2TEX_INPUT_FLAGS_EX = $(strip $(CPP2TEX_INPUT_FLAGS))"$<"
endif
ifeq ("-$(findstring =,$(CPP2TEX_OUTPUT_FLAGS))","-")
CPP2TEX_OUTPUT_FLAGS_EX = $(strip $(CPP2TEX_OUTPUT_FLAGS)) "$@"
else
CPP2TEX_OUTPUT_FLAGS_EX = $(strip $(CPP2TEX_OUTPUT_FLAGS))"$@"
endif

# Compile the convertion commands
ifeq ("${CPP2TEX_OUTPUT_STDOUT}","yes")
CPP2TEX_SHELL_CMD = $(CPP2TEX_BIN) $(CPP2TEX_FLAGS) $(CPP2TEX_INPUT_FLAGS_EX) $(CPP2TEX_POST_FLAGS) > "$@"
else
ifeq ("${CPP2TEX_OUTPUT_INPUT}","yes")
CPP2TEX_SHELL_CMD = $(CPP2TEX_BIN) $(CPP2TEX_FLAGS) $(CPP2TEX_OUTPUT_FLAGS_EX) $(CPP2TEX_INPUT_FLAGS_EX) $(CPP2TEX_POST_FLAGS)
else
CPP2TEX_SHELL_CMD = $(CPP2TEX_BIN) $(CPP2TEX_FLAGS) $(CPP2TEX_INPUT_FLAGS_EX) $(CPP2TEX_OUTPUT_FLAGS_EX) $(CPP2TEX_POST_FLAGS)
endif
endif


$(TEX_CPP): %.tex: %.cpp
	@ ${ECHO_CMD} "$< -> $@" && $(CPP2TEX_SHELL_CMD)

$(TEX_HPP): %.tex: %.hpp
	@ ${ECHO_CMD} "$< -> $@" && $(CPP2TEX_SHELL_CMD)

$(TEX_C): %.tex: %.c
	@ ${ECHO_CMD} "$< -> $@" && $(CPP2TEX_SHELL_CMD)

$(TEX_H): %.tex: %.h
	@ ${ECHO_CMD} "$< -> $@" && $(CPP2TEX_SHELL_CMD)

endif
