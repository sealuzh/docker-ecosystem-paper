library(ggplot2) 
library(pracma) # has the logspace function 

home <- "~/git_repos/papers/msr17-docker-evolution/analyses/ecosystem/"

#
#  Project Sizes
#

inBetween <- function(data, lower, upper) {
  print(paste(lower, upper, sep="->"))
  count <- nrow(data[data$size >= lower & data$size < upper,])
  return(count)
}

data_all = read.csv(paste(home, "data/size.csv", sep = ""))
total_files <- nrow(data_all)
data_top100 = read.csv(paste(home, "data/size_top100.csv", sep = ""))
total_files_100 <- nrow(data_top100)
data_top1000 = read.csv(paste(home, "data/size_top1000.csv", sep = ""))
total_files_1000 <- nrow(data_top1000)

df <- data.frame("Sizes"=integer(),
                 "Projects"=double(),
                 "Popularity" = character(), 
                 stringsAsFactors=FALSE) 


prev <- 0

for (i in logspace(log10(0.1), log10(10000000), n = 35)) { 
  all_val <- ( inBetween(data_all, prev, i) / total_files) * 100
  top100_val <- (inBetween(data_top100, prev, i) / total_files_100) * 100
  top1000_val <- (inBetween(data_top1000, prev, i) / total_files_1000) * 100
  df[nrow(df) + 1, ] <- list(i, all_val, "All")
  df[nrow(df) + 1, ] <- list(i, top100_val, "Top-100")
  df[nrow(df) + 1, ] <- list(i, top1000_val, "Top-1000")
  prev <- i
}
df$Popularity <- factor(df$Popularity)

cbPalette <- c("#3333FF", "#208222", "#C43428", "#E69F00", "#56B4E9", "#009E73", "#F0E442", "#D55E00")
p <- ggplot(df, aes(x=Sizes, y=Projects, fill=Popularity)) +  geom_bar(stat="identity", position=position_dodge()) + xlab("Project Size [kb]") + ylab("% of Projects") + theme_bw() + theme(legend.position = c(0.84, 0.7), legend.background = element_rect(colour = "black"), legend.title = element_blank()) + scale_fill_manual(values=cbPalette) + scale_x_log10(
  breaks = c(10^-1, 10^0, 10^1, 10^2, 10^3, 10^4, 10^5, 10^6, 10^7),
  labels = c(10^-1, 10^0, 10^1, 10^2, 10^3, 10^4, 10^5, 10^6, 10^7)
) 
print(p)