#!/bin/bash

for i in `find . -name "*.bib"`
do
    tmpfile=`mktemp -u`
    bibtool -i "$i" -o "$tmpfile"
    mv "$tmpfile" "$i"
done