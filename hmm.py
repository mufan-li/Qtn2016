import datetime
import numpy as np
from hmmlearn.hmm import GaussianHMM

in_data = np.genfromtxt('in_sample_data_headers2.csv', delimiter=",")
# first row and column are all NaNs
# ROC_0 starts at 602
in_data = in_data[1:,602:]
dim_h = 2
N_train = 500
n_stocks = 100
X = in_data[:N_train,:]
n_factors = X.shape[1]/n_stocks

# Make an HMM instance and execute fit
model = GaussianHMM(n_components=dim_h, covariance_type="diag", 
					n_iter=1000).fit(X)

N_pred = in_data[N_train:,:].shape[0]-1
RMSE = np.zeros(N_pred)
ER = np.zeros(N_pred)

# Predict the optimal sequence of internal hidden state
for i in range(N_pred):
	hidden_states = model.predict(in_data[:(N_train+i),:])
	state_cur = hidden_states[N_train+i-1]
	# model.transmat_
	pred_ind = np.arange(n_stocks) * n_factors
	
	mean_cur = model.means_[state_cur,:]
	mean_pred = mean_cur[pred_ind]
	
	covar_cur = model.covars_[state_cur,:]
	covar_pred = covar_cur[pred_ind,:][:,pred_ind]

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



















