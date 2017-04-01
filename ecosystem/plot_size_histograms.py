#!/usr/bin/env python

# Plots sizes of repositories in histograms.

import pandas as pd
import matplotlib.pyplot as plt
import numpy as np
from matplotlib.ticker import ScalarFormatter, FormatStrFormatter
from scipy import sparse

# read CSV with size data:
df_size = pd.read_csv('./data/size.csv').sort_values('size', ascending=True)
df_size.name = 'All'
df_size_top1000 = pd.read_csv('./data/size_top1000.csv').sort_values('size', ascending=True)
df_size_top1000.name = 'Top-1000'
df_size_top100 = pd.read_csv('./data/size_top100.csv').sort_values('size', ascending=True)
df_size_top100.name = 'Top-100'

fig, ax = plt.subplots()
data = [df_size['size'].values, df_size_top1000['size'].values, df_size_top100['size'].values]
weights = [
  np.ones_like(df_size['size'])/float(len(df_size['size'])),
  np.ones_like(df_size_top1000['size'])/float(len(df_size_top1000['size'])),
  np.ones_like(df_size_top100['size'])/float(len(df_size_top100['size']))
]
bins = np.logspace(np.log10(0.1), np.log10(10000000), 35)

ax.hist(data, bins=bins, weights=weights, label=['All', 'Top-1000', 'Top-100'])
ax.legend(loc='upper left')
ax.xaxis.set_major_formatter(FormatStrFormatter('%.0f'))
ax.set_xlabel('Project size [kb]')

plt.xscale('log') 

# position it:
fig.tight_layout()
fig.subplots_adjust(wspace=0.25, left=0.08, right=0.95, top=0.95, bottom=0.15)

# set figure size:
fig.set_figwidth(8)
fig.set_figheight(4)

# save:
fig.savefig('./fig/size_distribution.png')