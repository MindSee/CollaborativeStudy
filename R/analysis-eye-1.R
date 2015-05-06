
library("stringr")

source("functions-import.R")



### Read experiment setup definitions: ###############################

source("definition-experiment.R")

SETUPDIR <- "~/Workspace/MindSee/expsetup/stimuli"

expsetup <- import



conditions <- list.files(SETUPDIR, full = TRUE)
files <- lapply(conditions, list.files, pattern = ".*xml", full = TRUE)
files <- unlist(files, recursive = FALSE)

setups <- lapply(files, readExpSetup)



### Read fixation data: ##############################################

EYEDIR <- "~/Workspace/MindSee/data/bbciMat/"

participants <- list.files(EYEDIR, full = TRUE)
files <- lapply(participants, list.files, pattern = "EyeEvent_*", full = TRUE)

eyes <- lapply(files, lapply, readEye)

str(eyes[[1]][[1]], 1)


### ... ##############################################################

plot_setup <- function(x) {
  plot(x$xPos, x$yPos, pch = 19, col = ifelse(x$IsTarget, "red", "lightgray"),
       xlim = c(0, 1680), ylim = c(0, 1050))
}


get_setup <- function(x, setups) {
  s_cond <- as.character(sapply(setups, function(y) y$Condition[1]))
  s_symb <- as.character(sapply(setups, function(y) y$Symbol[1]))
  
  w <- which(x$Condition[1] == s_cond & x$Symbol[1] == s_symb)
}


plot_setup(setups[[1]][[3]])

lapply(setups, lapply, function(x) sum(x$IsTarget))



setups[[1]][[1]]

setups[[1]][[1]]

