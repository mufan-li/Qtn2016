import numpy as np
from sklearn import gaussian_process
import pandas as pd
import matplotlib.pyplot as plt

from gp_functions import *

ts_data = preprocess_data()

Nx, Ny = ts_data.shape
# naive: only use yesterday's data to predict
X = ts_data[:Nx-1,:]
Y = ts_data[1:Nx,1:2]

# gp = gaussian_process.GaussianProcess(theta0=1e-2, thetaL=1e-4, thetaU=1e-1)
gp = gaussian_process.GaussianProcess(theta0 = 1e-2,
	# theta0 = np.tile(1e-2,(Ny,)),
	corr = 'absolute_exponential')

# number of training data samples
T = 20
pred_len = 2
# y_pred, sigma_pred, SE = test_gp(gp, X, Y, T)
X_in = X[:T,0:1]
Y_in = Y[:T]
gp.fit(X_in,Y_in)

# x_pred = X[T:T+pred_len,0:1]
x_pred = np.atleast_2d(np.linspace(0, T+pred_len-1, 100)).T
y_pred, sigma2_pred = gp.predict(x_pred, eval_MSE=True)
sigma_pred = sigma2_pred**0.5

# tol = 0.005
# trades, returns = simple_trades(y_pred, Y[T:], tol)
# print np.prod(returns + 1) - 1

plt_start = 0
plt_end = T+pred_len
y1 = y_pred.ravel() + 1.96*sigma_pred
y2 = y_pred.ravel() - 1.96*sigma_pred
plt.plot(X[plt_start:plt_end,0],Y[plt_start:plt_end,:],'r.',ms=20)
plt.plot(x_pred, y_pred,'b',
	x_pred, y1,'b',
	x_pred, y2,'b')
plt.fill_between(x_pred.ravel(), y1, y2, facecolor='green', interpolate=True)
plt.show()
