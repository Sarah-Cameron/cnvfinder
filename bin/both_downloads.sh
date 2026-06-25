#!/bin/bash

while IFS=',' read -r col1 col2; do
    cd ./reads
    iseq -i "$col1" -g -r https
    mv "$col1".metadata.tsv ../metadata/
    cd ../assemblies
    wget https://allthebacteria-assemblies.s3.eu-west-2.amazonaws.com/"$col2".fa.gz
    gunzip "$col2".fa.gz
done < $1

