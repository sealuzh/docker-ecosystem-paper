library(ggplot2)
library(scales)
library(gridExtra)
library(plyr)
library(data.table)
library(dplyr)
library(tidyr)   

data <- read.csv("rule_violations.csv", header=TRUE)

app <- data.frame(table(data$violated_rule))
colnames(app) <- c("violated_rule", "count")

# get top 15 violated rules
topX = 12
num <- head(sort(app$count,decreasing=TRUE), n = topX)[topX]
top <- app[app$count >= num,]
others_total = sum(app[app$count < num,]$count)

top$rule[top$violated_rule == "DL3000"] <- "absolute WORKDIR"
top$rule[top$violated_rule == "DL3002"] <- "USER root"
top$rule[top$violated_rule == "DL3003"] <- "switch directory"
top$rule[top$violated_rule == "DL3004"] <- "avoid sudo"
top$rule[top$violated_rule == "DL3005"] <- "apt-get upgrade usage"
top$rule[top$violated_rule == "DL3006"] <- "image version pinning"
top$rule[top$violated_rule == "DL3007"] <- "image version :latest"
top$rule[top$violated_rule == "DL3008"] <- "apt-get version pinning"
top$rule[top$violated_rule == "DL3009"] <- "delete apt-get lists"
top$rule[top$violated_rule == "DL3012"] <- "maintainer email"
top$rule[top$violated_rule == "DL3013"] <- "pip version pinning"
top$rule[top$violated_rule == "DL3014"] <- "use -y switch"
top$rule[top$violated_rule == "DL3015"] <- "avoid additional packages"
top$rule[top$violated_rule == "DL3020"] <- "copy instead of add"
top$rule[top$violated_rule == "DL4000"] <- "maintainer missing"
top$rule[top$violated_rule == "DL4001"] <- "wget and curl"
top$rule[top$violated_rule == "SC2046"] <- "quote command expansion"
top$rule[top$violated_rule == "SC2086"] <- "double quote"
top$rule[top$violated_rule == "SC2164"] <- "use cd ... || exit"
top$rule[top$violated_rule == "SC2102"] <- "single char ranges"

# order ascending
top$rules_ordered <- reorder(top$rule, -top$count)

entry = data.frame(`violated_rule` = 'others', `count` = others_total, `rules_ordered` = 'Others', `rule` = "Others")
top <- rbind(top, entry)

# get percentage based on total number of rule violations
top$count_p <- top$count / nrow(data) * 100
top$count_label <- paste(round(top$count_p, digits=1), "%")

ggplot(top, aes(x = rules_ordered, y = count_p)) + 
  geom_bar(stat="identity") +
  geom_text(aes(label=count_label), hjust=-0.3, size=4) +
  coord_flip() +
  ylab("Rule Violations [%]") +
  xlab("") +
  theme(axis.text = element_text(colour="gray3", size=9), axis.title=element_text(size=11,face="bold"))
  ggsave("top_rule_violations.pdf", width = 15.35, height = 6.43, units="in")

# -------------------------  

# rule violations grouped by user/organization
orgs <- data %>%
         filter(violated_rule %in% top$violated_rule) %>%
         group_by(violated_rule, i_owner_type) %>%
         summarise(count = n())

others <- data %>%
  filter(!violated_rule %in% top$violated_rule) %>%
  group_by(i_owner_type) %>%
  summarise(count = n())

orgs$rules_ordered <- reorder(orgs$violated_rule, -orgs$count)

# small hack
a <- data.frame(orgs)
entry = data.frame(`violated_rule` = 'Others', `i_owner_type` = 'Organization', `count` = others$count[others$i_owner_type == 'Organization'], `rules_ordered` = 'Others')
entry2 = data.frame(`violated_rule` = 'others', `i_owner_type` = 'User', `count` = others$count[others$i_owner_type == 'User'], `rules_ordered` = 'Others')
a <- rbind(a, entry)
a <- rbind(a, entry2)

