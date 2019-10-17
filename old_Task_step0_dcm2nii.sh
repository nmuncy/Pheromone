#!/bin/bash




### --- Notes
#
# 1) this script will construct T1, T2, EPI data and organize output
#		according to BIDS formatting
#
# 2) written so you can just update $subjList and rerun the whole script



###??? change these variables/arrays
rawDir=/Volumes/Yorick/MriRawData			# location of raw data
workDir=/Volumes/Yorick/WiscoPhero				# desired working directory
docDir=${workDir}/docs

session=WiscoPheromones							# scanning session - for raw data organization (ses-STT)
task=task-phero									# name of task, for epi data naming
epiDirs=(L P{1,2})								# epi dicom directory name/prefix
t1Dir=t1										# t1 ditto



subj7List=(`cat ${docDir}/subjects.txt | awk '{print $2}'`)
pheroList=(`cat ${docDir}/subjects.txt | awk '{print $1}'`)



### set up BIDS parent dirs
for i in derivatives sourcedata stimuli; do
	if [ ! -d ${workDir}/$i ]; then
		mkdir -p ${workDir}/$i
	fi
done



c=0; while [ $c -lt ${#subj7List[@]} ]; do

	hold=${subj7List[$c]}
	subj7Dir=sub-${hold/s}
	subjPhero=sub-${pheroList[$c]}

	# for i in ${subjList[@]}; do

	### set up BIDS data dirs
	anatDir=${workDir}/rawdata/${subjPhero}/anat
	funcDir=${workDir}/rawdata/${subjPhero}/func
	derivDir=${workDir}/derivatives/${subjPhero}

	if [ ! -d $anatDir ]; then
		mkdir -p $anatDir $funcDir $derivDir
	fi


	### construct data
	dataDir=${rawDir}/${subj7Dir}/ses-${session}/dicom

	# t1 data
	if [ ! -f ${anatDir}/${i}_T1w.nii.gz ]; then
		dcm2niix -b y -ba y -z y -o $anatDir -f ${subjPhero}_T1w ${dataDir}/${t1Dir}*/
	fi


	# epi
	for j in ${!epiDirs[@]}; do
		pos=$(($j+1))
		if [ ! -f ${funcDir}/${i}_${task}_run-${pos}_bold.nii.gz ]; then
			dcm2niix -b y -ba y -z y -o $funcDir -f ${subjPhero}_${task}_run-${pos}_bold ${dataDir}/${epiDirs[$j]}*/
		fi
	done

	let c+=1
done
