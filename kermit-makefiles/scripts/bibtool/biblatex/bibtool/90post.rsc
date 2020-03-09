# Preamble
resource bibtool/include/preamble

# Delete all empty fields
rewrite.rule { "^\" *\"$" }
rewrite.rule { "^{ *}$" }
rewrite.rule { "^\"\"$" }
rewrite.rule { "^{}$" }
