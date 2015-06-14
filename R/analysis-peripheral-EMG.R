# Peripherals EMG analysis
#    
#   Author: Patrik P. Filippo M.  11/06/2015


# Clear Console
clearConsole()

# Loading required packages and library
stopifnot(require("R.matlab"))
stopifnot(require("ggplot2"))
stopifnot(require("reshape")) # Reshaping dataframe
require("pgirmess") # Friedman Posthoc test
require("plyr")
library("ez")
library("multcomp")
library("nlme")
library("pastecs")
library("lattice")
library("WRS2")
library("car") #useful for influential plot in case
library("lme4")
require("lmerTest")
library("lsmeans")
require("lsmeans")
library("pbkrtest")
require("pbkrtest")

source("~/Documents/MindSee/CollaborativeStudy/R/utils.R")
source("~/Documents/MindSee/CollaborativeStudy/R/functions-peripheral-EMG.R")
# source("~/Documents/MindSee/CollaborativeStudy/R/timeTot.R")

# Path
pathDataPeripherals <- "~/Documents/MindSee/data/DataPeripheral"
pathDataBehavioural  <- "~/Documents/MindSee/data/Behavioural_data_Collaborative_Study"

# Get Peripherals Data
boolReadPeripheralsTxt = TRUE
if (boolReadPeripheralsTxt){
  Peripheral_d <- read.table("~/Documents/MindSee/data/bbciRaw/Peripheral_d.txt", header = T)
} else {
  Peripheral_d <- readPeripherals(pathDataPeripherals)
  str(Peripheral_d)  
}

# Get Behavioural Data
boolReadBehaviouralTxt = FALSE
if (boolReadBehaviouralTxt){
  Peripheral_d <- read.table("~/Documents/MindSee/data/bbciRaw/Peripheral_d.txt", header = T)
} else {
  Behavioural_d <- readPeripherals(pathDataBehavioural)
  str(Behavioural_d)  
}

# Mean
tapply(Peripheral_d$EMGb, Peripheral_d$Condition, mean)
tapply(Peripheral_d$EMGa, Peripheral_d$Condition, mean)

# Subset
Hf_d <- subset(Peripheral_d, Peripheral_d$Condition == "hf")
length(Hf_d$EMGa)
Lf_d <- subset(Peripheral_d, Peripheral_d$Condition == "lf")
length(Lf_d$EMGa)

# Plot
qplot(Hf_d$EMGa)
qplot(Lf_d$EMGa)
qplot(Hf_d$EMGb)
qplot(Lf_d$EMGb)

# Anova - Linear Mixed Models
anovaEMGa <- anovaEMG(Peripheral_d, EMGa)
anovaEMGb <- anovaEMG(Peripheral_d, EMGb)
