#!/bin/bash
sed 1d experimentalDeps.csv | while IFS=, read col1 col2 col3
do
    if [ ! -d "$col3" ];
    then
        git clone -b $col1 $col2
    else
        echo "$col3 already in dependencies"
    fi
done
