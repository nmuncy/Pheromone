#!/bin/bash


# Written by Nathan Muncy on 8/16/17


workDir=/Volumes/Yorick/WiscoPheromone
refDir=${workDir}/101
tempDir=/Volumes/Yorick/Templates/vold2_mni
grpDir=${workDir}/grpAnalysis


if [ ! -d $grpDir ]; then
    mkdir $grpDir
fi
cd $grpDir


# make a mask
if [ ! -f brain_mask_resampled+tlrc.HEAD ]; then

    cp ${tempDir}/priors_ACT/Template_BrainCerebellumBinaryMask.nii.gz ${grpDir}/tmp_brain_mask.nii.gz
    3dcopy tmp_brain_mask.nii.gz tmp_brain_mask+tlrc
    3dfractionize -template ${refDir}/deconv1_blur4_ANTS_resampled+tlrc -prefix tmp_brain_mask_resampled -input tmp_brain_mask+tlrc
    3dcalc -a tmp_brain_mask_resampled+tlrc -prefix brain_mask_resampled -expr "step(a)"

    rm tmp*
fi


# run Monte Carlo simulations
if [ ! -f MCstats.txt ]; then

    stats=`3dClustSim -mask brain_mask_resampled+tlrc -fwhm 5 -athr 0.05 -iter 10000 -NN 1 -nodec`
    echo "$stats" > MCstats.txt
fi


# run MVM

out=MVM_StimXSex

