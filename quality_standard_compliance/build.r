library(ggplot2)
library(scales)
library(gridExtra)
library(plyr)
library(data.table)
library(dplyr)
library(tidyr)   

data <- read.csv("rule_violations.csv", header=TRUE)

build = data.frame()

runs = seq(1,3)
for(run in runs) {
    path = paste("build/results/run", run, ".csv",  collapse = '', sep='')
    
    newResults <- read.csv(path, header=FALSE, sep=";")
    build <- rbind(build, newResults)
}  

colnames(build) <- c("project", "time", "status")

# average time to fail
mean(build[build$status == 0,]$time)

# average time to success
mean(build[build$status == 1,]$time)

# merge results
build <- build %>%
  group_by(project, status) %>%
  summarise(avg = mean(time), sd = sd(time))

pdf("build_time_density.pdf",width=4.5,height=3.3)
fail <- density(build$avg[build$status==0])
succ <- density(build$avg[build$status==1])
par(mar=c(4,4,1,1))
plot(fail, col="red", main="", xlab="Build time in seconds")
lines(succ, col="blue")
legend("topright", legend=c("Build Failure", "Build Success"), col=c("red", "blue"), lty=1)
dev.off()

ggplot(build, mapping = aes(fill = status, x = avg)) + geom_density(alpha = 0.5)

# check whether there are projects having both failed and successful builds
multi <- build %>%
  group_by(project) %>%
  summarise(count = n())

multi$project[multi$count>1]

# projects with successful builds
length(build$project[build$status == 1])

# projects with failed builds
length(build$project[build$status == 0])

# average build duration of successful builds
mean(build$avg[build$status == 1])

# general stats for successful builds
summary(build$avg[build$status == 1])

# sd of successful builds
sd(build$avg[build$status == 1])

# average build duration of failed builds
mean(build$avg[build$status == 0])

# general stats for failed builds
summary(build$avg[build$status == 0])

# sd of failed builds
sd(build$avg[build$status == 0])

stats <- build %>% 
  select(project, status) %>%
  group_by(project, status)

stats$violated_rules <- apply(stats,1,function(row) (nrow(data[data$repo_path == row["project"],])))  

# average number of failed rules of failed builds:
mean(stats$violated_rules[stats$status == 0])

# total number of rule violations of failed builds
sum(stats$violated_rules[stats$status == 0])

# average number of failed rules of successful builds:
mean(stats$violated_rules[stats$status == 1])

# total number of rule violations of successful builds
sum(stats$violated_rules[stats$status == 1])


# plot top rule violations based on build status
status = 0    
# status = 0 ... build failure
# status = 1 ... build success

violations <- data %>%
  filter(repo_path %in% build$project[build$status == status] ) %>%
  group_by(violated_rule) %>%
  summarise(count = n())

# get top 15 violated rules
topX = 15
num <- head(sort(violations$count,decreasing=TRUE), n = topX)[topX]
top <- violations[violations$count >= num,]
others_total = sum(violations[violations$count < num,]$count)

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
top$count_p <- top$count / nrow(data[data$repo_path %in% build$project[build$status == status],]) * 100
top$count_label <- paste(round(top$count_p, digits=1), "%")

filename = paste("top_rule_violations_build_status_", status, ".pdf", collapse = '', sep='')
ggplot(top, aes(x = rules_ordered, y = count_p)) + 
  geom_bar(stat="identity") +
  geom_text(aes(label=count_label), hjust=-0.3, size=4) +
  coord_flip() +
  ylab(paste("Rule Violations of Projects with ", ifelse(status == 0, "Failed", "Successful") ," Builds [%]", collapse='', sep='')) +
  xlab("") +
  theme(axis.text = element_text(colour="gray3", size=10), axis.title=element_text(size=11,face="bold"))
ggsave(filename, width = 15.35, height = 6.43, units="in")

# ---------------------------------------------------

# less useful:
# stacked bar plot
# rule violations grouped by build status

# top violated rules of sample set
app <- data.frame(table(data$violated_rule[data$repo_path %in% build$project]))
colnames(app) <- c("violated_rule", "count")

# get top 15 violated rules
topX = 15
num <- head(sort(app$count,decreasing=TRUE), n = topX)[topX]
top <- app[app$count >= num,]

others_total = sum(app[app$count < num,]$count)

# only consider built projects and top15 violations of these projects
violations <- data %>%
  filter(repo_path %in% build$project & violated_rule %in% top$violated_rule)

# attach build status
violations$build_status <- apply(violations,1,function(row) (build$status[build$project == row["repo_path"]][1]))  

violations <- violations %>% 
  group_by(violated_rule, build_status) %>%
  summarise(count = n())

# others <- data %>%
#   filter(!violated_rule %in% top$violated_rule) %>%
#   group_by(i_owner_type) %>%
#   summarise(count = n())

violations$rules_ordered <- reorder(violations$violated_rule, -violations$count)

# # small hack
# a <- data.frame(orgs)
# entry = data.frame(`violated_rule` = 'Others', `i_owner_type` = 'Organization', `count` = others$count[others$i_owner_type == 'Organization'], `rules_ordered` = 'Others')
# entry2 = data.frame(`violated_rule` = 'others', `i_owner_type` = 'User', `count` = others$count[others$i_owner_type == 'User'], `rules_ordered` = 'Others')
# a <- rbind(a, entry)
# a <- rbind(a, entry2)

