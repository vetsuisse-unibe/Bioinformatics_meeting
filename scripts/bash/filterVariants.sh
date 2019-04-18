#!/bin/bash

# Version 4 from 1st April 2019
# bug fix number 3
# for internal use at the Institute of Genetics
# University fo Bern
# made by Irene Häfliger
# if any problems occure, please contact: irene.haefliger@vetsuisse.unibe.ch


echo '################################################################################' 
echo '# You are one of the lucky ones. Congratulations you can use this program!!!!! #' 
echo '################################################################################'

RIGHT_NOW=$(date +"%x %r %Z")
echo "${RIGHT_NOW}" | tee -a ${LOGFILE}

echo 'The program starts with checking all the input you have given it. This might take a while....'
echo '...'
######
### read control variables
source $1

#make sure input is correct
             gene=$( echo ${genes} | tr '\t' ' ' | tr -s ' ' | awk '{print toupper($0)}' )
              chr=$( echo ${chromosomes} | tr '\t' ' ' | tr -s ' ' )
           target=$( echo ${cases} | tr '\t' ' ' | tr -s ' ' | awk '{print toupper($0)}' )
 target_genotypes=$( echo ${cases_genotypes} | tr '\t' ' ' | tr -s ' ' )
          control=$( echo ${controls} | tr '\t' ' ' | tr -s ' ' | awk '{print toupper($0)}' )
control_genotypes=$( echo ${controls_genotypes} | tr '\t' ' ' | tr -s ' ' )
  exclude_animals=$( echo ${exclude} | tr '\t' ' ' | tr -s ' ' | awk '{print toupper($0)}' )
           filter=$( echo ${quality_filter} | tr '\t' ' ' | tr -s ' '  | awk '{print toupper($0)}' )
           impact=$( echo ${impacts} | tr '\t' ' ' | tr -s ' ' )

   start_position=$(echo ${start} | tr ',' '.' )
    rounded_start=$(echo ${start_position} | cut -d'.' -f1)
            start=$(echo ${start_position} )
     end_position=$(echo ${end} | tr ',' '.' )
      rounded_end=$(echo ${end_position} | cut -d'.' -f1)
              end=$( echo ${end_position} )

exclude_pseudogenes='FALSE' #In public version include pseudogenes always!
             header='TRUE'
         dir_output=${job_name}
        output_name=$( echo ${job_name}.vcf )

            LOGFILE=$( echo ${job_name}.log )


echo '...'

######
### check control variables 

### # function for reporting on console
usage () {
  local l_MSG=$1
  echo -e "\n" | tee -a ${LOGFILE}
  
  echo "Usage Error: $l_MSG" | tee -a ${LOGFILE}
  echo -e "\n" | tee -a ${LOGFILE}
  
  echo "Usage:   vcf=<string>" | tee -a ${LOGFILE}
  echo "  where <string> specifies the entire path to the input file" | tee -a ${LOGFILE}
  
  echo "Usage:  job_name=<string>" | tee -a ${LOGFILE}
  echo "  where <string> specifies the Name of the job that is going to run." | tee -a ${LOGFILE}
  echo "  This will also be the name of the folder with the output and the name of the final VCF." | tee -a ${LOGFILE}
  
  echo "Usage:  genes=<string>" | tee -a ${LOGFILE}
  echo "  where <string> specifies a list of genes that are going to be extracted from the VCF." | tee -a ${LOGFILE}
  
  echo "Usage:  chromosomes=<string>" | tee -a ${LOGFILE}
  echo "  where <string> specifies a list of chromosomes that are going to be extracted from the VCF." | tee -a ${LOGFILE}
  echo "  if you are not sure what the coding of the chromosome in the vcf file is, type: head /path/to/vcf-file.vcf and you will see the first 10 lines of the vcf file." | tee -a ${LOGFILE}
  
  echo "Usage:  start=<string>" | tee -a ${LOGFILE}
  echo "  where <string> specifies the start of a region that is going to be extracted from the VCF." | tee -a ${LOGFILE}
  
  echo "Usage:  end=<string>" | tee -a ${LOGFILE}
  echo "  where <string> specifies the end of a region that is going to be extracted from the VCF." | tee -a ${LOGFILE}
  
  echo "Usage:  cases=<string>" | tee -a ${LOGFILE}
  echo "  where <string> specifies the cases that are going to be analysed." | tee -a ${LOGFILE}
  
  echo "Usage:  cases_genotypes=<string>" | tee -a ${LOGFILE}
  echo "  where <string> specifies genotypes which the cases are expected to carry." | tee -a ${LOGFILE}
  
  echo "Usage:  controls=<string>" | tee -a ${LOGFILE}
  echo "  where <string> specifies the controls that are going to be analysed." | tee -a ${LOGFILE}
  
  echo "Usage:  controls_genotypes=<string>" | tee -a ${LOGFILE}
  echo "  where <string> specifies genotypes which the controls are expected to carry." | tee -a ${LOGFILE}
  
  echo "Usage:  impacts=<string>" | tee -a ${LOGFILE}
  echo "  where <string> specifies the filter for the estimated impact of the variants." | tee -a ${LOGFILE}
  echo "  If no impact to filter for type: ALL" | tee -a ${LOGFILE}
  echo "  Common impacts: HIGH MODERATE LOW MODIFIER" | tee -a ${LOGFILE}
  echo "  Several impact filters can be defined." | tee -a ${LOGFILE}
  
  echo "Usage:  quality_filter=<string>" | tee -a ${LOGFILE}
  echo "  where <string> specifies the filters used for the variant quality." | tee -a ${LOGFILE}
  echo "  If no filter used type: ALL" | tee -a ${LOGFILE}
  echo "  Common filters: PASS GATKstd LowQual" | tee -a ${LOGFILE}
  echo "  Several filters can be defined." | tee -a ${LOGFILE}
  exit 1
  
}


