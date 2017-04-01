#!/usr/bin/env python

# Plots explore repositories of certain size.

import pandas as pd
import matplotlib.pyplot as plt
import numpy as np
from matplotlib.ticker import ScalarFormatter, FormatStrFormatter
from scipy import sparse

# read CSV with size data:
df = pd.read_csv('./data/size.csv').sort_values('size', ascending=True)

filtered = df[df['size'] < 110]
filtered = filtered[filtered['size'] > 90]
print filtered

df['size'][11000:19000].hist(bins=200)
plt.show()