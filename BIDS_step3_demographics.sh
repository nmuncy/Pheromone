#!/bin/bash



rawDir=/Volumes/Yorick/WiscoPhero
docDir=${rawDir}/docs
dicomDir=/Volumes/Yorick/MriRawData
session=WiscoPheromones

wiscoList=(`tail -n +8 ${docDir}/SubjectKey.txt | awk '{print $1}'`)
brockList=(`tail -n +8 ${docDir}/SubjectKey.txt | awk '{print $2}'`)

print=${rawDir}/rawdata/participants.tsv
echo -e "participant_id\tsex\tage" > $print

c=0; while [ $c -lt ${#wiscoList[@]} ]; do

	subjWisco=sub-${wiscoList[$c]}
	subjBrock=sub-${brockList[$c]#s}
	
	age=`dicom_hdr ${dicomDir}/${subjBrock}/ses-${session}/dicom/t1*/IM*001.dcm | grep "0010 1010" | sed 's/.*\///' | sed 's/[^0-9]//'`
	sex=`dicom_hdr ${dicomDir}/${subjBrock}/ses-${session}/dicom/t1*/IM*001.dcm | grep "0010 0040" | sed 's/.*\///'`
	echo -e "${subjWisco}\t${age:1:2}\t${sex}" >> $print
	
	let c+=1
done