### check number of command line arguments
NUMARGS=$#
if [[ $NUMARGS -lt 1 ]] 
then
  echo "Number of arguments: $NUMARGS" | tee -a ${LOGFILE}
  usage 'No command line arguments specified - input parameterfile after calling the script.'
fi

### check that breed is not empty 
# -e checks if the file exists. if TRUE does the thing
if [[ ! -e ${vcf} ]]
then
    usage 'Input file does not exist!!'
fi

### check that header is defined TRUE or FALSE
# -z checks if the variable is empty
if [[ -z ${header} ]]
then
    usage 'Header occurence not defined.'
fi

### check if the output directory exists already
# -d checks if the diretory exists already
if [[ -d ${dir_output} ]]
then
    usage 'Output directory exists already!!'
fi
echo '...'

### check that output filename is defined
if [[ -z ${output_name} ]]
then
	usage  'No name of the output final is defined!!'
fi

### check that impact filter is set
if [[ -z ${impact} ]]
then
	usage  'No filter for the variant impact is defined!!'
fi
### check that quality filter is set
if [[ -z ${filter} ]]
then
	usage  'No filter for the variant quality is defined!!'
fi

### check that exclude_pseudogenes is set
if [[ -z ${exclude_pseudogenes} ]]
then
	usage  'No status for the pseudogenes defined!!'
fi
echo '...'

### check that genes and chromosomes are not used at the same time
if [[ ${gene} != "" && ${chr} != "" ]]
then
	usage 'You can not define a gene and a chromosome at the same time. Decide on what you want to run or do it in two different runs.'
fi

### check that chromosome is not longer than 1 when start or end are defined
NumberOfChromosomes=$(echo ${chr} | tr ' ' '\n' | wc -l )
if [[ ${start} != "" && ${NumberOfChromosomes} > 1 ]]
then
	usage 'You can not define more than one chromosome when looking into a region. Decide on one chromosome at a time or clear the end and/or start parameters.'
fi

if [[ ${end} != "" && ${NumberOfChromosomes} > 1 ]];
then
	usage 'You can not define more than one chromosome when looking into a region. Decide on one chromosome at a time or clear the end and/or start parameters.'
fi
echo '...'

### check that chromosome and start or end are defined
if [[ ${start} != "" && ${chr} == "" ]];
then
	usage 'You can not define a region without defining a chromosome. Please define one chromosome or clear the end and/or start parameters.'
fi

if [[ ${end} != "" && ${chr} == "" ]];
then
	usage 'You can not define a region without defining a chromosome. Please define one chromosome or clear the end and/or start parameters.'
fi
echo '...'

### check that start and end are defined correctly
if [[ ${start} != "" && ${end} == "" ]];
then
	usage 'You forgot to define the end of the region. Please define the end of the region.'
fi

if [[ ${end} != "" && ${start} == "" ]];
then
	usage 'You forgot to define the start of the region. Please define the start of the region.'
fi

if [[ ${rounded_start} -gt 500 || ${rounded_end} -gt 500 ]];
then
	usage 'The start or end positions seems extremely big. Please check if your input was truly in meagbase (MB). If your input is correct, please contact the program administrator (Irene Häfliger) directly.'
fi

echo '...'
echo '... maybe an even longer while ...'

### check if the defined chromosome could be correct
cut -f1 ${vcf} > chromosomes_temp
echo '...'

