# helper functions

import numpy as np
import numpy.random as rd
from numpy import transpose as t
import pandas as pd

# initialize the hidden state transition matrix
#  - first column is zero
#  - each row sum to one
#  - first row is set to 1/dim_hid for uniform prior
def A_init(dim_hid):
	A = rd.uniform(size = (dim_hid+1,dim_hid+1))
	A[:,0] = 0
	A[0,1:(dim_hid+1)] = 1./dim_hid
	A = t(t(A) / np.sum(A, axis = 1))
	return A

# initialize the transition matrix from hidden to visible
def B_init(dim_hid,dim_vis):
	B = rd.uniform(size = (dim_hid+1,dim_vis+1))
	B[:,0] = 0
	B[0,:] = 0
	B[0,0] = 1
	B = t(t(B) / np.sum(B, axis = 1))
	return B

def preprocess_data():
	input_data = pd.read_csv('in_sample_data.csv')
	# list(input_data.columns.values)

	col_index = [1] + list(np.linspace(2,22,11).astype(int))

	''' Convention: array_data[asset_index, data_index] '''
	array_data = np.asarray(input_data.ix[:,col_index])

	Nx, Ny = array_data.shape
	array_data = np.append(np.reshape(np.arange(Nx),(Nx,1)), array_data, axis = 1)
	# return_data = np.diff(array_data.T).T / array_data[:Nx-1, :Ny]
	# return_data = np.append(np.reshape(np.arange(Nx-1),(Nx-1,1)), return_data, axis = 1)
	return array_data

def test_gp(gp, X, Y, T):
	Tx, Ny = X.shape

	# X.shape = (n_samples, n_features)
	# Y.shape = (n_samples, n_targets)
	y_pred_vec = None
	sigma_pred_vec = None

	for i in np.arange(T, Tx):
		gp.fit(X[i-T:i,:], Y[i-T:i,:])
		# X.shape = (n_eval, n_features)
		y_pred, sigma2_pred = gp.predict(X[i:i+1,:], eval_MSE=True)
		if i == T:
			y_pred_vec = y_pred
			sigma_pred_vec = np.sqrt(sigma2_pred)
		else:
			y_pred_vec = np.append(y_pred_vec, y_pred, axis = 0)
			sigma_pred_vec = np.append(sigma_pred_vec, sigma2_pred, axis = 0)

	# standard error
	SE = np.sqrt(np.mean(np.power(Y[T:,:] - y_pred_vec,2)))

	return y_pred_vec, sigma_pred_vec, SE

def simple_sign(x_array, tol = 0.01):
	return (x_array > tol).astype(int) - (x_array < -tol).astype(int)

def simple_trades(y_pred, Y, tol = 0.01):
	trades = simple_sign(y_pred, tol)
	returns = Y * trades
	return trades, returns







