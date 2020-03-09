# Preamble
resource bibtool/include/preamble

#fmt.name.name = {}
#fmt.name.pre = {}
#fmt.inter.name = {}
#fmt.et.al = {EtAl}
##key.format = {bbl%9.1n(author)%2d(year)}
#key.format = {bbl {%2n(author)# %2n(editor)# NoName} { %2d(year)# }}
#default.key = {bblNoKey}
#key.base = {lower}
#key.number.separator = {}

#sort = on
#sort.format = {
#    {%-N(author)# %-N(editor)# zzNoName}
#    {%d(year)#9999}
#    {%-0T(title)#zzNoTitle}
#}


## Sanitize double {{ }}
#rewrite.rule = {"^{{\(.*\)}}$" = "{\1}"}

## Replace " ... " with { ... }
#rewrite.rule = {"^\"\(.*\)\"$" = "{\1}"}

# Get rid of useless fields
#delete.field = {abstract}
#delete.field = {affiliation}
#delete.field = {correspondence_address1}
#delete.field = {references}
#delete.field = {keywords}
#delete.field = {author_keywords}
#delete.field = {source}
#rewrite.rule = {note#"^{ *cited by.*}"}
#rewrite.rule = {language # "English"}

# Sanitize month
resource bibtool/include/month

# Fix for concret entry types
resource bibtool/include/eprint
resource bibtool/include/book

# Biblatex specific
resource bibtool/include/language


#
# Semantic checks for year fields
#
check.rule { year "^[\"{]?[0-9][0-9][\"}]?$"   }
check.rule { year "^[\"{]?1[89][0-9][0-9][\"}]?$"   }
check.rule { year "^[\"{]?20[0-9][0-9][\"}]?$"   }
check.rule { year "" "\@ \$: Semantic error. Year has to be a suitable number" }


# delete empty fields
rewrite.rule {"^\" *\"$"}
rewrite.rule {"^{ *}$"}
rewrite.rule {"ˆ{}$"}
rewrite.rule {"ˆ\"\"$"}

# delete useless fields introduced by reference managers
#delete.field {file}
#delete.field {abstract}
#delete.field {annote}
#delete.field {keywords}

# correct page ranges
rewrite.rule {pages # "\([0-9]+\) *\(-\|---\) *\([0-9]+\)" = "\1--\3"}

# delete delimiters if the field is purely numerical
rewrite.rule {"^[\"{] *\([0-9]+\) *[\"}]$" "\1"}

# remove duplicate entries
check.double = off
check.double.delete = off
pass.comments = off

# rewrite address
rewrite.rule = {address # "Москва" # "М."}

# rename url date field to be correctly used by BibTeX, BibLaTeX, abnTeX etc
rename.field {urldate = urlaccessdate}

#rename.field {$Misc = $Book}

# BibTeX-1.0 Support
apply.alias = on
apply.include = on
apply.modify = on

# Delete all empty fields
rewrite.rule { "^\" *\"$" }
rewrite.rule { "^{ *}$" }
rewrite.rule { "^\"\"$" }
rewrite.rule { "^{}$" }
