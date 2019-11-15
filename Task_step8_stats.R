



### Set up
parDir <- "/Volumes/Yorick/WiscoPhero/"
grpDir <- paste0(parDir,"Analyses/grpAnalysis/")
graphDir <- paste0(parDir,"write/")

dataDir <- paste0(grpDir,"/mvm_betas/")
statDir <- paste0(grpDir,"/mvm_stats/")
mvmBetas_list <- list.files(dataDir)

sv_dataDir <- paste0(grpDir,"/mvm_betas_smallVol/")
sv_statDir <- paste0(grpDir,"/mvm_stats_smallVol/")
sv_mvmBetas_list <- list.files(sv_dataDir)

outDir <- paste0(parDir,"Tables/")




### Functions
Function.mask <- function(analysis,comparison,cluster){
  if(analysis=="WB"){
    if(cluster==1){
      hold.roi <- "L. Frontal Pole"
      hold.name <- "LFP"
    }else{
      hold.roi <- "R. Frontal Pole"
      hold.name <- "RFP"
    }
  }else{
    if(comparison=="Lav-P2"){
      hold.roi <- "L. Anterior Insula"
      hold.name <- "LAIns"
    }else{
      hold.roi <- "R. Orbitofrontal"
      hold.name <- "ROFC"
    }
  }
  return(hold.name)
}




### MVM - whole brain
# j <- "Betas_PherOlf_F-M_Lav-P2.txt"

for(j in t(mvmBetas_list)){
  
  ## Get data
  raw_data <- read.delim2(paste0(dataDir,j),header=F)
  
  # num masks
  ind.mask <- grep("Mask", raw_data[,1])
  num.mask <- as.numeric(length(ind.mask))
  
  # num subjects
  ind.subj <- grep("File", raw_data[,1])
  num.subj <- as.numeric(length(ind.subj)/num.mask)
  hold.subj <- as.character(raw_data[ind.subj,1])
  list.subj.tmp <- gsub(" File","",hold.subj)
  list.subj <- list.subj.tmp[1:num.subj]
  
  # num betas
  ind.beta <- grep("beh", raw_data[,2])
  num.betas <- as.numeric(length(ind.beta)/num.subj/num.mask)
  ind.beta.start <- ind.beta[1]; ind.beta.end <- ind.beta[num.betas]
  hold.betas <- as.character(raw_data[ind.beta.start:ind.beta.end,2])
  hold.betas.tmp <- gsub("\\#.*$","",hold.betas)
  list.betas <- gsub("^.*_","",hold.betas.tmp)
  
  
  ## Make df for e/mask
  # written for two masks, two betas each
  
  lowerB <- 1; upperB <- ind.mask[2]-1
  for(k in 1:num.mask){
    
    # determine position of relevant data
    df_hold <- raw_data[lowerB:upperB,]
    ind.hold_beta <- grep("beh",df_hold[,2])
    ind.beh1 <- ind.hold_beta[c(TRUE, FALSE)]
    ind.beh2 <- ind.hold_beta[c(FALSE, TRUE)]
    
    # make wide dateframe
    df <- matrix(0,ncol=num.betas+2,nrow=num.subj)
    colnames(df) <- c("Subj","Sex",list.betas)
    df[,1] <- list.subj
    df[,3] <- as.numeric(as.character(df_hold[ind.beh1,3]))
    df[,4] <- as.numeric(as.character(df_hold[ind.beh2,3]))
    for(m in 1:length(df_hold[ind.beh1,1])){
      if(grepl("sub-1",as.character(df_hold[ind.beh1[m],1]))==T){
        df[m,2] <- "F"
      }else{
        df[m,2] <- "M"
      }
    }
    
    # Determine mask
    maskName <- Function.mask("WB","Foo",k)
    
    # write dataframe
    write.table(df,file=paste0(outDir,"Table_WB_",maskName,".txt"),sep = "\t",row.names=F,col.names=T,quote=F)
    
    
    # # make long dataframe
    # df_long <- matrix(NA,nrow=num.betas*dim(df)[1],ncol=4)
    # colnames(df_long) <- c("Subj","Sex","Beta","Value")
    # df_long[,1] <- rep(list.subj,2)
    # df_long[,2] <- rep(df[,2],2)
    # df_long[,3] <- c(rep(list.betas[1],num.subj),rep(list.betas[2],num.subj))
    # df_long[1:num.subj,4] <- df[,3]
    # df_long[(num.subj+1):(2*num.subj),4] <- df[,4]
    
    lowerB <- upperB+1; upperB <- dim(raw_data)[1]
  }
}




### MVM - small volume
# j <- "Betas_PherOlf_F-M_Lav-P2.txt"

for(j in t(sv_mvmBetas_list)){
  
  ## Get data
  raw_data <- read.delim2(paste0(sv_dataDir,j),header=F)
  
  # num masks
  ind.mask <- grep("Mask", raw_data[,1])
  num.mask <- as.numeric(length(ind.mask))
  
  # num subjects
  ind.subj <- grep("File", raw_data[,1])
  num.subj <- as.numeric(length(ind.subj)/num.mask)
  hold.subj <- as.character(raw_data[ind.subj,1])
  list.subj.tmp <- gsub(" File","",hold.subj)
  list.subj <- list.subj.tmp[1:num.subj]
  
  # num betas
  ind.beta <- grep("beh", raw_data[,2])
  num.betas <- as.numeric(length(ind.beta)/num.subj/num.mask)
  ind.beta.start <- ind.beta[1]; ind.beta.end <- ind.beta[num.betas]
  hold.betas <- as.character(raw_data[ind.beta.start:ind.beta.end,2])
  hold.betas.tmp <- gsub("\\#.*$","",hold.betas)
  list.betas <- gsub("^.*_","",hold.betas.tmp)
  
  
  ## Make df for e/mask
  # written for one, two betas each
    
  # determine position of relevant data
  df_hold <- raw_data
  ind.hold_beta <- grep("beh",df_hold[,2])
  ind.beh1 <- ind.hold_beta[c(TRUE, FALSE)]
  ind.beh2 <- ind.hold_beta[c(FALSE, TRUE)]
  
  # make wide dateframe
  df <- matrix(0,ncol=num.betas+2,nrow=num.subj)
  colnames(df) <- c("Subj","Sex",list.betas)
  df[,1] <- list.subj
  df[,3] <- as.numeric(as.character(df_hold[ind.beh1,3]))
  df[,4] <- as.numeric(as.character(df_hold[ind.beh2,3]))
  for(m in 1:length(df_hold[ind.beh1,1])){
    if(grepl("sub-1",as.character(df_hold[ind.beh1[m],1]))==T){
      df[m,2] <- "F"
    }else{
      df[m,2] <- "M"
    }
  }
  
  # Determine mask
  maskName <- Function.mask("SV",paste0(list.betas[1],"-",list.betas[2]),"Foo")
  
  # write dataframe
  write.table(df,file=paste0(outDir,"Table_SV_",maskName,".txt"),sep = "\t",row.names=F,col.names=T,quote=F)
}

