
plot_eda <- function(x) {
  x$Conductance[is.na(x$Trial)] <- NA
  x$PhasicData[is.na(x$Trial)] <- NA
  x$TonicData[is.na(x$Trial)] <- NA
  
  x <- subset(x, select = c(Time, Conductance, PhasicData, TonicData))
  x <- melt(x, id.vars = "Time")
  
  ggplot(x, aes(Time, value)) + geom_line() + facet_grid(variable ~ .)
}


plot_phasiceda <- function(x) {
  x$PhasicData[is.na(x$Trial)] <- NA
  
  x <- subset(x, select = c(Time, PhasicData))
  x <- melt(x, id.vars = "Time")
  
  ggplot(x, aes(Time, value)) + geom_line() + facet_grid(variable ~ .)  
}


compute_trial_feat <- function(block) {
  ddply(subset(block, !is.na(Trial)), "Trial",
        function(x) {
          y <- x[1, ]
          y$PhasicFeat <- sum(abs(x$PhasicData))
          y$Time <- NULL
          y$PhasicData <- NULL
          y
        })
}

