# autolatex - imggz2img.mk
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

ifeq ("$(call isTranslatorLoaded,imggz2img)","false")

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
# <binfile> <flags> <inputflags> <input.eps.gz> <outputflags> <outputfile.eps>
# <binfile> <flags> <inputflags> <input.png.gz> <outputflags> <outputfile.png>
# <binfile> <flags> <inputflags> <input.jpg.gz> <outputflags> <outputfile.jpg>
IMGGZ2IMG_BIN           = zcat
IMGGZ2IMG_FLAGS         =
IMGGZ2IMG_INPUT_FLAGS   =
IMGGZ2IMG_OUTPUT_FLAGS  =
IMGGZ2IMG_POST_FLAGS    =
IMGGZ2IMG_OUTPUT_INPUT  = no
IMGGZ2IMG_OUTPUT_STDOUT = yes

# List of supported formats (must be also supported by your LaTeX interpreter)
SUPPORTED_BITMAP_FORMATS = pdf eps png jpg bmp gif

#-----------------------------------
#----------- DO NOT CHANGE BELOW
#-----------------------------------

# Notify of the loading of this module
LOADED_TRANSLATORS += imggz2img

IMGGZ_FIG = $(foreach extension, ${SUPPORTED_BITMAP_FORMATS}, $(call launchShell, ${FIND_CMD} ${AUTO_GENERATE_IMAGE_DIRECTORY} -name "*.${extension}.gz"))

IMG_IMGGZ = $(basename ${IMGGZ_FIG})

SOURCE_IMAGES += ${IMGGZ_FIG}
IMAGES        += ${IMG_IMGGZ}

# Compile the convertion parameters
ifeq ("-$(findstring =,$(IMGGZ2IMG_INPUT_FLAGS))","-")
IMGGZ2IMG_INPUT_FLAGS_EX = $(strip $(IMGGZ2IMG_INPUT_FLAGS)) "$<"
else
IMGGZ2IMG_INPUT_FLAGS_EX = $(strip $(IMGGZ2IMG_INPUT_FLAGS))"$<"
endif
ifeq ("-$(findstring =,$(IMGGZ2IMG_OUTPUT_FLAGS))","-")
IMGGZ2IMG_OUTPUT_FLAGS_EX = $(strip $(IMGGZ2IMG_OUTPUT_FLAGS)) "$@"
else
IMGGZ2IMG_OUTPUT_FLAGS_EX = $(strip $(IMGGZ2IMG_OUTPUT_FLAGS))"$@"
endif

# Compile the convertion commands
ifeq ("${IMGGZ2IMG_OUTPUT_STDOUT}","yes")
IMGGZ2IMG_SHELL_CMD = $(IMGGZ2IMG_BIN) $(IMGGZ2IMG_FLAGS) $(IMGGZ2IMG_INPUT_FLAGS_EX) $(IMGGZ2IMG_POST_FLAGS) > "$@"
else
ifeq ("${IMGGZ2IMG_OUTPUT_INPUT}","yes")
IMGGZ2IMG_SHELL_CMD = $(IMGGZ2IMG_BIN) $(IMGGZ2IMG_FLAGS) $(IMGGZ2IMG_OUTPUT_FLAGS_EX) $(IMGGZ2IMG_INPUT_FLAGS_EX) $(IMGGZ2IMG_POST_FLAGS)
else
IMGGZ2IMG_SHELL_CMD = $(IMGGZ2IMG_BIN) $(IMGGZ2IMG_FLAGS) $(IMGGZ2IMG_INPUT_FLAGS_EX) $(IMGGZ2IMG_OUTPUT_FLAGS_EX) $(IMGGZ2IMG_POST_FLAGS)
endif
endif


$(IMG_IMGGZ): %: %.gz
	@ ${ECHO_CMD} "$< -> $@" && $(IMGGZ2IMG_SHELL_CMD)

endif
