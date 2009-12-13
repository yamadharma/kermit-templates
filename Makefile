# MACRO_FORMAT
# latex | xelatex
MACRO_FORMAT = latex

# Indicate which generation procedure to use. One in:
# pdf | dvi | ps | pspdf
LATEX_GENERATION_PROCEDURE = pdf

# HAS_MULTIPLE_BIB = yes
# MULTIPLE_BIB_FILES = default rec

# Shell command used to launch MakeIndex
# makeindex | xindy
MAKEINDEX_CMD = xindy

# Style file for MakeIndex
MAKEINDEX_STYLEFILE = index.xdy

# TEX4HT_FINAL_POST_CMD = scripts/html-fix

AUTO_GENERATE_IMAGE_DIRECTORY = image

include mkfiles/main.mk
