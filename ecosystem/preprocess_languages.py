#!/usr/bin/env python

# Creates a list of primary languages per project

import pandas as pd

df = pd.read_csv('../../dataset/31012017/all_languages.csv', sep=';')
idx = df.groupby(['repo_name'])['size'].transform(max) == df['size']
df = df[idx]
df = df.set_index('repo_name')['language']
df.to_csv('./data/languages_primary.csv', header=['language'])