#check if chromosomes exists
for single_chromosome in ${chr}
do
	countChromosomeID=$(grep "${single_chromosome}$" chromosomes_temp | wc -l )
	
	if [[ ${countChromosomeID} -lt 1 ]];
	then
		usage "chromosome ${single_chromosome} was not found in the VCF. Please check if your if your name of the chromosome is the same as you have in the file."
	fi
	
done
rm -f chromosomes_temp
echo '...'

### check if the defined IDs could be correct
head -1 ${vcf} | awk '{print toupper($0)}' | tr ' ' '\t' > headerline_temp

## check if animals to be excluded are defined within targets
for excludeSingleAnimal in ${exclude_animals};
do
	#check if the animal appears in the targets
	count_excludeSingleAnimal=$( echo ${target} | tr ' ' '\n' | grep ${excludeSingleAnimal} | wc -l )
	# if yes, exclude the animal
	if [[ ${count_excludeSingleAnimal} -gt 0 ]];
	then
		echo ${target} | tr ' ' '\n' | grep -v ${excludeSingleAnimal} > new_target.temp
		target=$( cat new_target.temp | tr '\n' ' ' )
	fi
done

rm -f new_target.temp

### check if all target are there
for targetID in ${target};
do
	countTargetID=$( cat headerline_temp | tr '\t' '\n' | grep "${targetID}$"| wc -l )
	
	if [[ ${countTargetID} -lt 1 ]];
	then
   		usage "case ID ${targetID} was not found in the header line of the VCF. Please check if your ID is right."
	fi
	
done

### make the list if control is set to 'ALL'
if [[ ${control} == "ALL" ]];
then
	echo "You had chosen ALL animals as controls. The program will find out the control animals now."
	lengthHeaderTotal=$(cat headerline_temp | tr '\t' '\n' | wc -l  )
	echo number of columns in the header: ${lengthHeaderTotal}
	endControls=$(echo "${lengthHeaderTotal}-19" | bc)
	cut -f6-${endControls} headerline_temp | tr '\t' '\n' > controlIDs.list
	# exclude cases
	for single_cases in ${target};
	do
		grep -v "${single_cases}" controlIDs.list > controlIDs.temp
		mv controlIDs.temp controlIDs.list
	done
	
	## check if animals to be excluded are defined within targets
	for excludeSingleAnimal_two in ${exclude_animals};
	do
		#check if the animal appears in the targets
		count_excludeSingleAnimal_two=$( grep "${excludeSingleAnimal_two}" controlIDs.list | wc -l )
		# if yes, exclude the animal
		if [[ ${count_excludeSingleAnimal_two} -gt 0 ]];
		then
			grep -v "${excludeSingleAnimal_two}" controlIDs.list > controlIDs.temp
			mv controlIDs.temp controlIDs.list
		fi
	done
	
	control=$(cat controlIDs.list | tr '\n' ' ' )
	echo "The list of control animals is: ${control}"
else
	echo '...'
	### check if all controls are there
	for controlID in ${control}
	do
		countControlID=$( cat headerline_temp | tr '\t' '\n' | grep "${controlID}$"| wc -l | cut -d' ' -f1 )
	
		if [[ ${countControlID} -lt 1 ]];
		then
			usage "control ID ${controlID} was not found in the header line of the VCF. Please check if your ID is right."
		fi
	done
fi

echo '... almost there ...'
rm -f headerline_temp controlIDs.list
echo '...'

### check if controls have defined genotypes
if [[ ${control} != "" ]]
then
	if [[ ${control_genotypes} == "" ]]
	then
   		usage "You forgot to define the genotypes of the controls. Please define them."
	fi
	
fi
echo '...'

### check if cases have defined genotypes
if [[ ${target} != "" ]]
then
	if [[ ${target_genotypes} == "" ]]
	then
   		usage "You forgot to define the genotypes of the cases. Please define them."
	fi
	
fi
echo '... last check ... '

### check if case is also part of controls
if [[ ${target} != "" && ${control} != "" && ${control} != "ALL" ]];
then
	
	for single_target in ${target};
	do
	
		countTargetIDs_inCases=$( echo ${control} | tr ' ' '\n' | grep "${single_target}$"| wc -l )
	
		if [[ ${countTargetIDs_inCases} -gt 0 ]];
		then
   		usage "case ID ${single_target} was found in the list of cases. Please check if your IDs are right and make sure you select all the right animals."
		fi
	
	done
	
fi

echo 'Done!'
echo 'Well the checking is done... Now the program will actually start'


######
### make directory
rm -rf ${dir_output}
mkdir ${dir_output}
#copy the parameter file in the output
cp $1 ${dir_output}/
cd ${dir_output}



