#!/bin/bash


# written by Nathan Muncy on 8/11/17


workDir=/Volumes/Yorick/WiscoPheromone/Analyses
dataDir=${workDir}/R_output


# Set up Master lists
cd $workDir
> master_list.txt

for i in Master*txt; do

    tmp=${i#*_}
    string=${tmp%%_*}
    echo $string >> master_list.txt
done


listM=($(cat master_list.txt ))

for i in ${listM[@]}; do
    > Master_grpAnalysis_${i}_stats.txt
done



# Pull Data
cd $dataDir

c=0; for i in TTest*.txt; do
    listT[$c]=$i
    let c=$[$c+1]
done

c=0; for i in WBRM*.txt; do
    listW[$c]=$i
    let c=$[$c+1]
done

c=0; for i in Post*.txt; do
    listP[$c]=$i
    let c=$[$c+1]
done


for i in ${listM[@]}; do

    stringM=$i

    print1=${workDir}/Master_grpAnalysis_TTEST_${i}_stats.txt
    print2=${workDir}/Master_grpAnalysis_WBRM_${i}_stats.txt
    print3=${workDir}/Master_grpAnalysis_PostHocT_${i}_stats.txt

    >$print1
    >$print2
    >$print3

    for j in ${listT[@]}; do

        hold=${j#*_}
        stringT=${hold%_*}

        if [[ $stringM == $stringT ]]; then

            hold1=${j##*_}
            maskT=${hold1%.*}

            echo $maskT >> $print1
            cat $j >> $print1
            echo >> $print1
        fi
    done


    for k in ${listW[@]}; do   # Lazy scripting for listW, listP due to time crunch

        hold2=${k#*_}
        stringW=${hold2%_*}

        if [[ $stringM == $stringW ]]; then

            hold3=${k##*_}
            maskW=${hold3%.*}

            echo $maskW >> $print2
            cat $k >> $print2
            echo >> $print2
        fi
    done


    for m in ${listP[@]}; do
        hold4=${m#*_}
        stringP=${hold4%_*}

        if [[ $stringM == $stringP ]]; then

            hold3=${m##*_}
            maskP=${hold4%.*}

            echo $maskP >> $print3
            cat $m >> $print3
            echo >> $print3
        fi
    done
done


cd $workDir
> grp_list.txt

for i in Master*.txt; do
    if [ ! -s $i ]; then
        rm $i
    fi
done


for i in Master*stats.txt; do
    echo $i >> grp_list.txt
done

