# This script draws a tree based on the maximum likelihood tree fron snpPhlyo package (http://chibba.pgml.uga.edu/snphylo/)
# contact : Vidhya.Jagannathan@vetsuisse.unibe.ch

# Load the Libraries 
library(ggtree)
library(ggplot2)
library(treeio)
library(RColorBrewer)
library(data.table)


file<-("snphylo.output.ml.tree")
tree<-read.tree(file)

#list of Sample IDs  
dogGroupInfo<-list(Airedale_Terrier=c("SRS932161", "TA001"),Alaskan_Husky=c("SY001", "SY018"),Alaskan_Malamute=c("AM007", "AM019"),Alpine_Dachsbracke=c("AD009", "AD034"),American_Staffordshire_Terrier=c("AS006", "AS008"),Australian_Cattle_Dog=c("AC023", "AC046", "AC065", "AC108", "AC364"),Australian_Shepherd=c("AU178", "AU184"),Australian_Terrier=c("AR001"),Basenji_=c("SRS932158"),Basset_Hound=c("BH003"),Bavarian_Hound=c("BG064"),Beagle=c("BE020"),Bearded_Collie=c("BC1893", "BC1895", "BC1896", "BD016", "BD036", "BD052", "BD085", "BD089", "BD091", "BD093", "BD098"),Berger_Blanc_Suisse=c("BB011"),Berger_Picard=c("SRS932146"),Bichon_Frise=c("BF21", "BF39"),Black_Russian_Terrier=c("SRS833812"),Border_Collie=c("12675RE", "6958RE", "BC0480", "BC272", "BC273", "BC485", "BC518", "BC547", "BC548", "BC549", "BC555", "BC597", "BC621", "SRS932162", "LN47"),Border_Terrier=c("SRS932144"),Bull_Terrier=c("BT012"),Bullmastiff=c("BU002"),Cairn_Terrier=c("CE073"),Cane_corso=c("12559RE", "CI001", "CI002", "CI003", "CI004"),Cavalier_King_Charles_Spaniel=c("CK006", "CK023"),Chihuahua=c("CH027", "CH019"),Chinese_Crested_dog=c("SRS713815"),Chinese_indigenous_dogs=c("DQ1", "DQ10", "DQ2", "DQ3", "DQ4", "DQ5", "DQ6", "DQ7", "DQ8", "DQ9", "LJ1", "LJ10", "LJ2", "LJ3", "LJ4", "LJ5", "LJ6", "LJ7", "LJ8", "LJ9", "YJ1", "YJ2", "YJ3", "YJ4", "YJ5", "YJ6", "YJ7", "YJ9"),Chow_Chow=c("CW011"),Cocker_Spaniel=c("CP003"),Collie=c("CL013"),Curly_Coated_Retriever=c("CR018", "CR023", "CR039", "CR040", "CR101"),Dachshund=c("DH0117", "DH098", "DH126"),Doberman_Pinscher=c("DO159", "DO242", "DO263"),Dogue_de_Bordeaux=c("BX002", "BX003", "DB1", "DB4"),Dutch_Shepherd=c("WW647__Zombie"),Elo=c("EL565"),English_Bulldog=c("EB003"),English_Springer_Spaniel=c("SRS932160"),Entlebucher_Sennenhund=c("EN091", "EN154", "EN221", "EN247", "EN261", "EN262", "EN263", "EN264"),Eurasier=c("EU008", "EU035"),French_Bulldog=c("FB046", "FB065"),German_Shepherd=c("DS043", "DS051", "DS053", "DS064", "GS1", "GS10", "GS2", "GS3", "GS4", "GS5", "GS6", "GS7", "GS8", "GS9", "SRS932159"),German_Shepherd_Mixed_breed=c("DS032", "DS041", "DS042"),German_Wirehaired=c("GW004"),Golden_Retriever=c("GR0855", "GR0859", "GR0860", "GR0892", "GR1161", "SRS932149"),Golden_Retriever_Mix=c("GR1078"),Great_Dane=c("DD116"),Great_Pyrenees=c("GP3"),Greater_Swiss_Mountain_Dog=c("6455RE", "SH008", "SH010", "SH011", "SH012", "SH013"),Greyhound=c("GY391", "GY393", "GY415", "GY416", "GY432"),Heideterrier=c("HT001"),Hovawart=c("HW1706", "HW1872", "HW1979"),Irish_Terrier=c("IT0390", "IT221"),Irish_Wolfhound=c("IWH13", "IWH156"),Jack_Russell_Terrier=c("JR0034", "JR045", "SRS932147", "SRS932151"),Jagdterrier=c("JT007", "JT011"),Kerry_Blue_Terrier=c("SRS932164"),Kromfohrlander=c("KF042"),Kunming_Dog=c("KM1", "KM10", "KM2", "KM3", "KM4", "KM5", "KM6", "KM7", "KM8", "KM9"),Labrador_Retriever=c("LA1869", "LA882", "LA900", "SRS932152"),Labrador_retriever=c("LA2443"),Lagotto_Romagnolo=c("LR1030", "LR1149", "LR390", "LR416", "LR433", "LR494", "LR538", "LR654", "LR753"),Landseer=c("LN048", "ZS14"),Leonberger=c("LB0013", "LB0139", "LB0147", "LB0197", "LB0203", "LB0268", "LB0304", "LB0305", "LB0339", "LB0418", "LB0482", "LB0507", "LB0554", "LB0656", "LB0683", "LB111", "LB1848", "LB1919", "LB1961", "LB214", "LB3506", "LB3521", "LB3601", "LB3659", "LB3705", "LB3906", "LB4183", "LB4693", "LB5378", "LB5751", "LE0051", "LE0237", "LE0269", "LE0512", "LE0738", "LE0896", "LE1294", "LE1301", "LE1302", "LE1355", "LE2450"),Malinois=c("MA008", "MA0163", "MA094", "MA142", "MA152", "MA324", "MA437"),Mini_Schnauzer=c("ZZ024_MS13", "ZZ025_MS25", "ZZ026_MS80", "ZZ028_MS171", "ZZ029_MS190", "ZZ030_MS241", "ZZ031_MS249", "ZZ032_MS251", "ZZ034_MS260", "ZZ035_MS279"),Miniature_Bull_terrier=c("BT007", "MB003"),Miniature_Schnauzers=c("MS32", "MS77"),Mixed_Breed=c("MI016", "LA2382"),Mixed_breed=c("MI020"),mixed_breed=c("MI025"),Newfoundland=c("NF187000", "NF492"),Norwich_Terrier=c("NW062", "NW152", "NW206", "NW255"),Nova_Scotia_Duck_Tolling_Retriever=c("NR562"),Old_English_Sheepdog=c("OS001"),Pembroke_Welsh_Corgi=c("SRS732550", "SRS732551"))
x<-list(Perro_de_Agua_Espanol=c("PE002"),Pomeranian=c("ZS14_2"),Poodle=c("PL116", "PL150__D00105", "PL152__D00270", "PL153__D00271", "PL154__D00285", "PL156__D00353", "PL157__D00354", "PL158__D00373", "PL159__D00382", "PL160__D00392", "PL161__D00397", "PL162__D00477", "PL163__D00530", "PL164__D00817", "PL165__D00868"),Portuguese_Podengo=c("SRS932163"),Rhodesian_Ridgeback=c("RR098", "RR123", "RR224"),Rottweiler=c("RO2"),Saluki=c("SL006"),Scottish_Deerhound=c("SRS932150"),Scottish_Terrier=c("SRS932157"),Shetland_Sheepdog=c("SRS932138", "SS004", "SS096"),Siberian_Husky=c("KKH2684", "SY046"),Sloughi=c("SG005", "SG006", "SG008"),Spitz_Grossspitz=c("GS104"),St_Bernard=c("STB24", "STB27"),Standard_Poodle=c("SRS932143"),Standard_Schnauzer=c("SM010"),Tibetan_Mastiff=c("TM1", "TM10", "TM2", "TM3", "TM4", "TM5", "TM6", "TM7", "TM8", "TM9"),Tibetan_Terrier=c("SRS932145", "SRS932148"),Weimaraner=c("WE006", "WE008"),West_Highland_White_Terrier=c("SRS932153", "WW174", "WW361", "WW362", "WW363", "WW364", "WW558", "WW635__West04", "WW637__West06", "WW639__West10", "WW64", "WW640__West13", "WW641__West16", "WW642__West19", "WW643__West24", "WW644__West25", "WW645__West26", "WW646__West30", "WW665"),Whippet=c("WH083"),Yorkshire_Terrier=c("YT003"))
dogGroupInfo<-c(dogGroupInfo,x)

