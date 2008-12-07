# Преамбула
include mkfiles/preamble.mk

# Основные переменные
include mkfiles/main_vars.mk

# eps2pdf conversion
# One of
include mkfiles/eps2pdf_epstopdf.mk
# include mkfiles/eps2pdf_ps2pdf.mk

# Правила преобразования
# include mkfiles/eps2pdf_.mk

# include mkfiles/dia2pdf.mk
# include mkfiles/dia2svg.mk

# include mkfiles/pdf2svg.mk
# include mkfiles/svg2pdf.mk

# include mkfiles/pst2pdf.mk

# include mkfiles/pdf2swf.mk



# Основные правила
include mkfiles/main_rules.mk


