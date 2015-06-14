# Read and analize peripherals data.
#    
#   Author: Filippo M.  11/06/2015

stopifnot(require("R.matlab"))
stopifnot(require("ggplot2"))
stopifnot(require("reshape"))

readPeripherals <- function(pathHome) {
  # Update the .mat file of the peripheral.
  # 
  # Syntax:
  #   peripheral <- csPeripheral(filePeripheral)
  # 
  # Parameters:
  #   --
  #   
  #   Return values:
  #   --
  #   
  #   Author: Filippo M.  11/06/2015

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
  print("Process terminated.")
  
  mat
  
}

readPeripheral <- function(file) {
  # Update the .mat file of the peripheral.
  # 
  # Syntax:
  #   peripheral <- csPeripheral(filePeripheral)
  # 
  # Parameters:
  #   --
  #   
  #   Return values:
  #   --
  #   
  #   Author: Filippo M.  11/06/2015
  
  
  print(cat("Elaboro: ", file))
  
  # Read File
  mat <- readMat(file)
  
  # Parameters
  fs <- mat$fs
  mrktime <- mat$mrktime
  mrky <- mat$mrky
  mrkclass <- mat$mrkclass[apply(mat$mrky, 2, function(x) which(x == 1))]
  
  # Periperals
  peripheral <- list()
  peripheral$EDA <- mat$ch3
  peripheral$EMGb <- mat$ch2
  peripheral$EMGa <- mat$ch1
  
  trial_start_time <- mrktime[mrkclass == "Start"]
  trial_stop_time <- mrktime[mrkclass == "Stop"]
  trial_start <- floor(trial_start_time / (1000/fs))
  trial_stop <- floor(trial_stop_time / (1000/fs))
  trials <- mapply(seq, trial_start, trial_stop, SIMPLIFY = FALSE)
  
  peripheral <- data.frame(peripheral)
  
  #   peripheral <- lapply(seq(trials), function(i) { peripheral[trials[[i]], ] })
  #   peripheral <- lapply(seq(peripheral), function(i) {cbind(trial = i, peripheral[[i]])})
  #   
  #   peripheral <- lapply(seq(peripheral), 
  #                        function(i) {
  #                          peripheral[[i]]$time <- seq(trial_start_time[i],
  #                                                      length.out = nrow(peripheral[[i]]), 
  #                                                      by = (1000/fs)) 
  #                          peripheral[[i]]
  #                        })
  #   
  #   peripheral <- do.call(rbind, peripheral)
    
  peripheral <- data.frame(Id = sub(".+Peripheral_(.+)_(.+)_(.+).mat", "\\3", file),
                           Condition = sub(".+Peripheral_(.+)_(.+)_(.+).mat", "\\1", file),
                           Symbol = sub(".+Peripheral_(.+)_(.+)_(.+).mat", "\\2", file),
                           peripheral)
  #   
  #   peripheral$TimeNorm <- do.call(c, lapply(split(peripheral$time, peripheral$trial), function(x) (x - min(x))))
  
  peripheral
}

readBehaviourals <- function(pathDataBehavioural) {
  # Update the .mat file of the peripheral.
  # 
  # Syntax:
  #   peripheral <- csPeripheral(filePeripheral)
  # 
  # Parameters:
  #   --
  #   
  #   Return values:
  #   --
  #   
  #   Author: Filippo M.  11/06/2015
  
  pathParticipants <- list.files(pathHome, full = TRUE)
  nParticipants <- length(pathParticipants)
  
  pathBlocks <- list.files(pathParticipants, pattern = "Peripheral_*", full = TRUE)
  nBlocks <- length(pathBlocks)
  
  excel <- read.csv()
  
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
  
  mat
}

anovaEMG <- function(databasePeripherals, EMG) {
  # Linear Mixed Models
  fit0 <- lmer(EMG ~ 1 + (1|Id), data = databasePeripherals)
  coef(fit0)
  fit1 <- lmer(EMG ~ Condition + (1 + Condition |Id), data = databasePeripherals)
  coef(fit1)
  
  # Anova
  anova(fit0, fit1)
  
  # Summary Linear Mixed Model
  summary(lmer(EMG ~ Condition + (1 + Condition |Id), data = databasePeripherals))
  
  # Boxplot
  Boxplot(databasePeripherals$EMG ~ databasePeripherals$Condition)
}

