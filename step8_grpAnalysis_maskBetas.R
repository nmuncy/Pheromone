library(openxlsx)
library(tiff)
library(car)
library(nlme)
library(ghostscript)
library(stringr)
library(tidyr)



### Set parameters
dataDir <- "/Volumes/Yorick/WiscoPheromone/Analyses/"
outDir <- "/Volumes/Yorick/WiscoPheromone/Analyses/R_output/"
data_list <- c("Sex.Lav", "Sex.Phero")



###################
# Stats Functions
###################

TT.Function <- function(x, y, dataN, maskN){
  ttest_out <- t.test(x,y,paired=F)
  output <- capture.output(print(ttest_out))
  writeLines(output,paste0(outDir,"TTest_",dataN,"_Mask",maskN,".txt"))
  # return(ttest_out)
}

WB_RM.Function <- function(x,y,z,dataN,maskN){

  df <- x
  N <- y
  P <- z    # Number of wi-subject factors
  K <- as.numeric(length(unique(df[,1])))    # Number of bx-subject factors

  for(a in 1:ncol(df)){
    df[is.na(df[,a]), a] <- mean(df[,a], na.rm = TRUE)
  }

  ind.male <- grep(2,df[,1])
  ind.female <- grep(1,df[,1])

  b1n <- as.numeric(length(ind.male))
  b2n <- as.numeric(length(ind.female))

  X.apb1 <- as.numeric(colMeans(df[ind.male,2:3])) # a = betas, b = sex
  X.apb2 <- as.numeric(colMeans(df[ind.female,2:3]))
  X.Ap <- as.numeric(colMeans(df[,2:3]))

  X.b1ap <- as.numeric(rowMeans(df[ind.male,2:3]))
  X.B1 <- mean(X.b1ap)
  X.b2ap <- as.numeric(rowMeans(df[ind.female,2:3]))
  X.B2 <- mean(X.b2ap)
  X.Bk <- cbind(X.B1,X.B2)

  X.g <- mean(as.matrix(df[,2:3]))

  SS.bx <- P*b1n*((X.B1 - X.g)^2) + P*b2n*((X.B2 - X.g)^2)
  SS.wi <- N*(sum((X.Ap - X.g)^2))
  SS.e <- P*(sum((X.b1ap-X.B1)^2)+(sum((X.b2ap-X.B2)^2)))
  SS.intx <- (b1n*(sum((X.apb1-X.g)^2)))+(b2n*(sum((X.apb2-X.g)^2))-SS.bx-SS.wi)
  SS.t <- SS.bx + SS.wi
  # SS.s <- (sum((df[ind.male,1]-X.apb1[1])^2)+sum((df[ind.male,2]-X.apb1[2])^2)+sum((df[ind.male,3]-X.apb1[3])^2)+sum((df[ind.male,4]-X.apb1[4])^2)+sum((df[ind.female,1]-X.apb2[1])^2)+sum((df[ind.female,2]-X.apb2[2])^2)+sum((df[ind.female,3]-X.apb2[3])^2)+sum((df[ind.female,4]-X.apb2[4])^2))-SS.e
  SS.s <- (sum((df[ind.male,2]-X.apb1[1])^2)+sum((df[ind.male,3]-X.apb1[2])^2)+sum((df[ind.female,2]-X.apb2[1])^2)+sum((df[ind.female,3]-X.apb2[2])^2))-SS.e
  
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
  write.table(output, paste0(outDir, "WBRM_", dataN,"_Mask",maskN,".txt"),quote=F)
}

Post_ttest.Function <- function(x,dataN,maskN){
  
  df <- x
  
  test1 <- t.test(df[sex=="F",2],df[sex=="F",3],paired=F)
  test2 <- t.test(df[sex=="M",2],df[sex=="M",3],paired=F)
  test3 <- t.test(df[sex=="F",2],df[sex=="M",2],paired=F)
  test4 <- t.test(df[sex=="F",3],df[sex=="M",3],paired=F)
  
  out1 <- capture.output(print(test1))
  out2 <- capture.output(print(test2))
  out3 <- capture.output(print(test3))
  out4 <- capture.output(print(test4))
  
  output <- c(out1, out2, out3, out4)
  writeLines(output,paste0(outDir,"PostHocT_",dataN,"_Mask",maskN,".txt"))
  
}



###################
# Graph Functions
###################

GraphNames.Function <- function(dataString){
  if(dataString=="Sex.Phero"){return(list(n1="M-P1",n2="F-P1",n3="M-P2",n4="F-P2"))
  } else if(dataString=="Sex.Lav"){return(list(n1="M-Lav",n2="F-Lav"))
  }
}

SE.Function <- function(x,plot_data){
  SD <- sd(plot_data[,x])/sqrt(length(plot_data[,x]))
  return(SD)
}

Graph1.Function <- function(DF,output_name,maskN){
  
  ebars.F <- SE.Function(2,DF[sex=="F",])
  ebars.M <- SE.Function(2,DF[sex=="M",])
  
  if(maskN == 7){TITLE <- "rOFC"}
  else if(maskN == 6){TITLE <- "rFP"}
  else{TITLE <- paste0("Mask", maskN)}
  
  MEANS <- rbind(mean(DF[sex=="F",2]),mean(DF[sex=="M",2]))
  E.BARS <- rbind(ebars.F,ebars.M)
  RANGE <- range(c(MEANS,MEANS-E.BARS,MEANS+E.BARS,0))
  plotable <- cbind(MEANS,E.BARS)
  XNAMES <- GraphNames.Function(output_name)
  
  graphOut <- paste0(outDir,output_name,"_",TITLE,".tiff")
  bitmap(graphOut, width = 6.5, units = 'in', type="tiff24nc", res=1200)
  barCenters <- barplot(plotable[,1], names.arg = c(XNAMES), main=TITLE, ylab="Beta value",ylim=RANGE)
  segments(barCenters, MEANS-E.BARS, barCenters, MEANS+E.BARS)
  arrows(barCenters, MEANS-E.BARS, barCenters, MEANS+E.BARS, lwd = 1, angle = 90, code = 3, length = 0.05)
  dev.off()
}

