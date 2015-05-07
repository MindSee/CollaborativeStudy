
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




