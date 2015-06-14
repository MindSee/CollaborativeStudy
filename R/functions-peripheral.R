
stopifnot(require("R.matlab"))
stopifnot(require("ggplot2"))
stopifnot(require("reshape"))


readPeripheral <- function(file, matlab_path = "/Applications/MATLAB_R2012b.app/bin/matlab") {
  ## Problem loading the BBCI saved file, therefore this way
  
  print(file)
  
  Matlab$startServer(matlab = matlab_path)
  matlab <- Matlab()
  isOpen <- open(matlab)
  
  evaluate(matlab, sprintf("per = load('%s');", file))
  
  evaluate(matlab, sprintf("fs = per.nfo.fs;"))
  fs <- getVariable(matlab, "fs")$fs[1, 1]
  
  evaluate(matlab, sprintf("mrktime = per.mrk.time;"))
  mrktime <- getVariable(matlab, "mrktime")$mrktime
  
  evaluate(matlab, sprintf("mrky = per.mrk.y;"))
  mrky <- getVariable(matlab, "mrky")$mrky
  
  evaluate(matlab, sprintf("mrkclass = per.mrk.className;"))
  mrkclass <- getVariable(matlab, "mrkclass")$mrkclass
  mrkclass <- unlist(mrkclass)
  
  mrkclass <- mrkclass[apply(mrky, 2, function(x) which(x == 1))]
  
  dat <- list()
  evaluate(matlab, sprintf("ch3 = per.ch3;"))
  dat$EDA <- getVariable(matlab, "ch3")$ch3
  
  evaluate(matlab, sprintf("ch2 = per.ch2;"))
  dat$EMGb <- getVariable(matlab, "ch2")$ch2
  
  evaluate(matlab, sprintf("ch1 = per.ch1;"))
  dat$EMGa <- getVariable(matlab, "ch1")$ch1
  
  close(matlab) 
  
  trial_start_time <- mrktime[mrkclass == "Start"]
  trial_stop_time <- mrktime[mrkclass == "Stop"]
  
  trial_start <- floor(trial_start_time / (1000/fs))
  trial_stop <- floor(trial_stop_time / (1000/fs))
  
  trials <- mapply(seq, trial_start, trial_stop, SIMPLIFY = FALSE)
  
  dat <- as.data.frame(dat)
  dat <- lapply(seq(trials), function(i) { dat[trials[[i]], ] })
  dat <- lapply(seq(dat), function(i) {cbind(trial = i, dat[[i]])})
  
  dat <- lapply(seq(dat), 
                function(i) {
                  dat[[i]]$time <- seq(trial_start_time[i],
                                       length.out = nrow(dat[[i]]), 
                                       by = (1000/fs)) 
                  dat[[i]]
                })
  
  dat <- do.call(rbind, dat)
  
  dat <- data.frame(Id = sub(".+Peripheral_(.+)_(.+)_(.+).mat", "\\3", file),
                    Condition = sub(".+Peripheral_(.+)_(.+)_(.+).mat", "\\1", file),
                    Symbol = sub(".+Peripheral_(.+)_(.+)_(.+).mat", "\\2", file),
                    dat)
  
  dat$TimeNorm <- do.call(c, lapply(split(dat$time, dat$trial), function(x) (x - min(x))))
  
  dat
}



