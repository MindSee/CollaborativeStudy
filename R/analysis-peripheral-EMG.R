# Peripherals.
#    
#   Author: Filippo M.  11/06/2015


source("~/Documents/MindSee/CollaborativeStudy/R/utils.R")
source("~/Documents/MindSee/CollaborativeStudy/R/functions-peripheral-EMG.R")
clearAll()

stopifnot(require("R.matlab"))
stopifnot(require("ggplot2"))
stopifnot(require("reshape"))

pathHome <- "/Users/filippominelle/Documents/MindSee/data/DataPeripheral"
pathParticipants <- list.files(pathHome, full = TRUE)
nParticipants <- length(pathParticipants)

pathBlocks <- list.files(pathParticipants, pattern = "Peripheral_*", full = TRUE)
nBlocks <- length(pathBlocks)

boolIsFirst = TRUE
for (iBlocks in 1:nBlocks) {
  file <- pathBlocks[iBlocks]
  if (grepl("old", file)) {
    print(cat("Non Elaboro: ", file))
  } 
  else{
    if (boolIsFirst){
      mat <- readPeripheral(file)
      boolIsFirst = FALSE
    }
    else{
      mat <- rbind(mat, readPeripheral(file))
    }       
  }
}

clearConsole()
print("Processo terminato.")