ggplot(data = violations, aes(x = rules_ordered, y = `count`, fill = build_status)) + 
  geom_bar(stat = "identity") +
  ylab("Rule Violations [%]") +
  xlab("") +
  coord_flip() +
  theme(axis.text = element_text(colour="gray3", size=10), axis.title=element_text(size=11,face="bold"))
ggsave("top_rule_violations_build_status_stacked.pdf", width = 11.43, height = 6.43, units="in")

# ---------------------------
# combined bar plot
# rule violations grouped by build status

# top violated rules of sample set
app <- data.frame(table(data$violated_rule[data$repo_path %in% build$project]))
colnames(app) <- c("violated_rule", "count")

# get top 15 violated rules
topX = 12
num <- head(sort(app$count,decreasing=TRUE), n = topX)[topX]
top <- app[app$count >= num,]

others_total = sum(app[app$count < num,]$count)

# only consider built projects and top15 violations of these projects
violations <- data %>%
  filter(repo_path %in% build$project, violated_rule %in% top$violated_rule)

others <- data %>%
  filter(repo_path %in% build$project, !(violated_rule %in% top$violated_rule))

# attach build status
violations$build_status <- apply(violations,1,function(row) (build$status[build$project == row["repo_path"]][1]))  
others$build_status <- apply(others,1,function(row) (build$status[build$project == row["repo_path"]][1]))  

demo <- violations %>% 
  group_by(violated_rule, build_status, i_owner_type) %>%
  summarise(count = n())

violations <- violations %>% 
  group_by(violated_rule, build_status) %>%
  summarise(count = n())

others <- others %>% 
  group_by(violated_rule, build_status) %>%
  summarise(count = n())

violations$count_p <- apply(violations, 1, function(row) (as.numeric(row["count"]) / nrow(data[data$repo_path %in% build$project[build$status == as.numeric(row["build_status"])],]) *100 ))
others$count_p <- apply(others, 1, function(row) (as.numeric(row["count"]) / nrow(data[data$repo_path %in% build$project[build$status == as.numeric(row["build_status"])],]) *100 ))

others <- others %>% group_by(build_status) %>% summarise(sum = sum(count_p))

violations$count_label <- paste(round(violations$count_p, digits=1), "%")

violations$rule[violations$violated_rule == "DL3000"] <- "absolute WORKDIR"
violations$rule[violations$violated_rule == "DL3002"] <- "USER root"
violations$rule[violations$violated_rule == "DL3003"] <- "switch directory"
violations$rule[violations$violated_rule == "DL3004"] <- "avoid sudo"
violations$rule[violations$violated_rule == "DL3005"] <- "apt-get upgrade usage"
violations$rule[violations$violated_rule == "DL3006"] <- "image version pinning"
violations$rule[violations$violated_rule == "DL3007"] <- "image version :latest"
violations$rule[violations$violated_rule == "DL3008"] <- "apt-get version pinning"
violations$rule[violations$violated_rule == "DL3009"] <- "delete apt-get lists"
violations$rule[violations$violated_rule == "DL3012"] <- "maintainer email"
violations$rule[violations$violated_rule == "DL3013"] <- "pip version pinning"
violations$rule[violations$violated_rule == "DL3014"] <- "use -y switch"
violations$rule[violations$violated_rule == "DL3015"] <- "avoid additional packages"
violations$rule[violations$violated_rule == "DL3020"] <- "copy instead of add"
violations$rule[violations$violated_rule == "DL4000"] <- "maintainer missing"
violations$rule[violations$violated_rule == "DL4001"] <- "wget and curl"
violations$rule[violations$violated_rule == "SC2046"] <- "quote command expansion"
violations$rule[violations$violated_rule == "SC2086"] <- "double quote"
violations$rule[violations$violated_rule == "SC2164"] <- "use cd ... || exit"
violations$rule[violations$violated_rule == "SC2102"] <- "single char ranges"


# others <- data %>%
#   filter(!violated_rule %in% top$violated_rule) %>%
#   group_by(i_owner_type) %>%
#   summarise(count = n())

violations$rules_ordered <- reorder(violations$rule, -violations$count)

# # small hack
# a <- data.frame(orgs)
# entry = data.frame(`violated_rule` = 'Others', `i_owner_type` = 'Organization', `count` = others$count[others$i_owner_type == 'Organization'], `rules_ordered` = 'Others')
# entry2 = data.frame(`violated_rule` = 'others', `i_owner_type` = 'User', `count` = others$count[others$i_owner_type == 'User'], `rules_ordered` = 'Others')
# a <- rbind(a, entry)
# a <- rbind(a, entry2)

violations$state_label[violations$build_status==0] <- "build failure"
violations$state_label[violations$build_status==1] <- "build success"


ggplot(data = violations, aes(x = rules_ordered, y = `count_p`, fill = state_label)) + 
  geom_bar(stat = "identity", position=position_dodge()) +
  # geom_text(aes(label=count_label), hjust=-0.3, size=4) +
  ylab("Rule Violations [%]") +
  xlab("") +
  coord_flip() +
  theme(axis.text = element_text(colour="gray3", size=10), axis.title=element_text(size=11,face="bold"), legend.position="bottom", plot.margin = unit(c(0, -1.5, 0, -0.9), "lines")) +
  guides(fill=guide_legend(title=NULL))
ggsave("top_rule_violations_build_status.pdf", width = 11.43, height = 6.43, units="in")

# theme(legend.position="bottom", axis.title = element_text(size=8), legend.text=element_text(size=8), legend.margin=unit(0.1,"cm"), plot.margin = unit(c(0.5, 0.4, 0, 0.4), "lines")) +
  
