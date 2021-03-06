#!/bin/bash





### --- Notes
#
# 1) this script will construct T1, T2, EPI data and organize output
#		according to BIDS formatting
#
# 2) written so you can just update $subjList and rerun the whole script
#
# 3) Will require input for constructing dataset_description.json
#
# 4) Make sure to update the jq task input where the epi Json files are being input!




###??? change these variables/arrays
rawDir=/Volumes/Yorick/MriRawData							# location of raw data
workDir=/Volumes/Yorick/WiscoPhero							# desired working directory
docDir=${workDir}/docs
tempDir=/Volumes/Yorick/Templates

pheroList=(`cat ${docDir}/subjects.txt | awk '{print $1}'`)
subj7List=(`cat ${docDir}/subjects.txt | awk '{print $2}'`)

session=WiscoPheromones										# scanning session - for raw data organization (ses-STT)
task=task-WiscoPhero										# name of task, for epi data naming
epiDirs=(P{1,2} L)											# epi dicom directory name/prefix. Run1=P1, Run2=P2, Run3=L
t1Dir=t1													# t1 ditto




### Check for jq
# jq will be used to append Json files

which jq >/dev/null 2>&1

if [ $? != 0 ]; then
	echo >&2
	echo "Software jq is required: download from https://stedolan.github.io/jq/ and add it to your \$PATH. Exit 1" >&2
	echo >&2
	exit 1
fi




### Set up BIDS parent dirs
for i in derivatives sourcedata stimuli rawdata; do
	if [ ! -d ${workDir}/$i ]; then
		mkdir -p ${workDir}/$i
	fi
done




### Write dataset_description.json
# This will request input

if [ ! -s ${workDir}/rawdata/dataset_description.json ]; then

	echo -e "\nNote: title below must be supplied in quotations"
	echo -e "\te.g. \"This is my title\"\n"
	read -p 'Please enter title of the manuscript:' title

	echo -e "\n\nNote: authors must be within quotes and separated by a comma & space"
	echo -e "\te.g. \"Nate Muncy\", \"Brock Kirwan\"\n"
	read -p 'Please enter authors:' authors

	cat > ${workDir}/rawdata/dataset_description.json << EOF
{
	"Name": $title,
	"BIDSVersion": "1.1.1",
	"License": "CCo",
	"Authors": [$authors]
}
EOF
fi



### Work
for i in ${!subj7List[@]}; do

	subj7=sub-${subj7List[$i]/s}
	subjP=sub-${pheroList[$i]}

	### set up BIDS data dirs
	anatDir=${workDir}/rawdata/${subjP}/anat
	funcDir=${workDir}/rawdata/${subjP}/func
	derivDir=${workDir}/derivatives/$subjP

	for j in {anat,func,deriv}Dir; do
		if [ ! -d $(eval echo \${$j}) ]; then
			mkdir -p $(eval echo \${$j})
		fi
	done


	### construct data
	dataDir=${rawDir}/${subj7}/ses-${session}/dicom

	# t1 data
	if [ ! -f ${anatDir}/${subjP}_T1w.nii.gz ]; then

		dcm2niix -b y -ba y -z y -o $anatDir -f tmp_${subjP}_T1w ${dataDir}/${t1Dir}*/

		# Deface by Brock Kirwan
		3dAllineate -base ${anatDir}/tmp_${subjP}_T1w.nii.gz -input ${tempDir}/mean_reg2mean.nii.gz -prefix ${anatDir}/tmp_mean_reg2mean_aligned.nii -1Dmatrix_save ${anatDir}/tmp_allineate_matrix
		3dAllineate -base ${anatDir}/tmp_${subjP}_T1w.nii.gz -input ${tempDir}/facemask.nii.gz -prefix ${anatDir}/tmp_facemask_aligned.nii -1Dmatrix_apply ${anatDir}/tmp_allineate_matrix.aff12.1D
		3dcalc -a ${anatDir}/tmp_facemask_aligned.nii -b ${anatDir}/tmp_${subjP}_T1w.nii.gz -prefix ${anatDir}/${subjP}_T1w.nii.gz -expr "step(a)*b"
		mv ${anatDir}/tmp_${subjP}_T1w.json ${anatDir}/${subjP}_T1w.json
		rm ${anatDir}/tmp*
	fi


	# epi
	for j in ${!epiDirs[@]}; do

		pos=$(($j+1))

		if [ ! -f ${funcDir}/${subjP}_${task}_run-${pos}_bold.nii.gz ]; then
			dcm2niix -b y -ba y -z y -o $funcDir -f ${subjP}_${task}_run-${pos}_bold ${dataDir}/${epiDirs[$j]}/
		fi

		# Json append by Brock Kirwan
		funcJson=${funcDir}/${subjP}_${task}_run-${pos}_bold.json
		taskExist=$(cat $funcJson | jq '.TaskName')
		if [ "$taskExist" == "null" ]; then
			jq '. |= . + {"TaskName":"PheromoneOlfaction"}' $funcJson > ${derivDir}/tasknameadd.json
			rm $funcJson && mv ${derivDir}/tasknameadd.json $funcJson
		fi
	done
done
