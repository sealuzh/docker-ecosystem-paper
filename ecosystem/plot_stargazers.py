#!/usr/bin/env python

# Plots stargazers of repositories.

import pandas as pd
import matplotlib.pyplot as plt
import numpy as np
from sklearn.neighbors import KernelDensity

# Based on: https://jakevdp.github.io/blog/2013/12/01/kernel-density-estimation/
def kde_sklearn(x, x_grid, bandwidth=0.2, **kwargs):
  """Kernel Density Estimation with Scikit-learn"""
  kde_skl = KernelDensity(bandwidth=bandwidth, **kwargs)
  kde_skl.fit(x[:, np.newaxis])
  # score_samples() returns the log-likelihood of the samples
  log_pdf = kde_skl.score_samples(x_grid[:, np.newaxis])
  return np.exp(log_pdf)


# read CSV with base image count:
df = pd.read_csv('./data/stargazers.csv').sort_values('stargazers', ascending=True)

plot_data = [df['stargazers']]


grid = np.linspace(1, 40000, 5000)
fig, ax = plt.subplots()
for data in plot_data:
  ax.plot(grid, kde_sklearn(data, grid, bandwidth=50), alpha=0.8)
ax.legend(labels=['Overall', 'Top 1000', 'Top 100'])
ax.legend(loc='upper left')
ax.set_xlabel('Project stargazers')

# ax.set_yscale('log')

# ax.set_ylim(-0.5, 5)

plt.show()