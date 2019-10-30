#!/bin/bash




###??? update these
workDir=~/compute/WiscoPhero
scriptDir=${workDir}/code
docDir=${workDir}/docs

slurmDir=${workDir}/derivatives/Slurm_out
time=`date '+%Y_%m_%d-%H_%M_%S'`
outDir=${slurmDir}/TS2_${time}
mkdir -p $outDir


subjList=(`cat ${docDir}/stim_order.txt | awk '{print $1}'`)
stimList=(`cat ${docDir}/stim_order.txt | awk '{print $2}'`)

cd ${workDir}/derivatives
c=0; while [ $c -lt ${#subjList[@]} ]; do

	subj=sub-${subjList[$c]}
	if [ -d $subj ]; then

		[ $subj == sub-101 ]; test=$?

	    sbatch \
	    -o ${outDir}/output_TS2_${subj}.txt \
	    -e ${outDir}/error_TS2_${subj}.txt \
	    ${scriptDir}/Task_step2_sbatch_regress.sh $subj $test ${stimList[$c]}

	    sleep 1
	fi
	let c+=1
done
