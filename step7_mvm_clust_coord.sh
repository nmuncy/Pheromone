#!/bin/bash


# written by Nathan Muncy on 8/16/17


workDir=/Volumes/Yorick/WiscoPheromone/grpAnalysis/clust_masks
master=/Volumes/Yorick/WiscoPheromone/Analyses/grpAnalysis_mvm_coordinates.txt

> $master
cd $workDir

for i in *.1D; do

    string=${i%_*}

    echo $string >> $master
    cat $i >> $master
    echo >> $master
done
