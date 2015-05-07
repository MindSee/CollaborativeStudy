
stopifnot(require("R.matlab"))


readBehaviour <- function(file) {
  x <- readMat(file)
  
  a <- as.numeric(x$behaviour[[1]])
  t <- as.numeric(x$behaviour[[2]])
  s <- as.numeric(x$behaviour[[3]]) / 1000
  
  y <- matrix(NA_integer_, nrow = 3, ncol = 4)
  y[1, 1:length(t)] <- a[1:length(t)]
  y[2, 1:length(t)] <- t[1:length(t)]
  y[3, 1:length(t)] <- s[1:length(t)]
  rownames(y) <- c("Answer", "Target", "Time")
  
  y <- as.data.frame(t(y))
  y <- cbind(Id = sub(".+Behaviour_(.+)_(.+)_(.+).mat", "\\3", file),
             Condition = sub(".+Behaviour_(.+)_(.+)_(.+).mat", "\\1", file),
             Symbol = sub(".+Behaviour_(.+)_(.+)_(.+).mat", "\\2", file),
             Trial = 1:nrow(y),
             y)
  y
}


readEye <- function(file) {
  mat <- readMat(file)
  mat <- mat$eye[, , 1]$fixations[, , 1]
  
  loc <- mat$location
  loc <- do.call(cbind, loc)
  colnames(loc) <- c("x", "y")
  
  mat$location <- NULL
  mat$plane <- NULL
  mat$dispersion <- NULL
  mat$pupil <- NULL
  
  mat <- as.data.frame(mat)
  mat <- cbind(mat, loc)
  
  mat <- cbind(Id = sub(".+EyeEvent_(.+)_(.+)_(.+).mat", "\\3", file),
               Condition = sub(".+EyeEvent_(.+)_(.+)_(.+).mat", "\\1", file),
               Symbol = sub(".+EyeEvent_(.+)_(.+)_(.+).mat", "\\2", file),
               mat)
  
  mat
}

