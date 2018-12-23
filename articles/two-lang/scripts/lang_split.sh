#!/bin/bash

file=$1

mkdir -p lang_split/english
mkdir -p lang_split/russian

sed -e '/\\begin{English}/d' \
    -e '/\\end{English}/d' \
    -e '/\\begin{Russian}/,/\\end{Russian}/d' \
    -e '/^%/d' \
    ${file} > ./lang_split/english/${file}

sed -e '/\\begin{Russian}/d' \
    -e '/\\end{Russian}/d' \
    -e '/\\begin{English}/,/\\end{English}/d' \
    -e '/^%/d' \
    ${file} > ./lang_split/russian/${file}

