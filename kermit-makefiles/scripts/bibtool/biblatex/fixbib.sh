#!/bin/bash

for i in `find . -name "*.bib"`
do
    for rc in bibtool/*.rsc
    do
	if [[ -f "$rc" ]]
	then
	    tmpfile=`mktemp -u`
	    bibtool -v -r "$rc" -i "$i" -o "$tmpfile"
	    mv "$tmpfile" "$i"
	fi
    done
done
