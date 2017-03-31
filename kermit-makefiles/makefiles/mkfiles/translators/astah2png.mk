# autolatex - astah2png.mk
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

ifeq ("$(call isTranslatorLoaded,astah2png)","false")

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
ASTAH2PNG_BIN           = astah2png
ASTAH2PNG_FLAGS         = 
ASTAH2PNG_INPUT_FLAGS   = 
ASTAH2PNG_OUTPUT_FLAGS  = 
ASTAH2PNG_POST_FLAGS    =
ASTAH2PNG_OUTPUT_INPUT  = no
ASTAH2PNG_OUTPUT_STDOUT = no

#-----------------------------------
#----------- DO NOT CHANGE BELOW
#-----------------------------------

# Notify of the loading of this module
LOADED_TRANSLATORS += astah2png

ASTAH_FIG = $(call launchShell, ${FIND_CMD} ${AUTO_GENERATE_IMAGE_DIRECTORY} -name "*.asta" -a -not -name "*.ltx.asta")
JUDE_FIG = $(call launchShell, ${FIND_CMD} ${AUTO_GENERATE_IMAGE_DIRECTORY} -name "*.jude" -a -not -name "*.ltx.jude")

PNG_ASTAH = $(addsuffix .png,          $(basename ${ASTAH_FIG}))
PNG_JUDE = $(addsuffix .png,          $(basename ${JUDE_FIG}))

SOURCE_IMAGES += ${ASTAH_FIG} ${JUDE_FIG}
IMAGES        += ${PNG_ASTAH} ${PNG_JUDE}

# Compile the convertion parameters
ifeq ("-$(findstring =,$(ASTAH2PNG_INPUT_FLAGS))","-")
ASTAH2PNG_INPUT_FLAGS_EX = $(ASTAH2PNG_INPUT_FLAGS) "$<"
else
ASTAH2PNG_INPUT_FLAGS_EX = "$(ASTAH2PNG_INPUT_FLAGS)$<"
endif
ifeq ("-$(findstring =,$(ASTAH2PNG_OUTPUT_FLAGS))","-")
ASTAH2PNG_OUTPUT_FLAGS_EX = $(ASTAH2PNG_OUTPUT_FLAGS) "$@"
else
ASTAH2PNG_OUTPUT_FLAGS_EX = "$(ASTAH2PNG_OUTPUT_FLAGS)$@"
endif

# Compile the convertion commands
ifeq ("${ASTAH2PNG_OUTPUT_STDOUT}","yes")
ASTAH2PNG_SHELL_CMD = $(ASTAH2PNG_BIN) $(ASTAH2PNG_FLAGS) $(ASTAH2PNG_INPUT_FLAGS_EX) $(ASTAH2PNG_POST_FLAGS) > "$@"
else
ifeq ("${ASTAH2PNG_OUTPUT_INPUT}","yes")
ASTAH2PNG_SHELL_CMD = $(ASTAH2PNG_BIN) $(ASTAH2PNG_FLAGS) $(ASTAH2PNG_OUTPUT_FLAGS_EX) $(ASTAH2PNG_INPUT_FLAGS_EX) $(ASTAH2PNG_POST_FLAGS)
else
ASTAH2PNG_SHELL_CMD = $(ASTAH2PNG_BIN) $(ASTAH2PNG_FLAGS) $(ASTAH2PNG_INPUT_FLAGS_EX) $(ASTAH2PNG_OUTPUT_FLAGS_EX) $(ASTAH2PNG_POST_FLAGS)
endif
endif



$(PNG_ASTAH): %.png: %.asta
	@ ${ECHO_CMD} "$< -> $@" && $(ASTAH2PNG_SHELL_CMD)

$(PNG_JUDE): %.png: %.jude
	@ ${ECHO_CMD} "$< -> $@" && $(ASTAH2PNG_SHELL_CMD)

cleanall::
	@rm -rf $(addsuffix ':'*.png, $(basename ${ASTAH_FIG})) 2>/dev/null
	@rm -rf $(addsuffix ':'*.png, $(basename ${JUDE_FIG})) 2>/dev/null

endif
