#!/bin/bash


# Version 1 from September 2018
# for internal use at the Institute of Genetics
# University fo Bern
# made by Irene Häfliger
# if any problems occure, please contact: irene.haefliger@vetsuisse.unibe.ch


######
### read control variables
source $1
LOGFILE=$( echo ${job_name}.log )

######
### check control variables 

### # function for reporting on console
usage () {
  local l_MSG=$1
  echo "Usage Error: $l_MSG"
  echo -e "\n"
  echo "Usage: $SCRIPT  dir_output=<string>" 
  echo "  where <string> specifies the output directory."
  echo "  The folder will be made in the current working directory."
  echo "  An existing folder will be deleted."
  echo "Usage: $SCRIPT output_name=<string>"
  echo "  where <string> specifies the Name of the final output file."
  exit 1
}

dir_output=${job_name}
output_name=${job_name}

### check number of command line arguments
NUMARGS=$#
echo "Number of arguments: $NUMARGS"

if [[ $NUMARGS -lt 1 ]] 
then
  usage 'No command line arguments specified - please input a parameterfile after calling the script.'
fi

### # check if the output directory exists already
# -d checks if the diretory exists already
if [[ -d ${dir_output} ]]
then
    usage 'Output directory exists already!!'
fi
### # check that output filename is defined
if [[ -z ${output_name} ]]
then
	usage  'No name of the output final is defined!!'
fi

# correct and check if the path is written correctly
check_path_correctnes=$(echo ${path_to_bamfiles} | grep '/$' )
if [[ ${check_path_correctnes} != "" ]]
then
    length_char_path=$( echo "${check_path_correctnes}" | wc -c )
	ouput_length=$(echo "${length_char_path}-1" | bc )
	path_to_bamfiles=$(echo "${check_path_correctnes}" | cut -b1-${ouput_length} )
fi

if [[ ! -d ${path_to_bamfiles} ]]
then
    usage 'Path to the bamfile does not exist!!'
fi


######
### make directory
rm -rf ${dir_output}
mkdir ${dir_output}

#copy the parameter file in the output
cp $1 ${dir_output}/
cd ${dir_output}

echo $1 > input_filename



echo '##############################################'
echo '# The only thing that will make you happy is #' 
echo '#  being happy with who you are, and not who #'
echo '#    people think you are.    Goldie Hawn.   #'
echo '##############################################'

RIGHT_NOW=$(date +"%x %r %Z")
echo "${RIGHT_NOW}" | tee -a ${LOGFILE}



##############
### first part
## preparations
## get the list of bamfiles
echo "preparing the general data" | tee -a ${LOGFILE}
rm -f target_files control_files
target=${case}

for i in ${target}
do
	ls ${path_to_bamfiles}/${i}*.bam >> target_files
done
#
for j in ${control}
do
	ls ${path_to_bamfiles}/${j}*.bam >> control_files
done

#make a bedfile of the region
echo -e "${chr}\t${start}\t${end}" > region.bed

#get the average coverage of the whole genome
list=$(cat target_files control_files | tr '\n' ' ' )
echo "calculating average coverage" | tee -a ${LOGFILE}
goleft covstats ${list} > av_cov_wg_target_and_control.txt # be aware that the file has an header line
#get the coverage per base
echo "calculating coverage per base" | tee -a ${LOGFILE}
echo "While this will take a while - maybe I can suggest you a paper concerning structural variants: " 
echo "Tattini L., D'Aurizio R., Magi A. (2015) Detection of Genomic Structural Variants from Next Generation Sequencing Data. Front Gioeng Giotechnol. 2015; 3: 92."
rm -f cov_perBase_${chr}_${species}.txt
samtools depth -b region.bed ${list} >> cov_perBase_${chr}_${species}.txt



##############
### final remarks, tidy up and report

rm target_files control_files region.bed


echo -e "\n" | tee -a ${LOGFILE}
echo "program finshed" | tee -a ${LOGFILE}

echo -e "\n" | tee -a ${LOGFILE}
echo "# you selected the following genomes to find a region:" | tee -a ${LOGFILE}

#check control animals
if [[ ${control} = "" ]]
then
	echo "- no animals were selected to take as controls" | tee -a ${LOGFILE}
else
	echo "- Selected animals for controls were: ${control}" | tee -a ${LOGFILE}
fi
#check target animals
if [[ ${target} = "" ]]
then
	echo "- no animals were selected to take as targets" | tee -a ${LOGFILE}
else
	echo "- Selected animals for targets were: ${target}" | tee -a ${LOGFILE}
fi

RIGHT_NOW=$(date +"%x %r %Z") | tee -a ${LOGFILE}
echo ${RIGHT_NOW} | tee -a ${LOGFILE}

echo '##############################################' | tee -a ${LOGFILE}
echo '# The grass is greener where you water it... #' | tee -a ${LOGFILE}
echo '##############################################' | tee -a ${LOGFILE}


