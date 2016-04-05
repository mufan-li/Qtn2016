<<<<<<< HEAD
from __future__ import division

import numpy as np
from sklearn import gaussian_process
import matplotlib.pyplot as plt

import hmm_functions as ff

# def f(x):
#     return x * np.sin(x)

# X = np.atleast_2d([1., 3., 5., 6., 7., 8.]).T
# y = f(X).ravel()
# x = np.atleast_2d(np.linspace(0, 10, 1000)).T

# # corr = 'cubic'
# gp = gaussian_process.GaussianProcess(corr='squared_exponential', theta0=1e-2,
#                                       thetaL=1e-4, thetaU=1e-1)
# gp.fit(X, y)
# y_pred, sigma2_pred = gp.predict(x, eval_MSE=True)

# plt.plot(x, y_pred, 'r:', label=u'$f(x) = x\,\sin(x)$')
# plt.plot(X, y, 'r.', markersize=10, label=u'Observations')
# sigma_pred = np.sqrt(sigma2_pred)
# y1 = y_pred - 1.96 * sigma_pred
# y2 = y_pred + 1.96 * sigma_pred
# x = x.ravel()
# plt.fill_between(x, y1, y2, color='b', alpha=0.5)
# plt.show()


def run_gp(opt, fout):
    M = opt['num_pts']
    N = opt['num_stocks']
    ND = opt['num_ema']
    NG = opt['nugget']
    K = opt['kernel']
    T = d['T']
    # T = 300
    roc = d['roc'][11:]

    roc_prod = np.cumprod(1 + roc, axis=1)
    roc_prod = roc_prod[:N, :]

    # Pre-process
    if opt['cumprod']:
        Y = roc_prod
    else:
        Y = roc

    # plt.plot(np.arange(T-2), Y[0])

    if opt['smooth']:
        # mpl = 2 / (ND + 1)
        # ema = np.zeros([N, T - 2])
        # for tt in xrange(ND):
        #     ema[:, tt] = np.mean(Y[:, :tt + 1], axis=1)
        # for tt in xrange(ND, T - 2):
        #     ema[:, tt] = (Y[:, tt] - ema[:, tt - 1]) * mpl + ema[:, tt - 1]
        # Y = ema
        Y = ff.ema(Y, ND)
    # plt.plot(np.arange(T-2), Y[0])
    # plt.show()

    y_pred = np.zeros([N, T - 2 - M])
    y_sigma_pred = np.zeros([N, T - 2 - M])
    for ii in xrange(N):
        sss = 0
        for tt in xrange(T - 2 - M):
            if tt % 10 == 0:
                print ii, tt
            start = tt
            end = tt + M
            # x = np.reshape(np.linspace(0, 1, M), [-1, 1])
            x = np.reshape(np.linspace(0, M - 1, M), [-1, 1])
            y = Y[ii, start: end]
            # x = np.reshape(np.linspace(0, (M + 1) / M, M + 1), [-1, 1])
            # y = Y[ii, start: end + 1]

            gp = gaussian_process.GaussianProcess(
                regr='quadratic',
                # corr='squared_exponential',
                # corr='absolute_exponential',
                corr=K,
                nugget=NG,
                theta0=1e-2,
                thetaL=1e-12,
                thetaU=1e-1,
                normalize=True,

                # random_start=5
                # thetaU=1e-0
            )
            gp.fit(x, y)
            # x_ = np.array([[(M + 1) / M]])
            x_ = np.array([[M]])
            _y_pred, _s_pred = gp.predict(x_, eval_MSE=True)
            y_pred[ii, tt] = _y_pred[0]

            sss += (y_pred[ii, tt] / Y[ii, tt + M - 1] - 1) * roc[ii, tt + M] >= 0
            # print _y_pred, _s_pred
            y_sigma_pred[ii, tt] = np.sqrt(_s_pred)
            # print 'h', y_pred[ii, tt], y_sigma_pred[ii, tt]

            # # time = np.linspace(0, (M + 1) / M, M + 1)
            # time = np.linspace(0, M, M + 1)
            # _time = np.reshape(time, [-1, 1])
            # _y_pred, _s_pred = gp.predict(_time, eval_MSE=True)
            # _s_pred = np.sqrt(_s_pred)
            # # print 'g', _y_pred[-1], _s_pred[-1]
            # # y_pred[ii, tt] = _y_pred[-1]
            # # y_sigma_pred[ii, tt] = _s_pred[-1]

            # plt.plot(time, Y[ii, start: end + 1], 'r.')
            # plt.plot(time, _y_pred, 'k.')
            # plt.fill_between(time, _y_pred - 1.96 * _s_pred,
            #                  _y_pred + 1.96 * _s_pred, color='b', alpha=0.5)
            # plt.show()
        print 'sss', sss / (T - M - 2)

    # time = np.arange(T - 2 - M)
    # plt.plot(time, Y[0, M:], 'r.')
    # plt.plot(time, roc_prod[0, M:], 'g.')
    # plt.plot(time, y_pred[0], 'k.')
    # plt.fill_between(time, y_pred[0] - 1.96 * y_sigma_pred[0],
    #                 y_pred[0] + 1.96 * y_sigma_pred[0], color='b', alpha=0.5)

    # Post-process
    if opt['cumprod']:
        roc_pred = np.zeros([N, T - 2 - M])
        roc_sigma_pred = np.zeros([N, T - 2 - M])
        if opt['smooth']:
            y_pred = ff.rm_ema(y_pred, Y[:N, M-1: T-3], ND)
            pass
        roc_pred = y_pred / roc_prod[:N, M-1: T-3] - 1
        roc_sigma_pred = y_sigma_pred / roc_prod[:N, M-1: T-3]
    else:
        if opt['smooth']:
            y_pred = ff.rm_ema(y_pred, Y[:N, M-1: T-3], ND)
        roc_pred = y_pred
        roc_sigma_pred = y_sigma_pred

    NN = 10
    print roc_pred[:, :20]
    print roc[:N, M:M+20]
    print roc_pred[:, :NN] * roc[:N, M:M+NN] >= 0
    er = np.mean(roc_pred[:, :-1] * roc[:N, M + 1:] < 0)
    # er = np.mean(roc_pred[:, :NN] * roc[:N, M:M+NN] < 0)
    rmse = np.sqrt(np.mean((roc_pred - roc[:N, M:]) ** 2))
    print 'ER: {:.4f} RMSE: {:.4f}'.format(er, rmse)

    def output_csv():
        with open(fout, 'w') as f:
            f.write('date')
            for ii in xrange(N):
                f.write(',Stock_{}_pred'.format(ii))
                f.write(',Stock_{}_sigma'.format(ii))
            f.write('\n')
            for tt in xrange(N, 2 + M):
                f.write(d['date'][tt])
                for ii in xrange(N):
                    f.write(',99')
                    f.write(',99')
                f.write('\n')
            for tt in xrange(2 + M, T):
                tt2 = tt - 2 - M
                f.write(d['date'][tt])
                for ii in xrange(N):
                    f.write(',{:.4f}'.format(roc_pred[ii, tt2]))
                    f.write(',{:.4f}'.format(roc_sigma_pred[ii, tt2]))
                f.write('\n')

    output_csv()
    plt.show()

if __name__ == '__main__':
    import read_data
    import calc_returns

    d = read_data.read()
    calc_returns.calc(d)

    opt = {}
    opt['cumprod'] = True
    opt['num_stocks'] = 10
    opt['num_pts'] = 50
    opt['smooth'] = False
    opt['num_ema'] = 5
    opt['nugget'] = 0
    # opt['nugget'] = 1e-2
    opt['nugget'] = 1e-4
    opt['kernel'] = 'squared_exponential'
    # opt['kernel'] = 'absolute_exponential'
    # opt['kernel'] = 'cubic'
    run_gp(opt, 'gp_pred.csv')
=======
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
>>>>>>> 127b5334cd1cbde60b359567ce8b3427fce895b5
