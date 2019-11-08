#!/bin/bash

#SBATCH --time=01:00:00   # walltime
#SBATCH --ntasks=2   # number of processor cores (i.e. tasks)
#SBATCH --nodes=1   # number of nodes
#SBATCH --mem-per-cpu=4gb   # memory per CPU core
#SBATCH -J "TS6"   # job name

# Compatibility variables for PBS. Delete if not needed.
export PBS_NODEFILE=`/fslapps/fslutils/generate_pbs_nodefile`
export PBS_JOBID=$SLURM_JOB_ID
export PBS_O_WORKDIR="$SLURM_SUBMIT_DIR"
export PBS_QUEUE=batch

# Set the max number of threads to use for programs using OpenMP. Should be <= ppn. Does nothing if the program doesn't use OpenMP.
export OMP_NUM_THREADS=$SLURM_CPUS_ON_NODE





### Set up
workDir=~/compute/WiscoPhero
grpDir=${workDir}/Analyses/grpAnalysis
maskDir=${grpDir}/mvm_masks_smallVol
betaDir=${grpDir}/mvm_betas_smallVol


maskArr=(F-M_Lav-P1 F-M_Lav-P2)
scanArr=(PherOlf PherOlf)
betaArr=("5,9" "5,13")


mkdir -p $maskDir $betaDir


### Function
MatchString (){
	local e match="$1"
	shift
	for e; do [[ "$e" == "$match" ]] && return 0; done
	return 1
}


### organize
cd $grpDir
mv Clust* $maskDir


### separate clusters
cd $maskDir

c=0; while [ $c -lt ${#maskArr[@]} ]; do

	mask=Clust_${scanArr[$c]}SmallVol_${maskArr[$c]}_mask
	3dcopy ${mask}+tlrc ${mask}.nii.gz
	num=`3dinfo ${mask}+tlrc | grep "At sub-brick #0 '#0' datum type is short" | sed 's/[^0-9]*//g' | sed 's/^...//'`

	for ((j=1; j<=$num; j++)); do
		if [ ! -f ${mask}_c${j}+tlrc.HEAD ]; then

			c3d ${mask}.nii.gz -thresh $j $j 1 0 -o ${mask}_c${j}.nii.gz
			3dcopy ${mask}_c${j}.nii.gz ${mask}_c${j}+tlrc
		fi
	done


	### extract betas from each cluster
	arrRem=(`cat ${grpDir}/info_rmSubj_${scanArr[$c]}.txt`)
	file=${scanArr[$c]}_stats_REML+tlrc
	print=${betaDir}/Betas_${scanArr[$c]}_${maskArr[$c]}.txt
	> $print

	for i in ${mask}_c*.HEAD; do

		maskClust=${i%.*}
		numClust=${maskClust##*_}
		echo $numClust >> $print

		for j in ${workDir}/derivatives/s*; do

			subj=${j##*\/}
			MatchString "$subj" "${arrRem[@]}"
			if [ $? == 1 ]; then
				stats=`3dROIstats -mask $maskClust "${j}/${file}[${betaArr[$c]}]"`
				echo "$subj $stats" >> $print
			fi
		done
		echo "" >> $print
	done

	let c+=1
done

