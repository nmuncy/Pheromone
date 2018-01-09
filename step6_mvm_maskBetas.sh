#!/bin/bash


# Written by Nathan Muncy on 8/16/17


workDir=/Volumes/Yorick/WiscoPheromone
grpDir=${workDir}/grpAnalysis
outDir=${workDir}/Analyses
clustDir=${grpDir}/clust_masks
deconFile=deconv1_blur4_ANTS_resampled+tlrc

subjList=(101 102 103 104 105 106 107 108 109 110 111 112 113 114 115 116 201 202 203 204 205 206 207 208 209 210 211 212 213)




### Step one: Split Clust masks, set up txt files
cd $grpDir


# organize
if [ ! -d $clustDir ]; then
    mkdir $clustDir
fi
mv Clust* $clustDir
cd $clustDir


# build list of clusters
c=0; for a in Clust*_mask+tlrc.HEAD; do

    clust[$c]="${a%+*}"
    let c=$[$c+1]
done


# pull number of labels per mask, split masks by label
if [ ! -f ${clust[0]}_1+tlrc.HEAD ] || [ ! -f ${clustDir}/${clust[0]}_1+tlrc.HEAD ]; then
    for b in ${clust[@]}; do

            if [ ! -f ${b}.nii.gz ]; then
                3dcopy ${b}+tlrc ${b}.nii.gz
            fi

        num=`3dinfo ${b}+tlrc | grep "At sub-brick #0 '#0' datum type is short" | sed 's/[^0-9]*//g' | sed 's/^...//'`

        for (( c=1; c<=$num; c++ )); do

            c3d ${b}.nii.gz -thresh $c $c 1 0 -o ${b}_${c}.nii.gz
            3dcopy ${b}_${c}.nii.gz ${b}_${c}+tlrc
        done
    done
fi


# build list of masks
c=0; for d in ${clustDir}/Clust*HEAD; do
    if [[ $d != *mask+tlrc* ]]; then

        tmp=${clustDir}/
        string=${d/$tmp}
        mask[$c]=${string/+tlrc.HEAD}
        let c=$[$c+1]
    fi
done

maskLen="${#mask[@]}"


# make output txt files
for e in ${mask[@]}; do
    > ${outDir}/"${e/Clust_}"_betas.txt
done



### Step two: get, print betas
cd $workDir

for i in ${subjList[@]}; do
cd $i

    for j in ${mask[@]}; do

        print=${outDir}/"${j/Clust_}"_betas.txt

        if [[ $j == *Phero* ]]; then
            betas=5,9
        elif [[ $j == *Lav* ]]; then
            betas=1
        fi

        stats=`3dROIstats -mask ${clustDir}/${j}+tlrc "${deconFile}[${betas}]"`
        echo "$i $stats" >> $print
        echo >> $print
    done

cd $workDir
done



## Step three: clean up output, make master files
cd $outDir

for a in ${clust[@]}; do
    > Master_"${a/Clust_}"_betas.txt
done


c=0; for b in Master*; do
    printM[$c]=$b
    let c=$[$c+1]
done

printMlen=${#printM[@]}


c=0; while [ $c -lt $printMlen ]; do

    print=${printM[$c]}

    tmp1=${printM[$c]}
    tmp2=${tmp1#*_}
    string=${tmp2%_*}

    for i in *mask_*_betas.txt; do
    match=${i%%_*}_mask

        if [[ $string == $match ]]; then

            maskN=`ls $i | sed -e s/[^0-9]//g`
            echo "Mask $maskN" >> $print
            cat $i >> $print
        fi
    done

let c=$[$c+1]
done


if [ ! -d txt_files ]; then
    mkdir txt_files
fi

mv *mask_*_betas.txt txt_files
