library(ggplot2) 

# Plots the commonly used base image types

# home <- "~/git_repos/papers/msr17-docker-evolution/analyses/ecosystem/"
home <- ""

image_types = read.csv(paste(home, "data/images_top25_types.csv", sep = ""))
images = read.csv(paste(home, "data/images_count.csv", sep = ""))
images <- merge(images, image_types, by="imagename")
images = images[order(-1 * images$count),][0:25,]
images_top100 = read.csv(paste(home, "data/images_count_top100.csv", sep = ""))
images_top100 <- merge(images_top100, image_types, by="imagename")
images_top100 = images_top100[order(-1 * images_top100$count),][0:25,]
images_top1000 = read.csv(paste(home, "data/images_count_top1000.csv", sep = ""))
images_top1000 <- merge(images_top1000, image_types, by="imagename")
images_top1000 = images_top1000[order(-1 * images_top1000$count),][0:25,]

types <- c("OS", "Language runtime", "Application", "Other", "Variable")

df <- data.frame("Type"=integer(),
                 "Projects"=double(),
                 "DataSet" = character(), 
                 stringsAsFactors=FALSE) 

for(type in types) {
  count_all <- 100 * sum(images[images$type == type,]$count) / sum(images$count)
  count_top100 <- 100 * sum(images_top100[images_top100$type == type,]$count) / sum(images_top100$count)
  count_top1000 <- 100 * sum(images_top1000[images_top1000$type == type,]$count) / sum(images_top1000$count)
  df[nrow(df) + 1, ] <- list(type, count_all, "All")
  df[nrow(df) + 1, ] <- list(type, count_top100, "Top-100")
  df[nrow(df) + 1, ] <- list(type, count_top1000, "Top-1000")
}
df$DataSet <- factor(df$DataSet)
df$Type <- factor(df$Type, levels=types)

cbPalette <- c("#3333FF", "#208222", "#C43428", "#E69F00", "#56B4E9", "#009E73", "#F0E442", "#D55E00")
ggplot(df, aes(x=Type, y=Projects, fill=DataSet)) +  geom_bar(stat="identity", position=position_dodge()) + ylab("% of Projects with Base Image of Type") + theme_bw() + theme(legend.justification=c(1,1), legend.position=c(1,1), legend.background = element_rect(colour = "black"), legend.title = element_blank()) + scale_fill_manual(values=cbPalette) + scale_y_continuous(
  breaks = c(0, 10, 20, 30, 40, 50, 60),
  labels = c(0, 10, 20, 30, 40, 50, 60)
)
ggsave("fig/top_image_types_r.pdf", width = 6.0, height = 3.56, units="in")
