import time

import matplotlib.pyplot as plt
import numpy as np
from scipy import signal

import adi
fs = int(sdr.sample_rate)
N = 1024
fc = int(3_000_000 / (fs / N)) * (fs / N)
ts = 1 / float(fs)
t = np.arange(0, N * ts, ts)
i = np.cos(2 * np.pi * t * fc) * 2 ** 14
q = np.sin(2 * np.pi * t * fc) * 2 ** 14
iq = i + 1j * q