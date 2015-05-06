
library("R.matlab")
library("ggplot2")
library("reshape")
library("plyr")



### Read behavioural data: ###########################################

readBehaviour <- function(file) {
  print(file)
  x <- readMat(file)

  a <- as.numeric(x$behaviour[[1]])
  t <- as.numeric(x$behaviour[[2]])
  s <- as.numeric(x$behaviour[[3]]) / 1000
  
  y <- matrix(NA_integer_, nrow = 3, ncol = 4)
  y[1, 1:length(t)] <- a[1:length(t)]
  y[2, 1:length(t)] <- t[1:length(t)]
  y[3, 1:length(t)] <- s[1:length(t)]
  rownames(y) <- c("Answer", "Target", "Time")
  
  y <- as.data.frame(t(y))
  y <- cbind(Id = sub(".+Behaviour_(.+)_(.+)_(.+).mat", "\\3", file),
             Condition = sub(".+Behaviour_(.+)_(.+)_(.+).mat", "\\1", file),
             Symbol = sub(".+Behaviour_(.+)_(.+)_(.+).mat", "\\2", file),
             Trial = 1:nrow(y),
             y)
  y
}


DIR <- "~/Workspace/MindSee/data/bbciMat/"

participants <- list.files(DIR, full = TRUE)
files <- lapply(participants, list.files, pattern = "Behaviour_*.", full = TRUE)

dat <- lapply(files, function(f) do.call(rbind, lapply(f, readBehaviour)))
dat <- do.call(rbind, dat)
dat$Delta <- dat$Target - dat$Answer

## Order same for every participant:
lev <- c("hf-sq", "lf-do", "hf-st", "lf-tr",
         "hf-es", "lf-cr", "hf-do", "lf-es",
         "hf-tr", "lf-st", "hf-cr", "lf-sq")


dat$TrialDesc <- sprintf("%s-%s", dat$Condition, dat$Symbol)
dat$TrialDesc <- ordered(dat$TrialDesc, levels = lev)

dat$SymbolType <- NA_character_
dat$SymbolType <- ifelse(dat$Symbol %in% c("sq", "es", "tr"), "Shape", dat$SymbolType)
dat$SymbolType <- ifelse(dat$Symbol %in%  c("do", "st", "cr"), "Pattern", dat$SymbolType)
dat$SymbolType <- factor(dat$SymbolType)



### Distribution of errors: ##########################################

ggplot(dat, aes(Delta, colour = Condition)) + geom_density()

# wilcox.test(subset(dat, Condition == "hf")$Delta, subset(dat, Condition == "lf")$Delta)


ggplot(dat, aes(Condition, Delta)) + geom_boxplot()
ggplot(dat, aes(Symbol, Delta)) + geom_boxplot()


ggplot(dat, aes(Trial, Delta, group = Trial)) + geom_boxplot() + facet_wrap(~ Condition)
ggplot(dat, aes(Trial, Delta, group = Trial)) + geom_boxplot() + facet_wrap(~ Symbol)



### Distribution of error "over time": ###############################

ggplot(dat, aes(Trial, Delta)) + 
  geom_hline(yintercept = 0, colour = "gray") +
  geom_boxplot(aes(group = Trial)) +
  geom_point() + 
  stat_summary(fun.y = mean, geom = "line", colour = "red") + 
  facet_wrap( ~ TrialDesc, ncol = 12, nrow = 1)



### Answer time: #####################################################

ggplot(dat, aes(abs(Delta), Time)) + geom_point()
ggplot(dat, aes(Trial, Time)) + geom_point()

ggplot(dat, aes(Time)) + geom_histogram() + facet_wrap(~ Trial)



### Per participant: #################################################

ggplot(dat, aes(Id, Time)) + geom_point()
ggplot(dat, aes(Id, Time, colour = factor(Trial))) + geom_hline(yintercept = 20) + geom_point()
ggplot(dat, aes(Id, abs(Delta), colour = factor(Trial))) + geom_hline(yintercept = 5) + geom_point()



### Overall stats: ###################################################

with(dat[complete.cases(dat), ], cor(Time, Target))
with(dat[complete.cases(dat), ], cor(Time, Answer))
with(dat[complete.cases(dat), ], cor(Time, Delta))

with(subset(dat[complete.cases(dat), ], Condition == "hf"), cor(Time, Delta))
with(subset(dat[complete.cases(dat), ], Condition == "lf"), cor(Time, Delta))

### Number of trials per block
### Number of trials per participant



### Trial quality: ###################################################

dat$MissingTrial <- is.na(dat$Answer)
dat$GoodTrial <- !dat$MissingTrial & dat$Time > 20 & abs(dat$Delta) < 5

table(dat$MissingTrial, dat$Id)
table(dat$MissingTrial, dat$Condition)
table(dat$MissingTrial, dat$Trial)
table(dat$MissingTrial, dat$Condition)
table(dat$MissingTrial, dat$Symbol)

table(dat$GoodTrial)
table(dat$GoodTrial, dat$Id)
table(dat$GoodTrial, dat$Trial)
table(dat$GoodTrial, dat$Condition)
table(dat$GoodTrial, dat$Symbol)



### Trials to be removed: ############################################

with(subset(dat, !GoodTrial), sprintf("%s_%s_%s", Condition, Symbol, Id))

