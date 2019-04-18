#!/bin/bash
RIGHT_NOW=$(date +"%x %r %Z")
echo ${RIGHT_NOW}

### Mini skript written at the 28.8.2018 by Irene Häfliger
### to do the liftover of the SNP data from the cattle
### original map based on the UMD3.1 genome
### new map based on the ARS-UCD1.2 genome

echo "Programm laeuft..."

oldmap=$1
newmap="/home/irene/vardb/003_cattle/0039_Pinzgauer_Farbe/SNPdata/9913_ARS1.2_777962_HD_marker_name_180705.map"

path_output=$(echo ${oldmap} | cut -d'.' -f1 )

rm -rf ${path_output}
mkdir ${path_output}
cd ${path_output}
echo "made directory ${path_output}"

cp ../${oldmap} old.map
cat ${newmap}  | awk '{print toupper($0)}'  > new.map

echo "copied the data to the directory ${path_output}"


updatedmap=${oldmap}
rm -f ${updatedmap}
echo "replacing the old with the new position per SNPname"

while read line;
do
	SNPname=$(echo ${line} | cut -d' ' -f2 )
	newline=$(grep ${SNPname} new.map )
	if [[ ${newline} == "" ]]
	then
		echo "${line}" | tr ' ' '\t' >> ${updatedmap}
	else
		position=$( echo ${newline} | cut -d' ' -f4 )
		chromosome=$( echo ${newline} | cut -d' ' -f1 )
		allele1=$( echo ${line} | cut -d' ' -f5 )
		allele2=$( echo ${line} | cut -d' ' -f6 )
		if [[ ${position} < 0 ]]
		then
			newposition=$(echo "${position}*-1"  | bc )
			echo ${newline} | awk -v pos=${newposition} -v a1=${allele1} -v a2=${allele2} -F' ' '{print $1,$2,0,pos,a1,a2}' | tr ' ' '\t' >> ${updatedmap}
		else	
			echo ${newline} | awk -v a1=${allele1} -v a2=${allele2} -F' ' '{print $1,$2,0,$4,a1,a2}' | tr ' ' '\t' >> ${updatedmap}
		fi
	fi
done < old.map 

echo "file updated and saved in ${path_output}/${updatedmap}"
RIGHT_NOW=$(date +"%x %r %Z")
echo ${RIGHT_NOW}

echo "Done!"