echo '###################################################' | tee -a ${LOGFILE}
echo '# You lucky bastard got a hand on my program!!!!! #' | tee -a ${LOGFILE}
echo '###################################################' | tee -a ${LOGFILE}

RIGHT_NOW=$(date +"%x %r %Z")
echo "${RIGHT_NOW}" | tee -a ${LOGFILE}

##############
### first part
#save headerline
echo "${vcf} input file used for selection" | tee -a ${LOGFILE}
if [[ ${header} == "TRUE" ]];
then
	head -1 ${vcf} | awk '{print toupper($0)}' | tr ' ' '\t'  > header.vcf
else
	echo "WARNING: The program will keep running." | tee -a ${LOGFILE}
	echo "Be aware that a header line in the .vcf-file is necessary for the filtering of target Animals!!" | tee -a ${LOGFILE}
	touch header.vcf
fi

#rough selection on the region / gene
if [[ ${gene} == "" ]];
then

	if [[ ${chr} == "" && ${start} == "" && ${end} == "" ]];
	then
		echo "The original file is being copied to the current working directory." | tee -a ${LOGFILE}
		echo "For your information: This is to make sure the original file is not going to be harmed in the next filtering steps.." | tee -a ${LOGFILE}
		cp ${vcf} variants_all.vcf 
		selection=variants_all.vcf
	elif [[ ${chr} != "" && ${start} == "" && ${end} == "" ]]
	then
		#make a selection of variants on the defined chromosome
		length=$(echo ${chr} | tr ' ' '\n' | wc -l )
		ChromosomeColumnNumber=$( cat header.vcf | tr '\t' '\n' | cat -n | grep 'CHROM' | cut -f1 | tr -d ' ' )
	
		echo "${length} chromosome/s are going to be processed" | tee -a ${LOGFILE}
		
		if [[ ${length} -eq 1 ]]
		then 
			#for one chromosome
			echo "extracts all variants of chromosome ${chr}" | tee -a ${LOGFILE}
			cat header.vcf > variants_${chr}.vcf
			awk -v columnChr=${ChromosomeColumnNumber} -v chromosome=${chr} '{ if ( $columnChr == chromosome ) print }' ${vcf}  >> variants_${chr}.vcf
			selection=variants_${chr}.vcf
		else
			#for several chromosomes
			echo ${chr} | tr ' ' '\n' > chromosomesDefined_temp
			echo "extracts all variants of the chromosomes ${chr}" | tee -a ${LOGFILE}
			cat header.vcf > variants_severalChromosomes.vcf
			rm -f variants_chromosomesDefined.vcf
			
			while read chromosomeNameSeveral
			do #loop over the included chromosomes
				awk -v columnChr=${ChromosomeColumnNumber} -v chromosome=${chromosomeNameSeveral} '{ if ( $columnChr == chromosome ) print }' ${vcf}  >> variants_chromosomesDefined.vcf
			done < chromosomesDefined_temp
			
			sort variants_chromosomesDefined.vcf | uniq >> variants_severalChromosomes.vcf
			
			rm -f chromosomesDefined_temp
			rm -f variants_chromosomesDefined.vcf
			
			selection=variants_severalChromosomes.vcf
		fi	
	else 
		#make a selection on a defined region on the chromosomes
		echo "extracts all variants of chromosome ${chr} in region from ${start} Mb to ${end} Mb " | tee -a ${LOGFILE}
		awk -v chr=${chr} -v s=${start} -v e=${end} 'BEGIN{s=s*1000000;e=e*1000000}{ if ( $1 == chr && $2 >= s && $2 <= e || NR == 1 ) print }' ${vcf} > variants_${chr}_${start}_${end}.vcf
		selection=variants_${chr}_${start}_${end}.vcf
	fi
