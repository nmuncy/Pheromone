#!/bin/bash


# Written by Nathan Muncy on 8/16/17


workDir=/Volumes/Yorick/WiscoPheromone
txtDir=${workDir}/Analyses
scriptDir=${workDir}/Scripts

listW=($(cat ${txtDir}/subjects.txt | awk '{print $1 }'))
listK=($(cat ${txtDir}/subjects.txt | awk '{print $2 }'))
listLen="${#listW[@]}"


c=0; while [ $c -lt $listLen ]; do
    ${scriptDir}/step1_preproc.sh "${listW[$c]}" "${listK[$c]}"
    let c=$[$c+1]
done
