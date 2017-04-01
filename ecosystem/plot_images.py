#!/usr/bin/env python

# Plots the commonly used base images.

import pandas as pd
import matplotlib.pyplot as plt

# read CSV with base image count:
df_images_count = pd.read_csv('./data/images_count.csv')
df_images_count_top100 = pd.read_csv('./data/images_count_top100.csv')
df_images_count_top1000 = pd.read_csv('./data/images_count_top1000.csv')

print ''
print '####################################'
print '# Number of official images'
print '####################################'
print df_images_count[df_images_count['imageisoffical'] == True].sum()

print ''
print '####################################'
print '# Overall number of base images used'
print '####################################'
count_overall = df_images_count['count'].sum()
count_top100 = df_images_count_top100['count'].sum()
count_top1000 = df_images_count_top1000['count'].sum()
print count_overall


print ''
print '####################################'
print '# Number of distinct images'
print '####################################'
print df_images_count['imagename'].count()


print ''
print '####################################'
print '# 15 most used images'
print '####################################'
df_images_count['percent'] = 100 * df_images_count['count'] / count_overall
df_images_count_top100['percent_100'] = 100 * df_images_count_top100['count'] / count_top100
df_images_count_top1000['percent_1000'] = 100 * df_images_count_top1000['count'] / count_top1000
df_images_count = df_images_count.sort_values('count', ascending=False)
df_images_count_top100 = df_images_count_top100.sort_values('count', ascending=False)
df_images_count_top1000 = df_images_count_top1000.sort_values('count', ascending=False)

df_top_images = df_images_count[:100].set_index('imagename')
df_top100_images = df_images_count_top100[:100].set_index('imagename')
df_top1000_images = df_images_count_top1000[:100].set_index('imagename')
df_top_combined = pd.concat([df_top_images, df_top100_images, df_top1000_images], axis=1).sort_values('percent', ascending=False)
print df_top_combined[['percent', 'percent_1000', 'percent_100']][:25]

# plot top 25 images and their percentage of usage:
ax = df_top_combined[['percent', 'percent_1000', 'percent_100']][:15].plot.barh()
ax.legend(labels=['All', 'Top-1000', 'Top-100'])
ax.set_xlabel('Base images referenced in FROM statements [%]')
fig = ax.get_figure()
fig.tight_layout()
fig.savefig('fig/top_images.png')