else 
	#selects the variants of the defined genes
	#checks if there are mor than one genes
	length=$(echo ${gene} | tr ' ' '\n' | wc -l )
	echo "${length} gene/s are going to be processed" | tee -a ${LOGFILE}
	GeneColumnNumber=$( cat header.vcf | tr '\t' '\n' | cat -n | grep $'\tGENE$' | cut -f1 | tr -d ' ' )
	
	if [[ ${length} -eq 1 ]]
	then 
		echo "extracts all variants of the gene ${gene}" | tee -a ${LOGFILE}
		cat header.vcf > variants_${gene}.vcf
		# grep three times 1) ^${GENE}$ 2) ^${GENE}- 3) -${GENE}$
		# 1) exact match of the gene
		grep $'\t'${gene}$'\t' ${vcf} >> variants_${gene}.vcf
		# 2) match with - afterwards
		grep "${gene}-" ${vcf} >> variants_${gene}.vcf
		# 3) match with - infront
		grep "\-${gene}" ${vcf} >> variants_${gene}.vcf
		selection=variants_${gene}.vcf
		
	else
		echo ${gene} | tr ' ' '\n' > genesDefined_temp
		echo "extracts all variants of the genes ${gene}" | tee -a ${LOGFILE}
		cat header.vcf > variants_severalGenes.vcf
		rm -f genesDefinded_getVariants.vcf
		
		while read geneNameSeveral
		do #loop over the included genes
			# grep three times 1) ^${GENE}$ 2) ^${GENE}- 3) -${GENE}$
			# 1) exact match of the gene
			grep $'\t'${geneNameSeveral}$'\t' ${vcf} >> genesDefinded_getVariants.vcf
			# 2) match with - afterwards
			grep "${geneNameSeveral}-" ${vcf} >> genesDefinded_getVariants.vcf
			# 3) match with - infront
			grep "\-${geneNameSeveral}" ${vcf} >> genesDefinded_getVariants.vcf
		done < genesDefined_temp
		
		sort genesDefinded_getVariants.vcf | uniq >> variants_severalGenes.vcf 
		rm -f genesDefined_temp
		rm -f genesDefinded_getVariants.vcf
		selection=variants_severalGenes.vcf
	fi
	
fi

echo "subset restricted to region, chromosome or gene is prepared" | tee -a ${LOGFILE}

echo -e "\n" | tee -a ${LOGFILE}

sleep 5m

##############
### second part
# selection on general filters such as impact, filter and pseudogenes
# selection on impact of variant
lengthImpact=$(echo ${impact} | tr ' ' '\n' | wc -l )

if [[ ${impact} == "ALL" || ${impact} == "all" ]]
then
	cp ${selection} variants_noFilter.vcf
	selectionIIA=variants_noFilter.vcf
elif [[ ${lengthImpact} -eq 1 ]]
then 
	echo "extracts all variants of ${impact} impact" | tee -a ${LOGFILE}
	cat header.vcf > variants_${impact}.vcf
	grep $'\t'${impact}$'\t' ${selection} >> variants_${impact}.vcf
	selectionIIA=variants_${impact}.vcf
else
	echo "${impact} impact variants are going to be selected" | tee -a ${LOGFILE}
	echo ${impact} | tr ' ' '\n' > impactsDefined_temp
	echo "extracts all variants of the ${impact} impact" | tee -a ${LOGFILE}
	cat header.vcf > variants_severalImpacts.vcf
	rm -f variants_impactsDefined.vcf
	
	while read uniqueImpact 
	do #loop over the included genes
		grep $'\t'${uniqueImpact}$'\t' ${selection} >> variants_impactsDefined.vcf # grabs only the genes wanted
	done < impactsDefined_temp
	
	sort variants_impactsDefined.vcf | uniq >> variants_severalImpacts.vcf
	
	rm -f impactsDefined_temp 
	rm -f variants_impactsDefined.vcf

	selectionIIA=variants_severalImpacts.vcf
fi

#exclude pseudogenes

if [[ ${exclude_pseudogenes} == 'FALSE' || ${exclude_pseudogenes} == 'F' ]]
then
	cp ${selectionIIA} variants_withPseudo.vcf
	selectionIIB=variants_withPseudo.vcf
elif [[ ${exclude_pseudogenes} == 'TRUE' || ${exclude_pseudogenes} == 'T' ]]
then 
	echo "excludes all variants of pseudogenes" | tee -a ${LOGFILE}
	cat header.vcf > variants_wo_pseudogenes.vcf
	grep -v 'pseudogene' ${selectionIIA} >> variants_wo_pseudogenes.vcf
	selectionIIB=variants_wo_pseudogenes.vcf
else
	echo "ERROR: you did not properly define the state of pseudogenes" | tee -a ${LOGFILE}
	echo '#use TRUE if you want to exclude them and FALSE if you want to keep them' | tee -a ${LOGFILE}
fi

# selection on quality filter
lengthFilterQuality=$(echo ${filter} | tr ' ' '\n' | wc -l )

if [[ ${filter} == "ALL" || ${filter} == "all" ]]
then
	cp ${selectionIIB} variants_noFilter.vcf
	selectionIIC=variants_noFilter.vcf
elif [[ ${lengthFilterQuality} -eq 1 ]]
then 
	echo "extracts all variants of ${filter} quality standard" | tee -a ${LOGFILE}
	cat header.vcf > variants_${filter}.vcf
	grep ${filter} ${selectionIIB} >> variants_${filter}.vcf
	selectionIIC=variants_${filter}.vcf
