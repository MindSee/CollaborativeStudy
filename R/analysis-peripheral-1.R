
source("functions-ledalab.R")

## There are two main components to the overall complex referred to as EDA
## 1) tonic-level EDA which relates to the slower acting components and 
##    background characteristics of the signal (the overall level, 
##    slow climbing, slow declinations over time).
##
## 2) phasic component which refers to the faster changing elements of
##    the signal



### Read LEDALAB results: ############################################

ORIGDIR <- "~/Workspace/MindSee/data/ledalabMat_orig/"
LEDADIR <- "~/Workspace/MindSee/data/ledalabMat/"

leda_files <- list.files(LEDADIR, pattern = ".+VPpa.+")
orig_files <- list.files(ORIGDIR, pattern = ".+VPpa.+")

stopifnot(all(orig_files == leda_files))

leda <- lapply(leda_files, readLedalab, ORIGDIR, LEDADIR)




plot(leda[[2]]$Time, leda[[2]]$TonicData, type = "l")
plot(leda[[4]]$Time, leda[[4]]$TonicData, type = "l")

plot(leda[[58]]$Time, leda[[58]]$TonicData, type = "l")
plot(leda[[4]]$Time, leda[[4]]$PhasicData, type = "l")




