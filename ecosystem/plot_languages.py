#!/usr/bin/env python

# Plots the commonly used programming languages.
# Compare with most popular languages based on GitHut project.
# 
# Extracted using jQuery:
# 
# $('.chart').each(function (e, obj) { console.log( $(obj).find('h4 b').text() + ', ' + $(obj).find('.linechart g').last().find('text').text().split('Q')[0] ) })
# 

import pandas as pd
import matplotlib.pyplot as plt

# superset of repos and their languages:
all_languages = pd.read_csv('./data/languages_primary.csv', index_col='repo_name').sort_index()

# get list of repositories in DB:
repos = pd.read_csv('./data/repos.csv', index_col='repo_name')
repos['overall'] = 1

repos_top1000 = pd.read_csv('./data/repos_top1000.csv', index_col='repo_name')
repos_top1000['top1000'] = 1

repos_top100 = pd.read_csv('./data/repos_top100.csv', index_col='repo_name')
repos_top100['top100'] = 1

# create dataframes showing percentage of languages:
languages = all_languages.join(repos)
languages = languages.loc[languages['overall'] == 1]
languages = languages.groupby('language')['language'].count().sort_values(ascending=False)
languages_sum = languages.sum()
languages_percent = (100 * languages) / languages_sum
languages_percent.name = 'All'

languages_top1000 = all_languages.join(repos_top1000)
languages_top1000 = languages_top1000.loc[languages_top1000['top1000'] == 1]
languages_top1000 = languages_top1000.groupby('language')['language'].count().sort_values(ascending=False)
languages_top1000_sum = languages_top1000.sum()
languages_top1000_percent = (100 * languages_top1000) / languages_top1000_sum
languages_top1000_percent.name = 'Top-1000'

languages_top100 = all_languages.join(repos_top100)
languages_top100 = languages_top100.loc[languages_top100['top100'] == 1]
languages_top100 = languages_top100.groupby('language')['language'].count().sort_values(ascending=False)
languages_top100_sum = languages_top100.sum()
languages_top100_percent = (100 * languages_top100) / languages_top100_sum
languages_top100_percent.name = 'Top-100'

languages_gh = pd.read_csv('./data/languages_github_primary.csv', index_col=0)['count']
languages_gh_sum = languages_gh.sum()
languages_gh_percent = (100 * languages_gh) / languages_gh_sum
languages_gh_percent.name = 'GitHub'
# print languages_gh_percent


# create overall dataframe:
df = pd.concat([languages_percent, languages_top1000_percent, languages_top100_percent, languages_gh_percent], axis=1).sort_values('All', ascending=False)

# plot it:
ax = df[:15].plot.barh()
ax.set_xlabel('Repositories with primary language [%]')
fig = ax.get_figure()
fig.tight_layout()
fig.savefig('fig/top_languages.png')