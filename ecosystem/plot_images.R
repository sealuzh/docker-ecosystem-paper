library(ggplot2) 

# Plots the commonly used base images.

# home <- "~/git_repos/papers/msr17-docker-evolution/analyses/ecosystem/"
home <- ""

images = read.csv(paste(home, "data/images_count.csv", sep = ""))
images_top100 = read.csv(paste(home, "data/images_count_top100.csv", sep = ""))
images_top1000 = read.csv(paste(home, "data/images_count_top1000.csv", sep = ""))

df <- data.frame("Image"=integer(),
                 "Projects"=double(),
                 "DataSet" = character(), 
                 stringsAsFactors=FALSE) 

# simply use a list of hard-coded images for now
images_to_use <- rev(c("busybox", "fedora", "php", "scratch", "ruby", "nginx", "java",
                       "alpine", "golang", "dockerfile/nodejs", "python", "centos",
                       "node", "debian", "ubuntu"))

for(image in images_to_use) {
  count_all <- 100 * images[images$imagename == image,][0:1,]$count / sum(images$count)
  count_top100 <- 100 * images_top100[images_top100$imagename == image,][0:1,]$count / sum(images_top100$count)
  count_top1000 <- 100 * images_top1000[images_top1000$imagename == image,][0:1,]$count / sum(images_top1000$count)
  df[nrow(df) + 1, ] <- list(image, count_all, "All")
  df[nrow(df) + 1, ] <- list(image, count_top100, "Top-100")
  df[nrow(df) + 1, ] <- list(image, count_top1000, "Top-1000")
}
df$DataSet <- factor(df$DataSet)
df$Image <- factor(df$Image, levels=images_to_use)

cbPalette <- c("#3333FF", "#208222", "#C43428", "#E69F00", "#56B4E9", "#009E73", "#F0E442", "#D55E00")
ggplot(df, aes(x=Image, y=Projects, fill=DataSet)) +  geom_bar(stat="identity", position=position_dodge()) + xlab(NULL) + ylab("% of Projects with Base Image Referenced in FROM Statements") + theme_bw() + theme(legend.justification=c(1,1), legend.position=c(1,1), legend.background = element_rect(colour = "black"), legend.title = element_blank()) + scale_fill_manual(values=cbPalette) + coord_flip() + scale_y_continuous(
  breaks = c(0, 5, 10, 15, 20, 25, 30),
  labels = c(0, 5, 10, 15, 20, 25, 30)
) 
ggsave("fig/top_images_r.pdf", width = 6.0, height = 4.8, units="in")


# legend.position = c(0.75, 0.85)