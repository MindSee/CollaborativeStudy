
library("stringr")

source("functions-eye.R")


### Read fixation data: ##############################################

EYEDIR <- "~/Workspace/MindSee/data/bbciMat/"

participants <- list.files(EYEDIR, full = TRUE)
files <- lapply(participants, list.files, pattern = "EyeEvent_*", full = TRUE)

eyes <- lapply(files, lapply, readEye)


plotFixations(subset(eyes[[1]][[1]], trial == 1))
plotFixations(subset(eyes[[1]][[1]], trial == 2))
plotFixations(subset(eyes[[1]][[1]], trial == 3))
plotFixations(subset(eyes[[1]][[1]], trial == 4))



### Summary statistics per condition: ################################

# Number of fixations
# Mean duration of fixation
# Number of fixations > 150

stats <- lapply(eyes, lapply, fixationStats)
stats <- do.call(rbind, unlist(stats, recursive = FALSE))

ggplot(stats, aes(Condition, NumFixations)) + geom_boxplot()
ggplot(stats, aes(Condition, MeanDuration)) + geom_boxplot()
ggplot(stats, aes(Condition, NumFixations150)) + geom_boxplot()
ggplot(stats, aes(Condition, MeanPupil)) + geom_boxplot()



### Summary statistics per condition and participant: ################

ggplot(stats, aes(Condition, NumFixations)) + geom_boxplot() + facet_grid(. ~ Id)
ggplot(stats, aes(Condition, MeanDuration)) + geom_boxplot() + facet_grid(. ~ Id)
ggplot(stats, aes(Condition, NumFixations150)) + geom_boxplot() + facet_grid(. ~ Id)
ggplot(stats, aes(Condition, MeanPupil)) + geom_boxplot() + facet_grid(. ~ Id)



### Focus on one shape in the two conditions: ########################

ggplot(stats, aes(Condition, NumFixations)) + geom_boxplot() + facet_grid(. ~ Symbol)
ggplot(stats, aes(Condition, MeanDuration)) + geom_boxplot() + facet_grid(. ~ Symbol)
ggplot(stats, aes(Condition, NumFixations150)) + geom_boxplot() + facet_grid(. ~ Symbol)
ggplot(stats, aes(Condition, MeanPupil)) + geom_boxplot() + facet_grid(. ~ Symbol)

