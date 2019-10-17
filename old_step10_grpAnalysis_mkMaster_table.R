
library(openxlsx)
library(tiff)
library(car)
library(nlme)
library(stringr)
library(tidyr)



listGRP <- read.table("/Volumes/Yorick/WiscoPheromone/Analyses/grp_list.txt")
listGRP <- t(listGRP)
outDir <- "/Volumes/Yorick/WiscoPheromone/Analyses/"

TT.master <- matrix(0,nrow=1,ncol=7)
WB.master <- matrix(0,nrow=1,ncol=14)
P.master <- matrix(0,nrow=1,ncol=22)

for(j in listGRP){
  
  data <- read.delim(paste0("/Volumes/Yorick/WiscoPheromone/Analyses/",j),header = F)
  
  if(grepl("TTEST",j)==T){
    
    ind.grpT2mask <- NA
    ind.grpT2values <- NA
    ind.grpT2cv <- NA
    
    for(i in 1:dim(data)[1]){
      if(grepl("Mask",(data[i,1]))==T){ind.grpT2mask <- c(ind.grpT2mask, i)}
      if(grepl("t =",(data[i,1]))==T){ind.grpT2values <- c(ind.grpT2values, i)}
      if(grepl("95 percent",(data[i,1]))==T){ind.grpT2cv <- c(ind.grpT2cv, i+1)}
    }
    grpT2.values.hold <- data[ind.grpT2values[-1],]
    grpT2.cv.hold <- data[ind.grpT2cv[-1],]
    
    grpT2.values <- str_split(grpT2.values.hold[,1], ",", n=3, simplify=T)
    grpT2.cv <- str_split(grpT2.cv.hold[,1], " ", n=3, simplify = T)
    
    grpT2.data <- data[ind.grpT2mask[-1],]
    grpT2.data <- cbind(grpT2.data, grpT2.values[,1:3])
    grpT2.data <- cbind(grpT2.data, grpT2.cv[,2:3])
    
    TT.master <- as.matrix(cbind(t(t(rep(j,dim(grpT2.data)[1]))), grpT2.data[,-2]))
    # TT.master <- rbind(TT.master, hold)
  }
  
  if(grepl("WBRM",j)==T){
    
    ind.WBmask <- NA
    
    ind.WBfbx <- NA
    ind.WBpbx <- NA
    ind.WBcvbx <- NA
    ind.WBebx <- NA
    
    ind.WBfwi <- NA
    ind.WBpwi <- NA
    ind.WBcvwi <- NA
    ind.WBewi <- NA
    
    ind.WBfintx <- NA
    ind.WBpintx <- NA
    ind.WBcvintx <- NA
    ind.WBeintx <- NA
    
    for(i in 1:dim(data)[1]){
      if(grepl("Mask",(data[i,1]))==T){ind.WBmask <- c(ind.WBmask, i)}
      
      if(grepl("F.bx",(data[i,1]))==T){ind.WBfbx <- c(ind.WBfbx, i)}
      if(grepl("P.bx",(data[i,1]))==T){ind.WBpbx <- c(ind.WBpbx, i)}
      if(grepl("CV.bx",(data[i,1]))==T){ind.WBcvbx <- c(ind.WBcvbx, i)}
      if(grepl("Eta2.bx",(data[i,1]))==T){ind.WBebx <- c(ind.WBebx, i)}
      
      if(grepl("F.wi",(data[i,1]))==T){ind.WBfwi <- c(ind.WBfwi, i)}
      if(grepl("P.wi",(data[i,1]))==T){ind.WBpwi <- c(ind.WBpwi, i)}
      if(grepl("CV.wi",(data[i,1]))==T){ind.WBcvwi <- c(ind.WBcvwi, i)}
      if(grepl("Eta2.wi",(data[i,1]))==T){ind.WBewi <- c(ind.WBewi, i)}
      
      if(grepl("F.intx",(data[i,1]))==T){ind.WBfintx <- c(ind.WBfintx, i)}
      if(grepl("P.intx",(data[i,1]))==T){ind.WBpintx <- c(ind.WBpintx, i)}
      if(grepl("CV.intx",(data[i,1]))==T){ind.WBcvintx <- c(ind.WBcvintx, i)}
      if(grepl("Eta2.intx",(data[i,1]))==T){ind.WBeintx <- c(ind.WBeintx, i)}
    }
    
    WBfbx.hold <- data[ind.WBfbx[-1],]
    WBcvbx.hold <- data[ind.WBcvbx[-1],]
    WBpbx.hold <- data[ind.WBpbx[-1],]
    WBebx.hold <- data[ind.WBebx[-1],]
    
    WBfwi.hold <- data[ind.WBfwi[-1],]
    WBcvwi.hold <- data[ind.WBcvwi[-1],]
    WBpwi.hold <- data[ind.WBpwi[-1],]
    WBewi.hold <- data[ind.WBewi[-1],]
    
    WBfintx.hold <- data[ind.WBfintx[-1],]
    WBcvintx.hold <- data[ind.WBcvintx[-1],]
    WBpintx.hold <- data[ind.WBpintx[-1],]
    WBeintx.hold <- data[ind.WBeintx[-1],]
    
    
    WBfbx.value <- str_split(WBfbx.hold[], " ", n=2, simplify = T)
    WBpbx.value <- str_split(WBpbx.hold[], " ", n=2, simplify = T)
    WBcvbx.value <- str_split(WBcvbx.hold[], " ", n=2, simplify = T)
    WBebx.value <- str_split(WBebx.hold[], " ", n=2, simplify = T)
    
    WBfwi.value <- str_split(WBfwi.hold[], " ", n=2, simplify = T)
    WBpwi.value <- str_split(WBpwi.hold[], " ", n=2, simplify = T)
    WBcvwi.value <- str_split(WBcvwi.hold[], " ", n=2, simplify = T)
    WBewi.value <- str_split(WBewi.hold[], " ", n=2, simplify = T)
    
    WBfintx.value <- str_split(WBfintx.hold[], " ", n=2, simplify = T)
    WBpintx.value <- str_split(WBpintx.hold[], " ", n=2, simplify = T)
    WBcvintx.value <- str_split(WBcvintx.hold[], " ", n=2, simplify = T)
    WBeintx.value <- str_split(WBeintx.hold[], " ", n=2, simplify = T)
    
    
    WB.data <- as.character(data[ind.WBmask[-1],])
    WB.data <- cbind(WB.data, WBfbx.value[,2])
    WB.data <- cbind(WB.data, WBpbx.value[,2])
    WB.data <- cbind(WB.data, WBcvbx.value[,2])
    WB.data <- cbind(WB.data, WBebx.value[,2])
    
    WB.data <- cbind(WB.data, WBfwi.value[,2])
    WB.data <- cbind(WB.data, WBpwi.value[,2])
    WB.data <- cbind(WB.data, WBcvwi.value[,2])
    WB.data <- cbind(WB.data, WBewi.value[,2])
    
    WB.data <- cbind(WB.data, WBfintx.value[,2])
    WB.data <- cbind(WB.data, WBpintx.value[,2])
    WB.data <- cbind(WB.data, WBcvintx.value[,2])
    WB.data <- cbind(WB.data, WBeintx.value[,2])
    
    WB.master <- as.matrix(cbind(t(t(rep(j,dim(WB.data)[1]))), WB.data))
    # WB.master <- rbind(WB.master, hold)
  }
  
  if(grepl("Post",j)==T){
    
    ind.Pmask <- NA
    ind.Pvalues <- NA
    ind.Pcv <- NA
    
    for(i in 1:dim(data)[1]){
      if(grepl("Mask",(data[i,1]))==T){ind.Pmask <- c(ind.Pmask, i)}
      if(grepl("t =",(data[i,1]))==T){ind.Pvalues <- c(ind.Pvalues, i)}
      if(grepl("95 percent",(data[i,1]))==T){ind.Pcv <- c(ind.Pcv, i+1)}
    }
    
    P.values.hold <- data[ind.Pvalues[-1],]
    P.cv.hold <- data[ind.Pcv[-1],]
    
    P.values <- str_split(P.values.hold[,1], ",", n=3, simplify=T)
    P.values <- as.data.frame(P.values)
    
    P.cv <- str_split(P.cv.hold[,1], " ", n=3, simplify = T)
    P.cv <- as.data.frame(P.cv[,-1])
    
 
    # Make a list of masks, to line data up
    maskHold <- NA
    hold.Pmask <- ind.Pmask[-1]
    for(i in 1:length(hold.Pmask)){
      hold <- data[hold.Pmask[i],]
      maskHold <- cbind(maskHold,hold)
    }
    
    # remove empty cells
    maskHold <- Filter(function(x)!all(is.na(x)),maskHold)
    maskHold <- maskHold[!sapply(maskHold,function(x) all(x == ""))]
    
    # remove everything before "_" and replace it with nothing
    for(i in 1:length(maskHold)){
      hold <- gsub("^.*?_","",maskHold[,i])    
      maskHold[,i] <- hold
    }
    maskHold <- as.list(maskHold)
    
    # loop through mask list, separate appropriate data
    count=1; for(i in maskHold){
      
      assign(paste0(i,"_pvalue"),c(t(P.values))[((12*count)-11):(12*count)])
      tmp.data <- get(paste0(i,"_pvalue"))
      assign(paste0(i,"_pvalue"), data.frame(lapply(tmp.data, function(x) t(data.frame(x)))))
      
      assign(paste0(i,"_cv"), c(t(P.cv))[((8*count)-7):(8*count)])
      tmp.cv <- get(paste0(i,"_cv"))
      assign(paste0(i,"_cv"), data.frame(lapply(tmp.cv, function(x) t(data.frame(x)))))
      
      count <- count+1
    }
    
    
    # combine all into a master list
    P.data <- matrix(0,nrow=length(maskHold),ncol=22)    # 22 = 2(analysis,mask) + 12(pvals) + 8(cvs)
    for(i in 1:length(maskHold)){
      P.data[i,] <- c(j,as.character(paste0("Mask",i)),as.matrix(get(paste0("Mask",i,"_pvalue"))),as.matrix(get(paste0("Mask",i,"_cv"))))
    }
    
    P.master <- as.data.frame(P.data)
  }
}

write.table(TT.master,paste0(outDir,"Stats_TTest_table.txt"),row.names=F)
write.table(WB.master,paste0(outDir,"Stats_WBRM_table.txt"),row.names=F)
write.table(P.master,paste0(outDir,"Stats_PostHocT_table.txt"),row.names=F)