else
	echo ${filter} | tr ' ' '\n' > filtersQualitiesDefined_temp
	echo "extracts all variants of the ${filter} filter" | tee -a ${LOGFILE}
	cat header.vcf > variants_severalFilters.vcf
	rm -f variants_filterQulaitiesDefined.vcf
	
	while read qualityFilterLine; 
	do #loop over the included genes
		grep ${qualityFilterLine} ${selectionIIB} >> variants_filterQulaitiesDefined.vcf # grabs only the genes wanted
	done < filtersQualitiesDefined_temp
	
	sort variants_filterQulaitiesDefined.vcf | uniq >> variants_severalFilters.vcf
	selectionIIC=variants_severalFilters.vcf
	
	rm -f filtersQualitiesDefined_temp 
	rm -f variants_filterQulaitiesDefined.vcf 
fi

mv ${selectionIIC} variants_generalFilters.vcf
selectionII=variants_generalFilters.vcf
rm -f ${selectionIIA} ${selectionIIB}

echo "subset based on general filters saved as ${dir_output}/${selectionII}" | tee -a ${LOGFILE}
echo -e "\n" | tee -a ${LOGFILE}


sleep 5m

##############
### third part
##
# selection on target animals
lengthHeaderFile=$( wc -l header.vcf  | cut -d' ' -f1 )
if [[ ${lengthHeaderFile} == 0 ]];
then
	echo "ERROR: header is missing!! No analysis of target animals is possible." | tee -a ${LOGFILE}
	echo "the program terminates now." | tee -a ${LOGFILE}
	exit 2
fi

lengthTargets=$(echo ${target} | tr ' ' '\n' | wc -l )

if [[ ${target} == "" ]]
then
	echo "no animals had been selected as cases" | tee -a ${LOGFILE}
	cp ${selectionII} variants_partTwo_noTarget.vcf
	selectionIIIA=variants_partTwo_noTarget.vcf
	target_genotypes=""
	
#one target animal
elif [[ ${lengthTargets} -eq 1 ]]
then
	echo "variants of ${target} are going to be analysed based on the genotypes ${target_genotypes}" | tee -a ${LOGFILE}
	col=$( cat header.vcf | tr '\t' '\n' | cat -n | grep ${target} | awk '{print $1}' )
	#no target genotype
	lengthTargetGenotypes=$(echo ${target_genotypes} | tr ' ' '\n' | wc -l )
	if [[ ${target_genotypes} == "" ]]
	then
		cp ${selectionII} variants_partTwo_noTarget.vcf
		selectionIIIA=variants_partTwo_noTarget.vcf
		echo "WARNING no genotypes had been defined for the cases" | tee -a ${LOGFILE}
	else
	# check for several genotypes
		cat header.vcf > variants_${target}.vcf
		echo ${target_genotypes} | tr ' ' '\n' > definedTargetGenotypes_temp
		rm -f variants_definedTargetGenotypes.vcf
		while read line;
		do #loop over genotypes
			awk -v t=${col} -v g=${line} '{if ( $t == g ) print }' ${selectionII} >> variants_definedTargetGenotypes.vcf
		done < definedTargetGenotypes_temp
		sort variants_definedTargetGenotypes.vcf | uniq >> variants_${target}.vcf

		selectionIIIA=variants_${target}.vcf
		
		rm -f definedTargetGenotypes_temp
		rm -f variants_definedTargetGenotypes.vcf
	fi
	
#several target animals
else
	#get a file with the columns to be analysed
	echo "variants of ${target} are going to be anaylased based on the target genotypes ${target_genotypes}" | tee -a ${LOGFILE}
	echo ${target} | tr ' ' '\n' > definedTargets_temp
	cat header.vcf | tr '\t' '\n' | cat -n | sort -k2,2 | join -o'1.1' -1 2 -2 1 - <(sort -k1,1 definedTargets_temp) > positionsOfDefinedTargets_temp
	echo ${target_genotypes} | tr ' ' '\n' > definedTargetsGenotypes_temp
	cat header.vcf > variants_sevTar.vcf
	cat ${selectionII} > tempfile_ExcludingNotWantedVariants.vcf
	subset=tempfile_ExcludingNotWantedVariants.vcf
	
	while read columns
	do
		rm -f temporaryFile_ToBeExcludedMoreVariants.vcf
		while read genotype
		do
			awk -v t=${columns} -v g=${genotype} '{if ( $t == g ) print }' ${subset} >> temporaryFile_ToBeExcludedMoreVariants.vcf
		done < definedTargetsGenotypes_temp
		mv temporaryFile_ToBeExcludedMoreVariants.vcf tempfile_ExcludingNotWantedVariants.vcf
	done < positionsOfDefinedTargets_temp
	
	sort tempfile_ExcludingNotWantedVariants.vcf | uniq >> variants_sevTar.vcf
	selectionIIIA=variants_sevTar.vcf
	
	rm -f definedTargets_temp
	rm -f definedTargetsGenotypes_temp
	rm -f positionsOfDefinedTargets_temp
	rm -f temporaryFile_ToBeExcludedMoreVariants.vcf
	rm -f tempfile_ExcludingNotWantedVariants.vcf

