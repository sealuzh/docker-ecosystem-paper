#!/usr/bin/env python

# Plots sizes of repositories.

import pandas as pd
import matplotlib.pyplot as plt
import numpy as np
from sklearn.neighbors import KernelDensity
from matplotlib.ticker import ScalarFormatter, FormatStrFormatter
import matplotlib.ticker as ticker

# Based on: https://jakevdp.github.io/blog/2013/12/01/kernel-density-estimation/
def kde_sklearn(x, x_grid, bandwidth=0.2, **kwargs):
  """Kernel Density Estimation with Scikit-learn"""
  kde_skl = KernelDensity(bandwidth=bandwidth, **kwargs)
  kde_skl.fit(x[:, np.newaxis])
  # score_samples() returns the log-likelihood of the samples
  log_pdf = kde_skl.score_samples(x_grid[:, np.newaxis])
  return np.exp(log_pdf)


# read CSV with size data:
df_size = pd.read_csv('./data/size.csv').sort_values('size', ascending=True)
df_size_top100 = pd.read_csv('./data/size_top100.csv').sort_values('size', ascending=True)
df_size_top1000 = pd.read_csv('./data/size_top1000.csv').sort_values('size', ascending=True)

plot_data = [df_size['size'], df_size_top1000['size'], df_size_top100['size']]

grid = np.linspace(1, 40000, 5000)
fig, ax = plt.subplots()
for data in plot_data:
  ax.plot(grid, kde_sklearn(data, grid, bandwidth=25), alpha=0.8)
# ax.hist(df_size_top1000['size'], 100000, fc='gray', histtype='stepfilled', alpha=0.3, normed=True)

ax.legend(labels=['All', 'Top-1000', 'Top-100'])
ax.legend(loc='upper left')
# multiply y-axis values for percent:
# ticks = ticker.FuncFormatter(lambda x, pos: '{0:g}'.format(x*100))
# ax.yaxis.set_major_formatter(ticks)
ax.set_ylabel('Density')
# use logarithmic scale:
ax.set_xscale('log')
ax.xaxis.set_major_formatter(FormatStrFormatter('%.0f'))
ax.set_xlabel('Project size [kb]')

# get figure, configure, and store:
fig = ax.get_figure()
fig.tight_layout()
fig.subplots_adjust(wspace=0.25, left=0.13, right=0.95, top=0.95, bottom=0.15)

# set figure size:
fig.set_figwidth(8)
fig.set_figheight(4)
# save:
fig.savefig('./fig/size_distribution.png')