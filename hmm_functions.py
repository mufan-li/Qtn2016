import numpy as np
import pandas as pd

def ema(in_data, n_ema=2):
    out_data = np.copy(in_data)
    for i in range(in_data.shape[0]):
        out_data[i, :] = pd.ewma(in_data[i,:], span=n_ema)
	return out_data

def rm_ema(pred_ema, prev_ema, n_ema=2):
    if (n_ema == 1):
        return pred_ema
    M = 2. / (n_ema + 1)
    pred_point = (pred_ema - prev_ema * (1-M)) / M
    return pred_point
	
