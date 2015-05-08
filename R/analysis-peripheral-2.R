
source("functions-peripheral.R")
source("functions-eye.R")



### EDA versus fixations: ############################################

eye_file <- "/Users/eugstem1/Workspace/MindSee/data/bbciMat/VPpab_15_03_06/EyeEvent_hf_cr_VPpab.mat"
per_file <- "/Users/eugstem1/Workspace/MindSee/data/bbciMat/VPpab_15_03_06/Peripheral_hf_cr_VPpab.mat"

dat_per <- readPeripheral(per_file)
dat_eye <- readEye(eye_file)

str(dat_per)
str(dat_eye)


ggplot(dat_per, aes(TimeNorm, EDA)) + geom_line() + facet_grid(trial ~ .) +
  geom_vline(data = subset(dat_eye, duration > (150 * 1000)), aes(xintercept = TimeNorm))