ggplot(data = a, aes(x = rules_ordered, y = `count`, fill = i_owner_type)) + 
  geom_bar(stat = "identity") +
  ylab("Rule Violations [%]") +
  xlab("") +
  coord_flip() +
  theme(axis.text = element_text(colour="gray3", size=10), axis.title=element_text(size=11,face="bold"))
  ggsave("top_rule_violations_organization.pdf", width = 11.43, height = 6.43, units="in")
  
  
# ---------
top100 <- read.csv("../top100.csv", header=TRUE)
top1000 <- read.csv("../top1000.csv", header=TRUE)
  
# rule violations based on star rating
# star_filter = 189    
  # >= 3400 stars -> top 100
  # >= 189 stars -> top 1000
  
app <- data %>%
    # filter(i_stargazers >= star_filter ) %>%
    filter(repo_path %in% top100$repo_path ) %>%
    # filter(repo_path %in% top1000$repo_path ) %>%
    group_by(violated_rule) %>%
    summarise(count = n())

# get top 12 violated rules
topX = 20
num <- head(sort(app$count,decreasing=TRUE), n = topX)[topX]
top <- app[app$count >= num,]
others_total = sum(app[app$count < num,]$count)

top$rule[top$violated_rule == "DL3000"] <- "absolute WORKDIR"
top$rule[top$violated_rule == "DL3002"] <- "USER root"
top$rule[top$violated_rule == "DL3003"] <- "switch directory"
top$rule[top$violated_rule == "DL3004"] <- "avoid sudo"
top$rule[top$violated_rule == "DL3005"] <- "apt-get upgrade usage"
top$rule[top$violated_rule == "DL3006"] <- "image version pinning"
top$rule[top$violated_rule == "DL3007"] <- "image version :latest"
top$rule[top$violated_rule == "DL3008"] <- "apt-get version pinning"
top$rule[top$violated_rule == "DL3009"] <- "delete apt-get lists"
top$rule[top$violated_rule == "DL3012"] <- "maintainer email"
top$rule[top$violated_rule == "DL3013"] <- "pip version pinning"
top$rule[top$violated_rule == "DL3014"] <- "use -y switch"
top$rule[top$violated_rule == "DL3015"] <- "avoid additional packages"
top$rule[top$violated_rule == "DL3020"] <- "copy instead of add"
top$rule[top$violated_rule == "DL4000"] <- "maintainer missing"
top$rule[top$violated_rule == "DL4001"] <- "wget and curl"
top$rule[top$violated_rule == "SC2046"] <- "quote command expansion"
top$rule[top$violated_rule == "SC2086"] <- "double quote"
top$rule[top$violated_rule == "SC2164"] <- "use cd ... || exit"
top$rule[top$violated_rule == "SC2102"] <- "single char ranges"


# order ascending
top$rules_ordered <- reorder(top$rule, -top$count)

entry = data.frame(`violated_rule` = 'others', `count` = others_total, `rules_ordered` = 'Others', `rule` = 'Others')
top <- rbind(top, entry)

# get percentage based on total number of rule violations
top$count_p <- top$count / nrow(data[data$repo_path %in% top100$repo_path,]) * 100
# top$count_p <- top$count / nrow(data[data$repo_path %in% top1000$repo_path,]) * 100
# top$count_p <- top$count / nrow(data[data$i_stargazers >= star_filter,]) * 100
top$count_label <- paste(round(top$count_p, digits = 1), "%")

filename = "top_rule_violations_stargazers_top1000.pdf"
# filename = paste("top_rule_violations_stargazers", star_filter, ".pdf", collapse = '', sep='')
ggplot(top, aes(x = rules_ordered, y = count_p)) + 
  geom_bar(stat="identity") +
  geom_text(aes(label=count_label), hjust=-0.3, size=4) +
  coord_flip() +
  ylab(paste("Rule Violations of Top 100 Starred Projects [%]")) +
  # ylab(paste("Rule Violations of Projects with <= ", star_filter, " stars [%]")) +
  xlab("") +
  theme(axis.text = element_text(colour="gray3", size=10), axis.title=element_text(size=11,face="bold"))
ggsave(filename, width = 15.35, height = 6.43, units="in")
