from ggplot import *
import pandas

data_version = "data_0131"

#
# distribution plot of how many revisions each Dockerfile has
#
data = pandas.read_csv("%s/projects_with_revs.csv" % data_version, sep=',')
p = ggplot(data, aes(x='count')) + geom_bar(binwidth=1) + xlim(1, 25) \
    + xlab("# of Revisions") + ylab("# of Projects")
ggsave(p, 'fig/distribution_revs.png')

#
# distribution plot of how large the changes in each revisions are
#
data = pandas.read_csv("%s/changes_per_rev.csv" % data_version, sep=',')
# variant 1 - this is the simple version without stacked details
p = ggplot(data, aes('total')) + geom_bar(binwidth=1) + xlim(1, 50) \
    + xlab("# of Lines Changed (Total)") + ylab("# of Revisions")
ggsave(p, 'fig/distribution_changes_total.png')
p = ggplot(data, aes('ins')) + geom_bar(binwidth=1) + xlim(1, 50) \
    + xlab("# of Lines Changed (Inserted)") + ylab("# of Revisions")
ggsave(p, 'fig/distribution_changes_ins.png')
p = ggplot(data, aes('del')) + geom_bar(binwidth=1) + xlim(1, 50) \
    + xlab("# of Lines Changed (Deleted)") + ylab("# of Revisions")
ggsave(p, 'fig/distribution_changes_del.png')
p = ggplot(data, aes('mod')) + geom_bar(binwidth=1) + xlim(1, 50) \
    + xlab("# of Lines Changed (Modified)") + ylab("# of Revisions")
ggsave(p, 'fig/distribution_changes_mod.png')
df = pandas.DataFrame()
total_ins = data['ins'].sum()
total_del = data['del'].sum()
total_mod = data['mod'].sum()
df = df.append({'type' : 1, 'mode': 'ins', 'val' : total_ins}, ignore_index=True)
df = df.append({'type' : 1, 'mode': 'del', 'val' : total_del}, ignore_index=True)
df = df.append({'type' : 1, 'mode': 'mod', 'val' : total_mod}, ignore_index=True)
p = ggplot(df, aes(x='type', weight='val', fill='mode')) + geom_bar() \
    + xlab("") + ylab("# of Revisions")
ggsave(p, 'fig/distribution_changes_summary.png')

# variant 2 - this is more detailed, with stacks for added, modified, deleted lines
# does not work yet
# df = pandas.DataFrame()
# for i in range(1, 50):
#     data_subset = data[data['total'] == i]
#     avg_ins = data_subset.mean('ins')
#     avg_mods = data_subset.mean('mod')
#     avg_dels = data_subset.mean('del')
#     # df = df.append({'mode': 'total', 'val' : i}, ignore_index=True)
#     df = df.append({'i' : i, 'mode': 'ins', 'val' : avg_ins}, ignore_index=True)
#     df = df.append({'i' : i, 'mode': 'mods', 'val' : avg_mods}, ignore_index=True)
#     df = df.append({'i' : i, 'mode': 'dels', 'val' : avg_dels}, ignore_index=True)
# print df
# p1 = ggplot(df, aes(x='i', weight='val', fill='mode')) + geom_bar() \
#     + xlab("# of Revisions") + ylab("Lines Added/Removed/Modified")
# ggsave(p1, 'fig/distribution_changes_detailed.png')
