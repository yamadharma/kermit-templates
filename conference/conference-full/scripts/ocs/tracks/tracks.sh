#!/bin/bash

./tracks report.csv

for i in *.tex
do
    sort -k 4 $i > $i.tmp
    mv $i.tmp $i
done