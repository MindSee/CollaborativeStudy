
stopifnot(require("R.matlab"))
stopifnot(require("ggplot2"))
stopifnot(require("reshape"))
stopifnot(require("classInt"))


readEye <- function(file) {
  print(file)
  
  mat <- readMat(file)

  trials <- unlist(mat$eye[, , 1]$events[, , 1]$description)
  trials <- which(grepl("_Start_", trials))
  
  if ( is.null(mat$eye[, , 1]$fixations) )
    return(NULL)
  
  mat <- mat$eye[, , 1]$fixations[, , 1]
  
  loc <- mat$location
  loc <- do.call(cbind, loc)
  colnames(loc) <- c("x", "y")
  
  pup <- mat$pupil[, , 1]$size[, , 1]$x
  
  mat$location <- NULL
  mat$plane <- NULL
  mat$dispersion <- NULL
  mat$pupil <- NULL
  
  mat <- as.data.frame(mat)
  mat <- cbind(mat, loc, pupil = pup)
  
  mat <- cbind(Id = sub(".+EyeEvent_(.+)_(.+)_(.+).mat", "\\3", file),
               Condition = sub(".+EyeEvent_(.+)_(.+)_(.+).mat", "\\1", file),
               Symbol = sub(".+EyeEvent_(.+)_(.+)_(.+).mat", "\\2", file),
               mat)
  
  mat <- mat[mat$trial %in% trials, ]
  mat$trial <- as.integer(ordered(mat$trial))
  
  mat$TimeNorm <- 
    do.call(c, lapply(split(mat$start, mat$trial), function(x) (x - min(x)) / 1000))
  
  mat
}


plotFixations <- function(x) {
  cl <- classIntervals(x$duration / 1000, style = "equal", n = 10)
  
  cols <- findCols(cl)
  ta <- classInt:::tableClassIntervals(cols, cl$brks, dataPrecision = 0)
  
  x$DurationClass <- ordered(cols, levels = seq(max(cols)), labels = names(ta))
  
  cat(sprintf("%s_%s_%s, Trial %s", 
          as.character(x$Condition[1]), as.character(x$Symbol[1]), 
          as.character(x$Id[1]), as.character(x$trial[1])), "\n")
  
  
  ggplot(x, aes(x, y, size = DurationClass, colour = DurationClass)) + 
    geom_point() + 
    xlim(c(0, 1680)) + ylim(c(0, 1050))
}


fixationStats <- function(x) {
  if ( is.null(x) ) 
    return(NULL)
  
  data.frame(
    Id = x$Id[1],
    Condition = x$Condition[1],
    Symbol = x$Symbol[1],
    NumFixations = nrow(x), 
    MeanDuration = mean(x$duration / 1000), 
    NumFixations150 = sum((x$duration / 1000) > 150),
    MeanPupil = mean(x$pupil))
}


fixationOnTarget <- function(eye, expdef, th = 60) {
  locs <- get_expdef_tarloc(eye, expdef)
  
  de <- as.matrix(eye[, c("x", "y")])
  lo <- as.matrix(locs[, c("x", "y")])
  
  fixdist <- flexclust::distEuclidean(de, lo)
  isTarfix <- which(fixdist < th, arr.ind = TRUE)
  
  isTarfix[, "row"]
}


targetsFixated <- function(eye, expdef, th = 60) {
  locs <- get_expdef_tarloc(eye, expdef)

  de <- as.matrix(eye[, c("x", "y")])
  lo <- as.matrix(locs[, c("x", "y")])
  
  fixdist <- flexclust::distEuclidean(de, lo)
  isTarfix <- which(fixdist < th, arr.ind = TRUE)
  
  unique(isTarfix[, "col"])
}


plotFixationOnTarget <- function(eye, expdef, th = 60) {
  locs <- get_expdef_tarloc(eye, expdef)
  
  f <- fixationOnTarget(eye, expdef, th = th)
  
  op <- par(mar = c(4, 4, 0, 0) + 0.1)
  plot(locs[, c("x", "y")], xlim = c(0, 1680),  ylim = c(0, 1050), col = "red", pch = 19)
  symbols(locs[, c("x", "y")], circles = rep(60, nrow(locs[, c("x", "y")])), add = TRUE, inches = FALSE)
  points(eye[f, c("x", "y")], col = "black", pch = 19)
  par(op)
}



getNumTargetsFixated <- function(x) {
  tr <- sort(unique(x$trial))
  sapply(tr, function(i) length(targetsFixated(get_trial(x, i), expdef)))
}

getNumTargetsAnswer <- function(x) {
  tr <- sort(unique(x$Trial))
  sapply(tr, function(i) get_trial(x, i)$Answer)
}

getNumTargetsTrue <- function(x) {
  tr <- sort(unique(x$Trial))
  sapply(tr, function(i) get_trial(x, i)$Target)
}

getNumTarFix <- function(eye, beh) {
  fi <- getNumTargetsFixated(eye)
  an <- getNumTargetsAnswer(beh)
  tr <- getNumTargetsTrue(beh)
  
  cbind(Fixated = fi,
        Answered = an[seq(along = fi)],
        True = tr[seq(along = fi)])
}
