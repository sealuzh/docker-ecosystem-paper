library(ggplot2) 

countInDataset <- function(dataset, repos, language) {
  merged <- merge(dataset, repos, by = "repo_name")
  total  <- nrow(merged)
  filtered <- merged[merged$language == language,]
  count_filtered  <- nrow(filtered)
  return(100 * count_filtered / total)
}

# home <- "~/git_repos/papers/msr17-docker-evolution/analyses/ecosystem/"
home <- ""
#
#  Languages
#

all_langs = read.csv(paste(home, "data/languages_primary.csv", sep = ""))
repos = read.csv(paste(home, "data/repos.csv", sep = ""))
repos_top100 = read.csv(paste(home, "data/repos_top100.csv", sep = ""))
repos_top1000 = read.csv(paste(home, "data/repos_top1000.csv", sep = ""))
github = read.csv(paste(home, "data/languages_github_primary.csv", sep = ""))
all_in_github <- sum(github$count)

df <- data.frame("Language"=integer(),
                 "Projects"=double(),
                 "DataSet" = character(), 
                 stringsAsFactors=FALSE) 

# simply use a list of hard-coded language values for now
languages_to_use <- rev(c("Clojure", "CoffeeScript", "Nginx", "C", "C++", "Makefile", "CSS",
                      "HTML", "PHP", "Java", "Ruby", "Go", "Python", "JavaScript", "Shell"))

for(lang in languages_to_use) {
  count_all <- countInDataset(repos, all_langs, lang)
  count_top100 <- countInDataset(repos_top100, all_langs, lang)
  count_top1000 <- countInDataset(repos_top1000, all_langs, lang)
  count_github <- 100 * github[github$language_name == lang,]$count / all_in_github
  df[nrow(df) + 1, ] <- list(lang, count_all, "All")
  df[nrow(df) + 1, ] <- list(lang, count_top100, "Top-100")
  df[nrow(df) + 1, ] <- list(lang, count_top1000, "Top-1000")
  df[nrow(df) + 1, ] <- list(lang, count_github, "GitHub")
}
df$DataSet <- factor(df$DataSet, levels=c("All", "Top-100", "Top-1000", "GitHub"))
df$Language <- factor(df$Language, levels=languages_to_use)

cbPalette <- c("#3333FF", "#208222", "#C43428", "#E69F00", "#56B4E9", "#009E73", "#F0E442", "#D55E00")

ggplot(df, aes(x=Language, y=Projects, fill=DataSet)) +  geom_bar(stat="identity", position=position_dodge()) + xlab(NULL) + ylab("% of Projects with Primary Language") + theme_bw() + theme(legend.justification=c(1,1), legend.position=c(1,1), legend.background = element_rect(colour = "black"), legend.title = element_blank()) + scale_fill_manual(values=cbPalette) + coord_flip() + scale_y_continuous(
  breaks = c(0, 5, 10, 15, 20, 25, 30),
  labels = c(0, 5, 10, 15, 20, 25, 30)
)
ggsave("fig/top_languages_r.pdf", width = 6.0, height = 5.68, units="in")

