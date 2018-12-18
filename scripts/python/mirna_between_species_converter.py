#Input list with miRNA names to convert
miRNA_list = '/Users/matthias/Downloads/blast_homologous_mirnas/mirnames_filtered.txt'

#list of mature mirnas from mirbase, in this case from horse
horse_mirbase_mature_fasta = '/Users/matthias/Downloads/blast_homologous_mirnas/eca_mirnas_mature.fa'

import re
def get_sequence(mirbase_id):
    # This function extracts the header and the specific sequence in fasta format from a big fasta file
    with open(horse_mirbase_mature_fasta) as x:
        for line in x:
            mirbase=mirbase_id+" "
            if mirbase in line:
                fasta_mirna=(line+next(x))
                return fasta_mirna

def blast_mirna(mirna_fasta):
    #This function blasts the input fasta miRNA sequence (mature in this case)
    file = open("mirna_seq.fa", "w+")
    file.write(mirna_fasta)
    file.close()
    bashCommand = "blastn -query mirna_seq.fa -db database_mature_hsa -task blastn-short -word_size 4 -dust no -soft_masking false -evalue 0.01"
    import subprocess
    process = subprocess.Popen(bashCommand.split(), stdout=subprocess.PIPE,universal_newlines=True)
    output, error = process.communicate()
    file = open("blast_output.fa", "w+")
    #output=print(str(output).replace('\\n', '\n'))
    file.write(str(output))
    file.close()
    return output

def get_line_of_interest(string,eca_mirna):
    #takes a multi-line string and looks for the best hit using a regex.
    #First the mirna name is processed to be used in the regex: input format: eca-miR-X[abcdef]-3p|5p?
    #Desired full format for regex: miR-X[abcdef]
    #Desired stripped format for regex: miR-107 (no [abcdef] or -3p -5p etc.)
    #However full hits will be prioritized over stripped hits
    print("entering get_line_of_interest")
    print(eca_mirna)
    m = re.search('eca-([miRlet]+-[0-9]+).*', eca_mirna)
    if m:
        mirna_stripped = m.group(1)
    #now the full regex
    m = re.search('eca-([miRlet]+-[0-9]+[abcdefghijk]?).*', eca_mirna)
    if m:
        mirna_full= m.group(1)
    list=string.split("\n")
    matchFound=False
    line_of_interest=''
    regex_full = r"(.*)" + re.escape(mirna_full) + r"([abcd]?[-5p]?[-3p]?)"
    regex_stripped= r"(.*)" + re.escape(mirna_stripped) + r"([-5p]?[-3p]?)"
     #first look for full match in whole list of hits
    for element in list:
        if re.match(regex_full,element):
            line_of_interest=element
            matchFound=True
            break
    #if no full match found look for stripped match (e.g. miR-107 instead of miR-107b-3p)
    if matchFound == False:
        for element in list:
            if re.match(regex_stripped, element):
                line_of_interest=element
                matchFound=True
                break
    if matchFound==False:
        #if no regex was able to find a hit, just take the first hit as default
        line_of_interest=list[1]
        return line_of_interest
    else:
        return line_of_interest


def extract_blast_hits(mirna):
    with open("blast_output.fa") as x:
        #alignment = eval = ident = gaps = mirna_name = "NA"
        inRecordingMode=False
        res=''
        for line in x:
            if not inRecordingMode:
                if line.startswith('Sequences producing'):
                    inRecordingMode = True
            elif (inRecordingMode == True) and (line.startswith('>')):
                inRecordingMode = False
            else:
                res+=line
        res2=re.sub("\n\s*\n*", "\n", res)
        line_of_interest=get_line_of_interest(res2,mirna)
        return line_of_interest

def extract_alignment_section(tophit_line):
    list=tophit_line.split()
    mrna=list[0]
    mrna='>'+mrna
    with open("blast_output.fa") as x:
        inRecordingMode=False
        res=''
        for line in x:
            if not inRecordingMode:
                if line.startswith(mrna):
                    inRecordingMode = True
            elif (inRecordingMode == True) and (line.startswith('>')):
                inRecordingMode = False
            elif inRecordingMode==True:
                res+=line

        res2=re.sub("\n\s*\n*", "\n", res)
        return res2

def process_blast_output(mirna):
    #This function extracts the top hit together with key statistics like evalue, gaps and matches.
    no_hits_found=False
    print("Starting process_blast_output")
    with open("blast_output.fa") as x:
        for line in x:
            if "No hits found" in line:
                no_hits_found=True
                break
        if no_hits_found == True:
            result = ["NA","NA","NA","NA","NA"]
            return result
        else:
            blast_top_hit=extract_blast_hits(mirna)
            word_list = blast_top_hit.split()
            mirna_name = word_list[0]
            eval = word_list[6]
            # Now get other key statistics including ident., gaps and alignment:
            res2=extract_alignment_section(blast_top_hit)
            list_alignment=res2.split("\n")
            identity=list_alignment[2].split(",")[0]
            gaps=list_alignment[2].split(",")[1]
            alignment = list_alignment[4]+list_alignment[5]+list_alignment[6]
            result=[mirna_name,eval,identity,gaps,alignment]
            return result



def main():
    import os
    with open(miRNA_list) as f:
        os.remove("Mirna_converter_output.txt")
        os.remove("Mirna_conversion_table.txt")
        os.remove("Mirna_conversion_table_noNA.txt")
        x = open("Mirna_converter_output.txt", "w+")
        y = open("Mirna_conversion_table.txt", "w+")
        z = open("Mirna_conversion_table_noNA.txt", "w+")
        mirna_list = f.read().splitlines()
        x.write("Output Structure:\n")
        x.write("[human homolougus miRNA; mirbase ID, e-value, identities, gaps, alignment]\n")
        x.write("-----------------------------------------------------------------------------------------------------------------\n")
        y.write("input miRNA\thuman homologous mirna\n")
        count_non_NA = 0
        count_total=0
        for mirna in mirna_list:
            #loop over every miRNA and blast it and process the results
            x.write(mirna+"\n")
            seq=get_sequence(mirna)
            blast_mirna(seq)
            result_list=process_blast_output(mirna)
            x.write(str(result_list)+"\n")
            x.write("-----------------------------------------------------------------------------------------------------------------\n")
            y.write(mirna+"\t"+result_list[0]+"\n")
            if result_list[0] != "NA":
                z.write(mirna + "\t" + result_list[0] + "\n")
                count_non_NA+=1
            os.remove("blast_output.fa")
            count_total+=1
        x.close()
        y.close()
        print("Total of "+str(count_total)+" miRNAs processed. \nFor "+str(count_non_NA)+" mirnas a high confidence homologous miRNA was found!")
main()