if [ ! -f ${out}+tlrc.HEAD ]; then

    3dMVM -prefix $out -jobs 6 -mask brain_mask_resampled+tlrc \
    -bsVars Sex \
    -wsVars Stim \
    -num_glt 6 \
    -gltLabel 1 Sex.Stim -gltCode 1 'Sex: 1*F -1*M' \
    -gltLabel 2 Sex.Lav -gltCode 2 'Stim: 1*Lav Sex: 1*F -1*M' \
    -gltLabel 3 Sex.P1 -gltCode 3 'Stim: 1*P1 Sex: 1*F -1*M' \
    -gltLabel 4 Sex.P2 -gltCode 4 'Stim: 1*P2 Sex: 1*F -1*M' \
    -gltLabel 5 Phero -gltCode 5 'Stim: 1*P1 -1*P2' \
    -gltLabel 6 Sex.Phero -gltCode 6 'Stim: 1*P1 -1*P2 Sex: 1*F -1*M' \
    -dataTable \
    Subj    Stim      Sex       InputFile \
    101     Lav       F         ${workDir}/101/deconv1_blur4_ANTS_resampled+tlrc[1] \
    101     P1        F         ${workDir}/101/deconv1_blur4_ANTS_resampled+tlrc[5] \
    101     P2        F         ${workDir}/101/deconv1_blur4_ANTS_resampled+tlrc[9] \
    102     Lav       F         ${workDir}/102/deconv1_blur4_ANTS_resampled+tlrc[1] \
    102     P1        F         ${workDir}/102/deconv1_blur4_ANTS_resampled+tlrc[5] \
    102     P2        F         ${workDir}/102/deconv1_blur4_ANTS_resampled+tlrc[9] \
    104     Lav       F         ${workDir}/104/deconv1_blur4_ANTS_resampled+tlrc[1] \
    104     P1        F         ${workDir}/104/deconv1_blur4_ANTS_resampled+tlrc[5] \
    104     P2        F         ${workDir}/104/deconv1_blur4_ANTS_resampled+tlrc[9] \
    105     Lav       F         ${workDir}/105/deconv1_blur4_ANTS_resampled+tlrc[1] \
    105     P1        F         ${workDir}/105/deconv1_blur4_ANTS_resampled+tlrc[5] \
    105     P2        F         ${workDir}/105/deconv1_blur4_ANTS_resampled+tlrc[9] \
    106     Lav       F         ${workDir}/106/deconv1_blur4_ANTS_resampled+tlrc[1] \
    106     P1        F         ${workDir}/106/deconv1_blur4_ANTS_resampled+tlrc[5] \
    106     P2        F         ${workDir}/106/deconv1_blur4_ANTS_resampled+tlrc[9] \
    107     Lav       F         ${workDir}/107/deconv1_blur4_ANTS_resampled+tlrc[1] \
    107     P1        F         ${workDir}/107/deconv1_blur4_ANTS_resampled+tlrc[5] \
    107     P2        F         ${workDir}/107/deconv1_blur4_ANTS_resampled+tlrc[9] \
    108     Lav       F         ${workDir}/108/deconv1_blur4_ANTS_resampled+tlrc[1] \
    108     P1        F         ${workDir}/108/deconv1_blur4_ANTS_resampled+tlrc[5] \
    108     P2        F         ${workDir}/108/deconv1_blur4_ANTS_resampled+tlrc[9] \
    109     Lav       F         ${workDir}/109/deconv1_blur4_ANTS_resampled+tlrc[1] \
    109     P1        F         ${workDir}/109/deconv1_blur4_ANTS_resampled+tlrc[5] \
    109     P2        F         ${workDir}/109/deconv1_blur4_ANTS_resampled+tlrc[9] \
    110     Lav       F         ${workDir}/110/deconv1_blur4_ANTS_resampled+tlrc[1] \
    110     P1        F         ${workDir}/110/deconv1_blur4_ANTS_resampled+tlrc[5] \
    110     P2        F         ${workDir}/110/deconv1_blur4_ANTS_resampled+tlrc[9] \
    111     Lav       F         ${workDir}/111/deconv1_blur4_ANTS_resampled+tlrc[1] \
    111     P1        F         ${workDir}/111/deconv1_blur4_ANTS_resampled+tlrc[5] \
    111     P2        F         ${workDir}/111/deconv1_blur4_ANTS_resampled+tlrc[9] \
    112     Lav       F         ${workDir}/112/deconv1_blur4_ANTS_resampled+tlrc[1] \
    112     P1        F         ${workDir}/112/deconv1_blur4_ANTS_resampled+tlrc[5] \
    112     P2        F         ${workDir}/112/deconv1_blur4_ANTS_resampled+tlrc[9] \
    113     Lav       F         ${workDir}/113/deconv1_blur4_ANTS_resampled+tlrc[1] \
    113     P1        F         ${workDir}/113/deconv1_blur4_ANTS_resampled+tlrc[5] \
    113     P2        F         ${workDir}/113/deconv1_blur4_ANTS_resampled+tlrc[9] \
    114     Lav       F         ${workDir}/114/deconv1_blur4_ANTS_resampled+tlrc[1] \
    114     P1        F         ${workDir}/114/deconv1_blur4_ANTS_resampled+tlrc[5] \
    114     P2        F         ${workDir}/114/deconv1_blur4_ANTS_resampled+tlrc[9] \
    115     Lav       F         ${workDir}/115/deconv1_blur4_ANTS_resampled+tlrc[1] \
    115     P1        F         ${workDir}/115/deconv1_blur4_ANTS_resampled+tlrc[5] \
    115     P2        F         ${workDir}/115/deconv1_blur4_ANTS_resampled+tlrc[9] \
    116     Lav       F         ${workDir}/116/deconv1_blur4_ANTS_resampled+tlrc[1] \
    116     P1        F         ${workDir}/116/deconv1_blur4_ANTS_resampled+tlrc[5] \
    116     P2        F         ${workDir}/116/deconv1_blur4_ANTS_resampled+tlrc[9] \
    201     Lav       M         ${workDir}/201/deconv1_blur4_ANTS_resampled+tlrc[1] \
    201     P1        M         ${workDir}/201/deconv1_blur4_ANTS_resampled+tlrc[5] \
    201     P2        M         ${workDir}/201/deconv1_blur4_ANTS_resampled+tlrc[9] \
    202     Lav       M         ${workDir}/202/deconv1_blur4_ANTS_resampled+tlrc[1] \
    202     P1        M         ${workDir}/202/deconv1_blur4_ANTS_resampled+tlrc[5] \
    202     P2        M         ${workDir}/202/deconv1_blur4_ANTS_resampled+tlrc[9] \
    203     Lav       M         ${workDir}/203/deconv1_blur4_ANTS_resampled+tlrc[1] \
    203     P1        M         ${workDir}/203/deconv1_blur4_ANTS_resampled+tlrc[5] \
    203     P2        M         ${workDir}/203/deconv1_blur4_ANTS_resampled+tlrc[9] \
    204     Lav       M         ${workDir}/204/deconv1_blur4_ANTS_resampled+tlrc[1] \
    204     P1        M         ${workDir}/204/deconv1_blur4_ANTS_resampled+tlrc[5] \
    204     P2        M         ${workDir}/204/deconv1_blur4_ANTS_resampled+tlrc[9] \
    205     Lav       M         ${workDir}/205/deconv1_blur4_ANTS_resampled+tlrc[1] \
    205     P1        M         ${workDir}/205/deconv1_blur4_ANTS_resampled+tlrc[5] \
    205     P2        M         ${workDir}/205/deconv1_blur4_ANTS_resampled+tlrc[9] \
    206     Lav       M         ${workDir}/206/deconv1_blur4_ANTS_resampled+tlrc[1] \
    206     P1        M         ${workDir}/206/deconv1_blur4_ANTS_resampled+tlrc[5] \
    206     P2        M         ${workDir}/206/deconv1_blur4_ANTS_resampled+tlrc[9] \
    207     Lav       M         ${workDir}/207/deconv1_blur4_ANTS_resampled+tlrc[1] \
    207     P1        M         ${workDir}/207/deconv1_blur4_ANTS_resampled+tlrc[5] \
    207     P2        M         ${workDir}/207/deconv1_blur4_ANTS_resampled+tlrc[9] \
    208     Lav       M         ${workDir}/208/deconv1_blur4_ANTS_resampled+tlrc[1] \
    208     P1        M         ${workDir}/208/deconv1_blur4_ANTS_resampled+tlrc[5] \
    208     P2        M         ${workDir}/208/deconv1_blur4_ANTS_resampled+tlrc[9] \
    209     Lav       M         ${workDir}/209/deconv1_blur4_ANTS_resampled+tlrc[1] \
    209     P1        M         ${workDir}/209/deconv1_blur4_ANTS_resampled+tlrc[5] \
    209     P2        M         ${workDir}/209/deconv1_blur4_ANTS_resampled+tlrc[9] \
    210     Lav       M         ${workDir}/210/deconv1_blur4_ANTS_resampled+tlrc[1] \
    210     P1        M         ${workDir}/210/deconv1_blur4_ANTS_resampled+tlrc[5] \
    210     P2        M         ${workDir}/210/deconv1_blur4_ANTS_resampled+tlrc[9] \
    211     Lav       M         ${workDir}/211/deconv1_blur4_ANTS_resampled+tlrc[1] \
    211     P1        M         ${workDir}/211/deconv1_blur4_ANTS_resampled+tlrc[5] \
    211     P2        M         ${workDir}/211/deconv1_blur4_ANTS_resampled+tlrc[9] \
    212     Lav       M         ${workDir}/212/deconv1_blur4_ANTS_resampled+tlrc[1] \
    212     P1        M         ${workDir}/212/deconv1_blur4_ANTS_resampled+tlrc[5] \
    212     P2        M         ${workDir}/212/deconv1_blur4_ANTS_resampled+tlrc[9] \
    213     Lav       M         ${workDir}/213/deconv1_blur4_ANTS_resampled+tlrc[1] \
    213     P1        M         ${workDir}/213/deconv1_blur4_ANTS_resampled+tlrc[5] \
    213     P2        M         ${workDir}/213/deconv1_blur4_ANTS_resampled+tlrc[9]
fi
