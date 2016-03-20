import numpy as np
import pandas as pd

def ema(in_data, n_ema=2):
	for i in range(in_data.shape[1]):
		in_data[:,i] = pd.ewma(in_data[:,i], span=n_ema)
	return in_data

def rm_ema(pred_ema, prev_ema, n_ema=2):
	if (n_ema == 1):
		return pred_ema
	M = 2. / (n_ema + 1)
	pred_point = (pred_ema - prev_ema * (1-M)) / M
	return pred_point
	