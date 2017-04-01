library(ggplot2) 

#
#  Revisions per Dockerfile
#

current_time <- as.numeric(Sys.time())
data_all = read.csv("~/git_repos/papers/msr17-docker-evolution/analyses/coevolution/data_0131/dockerfiles_with_rev_all.csv")
total_files <- nrow(data_all)
data_all['age_days'] = (current_time - data_all['created']) / (60*60*24)
data_all['rel_count'] = ceiling((data_all['count'] / data_all['age_days']) * 365)
data_top100 = read.csv("~/git_repos/papers/msr17-docker-evolution/analyses/coevolution/data_0131/dockerfiles_with_rev_top100.csv")
data_top100['age_days'] = (current_time - data_top100['created']) / (60*60*24)
data_top100['rel_count'] = ceiling((data_top100['count'] / data_top100['age_days']) * 365)
total_files_100 <- nrow(data_top100)
data_top1000 = read.csv("~/git_repos/papers/msr17-docker-evolution/analyses/coevolution/data_0131/dockerfiles_with_rev_top1000.csv")
data_top1000['age_days'] = (current_time - data_top1000['created']) / (60*60*24)
data_top1000['rel_count'] = ceiling((data_top1000['count'] / data_top1000['age_days']) * 365)
total_files_1000 <- nrow(data_top1000)

df <- data.frame("Versions"=integer(),
                 "Dockerfiles"=double(),
                 "Popularity" = character(), 
                 stringsAsFactors=FALSE) 
for (i in 1:20) { 
  all_val <- (nrow(data_all[data_all$rel_count == i,]) / total_files) * 100
  top100_val <- (nrow(data_top100[data_top100$rel_count == i,]) / total_files_100) * 100
  top1000_val <- (nrow(data_top1000[data_top1000$rel_count == i,]) / total_files_1000) * 100
  df[nrow(df) + 1, ] <- list(i, all_val, "All")
  df[nrow(df) + 1, ] <- list(i, top100_val, "Top-100")
  df[nrow(df) + 1, ] <- list(i, top1000_val, "Top-1000")
}
df$Popularity <- factor(df$Popularity)

cbPalette <- c("#3333FF", "#208222", "#C43428", "#E69F00", "#56B4E9", "#009E73", "#F0E442", "#D55E00")
p <- ggplot(df, aes(x=Versions, y=Dockerfiles, fill=Popularity)) +  geom_bar(stat="identity", position=position_dodge()) + xlab("Revisions Per Year") + ylab("% of Dockerfiles") + theme_bw() + theme(legend.position = c(0.84, 0.7), legend.background = element_rect(colour = "black"), legend.title = element_blank()) + scale_fill_manual(values=cbPalette)
print(p)

#
#  Amount of Change per Revision
#      (Version 1 - split up in All / Top-100 / Top-1000)
data_all = read.csv("~/git_repos/papers/msr17-docker-evolution/analyses/coevolution/data_0131/changes_per_rev_all.csv")
total_changes_all <- nrow(data_all)
# data_top100 = read.csv("~/git_repos/papers/msr17-docker-evolution/analyses/coevolution/data_0131/changes_per_rev_top100.csv")
#total_changes_top100 <- nrow(data_top100)
#data_top1000 = read.csv("~/git_repos/papers/msr17-docker-evolution/analyses/coevolution/data_0131/changes_per_rev_top1000.csv")
# total_changes_top1000 <- nrow(data_top1000)

df <- data.frame("Changes"=integer(),
                 "Revisions"=double(),
                 "Type" = character(), 
                 "Popularity" = character(), 
                 stringsAsFactors=FALSE) 
for (i in 0:15) { 
  all_val_total <- (nrow(data_all[data_all$total == i,]) / total_changes_all) * 100
  all_val_add <- (nrow(data_all[data_all$ins == i,]) / total_changes_all) * 100
  all_val_del <- (nrow(data_all[data_all$del == i,]) / total_changes_all) * 100
  all_val_mod <- (nrow(data_all[data_all$mod == i,]) / total_changes_all) * 100
#  top100_val_total <- (nrow(data_top100[data_top100$total == i,]) / total_changes_top100) * 100
#  top100_val_add <- (nrow(data_top100[data_top100$ins == i,]) / total_changes_top100) * 100
#  top100_val_del <- (nrow(data_top100[data_top100$del == i,]) / total_changes_top100) * 100
#  top100_val_mod <- (nrow(data_top100[data_top100$mod == i,]) / total_changes_top100) * 100
#  top1000_val_total <- (nrow(data_top1000[data_top1000$total == i,]) / total_changes_top1000) * 100
#  top1000_val_add <- (nrow(data_top1000[data_top1000$ins == i,]) / total_changes_top1000) * 100
#  top1000_val_del <- (nrow(data_top1000[data_top1000$del == i,]) / total_changes_top1000) * 100
#  top1000_val_mod <- (nrow(data_top1000[data_top1000$mod == i,]) / total_changes_top1000) * 100
  df[nrow(df) + 1, ] <- list(i, all_val_total, "Total", "All")
  df[nrow(df) + 1, ] <- list(i, all_val_add, "Added Lines", "All")
  df[nrow(df) + 1, ] <- list(i, all_val_del, "Removed Lines", "All")
  df[nrow(df) + 1, ] <- list(i, all_val_mod, "Modified Lines", "All")
#  df[nrow(df) + 1, ] <- list(i, top100_val_total, "Total", "Top-100")
#  df[nrow(df) + 1, ] <- list(i, top100_val_add, "Added Lines", "Top-100")
#  df[nrow(df) + 1, ] <- list(i, top100_val_del, "Removed Lines", "Top-100")
#  df[nrow(df) + 1, ] <- list(i, top100_val_mod, "Modified Lines", "Top-100")
#  df[nrow(df) + 1, ] <- list(i, top1000_val_total, "Total", "Top-1000")
#  df[nrow(df) + 1, ] <- list(i, top1000_val_add, "Added Lines", "Top-1000")
#  df[nrow(df) + 1, ] <- list(i, top1000_val_del, "Removed Lines", "Top-1000")
#  df[nrow(df) + 1, ] <- list(i, top1000_val_mod, "Modified Lines", "Top-1000")
}
df$Type <- factor(df$Type, levels = c("Total", "Added Lines", "Modified Lines", "Removed Lines"))
df$Popularity <- factor(df$Popularity)

#p <- ggplot(df, aes(x=Changes, y=Revisions, fill=Popularity)) +  geom_bar(stat="identity", position=position_dodge()) + facet_grid(Type ~ .) + xlab("LOC Changed ") + ylab("% of Revisions")
#print(p)

cbPalette <- c("#000000", "#E69F00", "#56B4E9", "#009E73", "#F0E442", "#0072B2", "#D55E00", "#CC79A7")
#      (Version 2 - one plot with add / del / mod)
p <- ggplot(df[df$Popularity == "All",], aes(x=Changes, y=Revisions, fill=Type)) +  geom_bar(stat="identity", position=position_dodge()) + xlab("Lines Changed in Docker") + ylab("% of Revisions")+ theme_bw() + theme(legend.position = c(0.85, 0.75), legend.background = element_rect(colour = "black"),  legend.title = element_blank()) + scale_fill_manual(values=cbPalette)
print(p)

