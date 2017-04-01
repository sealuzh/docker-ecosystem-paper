library(ggplot2)
library(scales)
library(gridExtra)
library(plyr)
library(dplyr)
library(tidyr)   
library(hexbin)


data <- read.csv("instructions.csv", header=TRUE)

data <- data %>%
  filter(count < 80, instructions < 80)

# bin<-hexbin(data$instructions, data$count, xbins=75, xlab = "bla") 
# plot(bin, xlab = "Instructions", ylab = "Rule Violations")

# gplot.hexbin(bin,colorcut=10)

pdf("rule_violation_density.pdf",width=6.5,height=6.5)
plot(data$instructions, data$count, xlab = "Instructions", ylab = "Rule Violations", col=rgb(0,100,0,50,maxColorValue=255), pch=16)
dev.off()



build = data.frame()

runs = seq(1,3)
for(run in runs) {
  path = paste("build/results/run", run, ".csv",  collapse = '', sep='')
  
  newResults <- read.csv(path, header=FALSE, sep=";")
  build <- rbind(build, newResults)
  
}  

colnames(build) <- c("project", "time", "status")

data <- read.csv("instructions.csv", header=TRUE)
failed <- data %>%
  filter(repo_path %in% build$project[build$status == 0] )

success <- data %>%
  filter(repo_path %in% build$project[build$status == 1] )
  
# bin<-hexbin(data$instructions, data$count, xbins=75, xlab = "bla") 
# plot(bin, xlab = "Instructions", ylab = "Rule Violations")

# gplot.hexbin(bin,colorcut=10)

pdf("rule_violation_density_success.pdf",width=6.5,height=6.5)
plot(success$instructions, success$count, xlab = "Instructions", ylab = "Rule Violations", xlim = c(1,50), ylim = c(1,50), col=rgb(0,100,0,80,maxColorValue=255), pch=16)
dev.off()

pdf("rule_violation_density_failed.pdf",width=6.5,height=6.5)
plot(failed$instructions, failed$count, xlab = "Instructions", ylab = "Rule Violations", xlim = c(1,50), ylim = c(1,50), col=rgb(0,100,0,80,maxColorValue=255), pch=16)
dev.off()

pdf("rule_violation_density_build_status.pdf",width=13,height=6.5)
old.par <- par(mfrow=c(1, 2))
plot(success$instructions, success$count, xlab = "Instructions", ylab = "Rule Violations", main = "Successful Builds", xlim = c(1,50), ylim = c(1,50), col=rgb(0,100,0,80,maxColorValue=255), pch=16)
plot(failed$instructions, failed$count, xlab = "Instructions", ylab = "Rule Violations", main = "Failed Builds", xlim = c(1,50), ylim = c(1,50), col=rgb(0,100,0,80,maxColorValue=255), pch=16)
par(old.par)
dev.off()