Graph2.Function <- function(DF,output_name,maskN){
  
  ebars.F <- cbind(SE.Function(2,DF[sex=="F",]),SE.Function(3,DF[sex=="F",]))
  ebars.M <- cbind(SE.Function(2,DF[sex=="M",]),SE.Function(3,DF[sex=="M",]))
  
  if(maskN == 12){TITLE <- "rOFC"}
  else if(maskN == 18){TITLE <- "blPFC"}
  else{TITLE <- paste0("Mask", maskN)}
  
  MEANS <- rbind(colMeans(DF[sex=="F",2:3]),colMeans(DF[sex=="M",2:3]))
  E.BARS <- rbind(ebars.F,ebars.M)
  RANGE <- range(c(MEANS,MEANS-E.BARS,MEANS+E.BARS,0))
  plotable <- cbind(MEANS,E.BARS)
  XNAMES <- GraphNames.Function(output_name)
  
  graphOut <- paste0(outDir,output_name,"_",TITLE,".tiff")
  bitmap(graphOut, width = 6.5, units = 'in', type="tiff24nc", res=1200)
  barCenters <- barplot(plotable[,1:2], beside=T, names.arg = c(XNAMES), main=TITLE, ylab="Beta value", ylim=RANGE, col=c("darkblue", "darkred"))
  segments(barCenters, MEANS-E.BARS, barCenters, MEANS+E.BARS)
  arrows(barCenters, MEANS-E.BARS, barCenters, MEANS+E.BARS, lwd = 1, angle = 90, code = 3, length = 0.05)
  legend("topright", fill=c("darkblue", "darkred"), legend = c("Male","Female"))
  dev.off()
}



###################
# Do it
###################

for(j in t(data_list)){
  
  ### get info
  masks <- read.delim(paste0(dataDir,"Master_",j,"_mask_betas.txt"),header=F)
  
  #mask
  ind.mask <- grep("Mask", masks[,1])
  num.mask <- length(ind.mask)
  
  #subjects
  ind.subj <- grep("File", masks[,1])
  len.subj <- length(ind.subj)
  num.subj <- len.subj/num.mask
  
  #betas
  ind.betas <- grep("+orig|+tlrc", masks[,1])
  len.betas <- length(ind.betas)
  num.betas <- (len.betas/num.mask)/num.subj
  
  ### organize data
  ind.data <- matrix(as.numeric(as.character(masks[grep("+tlrc",masks[,1]),3])),ncol=num.betas,byrow=T)
  Mdata <- matrix(0,nrow=num.subj, ncol=num.mask*num.betas)
  for(i in 1:num.mask){
    Mdata[,(num.betas*i-(num.betas-1)):(num.betas*i)] <- ind.data[(num.subj*i-(num.subj-1)):(num.subj*i),1:num.betas]
  }
  colnames(Mdata) <- c(as.character(rep(masks[ind.mask,1],each=num.betas)))
  
  
  ## make dataframe per mask
  rm(list=ls()[grep("table_mask", ls())])      # clear global variable for loop iterations
  
  for(i in 1:num.subj){
    for(k in 1:num.mask){
      assign(paste0("table_mask",k), matrix(0,nrow=num.subj,ncol=num.betas))
    }
  }
  
  for(i in 1:num.subj){
    for(k in 1:num.mask){
      hold <- get(paste0("table_mask",k))
      hold[i,] <- Mdata[i,(num.betas*(k-1)+1):(num.betas*k)]
      assign(paste0("table_mask",k),hold)
    }
  }
  
  # Assign demographics
  sex <- c(rep("F", 16), rep("M", 13))
  for(k in 1:num.mask){
    hold <- get(paste0("table_mask",k))
    hold <- cbind(as.factor(sex),hold)
    assign(paste0("table_mask",k),hold)
  }

  
  ### Graphs
  if(j == "Sex.Lav"){
    for(i in 1:num.mask){
      hold <- as.data.frame(get(paste0("table_mask",i)))
      Graph1.Function(hold,j,i)
    }
  } else if(j == "Sex.Phero"){
    for(i in 1:num.mask){
      hold <- as.data.frame(get(paste0("table_mask",i)))
      Graph2.Function(hold,j,i)
    }
  }
  

  ### Stats
  if(j == "Sex.Lav"){
    for(i in 1:num.mask){
      hold <- get(paste0("table_mask",i))
      TT.Function(hold[sex=="F",2],hold[sex=="M",2],j,i)
    }
  } else if(j == "Sex.Phero"){
    for(i in 1:num.mask){
      hold <- get(paste0("table_mask",i))
      WB_RM.Function(hold,num.subj,num.betas,j,i)
    }
  }
  
  # Post-hoc
  if(j == "Sex.Phero"){
    for(i in 1:num.mask){
      hold <- get(paste0("table_mask",i))
      Post_ttest.Function(hold,j,i)
    }
  }
}
