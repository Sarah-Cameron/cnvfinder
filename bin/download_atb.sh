while read p; do
 wget https://allthebacteria-assemblies.s3.eu-west-2.amazonaws.com/"$p".fa.gz
done <"$1"
