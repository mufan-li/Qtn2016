import datetime
import numpy as np
from hmmlearn.hmm import GaussianHMM
from hmm_functions import *

in_data = np.genfromtxt('in_sample_data_headers2.csv', delimiter=",")
# first row and column are all NaNs
# ROC_0 starts at 602
in_data = in_data[1:, 602:]

# smoothing using exp MA
n_ema=1
in_data_ema = ema(in_data, n_ema = n_ema)

dim_h = 5
N_train = 500
n_stocks = 1
X = in_data[:N_train,:(n_stocks*3)]
n_factors = X.shape[1] / n_stocks

# Make an HMM instance and execute fit

model = GaussianHMM(n_components=dim_h, covariance_type="diag", 
					n_iter=1000).fit(in_data_ema[:(N_train),:])

RMSE_train = np.zeros(N_train)
ER_train = np.zeros(N_train)

# Predict the optimal sequence of internal hidden state
hidden_states = model.predict(in_data_ema[:N_train,:])
	state_cur = hidden_states[i]
	# model.transmat_
	pred_ind = np.arange(n_stocks) * n_factors
	
	mean_cur = model.means_[state_cur,:]
	mean_pred = mean_cur[pred_ind]
	# need 
	prev_ema = in_data_ema[i,pred_ind]
	mean_pred = rm_ema(mean_pred, prev_ema, n_ema=n_ema)
	
	covar_cur = model.covars_[state_cur,:]
	covar_pred = covar_cur[pred_ind,:][:,pred_ind]
	covar_pred = rm_ema(covar_pred, 0, n_ema=n_ema)

	y_true = in_data[(i+1),pred_ind]
	RMSE_train[i] = np.sqrt(np.mean((y_true - mean_pred)**2))
	ER_train[i] = np.mean(y_true * mean_pred < 0)

print "Train RMSE: ", np.mean(RMSE_train) 
print "Train ER: ", np.mean(ER_train)


# Testing

N_pred = in_data_ema[N_train:,:].shape[0]-1
RMSE = np.zeros(N_pred)
ER = np.zeros(N_pred)

# Predict the optimal sequence of internal hidden state
for i in range(N_pred):

	hidden_states = model.predict(in_data_ema[:(N_train+i),:])
	state_cur = hidden_states[N_train+i-1]
	# model.transmat_
	pred_ind = np.arange(n_stocks) * n_factors
	
	mean_cur = model.means_[state_cur,:]
	mean_pred = mean_cur[pred_ind]
	# need 
	prev_ema = in_data_ema[(N_train+i-1),pred_ind]
	mean_pred = rm_ema(mean_pred, prev_ema, n_ema=n_ema)
	
	covar_cur = model.covars_[state_cur,:]
	covar_pred = covar_cur[pred_ind,:][:,pred_ind]
	covar_pred = rm_ema(covar_pred, 0, n_ema=n_ema)

	y_true = in_data[(N_train+i),pred_ind]
	RMSE[i] = np.sqrt(np.mean((y_true - mean_pred)**2))
	ER[i] = np.mean(y_true * mean_pred < 0)

print "RMSE: ", np.mean(RMSE) 
print "ER: ", np.mean(ER)
# print("Transition matrix")
# print(model.transmat_)
# print()

# print("Means and vars of each hidden state")
# for i in range(model.n_components):
#     print("{0}th hidden state".format(i))
#     print("mean = ", model.means_[i])
#     print("var = ", np.diag(model.covars_[i]))
#     print()



















