from __future__ import division

import numpy as np
from sklearn import gaussian_process

import matplotlib.pyplot as plt

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
    roc = d['roc']

    roc_prod = np.cumprod(1 + roc, axis=1)
    roc_prod = roc_prod[:N, :]

    # Pre-process
    if opt['cumprod']:
        Y = roc_prod
    else:
        Y = roc

    if opt['smooth']:
        mpl = 2 / (ND + 1)
        ema = np.zeros([N, T - 2])
        for tt in xrange(ND):
            ema[:, tt] = np.mean(Y[:, :tt + 1], axis=1)
        for tt in xrange(ND, T - 2):
            ema[:, tt] = (Y[:, tt] - ema[:, tt - 1]) * mpl + ema[:, tt - 1]
        Y = ema


    y_pred = np.zeros([N, T - 2 - M])
    y_sigma_pred = np.zeros([N, T - 2 - M])
    for ii in xrange(N):
        for tt in xrange(T - 2 - M):
            if tt % 10 == 0:
                print ii, tt
            start = tt
            end = tt + M
            x = np.reshape(np.arange(M), [M, 1])
            y = Y[ii, start: end]
            gp = gaussian_process.GaussianProcess(
                # corr='squared_exponential', 
                corr=K,
                nugget=NG,
                # theta0=1e-2, 
                # thetaL=1e-4, 
                # thetaU=1e-1
            )
            gp.fit(x, y)
            x_ = np.array([[M]])
            _y_pred, _s_pred = gp.predict(x_, eval_MSE=True)
            y_pred[ii, tt] = _y_pred[0]
            y_sigma_pred[ii, tt] = np.sqrt(_s_pred)

            # time = np.arange(start, end + 1)
            # _time  = np.reshape(time, [-1, 1])
            # _y_pred, _s_pred = gp.predict(_time, eval_MSE=True)
            # plt.plot(time, Y[ii, start: end + 1], 'r.')
            # plt.plot(time, _y_pred, 'k.')
            # plt.fill_between(time, _y_pred - 1.96 * _s_pred, 
            #     _y_pred + 1.96 * _s_pred, color='b', alpha=0.5)
            # plt.show()

    time = np.arange(T - 2 - M)
    plt.plot(time, Y[0, M: ], 'r.')
    plt.plot(time, y_pred[0], 'k.')
    plt.fill_between(time, y_pred[0] - 1.96 * y_sigma_pred[0], 
        y_pred[0] + 1.96 * y_sigma_pred[0], color='b', alpha=0.5)

    # Post-process
    if opt['cumprod']:
        roc_pred = np.zeros([N, T - 2 - M])
        roc_sigma_pred = np.zeros([N, T - 2 - M])
        for tt in xrange(T - 2 - M):
            roc_pred[:, tt] = y_pred[:, tt] / roc_prod[:, tt + M - 1] - 1
            roc_sigma_pred[:, tt] = y_sigma_pred[:, tt] / roc_prod[:, tt + M - 1]
    else:
        roc_pred = y_pred
        roc_sigma_pred = y_sigma_pred

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
    opt['num_stocks'] = 5
    opt['num_pts'] = 50
    opt['smooth'] = True
    opt['num_ema'] = 2
    opt['nugget'] = 1e-6
    opt['kernel'] = 'cubic'

    run_gp(opt, 'gp_pred.csv')
