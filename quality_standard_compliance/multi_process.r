library(ggplot2)
library(scales)
library(gridExtra)
library(plyr)
library(dplyr)
library(tidyr)   

data <- read.csv("multi_process.csv", header=TRUE)

# multi process tool grouped by tool and instruction (cmd or entrypoint)
tool <- data %>%
  group_by(multi_process_tool, type) %>%
  summarise(count = n())

#orgs$rules_ordered <- reorder(orgs$violated_rule, -orgs$count)

ggplot(data = tool, aes(x = multi_process_tool, y = `count`, fill = type)) + 
  geom_bar(stat = "identity") +
  ylab("Multi Process Tooling") +
  xlab("") +
  coord_flip() +
  theme(axis.text = element_text(colour="gray3", size=10), axis.title=element_text(size=11,face="bold"))
ggsave("multi_process_tooling.pdf", width = 11.43, height = 6.43, units="in")

