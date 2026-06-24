#! /bin/bash
bfile=$1
snps=$2
p1=$3
r2=$4
kb=$5
out=$6
plink \
    --bfile $bfile \
    --clump $snps \
    --clump-p1 $p1 \
    --clump-r2 $r2 \
    --clump-kb $kb \
    --out $out
