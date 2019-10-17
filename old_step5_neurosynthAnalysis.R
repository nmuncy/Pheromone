
library(openxlsx)
library(tiff)
library(car)
library(nlme)
library(agricolae)
library(tidyr)




###################
# Variables
###################

dataDir <- "/Volumes/Yorick/WiscoPheromone/nsynAnalysis/txt_files/"
subj_list <- read.table(paste0(dataDir,"subj_list.txt"))
demo_sex <- read.table(paste0(dataDir,"demographics.txt"))
outDir <- dataDir


###################
# Functions
###################

MaskNames.Function <- function(x){
  if(x==1){return(roi="lAmyg")}
  else if(x==2){return(roi="lColS")}
  else if(x==3){return(roi="rAmyg")}
  else if(x==4){return(roi="rBA3845")}
  else if(x==5){return(roi="rOFC")}
}

WB_RM.Function <- function(x,y,z,dataN,maskN){
  
  df <- x
  N <- y
  P <- z    # Number of wi-subject factors
  K <- as.numeric(length(unique(sex)))    # Number of bx-subject factors
  
  for(a in 1:ncol(df)){
    df[is.na(df[,a]), a] <- mean(df[,a], na.rm = TRUE)
  }
  
  ind.male <- grep("2",df[,1])
  ind.female <- grep("1",df[,1])
  
  b1n <- as.numeric(length(ind.male))
  b2n <- as.numeric(length(ind.female))
  
  X.apb1 <- as.numeric(colMeans(df[ind.male,2:4])) # a = betas, b = sex
  X.apb2 <- as.numeric(colMeans(df[ind.female,2:4]))
  X.Ap <- as.numeric(colMeans(df[,2:4]))
  
  X.b1ap <- as.numeric(rowMeans(df[ind.male,2:4]))
  X.B1 <- mean(X.b1ap)
  X.b2ap <- as.numeric(rowMeans(df[ind.female,2:4]))
  X.B2 <- mean(X.b2ap)
  X.Bk <- cbind(X.B1,X.B2)
  
  X.g <- mean(as.matrix(df[,2:4]))
  
  SS.bx <- P*b1n*((X.B1 - X.g)^2) + P*b2n*((X.B2 - X.g)^2)
  SS.wi <- N*(sum((X.Ap - X.g)^2))
  SS.e <- P*(sum((X.b1ap-X.B1)^2)+(sum((X.b2ap-X.B2)^2)))
  SS.intx <- (b1n*(sum((X.apb1-X.g)^2)))+(b2n*(sum((X.apb2-X.g)^2))-SS.bx-SS.wi)
  SS.t <- SS.bx + SS.wi
  SS.s <- (sum((df[ind.male,2]-X.apb1[1])^2)+sum((df[ind.male,3]-X.apb1[2])^2)+sum((df[ind.male,4]-X.apb1[3])^2)+sum((df[ind.female,2]-X.apb2[1])^2)+sum((df[ind.female,3]-X.apb2[2])^2)+sum((df[ind.female,4]-X.apb2[3])^2))-SS.e
  
  df.bx <- K-1
  df.wi <- P-1
  df.s <- ((N-K)*(P-1))
  df.intx <- ((K-1)*(P-1))
  df.e <- (N-K)
  
  MS.bx <- SS.bx/df.bx
  MS.wi <- SS.wi/df.wi
  MS.s <- SS.s/df.s
  MS.intx <- SS.intx/df.intx
  MS.e <- SS.e/df.e
  
  F.bx <- MS.bx/MS.e
  F.wi <- MS.wi/MS.s
  F.intx <- MS.intx/MS.s
  
  CV.bx <- qf(0.95, K-1, N-K)
  CV.wi <- qf(0.95, P-1, (N-K)*(P-1))
  CV.intx <- qf(0.95, (K-1)*(P-1), (N-K)*(P-1))
  
  Eta2.bx <- SS.bx/(SS.bx+SS.e)
  Eta2.wi <- SS.wi/(SS.wi+SS.s)
  Eta2.intx <- SS.intx/(SS.intx+SS.s)
  
  P.bx <- pf(F.bx, K-1, N-K, lower.tail = F)
  P.wi <- pf(F.wi, P-1, (N-K)*(P-1), lower.tail = F)
  P.intx <- pf(F.intx, (K-1)*(P-1), (N-K)*(P-1), lower.tail = F)
  
  output <- rbind(F.bx, df.bx, CV.bx, P.bx, Eta2.bx, F.wi, df.wi, CV.wi, P.wi, Eta2.wi, F.intx, df.intx, df.e, CV.intx, P.intx, Eta2.intx)
  ROI <- MaskNames.Function(maskN)
  write.table(output, paste0(outDir, "WBRM_", dataN,"_", ROI,".txt"),quote=F)
}