# colors for the breeds 
colourCount = length(dogGroupInfo)
getPalette = colorRampPalette(brewer.pal(9, "BrBG"))
cols=getPalette(colourCount)

# tree with group (group samples into breeds) information
tree <- groupOTU(tree, dogGroupInfo)

# plot the circular tree 
tree_plot<-ggtree(tree,branch.length='none', aes(color=group), layout='circular') + geom_tiplab(size=1, aes(angle=angle))
tree_dt <- data.table(tree_plot$data)
tree_dt <- tree_dt[isTip == TRUE][order(y)]
coord_groups <- tree_dt[, .(y1 = y[1],
                            y2 = y[.N],
                            angle = mean(angle),
                            n = .N), # optional - helps with counting
                        by = .(group, 
                               id_gr = rleid(group, 
                                             prefix = "grp"))]
coord_groups[, y_mid := rowMeans(.SD), .SDcols = c("y1", "y2")]
coord_groups[, y1_adj := ifelse(y1 == y2, y1 - 0.2, y1)]
coord_groups[, y2_adj := ifelse(y1 == y2, y2 + 0.2, y2)]

coord_groups[, angle_adj := ifelse(angle %between% c(90, 180), 
                                   yes = angle + 180,
                                   no = ifelse(angle > 180 & angle <= 270,
                                               yes = angle - 180,
                                               no = angle))]
coord_groups[, hjust_adj := ifelse(angle %between% c(90, 270), yes = 1L, no = 0L)]

#Annotate tree 
my_x <- max(tree_dt$x) + 4
tree_labeled <-   tree_plot + 
  geom_segment(data = coord_groups,
               aes(x = my_x, 
                   y = y1_adj, 
                   xend = my_x, 
                   yend = y2_adj),
               color = "black",
               lineend = "butt",
               size = 3) +
  geom_text(data = coord_groups,
            aes(x = my_x,
                y = y_mid,
                angle = angle_adj,
                hjust = hjust_adj,
                label = group),
            vjust = 0.5, 
            size  = 1.0,
            nudge_x = 1.0, # Offsetting label from its default x coordinate.
            color = "black") 

# create a high resoltion image 

tiff("test.tiff", units="in", width=5, height=5, res=600)
tree_labeled
dev.off()