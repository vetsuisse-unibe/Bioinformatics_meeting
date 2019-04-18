## QUESTION: IS SSC29 THE MOTHER OF SSC28 AND SSC006?? 
##

# skript to anlyse the inheritance of translocated parts
# written 16.8.2018 
# by Irene H??fliger


# plot coverage of bam files chromosome wide
#setwd("G:/IGEH/IRENE/004_pig/0042_abormalitiesOffspringWilly_cleftpalate")
setwd("~/Desktop/0042_Willy/prove_trisomy")
getwd()

path_data <- "~/Desktop/0042_Willy/prove_trisomy/SNPchip_data"
#path_data <- "G:/IGEH/IRENE/004_pig/0042_abormalitiesOffspringWilly_cleftpalate/SNPchip_data/"
path_output <- "~/Desktop/0042_Willy/prove_trisomy/output_families"
#path_output <- "G:/IGEH/IRENE/004_pig/0042_abormalitiesOffspringWilly_cleftpalate/prove_trisomy/"

#load data
#prepare data of chr14
data_ped_chr8 <- read.table(paste(path_data,"/85Pigs_Sscrofa11.1_chr8_2.ped",sep=""),sep=" ", header=F, na.strings="00")
head(data_ped_chr8)[1:10]
data_map_chr8 <- read.table(paste(path_data,"/85Pigs_Sscrofa11.1_chr8.map",sep=""),sep="\t", header=F, na.strings="00")
head(data_map_chr8)

#prepare data of chr14
data_ped_chr14 <- read.table(paste(path_data,"/85Pigs_Sscrofa11.1_chr14_2.ped",sep=""),sep=" ", header=F, na.strings="00")
head(data_ped_chr14)[1:10]
data_map_chr14 <- read.table(paste(path_data,"/85Pigs_Sscrofa11.1_chr14.map",sep=""),sep="\t", header=F, na.strings="00")
head(data_map_chr14)

# allele frequency data
allelefrequencies <- read.csv("~/Desktop/0042_Willy/prove_trisomy/workingfiles/plottingfile.csv",sep=",",na.strings="00")

#define the regions
CHR8 <- c(0,138966237)
BREAK_CHR8 <- c(25854180,25855619)
deletion <- c(8,0,25854180)
CHR14 <- c(0,141755446)
BREAK_CHR14 <- c(109709516,109710060)
CHROMOSOMES <- c("8","14")
duplication <- c(14,109710060,141755446)

families <- list( c("SSC040","SSC029","SSC006","SSC016","SSC027","SSC028")
                  ,c("SSC040","SSC031","SSC001","SSC002","SSC017","SSC018")
                  ,c("SSC040","SSC032","SSC009","SSC010","SSC011","SSC024")
                  ,c("SSC040","SSC033","SSC012","SSC021","SSC022")
                  ,c("SSC040","SSC034","SSC007","SSC008","SSC015","SSC019","SSC020")
                  ,c("SSC040","SSC030","SSC003","SSC025","SSC026")
                  )

titles <- list( c("father","mother","affected","affected","non-affected","non-affected")
                  ,c("father","mother","affected","affected","non-affected","non-affected")
                  ,c("father","mother","affected","affected","affected","non-affected")
                  ,c("father","mother","affected","non-affected","non-affected")
                  ,c("father","mother","affected","affected","affected","non-affected","non-affected")
                  ,c("father","mother","affected","non-affected","non-affected")
)

