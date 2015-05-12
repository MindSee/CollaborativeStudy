
source("functions-eye.R")
source("functions-behaviour.R")
source("functions-expdef.R")


get_trial <- function(x, which) {
  
  if ( !is.null(x$trial) ) {
    return(subset(x, trial == which))
  }
  if ( !is.null(x$Trial) ) {
    return(subset(x, Trial == which))
  }
  
  return(NULL)
}


### Load experiment definition: ######################################

TARLOCDIR <- "/Users/eugstem1/Workspace/MindSee/expsetup/targetlocs/"
SETUPDIR <- "/Users/eugstem1/Workspace/MindSee/expsetup/stimuli/"

expdef <- loadExpSetup(SETUPDIR, TARLOCDIR)



### Read fixation data: ##############################################

EYEDIR <- "~/Workspace/MindSee/data/bbciMat/"

participants <- list.files(EYEDIR, full = TRUE)
files <- lapply(participants, list.files, pattern = "EyeEvent_*", full = TRUE)

eyes <- lapply(files, lapply, readEye)



### Read behaviour data: #############################################

BEHDIR <- "~/Workspace/MindSee/data/bbciMat/"

participants <- list.files(BEHDIR, full = TRUE)
files <- lapply(participants, list.files, pattern = "Behaviour_*.", full = TRUE)
beh <- lapply(files, lapply, readBehaviour)



### Example trials: ##################################################

plotFixationOnTarget(get_trial(eyes[[1]][[1]], 1), expdef)
get_trial(beh[[1]][[1]], 1)
length(targetsFixated(get_trial(eyes[[1]][[1]], 1), expdef))

plotFixationOnTarget(get_trial(eyes[[1]][[1]], 2), expdef)
get_trial(beh[[1]][[1]], 2)
length(targetsFixated(get_trial(eyes[[1]][[1]], 2), expdef))

plotFixationOnTarget(get_trial(eyes[[1]][[1]], 3), expdef)
get_trial(beh[[1]][[1]], 3)
length(targetsFixated(get_trial(eyes[[1]][[1]], 3), expdef))

plotFixationOnTarget(get_trial(eyes[[1]][[1]], 4), expdef)
get_trial(beh[[1]][[1]], 4)
length(targetsFixated(get_trial(eyes[[1]][[1]], 4), expdef))



### Number of targets fixated versus Answer: #########################

x <- mapply(function(x, y) mapply(getNumTarFix, x, y, SIMPLIFY = FALSE), eyes, beh, SIMPLIFY = FALSE)
x <- lapply(x, function(y) do.call(rbind, y[sapply(y, length) > 0]))
x <- do.call(rbind, x)
x <- as.data.frame(x)

x$DeltaScore <- x$True - x$Answered
x$DeltaFixated <- x$Answered - x$Fixated


ggplot(x, aes(Fixated)) + geom_histogram()
ggplot(x, aes(DeltaFixated)) + geom_histogram()



### Trials which might be just guessed: ##############################

sum(abs(x$DeltaFixated) > 5, na.rm = TRUE)

