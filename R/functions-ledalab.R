
stopifnot(require("R.matlab"))

readLedalab <- function(f, ORIGDIR, LEDADIR) {
  leda_obj <- readMat(file.path(LEDADIR, f))
  orig_obj <- readMat(file.path(ORIGDIR, f))
  
  ret <-
    data.frame(
      Id = sub("(.+)_\\d\\d_\\d\\d.+_EDA_(.+)_(.+)_.+.mat", "\\1", f),
      Condition = sub("(.+)_\\d\\d_\\d\\d.+_EDA_(.+)_(.+)_.+.mat", "\\2", f),
      Symbol = sub("(.+)_\\d\\d_\\d\\d.+_EDA_(.+)_(.+)_.+.mat", "\\3", f),
      Trial = NA_integer_,
      Time = leda_obj$data["time", , ]$time[1, ],
      Conductance = leda_obj$data["conductance", , ]$conductance[1, ],
      PhasicData = leda_obj$analysis["phasicData", , ]$phasicData[1, ],
      TonicData = leda_obj$analysis["tonicData", , ]$tonicData[1, ])
  
  fs <- orig_obj$data["fs", , ]$fs[1, 1]
  trials <- orig_obj$data["trials", , ]$trials
  trials <- round(trials / (1000 / fs))
  
  for ( i in 1:ncol(trials) ) {
    ret$Trial[seq(from = trials[1, i], to = trials[2, i])] <- i
  }
  
  ret
}