Post_WCox.Function <- function(x,dataN,maskN){
  
  df <- x
  
  ind.female <- grep(1,df[,1])
  ind.male <- grep(2,df[,1])
  
  data.Lav <- as.matrix(df[,2])
  data.P1 <- as.matrix(df[,3])
  data.P2 <- as.matrix(df[,4])
  
  data.LF <- as.matrix(data.Lav[ind.female,])
  data.LM <- as.matrix(data.Lav[ind.male,])
  data.P1F <- as.matrix(data.P1[ind.female,])
  data.P1M <- as.matrix(data.P1[ind.male,])
  data.P2F <- as.matrix(data.P2[ind.female,])
  data.P2M <- as.matrix(data.P2[ind.male,])
  
  test1 <- wilcox.test(data.LF, data.LM)
  test2 <- wilcox.test(data.LF, data.P1F)
  test3 <- wilcox.test(data.LF, data.P1M)
  test4 <- wilcox.test(data.LF, data.P2F)
  test5 <- wilcox.test(data.LF, data.P2M)
  test6 <- wilcox.test(data.LM, data.P1F)
  test7 <- wilcox.test(data.LM, data.P1M)
  test8 <- wilcox.test(data.LM, data.P2F)
  test9 <- wilcox.test(data.LM, data.P2M)
  test10 <- wilcox.test(data.P1F, data.P1M)
  test11 <- wilcox.test(data.P1F, data.P2F)
  test12 <- wilcox.test(data.P1F, data.P2M)
  test13 <- wilcox.test(data.P1M, data.P2F)
  test14 <- wilcox.test(data.P1M, data.P2M)
  test15 <- wilcox.test(data.P2F, data.P2M)
  
  out1 <- capture.output(print(test1))
  out2 <- capture.output(print(test2))
  out3 <- capture.output(print(test3))
  out4 <- capture.output(print(test4))
  out5 <- capture.output(print(test5))
  out6 <- capture.output(print(test6))
  out7 <- capture.output(print(test7))
  out8 <- capture.output(print(test8))
  out9 <- capture.output(print(test9))
  out10 <- capture.output(print(test10))
  out11 <- capture.output(print(test11))
  out12 <- capture.output(print(test12))
  out13 <- capture.output(print(test13))
  out14 <- capture.output(print(test14))
  out15 <- capture.output(print(test15))
  
  output <- c(out1, out2, out3, out4, out5, out6, out7, out8, out9, out10, out11, out12, out13, out14, out15)
  ROI <- MaskNames.Function(maskN)
  writeLines(output,paste0(outDir,"PostHoc_WilCox_",dataN,"_",ROI,".txt"))
}



###################
# Just Do It 
###################

### Get data
data_raw <- read.delim(paste0(dataDir, "nsynth_betas.txt"),header = F)

num.subj <- dim(subj_list)[1]
ind.masks <- grep("File",data_raw[,1])
num.masks <- length(ind.masks)/num.subj
ind.betas <- grep("deconv",data_raw[,1])
num.betas <- length(ind.betas)/(num.subj*num.masks)

ind.data <- matrix(as.numeric(as.character(data_raw[grep("+orig|+tlrc",data_raw[,1]),3])),ncol=(num.betas*num.masks),byrow=T)
data <- matrix(0,nrow = num.subj,ncol = num.betas*num.masks)
data <- ind.data
dim.hold <- dim(data)

# Assign demographics
sex <- c(rep("F", 16), rep("M", 13))


### Stats
for(i in 1:((dim.hold[2])/num.betas)){
  hold <- data[,((num.betas*i)-2):(num.betas*i)]
  hold.data <- cbind(as.factor(sex),hold)
  WB_RM.Function(hold.data,num.subj,num.betas,"nsynth_betas",i)
  Post_WCox.Function(hold.data,"nsynth_betas",i)
}



