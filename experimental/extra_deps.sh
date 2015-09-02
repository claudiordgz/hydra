#!/bin/bash
while IFS=, read col1 col2 col3
do
    if [ ! -d "$col3" ]; then
      git clone -b $col1 $col2
    fi
done < experimentalDeps.csv
