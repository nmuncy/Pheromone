#!/bin/bash


# Written by Nathan Muncy on 8/16/17


workDir=~/compute/WiscoPheromone
scriptDir=${workDir}/Scripts
txtDir=${workDir}/Analyses

time=`date '+%Y_%m_%d-%H_%M_%S'`
outDir=${workDir}/Slurm_out/deconv_$time
mkdir -p $outDir


listS=($(cat ${txtDir}/stim_order.txt | awk '{print $1 }'))
listC=($(cat ${txtDir}/stim_order.txt | awk '{print $2 }'))
arrLen="${#listS[@]}"


c=0; while [ $c -lt $arrLen ]; do
    if [[ "${listS[$c]}" != P? ]]; then

        sbatch \
        -o ${outDir}/output_deconv_"${listS[$c]}".txt \
        -e ${outDir}/error_deconv_"${listS[$c]}".txt \
        ${scriptDir}/step2_sbatch_deconv.sh "${listS[$c]}" "${listC[$c]}"
    fi

    sleep 1
    let c=$[$c+1]
done
