#!/bin/bash


# written by Nathan Muncy on 9/1/17


### Set up vars, lists, output
workDir=/Volumes/Yorick/WiscoPheromone
roiDir=${workDir}/nsynAnalysis
outDir=${roiDir}/txt_files
ref=${workDir}/201/deconv1_blur4_ANTS_resampled+tlrc

print=${outDir}/nsynth_betas.txt
> $print



### Arrays
Sex_0=(1:rAmyg)
Sex_1=(2:xlBS)
Sex_2=(3:lAmyg)
Sex_3=(4:lColS)
Sex_4=(5:xrMTL)
Sex_5=(6:rBA3845)
Sex_6=(7:xrCer)
Sex_7=(8:xrBS)
Sex_8=(9:rOFC)
Sex_9=(10:xlTec)

Sex_list=(
    Sex_0[@]
    Sex_1[@]
    Sex_2[@]
    Sex_3[@]
    Sex_4[@]
    Sex_5[@]
    Sex_6[@]
    Sex_7[@]
    Sex_8[@]
    Sex_9[@]
)



### Functions
# split masks
MakeMask() {
    file=$1
    name=${file%%_*}
    num=`3dinfo $file | grep "At sub-brick #0 '#0' datum type is short" | sed 's/[^0-9]*//g' | sed 's/^...//'`
    3dcopy $file tmp_${name}.nii.gz
    for (( c=1; c<=$num; c++ )); do
        c3d tmp_${name}.nii.gz -thresh $c $c 1 0 -o tmp_${name}_mask${c}.nii.gz
        3dcopy tmp_${name}_mask${c}.nii.gz tmp_${name}_mask${c}+tlrc
        3dFractionize -template $ref -input tmp_${name}_mask${c}+tlrc -prefix tmp_${name}_mask${c}_resampled
        3dcalc -a tmp_${name}_mask${c}_resampled+tlrc -prefix ${name}_mask${c} -expr "step(a)"
    done
    rm tmp*
}

# rename masks
Rename() {
    string=$1
    len=${#Sex_list[@]}
    for (( a=0; a<$len; a++ )); do
        let c=$[$a+1]
        fileB=${string}_mask${c}+tlrc.BRIK
        fileH=${string}_mask${c}+tlrc.HEAD
        maskN=${!Sex_list[a]%:*}
        name=${!Sex_list[a]#*:}
        mv $fileB ${fileB/$maskN/_$name}
        mv $fileH ${fileH/$maskN/_$name}
    done
}




### Work
# split masks, rename
cd $roiDir
MakeMask Sex_z0_k60_mask+tlrc
Rename Sex


# make array of files
c=0; for i in *mask*HEAD; do
    if [[ $i != *z* ]] && [[ $i != *_x* ]]; then
        maskList[$c]=${i%.*}
        let c=$[$c+1]
    fi
done


# get participant betas
cd $workDir

for i in 1* 2*; do
cd $i

    for j in ${maskList[@]}; do

        mask=${roiDir}/$j
        hold=${j%+*}
        maskName=${hold##*_}
        file=deconv1_blur4_ANTS_resampled+tlrc
        betas=1,5,9

        stats=`3dROIstats -mask $mask "${file}[$betas]"`
        echo "$i $maskName $stats" >> $print
        echo >> $print
    done

cd $workDir
done