fi

sleep 5m

##
# selection on control animals
lengthControls=$(echo ${control} | tr ' ' '\n' | wc -l )

if [[ ${control} == "" ]]
then
	selectionIIIB=${selectionIIIA}
	echo "no control animals had been selected" | tee -a ${LOGFILE}
	control_genotypes=""
	
#one control animal
elif [[ ${lengthControls} -eq 1 ]]
then
	echo "variants of ${control} are going to be anaylased based on the control genotypes ${control_genotypes}" | tee -a ${LOGFILE}
	col=$( cat header.vcf | tr '\t' '\n' | cat -n | grep ${control} | awk '{print $1}' )
	
	#no control genotype
	lengthControlsGenotypes=$(echo ${control_genotypes} | tr ' ' '\n' | wc -l )
	
	if [[ ${control_genotypes} == "" ]]
	then
		selectionIIIB=${selectionIIIA}
		echo "No control genotypes had been selected" | tee -a ${LOGFILE}
	else
	# check for several genotypes
		cat header.vcf > variants_${control}.vcf
		echo ${control_genotypes} | tr ' ' '\n' > definedControlGenotypes_temp
		rm -f variants_definedControlsGenotypes.vcf
		
		while read genotype;
		do #loop over genotypes
			awk -v t=${col} -v g=${genotype} '{if ( $t == g ) print }' ${selectionIIIA} >> variants_definedControlsGenotypes.vcf
		done < definedControlGenotypes_temp

		sort variants_definedControlsGenotypes.vcf | uniq >> variants_${control}.vcf
		
		selectionIIIB=variants_${control}.vcf
		
		rm -f definedControlGenotypes_temp
		rm -f variants_definedControlsGenotypes.vcf
		
	fi
	
#several control animals
else
	#get a file with the columns to be analysed
	echo "variants of ${control} are going to be analysed based on the control genotypes ${control_genotypes}" | tee -a ${LOGFILE}
	echo ${control} | tr ' ' '\n' > definedControls_temp
	cat header.vcf | tr '\t' '\n' | cat -n | sort -k2,2 | join -o'1.1' -1 2 -2 1 - <(sort -k1,1 definedControls_temp) > definedControlsColumns_temp
	echo ${control_genotypes} | tr ' ' '\n' > definedControlsGenotypes_temp
	cat header.vcf > variants_sevCon.vcf
	cat ${selectionIIIA} > variants_ExcludingNonControlsGenotypes_temp
	subset=variants_ExcludingNonControlsGenotypes_temp
	
	while read columns
	do
		rm -f temporaryFile_variantsWillBeExcludedFromThisFile.vcf
		
		while read genotype
		do
			awk -v t=${columns} -v g=${genotype} '{if ( $t == g ) print }' ${subset} >> temporaryFile_variantsWillBeExcludedFromThisFile.vcf
		done < definedControlsGenotypes_temp
		
		cp temporaryFile_variantsWillBeExcludedFromThisFile.vcf variants_ExcludingNonControlsGenotypes_temp
	done < definedControlsColumns_temp
	
	sort variants_ExcludingNonControlsGenotypes_temp | uniq >> variants_sevCon.vcf
	selectionIIIB=variants_sevCon.vcf
	
	rm -f definedControls_temp
	rm -f definedControlsColumns_temp
	rm -f definedControlsGenotypes_temp
	rm -f variants_ExcludingNonControlsGenotypes_temp
	rm -f temporaryFile_variantsWillBeExcludedFromThisFile.vcf
	
fi

OUTPUT=$(echo "${output_name}")
cp ${selectionIIIB} ${OUTPUT}
selectionIII=${OUTPUT}
rm -f ${selectionIIIA} 
rm -f ${selectionIIIB} 


sleep 5m

##############
### final remarks, tidy up and report
rm -f header.vcf

echo -e "\n" | tee -a ${LOGFILE}
echo "program finished." | tee -a ${LOGFILE}
echo "final selection stored in ${dir_output}/ as ${selectionIII} " | tee -a ${LOGFILE}
echo -e "\n" | tee -a ${LOGFILE}
echo '# you selected the following filters defining a region:' | tee -a ${LOGFILE}

