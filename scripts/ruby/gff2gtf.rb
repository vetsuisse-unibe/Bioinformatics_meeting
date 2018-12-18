#!/software/bin/ruby

=begin
   
 This script is used to convert gff format for genes to gtf format.

 contact = Vidhya.Jagannathan@vetsuisse.unibe.ch
#input Example 
##gff-version 3
#!gff-spec-version 1.21
#!processor NCBI annotwriter
#!genome-build CanFam3.1
#!genome-build-accession NCBI_Assembly:GCF_000002285.3
#!annotation-date 17 September 2015
#!annotation-source NCBI Canis lupus familiaris Annotation Release 104
##sequence-region NC_006583.3 1 122678785
##species https://www.ncbi.nlm.nih.gov/Taxonomy/Browser/wwwtax.cgi?id=9615
1       RefSeq  region  1       122678785       .       +       .       ID=id0;Dbxref=taxon:9615;Name=1;breed=boxer;chromosome=1;gbkey=Src;genome=chromosome;mol_type=genomic DNA;sex=female;sub-species=familiaris
1       Gnomon  gene    251990  322081  .       -       .       ID=gene0;Dbxref=GeneID:100856150;Name=ENPP1;gbkey=Gene;gene=ENPP1;gene_biotype=protein_coding
1       Gnomon  mRNA    251990  322081  .       -       .       ID=rna0;Parent=gene0;Dbxref=GeneID:100856150,Genbank:XM_003638785.2;Name=XM_003638785.2;gbkey=mRNA;gene=ENPP1;product=ectonucleotide pyrophosphatase/phosphodiesterase 1%2C transcript variant X2;transcript_id=XM_003638785.2
1       Gnomon  exon    321851  322081  .       -       .       ID=id1;Parent=rna0;Dbxref=GeneID:100856150,Genbank:XM_003638785.2;gbkey=mRNA;gene=ENPP1;product=ectonucleotide pyrophosphatase/phosphodiesterase 1%2C transcript variant X2;transcript_id=XM_003638785.2
1       Gnomon  exon    289674  289746  .       -       .       ID=id2;Parent=rna0;Dbxref=GeneID:100856150,Genbank:XM_003638785.2;gbkey=mRNA;gene=ENPP1;product=ectonucleotide pyrophosphatase/phosphodiesterase 1%2C transcript variant X2;transcript_id=XM_003638785.2
1       Gnomon  exon    287787  287903  .       -       .       ID=id3;Parent=rna0;Dbxref=GeneID:100856150,Genbank:XM_003638785.2;gbkey=mRNA;gene=ENPP1;product=ectonucleotide pyrophosphatase/phosphodiesterase 1%2C transcript variant X2;transcript_id=XM_003638785.2
   
#output Example

1       Gnomon  exon    321851  322081  .       -       .       transcript_id "XM_003638785.2"; gene_id "100856150"; gene_name "ENPP1";
1       Gnomon  exon    289674  289746  .       -       .       transcript_id "XM_003638785.2"; gene_id "100856150"; gene_name "ENPP1";
1       Gnomon  exon    287787  287903  .       -       .       transcript_id "XM_003638785.2"; gene_id "100856150"; gene_name "ENPP1";
1       Gnomon  exon    286842  286967  .       -       .       transcript_id "XM_003638785.2"; gene_id "100856150"; gene_name "ENPP1";
1       Gnomon  exon    285904  285964  .       -       .       transcript_id "XM_003638785.2"; gene_id "100856150"; gene_name "ENPP1";
1       Gnomon  exon    283862  283959  .       -       .       transcript_id "XM_003638785.2"; gene_id "100856150"; gene_name "ENPP1";
1       Gnomon  exon    281894  281973  .       -       .       transcript_id "XM_003638785.2"; gene_id "100856150"; gene_name "ENPP1";
1       Gnomon  exon    280770  280889  .       -       .       transcript_id "XM_003638785.2"; gene_id "100856150"; gene_name "ENPP1";
1       Gnomon  exon    279595  279704  .       -       .       transcript_id "XM_003638785.2"; gene_id "100856150"; gene_name "ENPP1";
1       Gnomon  exon    278628  278693  .       -       .       transcript_id "XM_003638785.2"; gene_id "100856150"; gene_name "ENPP1";
1       Gnomon  exon    278245  278317  .       -       .       transcript_id "XM_003638785.2"; gene_id "100856150"; gene_name "ENPP1";
1       Gnomon  exon    275918  276026  .       -       .       transcript_id "XM_003638785.2"; gene_id "100856150"; gene_name "ENPP1";

#command 
ruby gff2gtf.rb -i genes.gff3 
=end

# Parse command Line options 
require 'optparse'

options = {}
OptionParser.new do |parser|
  parser.banner = "Usage: hello.rb [options]"
  parser.on("-i", "--input GFF3 FILE", "Name of the input GFF3 file.") do |v|
    options[:input] = v
  end
  parser.on("-h", "--help", "Show this help message") do ||
    puts parser
  end
end.parse!

# get the Hash with parent ID

geneIdHash = Hash.new
transcriptidHash = Hash.new
geneNameHash = Hash.new

# input file 
infile=options[:input]

i=0
File.open(infile).each do | line| 
  if (line !~ /^#/)
    tmp = line.strip.split(/\t/)
    if (tmp[2] =~ /exon/)
      parentID = tmp[-1].split('Parent=')[-1].split(';')[0]
      line =~ /GeneID:(\d+)/
      geneID = $1
      line =~ /transcript_id=(\S+)/
      transcriptID = $1
      if (transcriptID.to_s.empty?)
        transcriptID = geneID
      end
      line =~ /gene=(.*?);/
      geneName = $1
      if (geneName.to_s.empty?)
        geneName = geneID
      end
      #print parentID, "\t", geneID, "\t", transcriptID, "\t", geneName, "\n"
      geneIdHash[parentID] = geneID
      transcriptidHash[parentID] = transcriptID
      geneNameHash[parentID] = geneName
    end
  end
  
end 

File.open(infile).each do | line| 
   if (line !~ /^#/)
      tmp = line.strip.split(/\t/)
      if (tmp[2] =~ /exon|CDS/)
        print line.rpartition(/\t/).first
        parentID = tmp[-1].split('Parent=')[-1].split(';')[0]
        print "\t", "transcript_id", " ", "\"", transcriptidHash[parentID], "\"", "; ", "gene_id", " ", "\"", geneIdHash[parentID], "\"","; ", "gene_name", " ", "\"",geneNameHash[parentID], "\"", "; ", "\n"
      end
  end

end
