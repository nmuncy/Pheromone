#!/bin/bash

# Written by Nathan Muncy on 8/16/17


#SBATCH --time=20:00:00   # walltime
#SBATCH --ntasks=2   # number of processor cores (i.e. tasks)
#SBATCH --nodes=1   # number of nodes
#SBATCH --mem-per-cpu=16gb   # memory per CPU core
#SBATCH -J "WPdecon"   # job name

# Compatibility variables for PBS. Delete if not needed.
export PBS_NODEFILE=`/fslapps/fslutils/generate_pbs_nodefile`
export PBS_JOBID=$SLURM_JOB_ID
export PBS_O_WORKDIR="$SLURM_SUBMIT_DIR"
export PBS_QUEUE=batch

# Set the max number of threads to use for programs using OpenMP. Should be <= ppn. Does nothing if the program doesn't use OpenMP.
export OMP_NUM_THREADS=$SLURM_CPUS_ON_NODE




sub=$1
stimcode=$2

workDir=~/compute/WiscoPheromone
tempDir=~/bin/Templates/vold2_mni
paDir=${tempDir}/priors_ACT
stimDir=${workDir}/stim_vectors
subDir=${workDir}/${sub}



### Step 1: Get Stim times
cd $subDir

if [ ! -f BeVectOutput.03.1D ]; then
    if [ $stimcode == 132 ]; then
        cp ${stimDir}/BeVect1.txt BeVectData.txt

    elif [ $stimcode == 231 ]; then
        cp ${stimDir}/BeVect2.txt BeVectData.txt

    elif [ $stimcode == 123 ]; then
        cp ${stimDir}/BeVect3.txt BeVectData.txt

    elif [ $stimcode == 213 ]; then
        cp ${stimDir}/BeVect4.txt BeVectData.txt

    elif [ $stimcode == 312 ]; then
        cp ${stimDir}/BeVect5.txt BeVectData.txt

    elif [ $stimcode == 321 ]; then
        cp ${stimDir}/BeVect6.txt BeVectData.txt
    fi

    make_stim_times.py -files BeVectData.txt -prefix BeVectOutput -tr 5 -nruns 3 -nt 78 -offset 0
fi




### Step 2: Skull-strip

if [ ! -f struct_rotated_brain_mask_resampled+orig.BRIK ]; then

    dim=3
    struct=struct.nii
    tempH=${tempDir}/vold2_mni_head.nii.gz
    pmask=${paDir}/Template_BrainCerebellumProbabilityMask.nii.gz
    out=ss_

    antsBrainExtraction.sh -d $dim -a $struct -e $tempH -m $pmask -o $out


    # rotate
    cp ss_BrainExtractionBrain.nii.gz struct_brain.nii.gz
    3dcopy struct_brain.nii.gz struct_brain+orig
    3dWarp -oblique_parent run3_volreg+orig -prefix struct_rotated_brain struct_brain+orig
    3dcopy struct_rotated_brain+orig struct_rotated_brain.nii.gz        # for ANTs

    # resample, binarize
    3dfractionize -template run3_volreg+orig -prefix struct_rotated_brain_resampled -input struct_rotated_brain+orig
    3dcalc -a struct_rotated_brain_resampled+orig -prefix struct_rotated_brain_mask_resampled -expr "step(a)"

fi




### Step 3: Deconvolve

if [ ! -f deconv1_blur4+orig.BRIK ]; then

    3dDeconvolve -input run1_aligned+orig run2_aligned+orig run3_volreg+orig \
    -mask struct_rotated_brain_mask_resampled+orig \
    -polort A -num_stimts 12 \
    -stim_file   1 "motion.txt[0]" -stim_label 1 "Roll"  -stim_base   1 \
    -stim_file   2 "motion.txt[1]" -stim_label 2 "Pitch" -stim_base   2 \
    -stim_file   3 "motion.txt[2]" -stim_label 3 "Yaw"   -stim_base   3 \
    -stim_file   4 "motion.txt[3]" -stim_label 4 "dS"    -stim_base   4 \
    -stim_file   5 "motion.txt[4]" -stim_label 5 "dL"    -stim_base   5 \
    -stim_file   6 "motion.txt[5]" -stim_label 6 "dP"    -stim_base   6 \
    -stim_times  7 BeVectOutput.03.1D 'BLOCK(5,1)' -stim_label  7 "Lav" \
    -stim_times  8 BeVectOutput.04.1D 'BLOCK(5,1)' -stim_label  8 "LavT" \
    -stim_times  9 BeVectOutput.05.1D 'BLOCK(5,1)' -stim_label  9 "P1" \
    -stim_times  10 BeVectOutput.06.1D 'BLOCK(5,1)' -stim_label  10 "P1T" \
    -stim_times  11 BeVectOutput.07.1D 'BLOCK(5,1)' -stim_label  11 "P2" \
    -stim_times  12 BeVectOutput.08.1D 'BLOCK(5,1)' -stim_label  12 "P2T" \
    -num_glt 9 \
    -gltsym 'SYM: Lav'  -glt_label 1 Lav \
    -gltsym 'SYM: LavT' -glt_label 2 LavT \
    -gltsym 'SYM: P1'   -glt_label 3 P1 \
    -gltsym 'SYM: P1T'  -glt_label 4 P1T \
    -gltsym 'SYM: P2'   -glt_label 5 P2 \
    -gltsym 'SYM: P2T'  -glt_label 6 P2T \
    -gltsym 'SYM: 1*P1 -1*P2' -glt_label 7 P1-P2 \
    -gltsym 'SYM: 1*P1 -1*Lav' -glt_label 8 P1-Lav \
    -gltsym 'SYM: 1*P2 -1*Lav' -glt_label 9 P2-Lav \
    -censor 'motion_censor_vector.txt[0]' \
    -nobout -nocout -tout \
    -bucket deconv1 \
    -jobs 1 \
    -GOFORIT 12

    #blur the functional dataset
    3dmerge -prefix deconv1_blur4 -1blur_fwhm 4.0 -doall deconv1+orig
fi




### Step 4: Run ANTs, antify

# ANTs
fix=${tempDir}/vold2_mni_brain.nii.gz
out=ants_

if [ ! -f ants_0GenericAffine.mat ]; then

    dim=3
    moving=struct_rotated_brain.nii.gz

    antsRegistrationSyN.sh \
    -d $dim \
    -f $fix \
    -m $moving \
    -o $out

fi


#Antify
time=`date '+%Y_%m_%d-%H_%M_%S'`
ant_out=${workDir}/Slurm_out/antify_${time}
mkdir -p $ant_out


for j in *blur4+orig.HEAD; do
    if [ ! -f "${j/+orig.HEAD}"_ANTS_resampled+tlrc.HEAD ]; then
        ~/compute/antifyFunctional_nate.sh -a $out -t $fix -i "${j/.HEAD}" -o $ant_out -f ${subj}_antify.txt
    fi
done