for (family in 1:length(families)) {
  animals_of_interest <- families[[family]]

  individuals_chr8<- data_ped_chr8[,2]
  rows_chr8 <- animals_of_interest
  for (animal in 1:length(animals_of_interest)){
    rows_chr8[animal] <- which(individuals_chr8 == animals_of_interest[animal])
  }

  data_ped_chr8_ofInterest <- data_ped_chr8[rows_chr8,]
  rownames(data_ped_chr8_ofInterest) <- data_ped_chr8_ofInterest[,2]
  t_data_ped_chr8_ofInterest <- t(data_ped_chr8_ofInterest[,8:ncol(data_ped_chr8_ofInterest)])
  colnames(t_data_ped_chr8_ofInterest) <- rownames(data_ped_chr8_ofInterest)

  individuals_chr14<- data_ped_chr14[,2]
  rows_chr14 <- animals_of_interest
  for (ani in 1:length(animals_of_interest)){
    rows_chr14[ani] <- which(individuals_chr14 == animals_of_interest[ani])
  }

  data_ped_chr14_ofInterest <- data_ped_chr14[rows_chr14,]
  rownames(data_ped_chr14_ofInterest) <- data_ped_chr14_ofInterest[,2]
  t_data_ped_chr14_ofInterest <- t(data_ped_chr14_ofInterest[,8:ncol(data_ped_chr14_ofInterest)])
  colnames(t_data_ped_chr14_ofInterest) <- rownames(data_ped_chr14_ofInterest)
  
  ###############
  ### DELETION
  parents <- c(animals_of_interest[1],animals_of_interest[2])
  offspring <- c(animals_of_interest[-(1:2)])
  SNPcombination <- c("AA","CC","TT","GG")

  ## subset the data from the duplication
  SNPs_deletion <- which(data_map_chr8[,4] < deletion[3] & data_map_chr8[,4] >= deletion[2])
  data_ped_chr8_ofInterest_SNPs <- t_data_ped_chr8_ofInterest[SNPs_deletion,]
  data_map_chr8_t1 <- data_map_chr8[SNPs_deletion,]

  posFather <- which(colnames(data_ped_chr8_ofInterest_SNPs)==parents[1])
  posMother <- which(colnames(data_ped_chr8_ofInterest_SNPs)==parents[2])

  #get the SNPs of which both parents are homozygous but not for the same
  fatherHomozygous <- which(data_ped_chr8_ofInterest_SNPs[,posFather] == SNPcombination[1] |
                            data_ped_chr8_ofInterest_SNPs[,posFather] == SNPcombination[2] |
                            data_ped_chr8_ofInterest_SNPs[,posFather] == SNPcombination[3] |
                            data_ped_chr8_ofInterest_SNPs[,posFather] == SNPcombination[4]
  )
  data_ped_chr8_ofInterest_SNPs_fatherHOM <- data_ped_chr8_ofInterest_SNPs[fatherHomozygous,]
  data_map_chr8_t2 <- data_map_chr8_t1[fatherHomozygous,]

  motherHomozygous <- which(data_ped_chr8_ofInterest_SNPs_fatherHOM[,posMother] == SNPcombination[1] |
                            data_ped_chr8_ofInterest_SNPs_fatherHOM[,posMother] == SNPcombination[2] |
                            data_ped_chr8_ofInterest_SNPs_fatherHOM[,posMother] == SNPcombination[3] |
                            data_ped_chr8_ofInterest_SNPs_fatherHOM[,posMother] == SNPcombination[4] 
  )
  data_ped_chr8_ofInterest_SNPs_motherHOM <- data_ped_chr8_ofInterest_SNPs_fatherHOM[motherHomozygous,]
  data_map_chr8_t3 <- data_map_chr8_t2[motherHomozygous,]

  bothUnequalHomozygouse <- which( data_ped_chr8_ofInterest_SNPs_motherHOM[,posFather] != data_ped_chr8_ofInterest_SNPs_motherHOM[,posMother])

  ## These are the SNPs of interest on chromosome 14 where one part is duplicated
  data_ped_chr8_ofInterest_SNPs_parentsUnequalHOM <- data_ped_chr8_ofInterest_SNPs_motherHOM[bothUnequalHomozygouse,]
  data_map_chr8_ofInterest_SNPs_parentsUnequalHOM <- data_map_chr8_t3[bothUnequalHomozygouse,]


  posOffspring <- offspring
  for (off in 1:length(offspring)){
    posOffspring[off] <- which(colnames(data_ped_chr8_ofInterest_SNPs)==offspring[off])
  }

  # checking with the B allele frequency
  # chr 8 deletion
  head(data_ped_chr8_ofInterest_SNPs_parentsUnequalHOM); nrow(data_ped_chr8_ofInterest_SNPs_parentsUnequalHOM)
  head(data_map_chr8_ofInterest_SNPs_parentsUnequalHOM); nrow(data_map_chr8_ofInterest_SNPs_parentsUnequalHOM)
  colnames(data_map_chr8_ofInterest_SNPs_parentsUnequalHOM) <- c("chr","SNPname","Zero","Position")

  head(allelefrequencies)
  allelefrequencies_interestingSNPs_chr8 <- subset(allelefrequencies, allelefrequencies$chr == 8 & allelefrequencies$Position <= deletion[3] )

  #getting the samples of the alleles of interest
  allelefrequencies_interestingSNPs_deletion_mother <- subset(allelefrequencies_interestingSNPs_chr8, allelefrequencies_interestingSNPs_chr8$Sample.ID==parents[2])
  allelefrequencies_deletion_mother <- merge(allelefrequencies_interestingSNPs_deletion_mother, data_map_chr8_ofInterest_SNPs_parentsUnequalHOM, by="Position")

  allelefrequencies_interestingSNPs_deletion_father <- subset(allelefrequencies_interestingSNPs_chr8, allelefrequencies_interestingSNPs_chr8$Sample.ID==parents[1])
  allelefrequencies_deletion_father <- merge(allelefrequencies_interestingSNPs_deletion_father, data_map_chr8_ofInterest_SNPs_parentsUnequalHOM, by="Position")

  for (spring in c(1:length(offspring))){
    if (spring == 1){
      allelefrequencies_interestingSNPs_deletion_offspring <- list(subset(allelefrequencies_interestingSNPs_chr8, allelefrequencies_interestingSNPs_chr8$Sample.ID==offspring[spring]))
      allelefrequencies_deletion_offspring <- list(merge(allelefrequencies_interestingSNPs_deletion_offspring, data_map_chr8_ofInterest_SNPs_parentsUnequalHOM, by="Position"))
    } else {
      allelefrequencies_interestingSNPs_deletion_offspring[[spring]] <- subset(allelefrequencies_interestingSNPs_chr8, allelefrequencies_interestingSNPs_chr8$Sample.ID==offspring[spring])
      allelefrequencies_deletion_offspring[[spring]] <- merge(allelefrequencies_interestingSNPs_deletion_offspring[[spring]], data_map_chr8_ofInterest_SNPs_parentsUnequalHOM, by="Position")
    }
  }

  ###############
  ### DUPLICATION
  ## subset the data from the duplication
  SNPs_duplication <- which(data_map_chr14[,4] < duplication[3] & data_map_chr14[,4] >= duplication[2])
  data_ped_chr14_ofInterest_SNPs <- t_data_ped_chr14_ofInterest[SNPs_duplication,]
  data_map_chr14_t1 <- data_map_chr14[SNPs_duplication,]

  posFather <- which(colnames(data_ped_chr14_ofInterest_SNPs)==parents[1])
  posMother <- which(colnames(data_ped_chr14_ofInterest_SNPs)==parents[2])

  #get the SNPs of which both parents are homozygous but not for the same
  fatherHomozygous <- which(data_ped_chr14_ofInterest_SNPs[,posFather] == SNPcombination[1] |
                            data_ped_chr14_ofInterest_SNPs[,posFather] == SNPcombination[2] |
                            data_ped_chr14_ofInterest_SNPs[,posFather] == SNPcombination[3] |
                            data_ped_chr14_ofInterest_SNPs[,posFather] == SNPcombination[4]
  )
  data_ped_chr14_ofInterest_SNPs_fatherHOM <- data_ped_chr14_ofInterest_SNPs[fatherHomozygous,]
  data_map_chr14_t2 <- data_map_chr14_t1[fatherHomozygous,]

  motherHomozygous <- which(data_ped_chr14_ofInterest_SNPs_fatherHOM[,posMother] == SNPcombination[1] |
                            data_ped_chr14_ofInterest_SNPs_fatherHOM[,posMother] == SNPcombination[2] |
                            data_ped_chr14_ofInterest_SNPs_fatherHOM[,posMother] == SNPcombination[3] |
                            data_ped_chr14_ofInterest_SNPs_fatherHOM[,posMother] == SNPcombination[4] 
  )
  data_ped_chr14_ofInterest_SNPs_motherHOM <- data_ped_chr14_ofInterest_SNPs_fatherHOM[motherHomozygous,]
  data_map_chr14_t3 <- data_map_chr14_t2[motherHomozygous,]

  bothUnequalHomozygouse <- which( data_ped_chr14_ofInterest_SNPs_motherHOM[,posFather] != data_ped_chr14_ofInterest_SNPs_motherHOM[,posMother])


  ## These are the SNPs of interest on chromosome 14 where one part is duplicated
  data_ped_chr14_ofInterest_SNPs_parentsUnequalHOM <- data_ped_chr14_ofInterest_SNPs_motherHOM[bothUnequalHomozygouse,]
  data_map_chr14_ofInterest_SNPs_parentsUnequalHOM <- data_map_chr14_t3[bothUnequalHomozygouse,]

  posOffspring <- offspring
  for (off in 1:length(offspring)){
    posOffspring[off] <- which(colnames(data_ped_chr14_ofInterest_SNPs)==offspring[off])
  }

  # checking with the B allele frequency
  # chr 14 duplication
  head(data_ped_chr14_ofInterest_SNPs_parentsUnequalHOM); nrow(data_ped_chr14_ofInterest_SNPs_parentsUnequalHOM)
  head(data_map_chr14_ofInterest_SNPs_parentsUnequalHOM); nrow(data_map_chr14_ofInterest_SNPs_parentsUnequalHOM)
  colnames(data_map_chr14_ofInterest_SNPs_parentsUnequalHOM) <- c("chr","SNPname","Zero","Position")

  head(allelefrequencies)
  allelefrequencies_interestingSNPs_chr14 <- subset(allelefrequencies, allelefrequencies$chr == 14 & allelefrequencies$Position >= duplication[2] )

  #getting the samples of the alleles of interest
  allelefrequencies_interestingSNPs_duplication_mother <- subset(allelefrequencies_interestingSNPs_chr14, allelefrequencies_interestingSNPs_chr14$Sample.ID==parents[2])
  allelefrequencies_duplication_mother <- merge(allelefrequencies_interestingSNPs_duplication_mother, data_map_chr14_ofInterest_SNPs_parentsUnequalHOM, by="Position")

  allelefrequencies_interestingSNPs_duplication_father <- subset(allelefrequencies_interestingSNPs_chr14, allelefrequencies_interestingSNPs_chr14$Sample.ID==parents[1])
  allelefrequencies_duplication_father <- merge(allelefrequencies_interestingSNPs_duplication_father, data_map_chr14_ofInterest_SNPs_parentsUnequalHOM, by="Position")

  for (spring in c(1:length(offspring))){
    if (spring == 1){
      allelefrequencies_interestingSNPs_duplication_offspring <- list(subset(allelefrequencies_interestingSNPs_chr14, allelefrequencies_interestingSNPs_chr14$Sample.ID==offspring[spring]))
      allelefrequencies_duplication_offspring <- list(merge(allelefrequencies_interestingSNPs_duplication_offspring, data_map_chr14_ofInterest_SNPs_parentsUnequalHOM, by="Position"))
    } else {
      allelefrequencies_interestingSNPs_duplication_offspring[[spring]] <- subset(allelefrequencies_interestingSNPs_chr14, allelefrequencies_interestingSNPs_chr14$Sample.ID==offspring[spring])
      allelefrequencies_duplication_offspring[[spring]] <- merge(allelefrequencies_interestingSNPs_duplication_offspring[[spring]], data_map_chr14_ofInterest_SNPs_parentsUnequalHOM, by="Position")
    }
  }

  # plot only SNPs of interest
  pch <- 19
  scale <- 10000000
  ylab <- "B allele frequency"
  xlab_chr8 <- ""
  xlab_chr14 <- ""
  ylim <- c(0,1)
  xlim_chr8 <- c(min(allelefrequencies_interestingSNPs_chr8$Position),max(allelefrequencies_interestingSNPs_chr8$Position))/scale
  xlim_chr14 <- c(min(allelefrequencies_interestingSNPs_chr14$Position),max(allelefrequencies_interestingSNPs_chr14$Position))/scale
  colour_chart_chr8 <- rep("blue",nrow(allelefrequencies_deletion_father))
  colour_chart_chr8[which(allelefrequencies_deletion_father$B.Allele.Freq > 0.6)] <- "red"
  colour_chart_chr14 <- rep("blue",nrow(allelefrequencies_duplication_father))
  colour_chart_chr14[which(allelefrequencies_duplication_father$B.Allele.Freq > 0.6)] <- "red"
  colour_all <- "grey"
  pdf_width <- 11.69
  pdf_height <- 8.27

  #####################################
  ### plotting only SNPs of interest
  #####################################
  pdf(paste(path_output,"/SNPs_ofInterest_proove-trisomy_Ballele_family-",family,".pdf",sep=""),width=pdf_width, height=pdf_height)

  par(mfrow=c(2,length(animals_of_interest)),font=2, las=2,font.lab=2,font.axis=2)
  par(mar=c(6,4,4,0.3))
  ## make both regions fit on one paper

  #deletion
  plot(allelefrequencies_deletion_father$Position/scale,allelefrequencies_deletion_father$B.Allele.Freq
       ,main=parents[1]
        ,ylim=ylim,xlim=xlim_chr8,ylab=ylab,xlab="", col=colour_chart_chr8,pch=pch)
  ###? par(mar=?)
  plot(allelefrequencies_deletion_mother$Position/scale,allelefrequencies_deletion_mother$B.Allele.Freq
       ,main=parents[2]
       ,ylim=ylim,xlim=xlim_chr8,ylab="",xlab=xlab_chr8, col=colour_chart_chr8,pch=pch)
  for (off_id in 1:length(offspring)){
    positions <- allelefrequencies_deletion_offspring[[off_id]][[1]]
    Balleles <- allelefrequencies_deletion_offspring[[off_id]][[4]]
    plot(positions/scale,Balleles
        , main=offspring[off_id]
        ,ylim=ylim,xlim=xlim_chr8,ylab="",xlab="", col=colour_chart_chr8,pch=pch)
  }


  # duplication
  par(mar=c(6,4,4,0.3))
  
  plot(allelefrequencies_duplication_father$Position/scale,allelefrequencies_duplication_father$B.Allele.Freq
       ,main=parents[1]
      ,ylim=ylim,xlim=xlim_chr14,ylab=ylab,xlab="", col=colour_chart_chr14,pch=pch)
  ###? par(mar=?)
  plot(allelefrequencies_duplication_mother$Position/scale,allelefrequencies_duplication_mother$B.Allele.Freq
       ,main=parents[2]
      ,ylim=ylim,xlim=xlim_chr14,ylab="",xlab=xlab_chr14, col=colour_chart_chr14,pch=pch)
  for (off_id in 1:length(offspring)){
   positions <- allelefrequencies_duplication_offspring[[off_id]][[1]]
   Balleles <- allelefrequencies_duplication_offspring[[off_id]][[4]]
   plot(positions/scale,Balleles
        ,main=offspring[off_id]
        ,ylim=ylim,xlim=xlim_chr14,ylab="",xlab="", col=colour_chart_chr14,pch=pch)
  }


  dev.off()
  
  #####################################
  ### plotting all SNPs of interest
  #####################################
  
  
  pdf(paste(path_output,"/SNPs_all_proove-trisomy_Ballele_family-",family,".pdf",sep=""),width=pdf_width, height=pdf_height)
  
  par(mfrow=c(2,length(animals_of_interest)),font=2, las=2,font.lab=2,font.axis=2)
  par(mar=c(4,4,6,0.3))
  
  ## DELETION
  plot(allelefrequencies_interestingSNPs_deletion_father$Position/scale,allelefrequencies_interestingSNPs_deletion_father$B.Allele.Freq
       ,main=parents[1]
       ,ylim=ylim,xlim=xlim_chr8,ylab=ylab,xlab="",col=colour_all,pch=pch)
  par(new=T)
  plot(allelefrequencies_deletion_father$Position/scale,allelefrequencies_deletion_father$B.Allele.Freq
       ,main=parents[1]
       ,ylim=ylim,xlim=xlim_chr8,ylab="",xlab="",col=colour_chart_chr8,pch=pch)
  #mother
  plot(allelefrequencies_interestingSNPs_deletion_mother$Position/scale,allelefrequencies_interestingSNPs_deletion_mother$B.Allele.Freq
       ,main=parents[2]
       ,ylim=ylim,xlim=xlim_chr8,ylab="",xlab=xlab_chr8,col=colour_all,pch=pch)
  par(new=T)
  plot(allelefrequencies_deletion_mother$Position/scale,allelefrequencies_deletion_mother$B.Allele.Freq
       ,main=parents[2]
      ,ylim=ylim,xlim=xlim_chr8,ylab="",xlab="",col=colour_chart_chr8,pch=pch)
  #offspring
  for (off_id in 1:length(offspring)){
    positions_all <- allelefrequencies_interestingSNPs_deletion_offspring[[off_id]][[6]]
    Balleles_all <- allelefrequencies_interestingSNPs_deletion_offspring[[off_id]][[3]]
    positions <- allelefrequencies_deletion_offspring[[off_id]][[1]]
    Balleles <- allelefrequencies_deletion_offspring[[off_id]][[4]]
    plot(positions_all/scale ,Balleles_all
         ,main=offspring[off_id]
        ,ylim=ylim,xlim=xlim_chr8,ylab="",xlab="", col=colour_all,pch=pch)
   par(new=T)
   plot(positions/scale,Balleles
        ,main=offspring[off_id]
        ,ylim=ylim,xlim=xlim_chr8,ylab="",xlab="",col=colour_chart_chr8,pch=pch)
  }

  ## DUPLICATION
  par(mar=c(6,4,4,0.3))
  
  plot(allelefrequencies_interestingSNPs_duplication_father$Position/scale,allelefrequencies_interestingSNPs_duplication_father$B.Allele.Freq
       ,main=parents[1]
       ,ylim=ylim,xlim=xlim_chr14,ylab=ylab,xlab="",col=colour_all,pch=pch)
  par(new=T)
  plot(allelefrequencies_duplication_father$Position/scale,allelefrequencies_duplication_father$B.Allele.Freq
       ,main=parents[1]
       ,ylim=ylim,xlim=xlim_chr14,ylab="",xlab="",col=colour_chart_chr14,pch=pch)
  #mother
  plot(allelefrequencies_interestingSNPs_duplication_mother$Position/scale,allelefrequencies_interestingSNPs_duplication_mother$B.Allele.Freq
       ,main=parents[2]
      ,ylim=ylim,xlim=xlim_chr14,ylab="",xlab=xlab_chr14,col=colour_all,pch=pch)
  par(new=T)
  plot(allelefrequencies_duplication_mother$Position/scale,allelefrequencies_duplication_mother$B.Allele.Freq
       ,main=parents[2]
       ,ylim=ylim,xlim=xlim_chr14,ylab="",xlab="",col=colour_chart_chr14,pch=pch)
  #offspring
  for (off_id in 1:length(offspring)){
    positions_all <- allelefrequencies_interestingSNPs_duplication_offspring[[off_id]][[6]]
    Balleles_all <- allelefrequencies_interestingSNPs_duplication_offspring[[off_id]][[3]]
    positions <- allelefrequencies_duplication_offspring[[off_id]][[1]]
    Balleles <- allelefrequencies_duplication_offspring[[off_id]][[4]]
    plot(positions_all/scale ,Balleles_all
         ,main=offspring[off_id]
         ,ylim=ylim,xlim=xlim_chr14,ylab="",xlab="", col=colour_all,pch=pch)
    par(new=T)
    plot(positions/scale,Balleles
         ,main=offspring[off_id]
         ,ylim=ylim,xlim=xlim_chr14,ylab="",xlab="",col=colour_chart_chr14,pch=pch)
  }

  dev.off()

}




