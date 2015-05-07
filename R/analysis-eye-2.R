
source("functions-eye.R")
source("functions-expdef.R")


### Read experiment setup definitions: ###############################

def <- loadExpSetup("~/Workspace/MindSee/expsetup/stimuli")

head(def$Trials)

plotSetup(def$Stimuli[[1]])

sapply(def$Stimuli, function(x) sum(x$IsTarget))
