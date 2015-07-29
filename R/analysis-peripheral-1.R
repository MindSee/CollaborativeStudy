
source("functions-ledalab.R")
source("functions-eda.R")

library("reshape")
library("plyr")
library("ggplot2")


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



### Visual inspection of deconvolution: ##############################

plot_eda(leda[[1]])
plot_eda(leda[[4]])
plot_eda(leda[[58]])



### Focus on phasic: #################################################

phasic_leda <- lapply(leda, subset, select = -c(TonicData, Conductance))

maxval <- sapply(phasic_leda, function(x) max(x$PhasicData[!is.na(x$Trial)]))
maxval <- split(maxval, sapply(phasic_leda, function(x) x$Id[1]))
maxval <- lapply(maxval, max)
maxval <- melt(maxval)

for ( i in seq(along = phasic_leda )) {
  mv <- subset(maxval, L1 == phasic_leda[[i]]$Id[1])$value
  phasic_leda[[i]]$PhasicData <- phasic_leda[[i]]$PhasicData / mv
}

plot_phasiceda(phasic_leda[[2]])


## Compute features:
phasic_feat <- lapply(phasic_leda, compute_trial_feat)
phasic_feat <- do.call(rbind, phasic_feat)


## Visual inspection:
ggplot(phasic_feat, aes(Condition, PhasicFeat)) + geom_boxplot()
ggplot(phasic_feat, aes(Condition, PhasicFeat)) + geom_boxplot() + facet_wrap(~ Id)


# a <- split(phasic_feat$PhasicFeat, phasic_feat$Condition)
# wilcox.test(a$hf, a$lf)

#b <- subset(phasic_feat, Id == "VPpas")
#b <- split(b$PhasicFeat, b$Condition)
#wilcox.test(b$hf, b$lf)



# ### Mixed effects model: #############################################
# 
# library("lme4")
# 
# phasic_feat$Id <- factor(phasic_feat$Id)
# phasic_feat$Condition <- factor(phasic_feat$Condition)
# 
# 
# phasic_feat$PhasicFeat <- scale(phasic_feat$PhasicFeat)
# 
# m1 <- glmer(Condition ~ 1 + (1|Id) + PhasicFeat, data = phasic_feat, family = binomial)
# 
# m1
# summary(m1)
# fixef(m1)
# ranef(m1)
# 
# 

# ### Focus on tonic: ##################################################
# 
# plot_toniceda <- function(x) {
#   x$TonicData[is.na(x$Trial)] <- NA
#   x$Baseline[is.na(x$Trial)] <- NA
#   x$TonicDataNorm[is.na(x$Trial)] <- NA
#   
#   x <- subset(x, select = c(Time, TonicDataNorm))
#   x <- melt(x, id.vars = "Time")
#   
#   ggplot(x, aes(Time, value)) + geom_line() + facet_grid(variable ~ ., scales = "free_y")
# }
# 
# 
# 
# ### Remove baseline:
# 
# tonic_leda <- lapply(leda, subset, select = -c(PhasicData, Conductance))
# tonic_leda <- lapply(tonic_leda, 
#                      function(x) {
#                        x$BaselineMean <- mean(x$TonicData, na.rm = TRUE)  # "General sweat level of a person"
#                        x$BaselineSd <- sd(x$TonicData, na.rm = TRUE)      # "Sweat variation"
#                        x$TonicDataNorm <- (x$TonicData - x$BaselineMean) / x$BaselineSd
#                        #x$TonicDataNorm <- (x$TonicData - x$BaselineMean)
#                        x
#                      })
# 
# plot_toniceda(tonic_leda[[1]])
# plot_toniceda(tonic_leda[[2]])
# 
# 
# 
# ### Compute feature (i.e., integrate over time):
# 
# compute_trial_feat <- function(block) {
#   ddply(subset(block, !is.na(Trial)), "Trial",
#                function(x) {
#                  y <- x[1, ]
#                  y$TonicDataNorm <- sum(abs(x$TonicDataNorm))
#                  y$TonicData <- NULL
#                  y$BaselineMean <- NULL
#                  y$BaselineSd <- NULL
#                  y$Time <- NULL
#                  y
#                })
# }
# 
# tonic_feat <- lapply(tonic_leda, compute_trial_feat)
# tonic_feat <- do.call(rbind, tonic_feat)
#        
# ggplot(tonic_feat, aes(Condition, TonicDataNorm)) + geom_boxplot() 
