#!/bin/bash


# Written by Brock Kirwan
# Edited by Nathan Muncy on 8/16/17

### wrap with step0_wrap.sh


sub=$1
KirwanID=$2

workDir=/Volumes/Yorick/WiscoPheromone
subjDir=${workDir}/${sub}
rawDir=/Volumes/Yorick/MriRawData/${KirwanID}/phero

if [ ! -d $subjDir ]; then
    mkdir $subjDir
fi



### Step one: make files
cd $subjDir

# make struct
if [ ! -f struct.nii ]; then

    dcm2nii -a y -g n -x y -o ${subjDir} ${rawDir}/t1*/*.dcm
    mv co* struct.nii
fi


# make func nii
PathOrigScanName=$(echo ${rawDir}/run1*)
echo "PathOrigScanName = $PathOrigScanName"
PathRun="${PathOrigScanName%_*}"
echo "PathRun = $PathRun"
RunName="${PathRun##*/}"
echo "RunName = $RunName"
FinalRunName="${RunName#*_}"
echo "FinalRunName = $FinalRunName"

if [ ! -f run3.nii ]; then

    dcm2nii -o ${subjDir} -a y -g n -d N -r N -e N ${rawDir}/L/*.dcm
    mv ${FinalRunName}.nii /${RunName}.nii
    mv *L.nii run3.nii
fi


PathOrigScanName=$(echo ${rawDir}/run2*)
echo "PathOrigScanName = $PathOrigScanName"
PathRun="${PathOrigScanName%_*}"
echo "PathRun = $PathRun"
RunName="${PathRun##*/}"
echo "RunName = $RunName"
FinalRunName="${RunName#*_}"
echo "FinalRunName = $FinalRunName"

if [ ! -f run1.nii ]; then

    dcm2nii -o ${subjDir} -a y -g n -d N -r N -e N ${rawDir}/P1/*.dcm
    mv ${FinalRunName}.nii ${RunName}.nii
    mv *P1.nii run1.nii
fi


PathOrigScanName=$(echo ${rawDir}/run3*)
echo "PathOrigScanName = $PathOrigScanName"
PathRun="${PathOrigScanName%_*}"
echo "PathRun = $PathRun"
RunName="${PathRun##*/}"
echo "RunName = $RunName"
FinalRunName="${RunName#*_}"
echo "FinalRunName = $FinalRunName"

if [ ! -f run2.nii ]; then

    dcm2nii -o ${subjDir} -a y -g n -d N -r N -e N ${rawDir}/P2/*.dcm
    mv ${FinalRunName}.nii ${RunName}.nii
    mv *P2.nii run2.nii
fi


# clean
if [ ! -d extra_files ]; then
    mkdir extra_files
fi
mv o* extra_files
mv 20* extra_files



### Step two: volreg, align

if [ ! -f struct+orig.HEAD ]; then
    for run in run1 run2 run3 struct; do
        3dcopy ${run}.nii ${run}+orig
    done
fi


if [ ! -f struct_rotated+orig.HEAD ]; then
    3dWarp -oblique_parent run3+orig -prefix struct_rotated struct+orig
fi


# volreg
if [ ! -f Run3_volreg+orig.HEAD ]; then

    3dvolreg -base run1+orig'[205]' -prefix run1_volreg -1Dfile motion_1 run1+orig
    3dvolreg -base run2+orig'[205]' -prefix run2_volreg -1Dfile motion_2 run2+orig
    3dvolreg -base run3+orig'[205]' -prefix run3_volreg -1Dfile motion_3 run3+orig
fi


#align
if [ ! -f run1_aligned+orig.HEAD ]; then
    for run in run1 run2; do

        3dvolreg -base run3_volreg+orig'[0]' -prefix ${run}_aligned ${run}_volreg+orig
        rm ${run}*volreg*
    done
fi




### Step Three: motion files

if [ ! -f motion_censor_vector.txt ]; then

    cat motion_* >> motion.txt
    /Volumes/Yorick/move_censor.pl
fi
