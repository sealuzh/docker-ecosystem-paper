#!/usr/bin/env python

# Plots the commonly used base image types.

import pandas as pd
import matplotlib.pyplot as plt

# read CSV with base image count:
df_images_count = pd.read_csv('./data/images_count.csv')
df_images_count_top100 = pd.read_csv('./data/images_count_top100.csv')
df_images_count_top1000 = pd.read_csv('./data/images_count_top1000.csv')


print ''
print '####################################'
print '# Number of base images used'
print '####################################'
count_overall = df_images_count['count'].sum()
count_top100 = df_images_count_top100['count'].sum()
count_top1000 = df_images_count_top1000['count'].sum()
print 'Overall: %s' % count_overall
print 'Top 1000: %s' % count_top1000
print 'Top 100: %s' % count_top100


print ''
print '####################################'
print '# Number of distinct images'
print '####################################'
print df_images_count['imagename'].count()


df_top_images = df_images_count.sort_values('count', ascending=False)[:25].set_index('imagename')
df_top_images['percent'] = 100 * df_top_images['count'] / df_top_images['count'].sum()
# print df_top_images

df_top_images_top1000 = df_images_count_top1000.sort_values('count', ascending=False)[:25].set_index('imagename')
print df_top_images_top1000
df_top_images_top1000['percent 1000'] = 100 * df_top_images_top1000['count'] / df_top_images_top1000['count'].sum()

df_top_images_top100 = df_images_count_top100.sort_values('count', ascending=False)[:25].set_index('imagename')
df_top_images_top100['percent 100'] = 100 * df_top_images_top100['count'] / df_top_images_top100['count'].sum()

df_top_images_types = pd.read_csv('./data/images_top25_types.csv').set_index('imagename')

df_top_combined = pd.concat([df_top_images['percent'], df_top_images_top1000['percent 1000'], df_top_images_top100['percent 100'], df_top_images_types], axis=1)
df = pd.concat([
  df_top_combined.groupby('type')['percent'].sum(),
  df_top_combined.groupby('type')['percent 1000'].sum(),
  df_top_combined.groupby('type')['percent 100'].sum()
], axis=1)
df.columns = ['Overall', 'Top 1000', 'Top 100']
df = df.sort_values('Overall', ascending=False)

# plot it:
ax = df.plot(kind='bar', rot=0)
ax.legend(labels=['All', 'Top-1000', 'Top-100'])
ax.set_ylabel('Base image types [%]')
ax.set_xlabel('')

fig = ax.get_figure()
fig.set_figwidth(8)
fig.set_figheight(4)
fig.tight_layout()
fig.savefig('fig/top_images_types.png')