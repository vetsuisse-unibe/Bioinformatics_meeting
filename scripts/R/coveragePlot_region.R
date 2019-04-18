# Rscript to plot coverage of regions of a bam file
# belongs together with the shell script "coveragePlot_region.sh"
# Version 1 from September 2018
# for internal use at the Institute of Genetics
# University fo Bern
# made by Irene Häfliger
# if any problems occure, please contact: irene.haefliger@vetsuisse.unibe.ch

#load parameters
controlparameters_filename <- read.table("input_filename")
FILENAME <- as.character(controlparameters_filename[1,1])
FILENAME

ctrlParameters <- read.table(FILENAME,sep="=", header=F)
#assign parameters
chr <- ctrlParameters[[which(ctrlParameters[,1] == "chr"),2]]
start <- ctrlParameters[[which(ctrlParameters[,1] == "start"),2]]
end <- ctrlParameters[[which(ctrlParameters[,1] == "end"),2]]
species <- ctrlParameters[[which(ctrlParameters[,1] == "species"),2]]

# load data with whole genome coverage
dataCovWG <- read.table("av_cov_wg_target_and_control.txt",sep="\t", header=T)

# load data with coverage per base
fileCovPB <- paste("cov_perBase_",chr,"_",species,".txt",sep="")
data_raw <- read.table(fileCovPB,sep="\t", header=F)

start_pos <- as.numeric(as.character(start))
end_pos <- as.numeric(as.character(end))
data <- subset(data_raw,data_raw[,2] >= start_pos & data_raw[,2] <= end_pos)

# define the number of plots to be drawn
nrplots <- ncol(data)-2


SCALE <- 1000000 # for x-axis as Mb
roundAxisLabel <- 2

#get the avcoverage of the individual
target <- as.character(ctrlParameters[[which(ctrlParameters[,1] == "case"),2]])
selTar <- which( nchar(strsplit(target," ")[[1]]) > 1 )
lengthTar <- length(selTar)
listTarget <- strsplit(target[[1]]," ")[[1]][selTar]
control <- as.character(ctrlParameters[[which(ctrlParameters[,1] == "control"),2]])
selContr <- which( nchar(strsplit(control," ")[[1]]) > 1 )
lengthContr <- length(selContr)
listContr <- strsplit(control[[1]]," ")[[1]][selContr]
list <- c(listTarget,listContr)

#get the average coverage per individual
mean <- rep(NA,nrplots)
for (i in c(1:nrplots)){
  mean[i] <- dataCovWG[i,1]  
}
mean


### make plots
outputName <- paste("cov_perBase_",chr,"_",start,"_",end,"_",species,".pdf",sep="")
pdf(outputName)


#layout of the output
layout(matrix(c(1:nrplots), nrplots, 1, byrow = TRUE))

xlim <- c(min(data[,2])/SCALE,max(data[,2])/SCALE)
ylim <- c(0,max(mean)*4)
ylab <- "coverage"
xlab <- paste("region on ",chr,sep=" ")

n <- nrow(data)/10000



###########
#plots 
par(mar=c(4,3.8,1.5,1))
#chr8
par(new=F)

for (i in c(1:nrplots)){
  #calculate mean over 10000 positions
  #calculate mean over n observations
  if (nrow(data) <= 10000){
    y <- data[,i+2]
    x <- data[,2]
  } else {
    y <- aggregate(data[,i+2], list(rep(1:nrow(data) %/% n +1)),each=n,len=nrow(data),mean)[-1]
    x <- aggregate(data[,2], list(rep(1:nrow(data) %/% n +1)),each=n,len=nrow(data),mean)[-1]
  }
  dat <- data.frame(x/SCALE,y)
  #plot the coverage
  plot(dat,type='h', lwd=1, col="gray47", ylim=ylim,
       xlim=xlim,ylab=ylab,xlab=xlab,bty="n", las=1, main=list[i])
  #add line for the average
  segments(y0=mean[i],y1=mean[i],x0=xlim[1],x1=xlim[2],col="red",lty=3)
  par(new=F)
}

dev.off()