#check gene filter
if [[ ${gene} == "" ]]
then
	echo "- no filter for genes were used" | tee -a ${LOGFILE}
else
	echo "- Genes filtered for: ${gene}" | tee -a ${LOGFILE}
fi

#check chromosome filter
if [[ ${chr} == "" ]]
then
	echo "- no filter for chromosomes were used" | tee -a ${LOGFILE}
else
	echo "- Chromosomes filtered for: ${chr}" | tee -a ${LOGFILE}
fi

#check region within chromosome
if [[ ${start} == "" && ${end} == "" ]]
then
	echo "- no filter for regional limiting were used" | tee -a ${LOGFILE}
else
	echo "- Region filtered for: ${start} - ${end} Mb" | tee -a ${LOGFILE}
fi

numberLinesPartOne=$( wc -l ${selection} | cut -d' ' -f1 )
numberVariantsPartOne=$( echo "${numberLinesPartOne}-1" | bc )
echo "Number of variants after regional filtering:" | tee -a ${LOGFILE}
echo ${numberVariantsPartOne} | tee -a ${LOGFILE}

rm ${selection}


echo -e "\n" | tee -a ${LOGFILE}
echo '# you selected the following general filters:' | tee -a ${LOGFILE}

#check quality filter
if [[ ${filter} == "" ]]
then
	echo "- no quality filter was used" | tee -a ${LOGFILE}
else
	echo "- Quality filter: ${filter}" | tee -a ${LOGFILE}
fi

#check variant impact filter
if [[ ${impact} == "" ]]
then
	echo "- no filter for the variant impact was used" | tee -a ${LOGFILE}
else
	echo "- Variant impact filter: ${impact}" | tee -a ${LOGFILE}
fi

numberLinesPartTwo=$( wc -l ${selectionII} | cut -d' ' -f1 )
numberVariantsPartTwo=$( echo "${numberLinesPartTwo}-1" | bc )
echo "Number of variants after general filtering:" | tee -a ${LOGFILE}
echo ${numberVariantsPartTwo} | tee -a ${LOGFILE}

rm ${selectionII}

echo -e "\n" | tee -a ${LOGFILE}
echo '# you selected the filter parameters on individuals:' | tee -a ${LOGFILE}

#check target animals
if [[ ${target} == "" ]]
then
	echo "- no animals were selected to select for as cases" | tee -a ${LOGFILE}
else
	echo "- Selected animals as cases were: ${target}" | tee -a ${LOGFILE}
fi

#check target genotype
if [[ ${target_genotypes} == "" && ${target} != "" ]]
then
	echo "- no genotypes for the cases were defined" | tee -a ${LOGFILE}
elif [[ ${target_genotypes} != "" && ${target} != ""  ]]
then
	echo "- Suspected genotypes of cases animals is: ${target_genotypes}" | tee -a ${LOGFILE}
fi

#check control animals
if [[ ${control} == "" ]]
then
	echo "- no animals were selected to take as controls" | tee -a ${LOGFILE}
else
	echo "- Selected animals for controls were: ${control}" | tee -a ${LOGFILE}
fi

#check control genotype
if [[ ${control_genotypes} == "" && ${control} != "" ]]
then
	echo "- no genotypes for the control animals were defined!" | tee -a ${LOGFILE}
elif [[ ${control_genotypes} != "" && ${control} != "" ]]
then
	echo "- Suspected genotypes of control animals are: ${control_genotypes}" | tee -a ${LOGFILE}
fi

#check excluded animals
if [[ ${exclude} == "" ]]
then
	echo "- no animals were selected to be excluded from the analysis" | tee -a ${LOGFILE}
else
	echo "- Selected animals to be excluded from the analysis were: ${exclude}" | tee -a ${LOGFILE}
fi

numberLinesPartThree=$( wc -l ${selectionIII} | cut -d' ' -f1 )
numberVariantsPartThree=$( echo "${numberLinesPartThree}-1" | bc )
echo "Number of variants after final filtering of target and control animals:" | tee -a ${LOGFILE}
echo ${numberVariantsPartThree} | tee -a ${LOGFILE}
echo -e "\n" | tee -a ${LOGFILE}


RIGHT_NOW=$(date +"%x %r %Z") 
echo "${RIGHT_NOW}" | tee -a ${LOGFILE}

echo '#########################' | tee -a ${LOGFILE}
echo '# Hasta la vista, Baby! #' | tee -a ${LOGFILE}
echo '#########################' | tee -a ${LOGFILE}


