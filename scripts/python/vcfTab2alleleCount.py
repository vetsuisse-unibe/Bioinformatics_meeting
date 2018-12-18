#!/usr/local/bin/python3

''' 
The script converts the table produced with VarinatsToTable (GATK) to major and minor alleles.

# Example input:
CHROM   POS     REF     APZ001.GT       APZ002.GT       APZ003.GT       APZ004.GT       APZ005.GT       APZ015.GT       APZ017.GT       APZ048.GT       APZ061.GT       APZ062.GT       APZ070.GT
       APZ071.GT       APZ072.GT       APZ073.GT       APZ074.GT       APZ075.GT       APZ076.GT       APZ077.GT       APZ078.GT       APZ079.GT       APZ080.GT       APZ081.GT       APZ082.GT
       APZ083.GT
CM004562.1      5802    C       C/C     C/G     C/C     C/C     C/C     C/C     C/C     C/C     C/C     C/G     C/G     C/C     G/G     C/C     C/C     C/G     C/C     C/C     C/C     C/C     C/C
     C/C     C/C     C/G
CM004562.1      5969    C       C/G     C/G     C/G     C/C     C/G     C/C     C/C     C/G     C/G     C/G     C/C     C/G     C/C     C/G     G/G     C/C     C/C     C/C     C/C     C/G     C/C
     C/C     C/G     C/G

# Example output: 
#CHR    POS     REF     major_allele    minor_allele
CM004562.1      5802    C       C       G       41      7
CM004562.1      5969    C       C       G       34      14
CM004562.1      6033    C       C       G       38      10
CM004562.1      6171    AC      AC      A       26      22
CM004562.1      6357    C       C       G       40      8
CM004562.1      6888    A       G       -       48      0


# vidhya.jagannathan@vetsuisse.unibe.CHROM

'''
########## modules ###### 
import vcf # my custom module 
import collections # for counting

parser=vcf.CommandLineParser()
parser.add_argument('-i','--input',help="Name of the input file",type=str,required=True)
parser.add_argument('-o','--output',help="Name of the output fike",type=str,required=True)
args=parser.parse_args()

#######################functions#############
def all_same(items):
    return all(x==items[0] for x in items[1:])

#################main program###############
counter =0
outfile = open(args.output,'w')
outfile.write("#CHR\tPOS\tREF\tmajor_allele\tminor_allele\tmajorAlleleCount\tminorAlleleCount\n")
print('Opening the file ...')

with open(args.input) as datafile:
    header_line = datafile.readline()
    
    for line in datafile:
        var = line.split()
        metaInfo=var[0:3]
        metaInfo ='\t'.join(str(e) for e in metaInfo)
        

        GT=var[3:]
        #alleles = vcf.alleleCount(GT)
        allelesSplit =[x.split('/') for x in GT]
        # convert 2D array to 1D array
        AllallesN = [i for e in allelesSplit for i in e]
        
        if '.' in AllallesN:
            Allalles = [x for x in AllallesN if x != '.']
        else:
            Allalles=AllallesN

            numAl = collections.Counter(Allalles)
            numAlV = numAl.values()
            numAlM=numAl.most_common()
            
            if all_same(Allalles): # no variation
                
                minorAllele="0"
                majorAllele=numAlM[0][1]
                outfile.write("%s\t%s\t-\t%s\t%s\n" % (metaInfo,Allalles[0],majorAllele,minorAllele))
            elif all_same(list(numAlV)):
                Alcomm = [i[0] for i in numAlM]
                AlcommP = '\t'.join(str(e) for e in Alcomm)
                alleleCount=list(numAlV)
                alleleCount='\t'.join(str(e) for e in alleleCount)
                outfile.write("%s\t%s\t%s\n" % (metaInfo, AlcommP,alleleCount))
            elif (len(numAlV)==3) and (numAlM[0][1]==numAlM[1][1]):
                Alcomm = [i[0] for i in numAlM[0:2]]
                AlcommP = ','.join(str(e) for e in Alcomm)
                outfile.write("%s\t%s\t%s\n" % (metaInfo, AlcommP, numAlM[2][0]))
            else:
                Alrare = [i[0] for i in numAlM[1:]]
                AlrareP = ','.join(str(e) for e in Alrare)
                alleleCount=list(numAlV)
                alleleCount=sorted(alleleCount,reverse=True)
                alleleCount='\t'.join(str(e) for e in alleleCount)
                outfile.write("%s\t%s\t%s\t%s\n" % (metaInfo, numAlM[0][0], AlrareP,alleleCount))
            counter +=1
            if counter % 1000000 == 0:
                print(str(counter),"lines processed")
    
    datafile.close()
    outfile.close()
    print('Done!')
            
            