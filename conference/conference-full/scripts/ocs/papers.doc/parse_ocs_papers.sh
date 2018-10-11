#!/bin/bash

for i in *.xml
do
    ./parse_ocs_papers "$i"
done

