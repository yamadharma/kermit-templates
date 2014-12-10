# autolatex - eps2pdf_epstopdf.mk
# Copyright (C) 1998-09  Stephane Galland <galland@arakhne.org>
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

ifeq ("$(call isTranslatorLoaded,eps2pdf)","false")

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
# <binfile> <flags> <inputflags> <input.eps> <outputflags> <output.pdf>
EPS2PDF_BIN           = epstopdf
EPS2PDF_FLAGS         =
EPS2PDF_INPUT_FLAGS   =
EPS2PDF_OUTPUT_FLAGS  = --outfile=
EPS2PDF_POST_FLAGS    =
EPS2PDF_OUTPUT_INPUT  = yes
EPS2PDF_OUTPUT_STDOUT = no

#-----------------------------------
#----------- DO NOT CHANGE BELOW
#-----------------------------------

# Notify of the loading of this module
LOADED_TRANSLATORS += eps2pdf

# Compile the convertion parameters
ifeq ("-$(findstring =,$(EPS2PDF_INPUT_FLAGS))","-")
EPS2PDF_INPUT_FLAGS_EX = $(strip $(EPS2PDF_INPUT_FLAGS)) "$<"
else
EPS2PDF_INPUT_FLAGS_EX = $(strip $(EPS2PDF_INPUT_FLAGS))"$<"
endif
ifeq ("-$(findstring =,$(EPS2PDF_OUTPUT_FLAGS))","-")
EPS2PDF_OUTPUT_FLAGS_EX = $(strip $(EPS2PDF_OUTPUT_FLAGS)) "$@"
else
EPS2PDF_OUTPUT_FLAGS_EX = $(strip $(EPS2PDF_OUTPUT_FLAGS))"$@"
endif

# Compile the convertion commands
ifeq ("${EPS2PDF_OUTPUT_STDOUT}","yes")
EPS2PDF_SHELL_CMD = $(EPS2PDF_BIN) $(EPS2PDF_FLAGS) $(EPS2PDF_INPUT_FLAGS_EX) $(EPS2PDF_POST_FLAGS) > "$@"
else
ifeq ("${EPS2PDF_OUTPUT_INPUT}","yes")
EPS2PDF_SHELL_CMD = $(EPS2PDF_BIN) $(EPS2PDF_FLAGS) $(EPS2PDF_OUTPUT_FLAGS_EX) $(EPS2PDF_INPUT_FLAGS_EX) $(EPS2PDF_POST_FLAGS)
else
EPS2PDF_SHELL_CMD = $(EPS2PDF_BIN) $(EPS2PDF_FLAGS) $(EPS2PDF_INPUT_FLAGS_EX) $(EPS2PDF_OUTPUT_FLAGS_EX) $(EPS2PDF_POST_FLAGS)
endif
endif

endif
