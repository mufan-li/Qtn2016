import read_data
import numpy as np

def calc(d):
    N = d['N']
    T = d['T']
    so = d['so']
    sh = d['sh']
    sl = d['sl']
    sc = d['sc']
    tvl = d['tvl']
    ind = d['ind']

    so__ = np.concatenate([so, np.zeros([N, 1])], axis=1)
    sc__ = np.concatenate([sc, np.zeros([N, 1])], axis=1)
    so_ = np.concatenate([np.zeros([N, 1]), so], axis=1)
    sc_ = np.concatenate([np.zeros([N, 1]), sc], axis=1)
    rcc = sc__ / sc_ - 1
    rcc = rcc[:, 1:]
    rco = so__ / sc_ - 1
    rco = rco[:, 1:]
    roc = sc / so - 1
    roo = so__ / so_ - 1
    roo = roo[:, 1:]
    rvp = 1 / (4 * np.log(2)) * (np.log(sh) - np.log(sl)) ** 2

    rcc_ = rcc[:, 1: T - 1]
    rco_ = rco[:, 1: T - 1]
    roc_ = roc[:, 1: T - 1]
    roo_ = roo[:, 1: T - 1]
    rvp_ = rvp[:, 1: T - 1]
    tvl_ = tvl[:, 1: T - 1]

    rcc = rcc[:, 2:]
    rco = rco[:, 2:]
    roc = roc[:, 2:]
    roo = roo[:, 2:]

    mrcc = np.mean(rcc, axis=0, keepdims=True)
    mroc = np.mean(roc, axis=0, keepdims=True)
    mroo = np.mean(roo, axis=0, keepdims=True)
    mrco = np.mean(rco, axis=0, keepdims=True)

    mrcc_ = np.mean(rcc_, axis=0, keepdims=True)
    mroc_ = np.mean(roc_, axis=0, keepdims=True)
    mroo_ = np.mean(roo_, axis=0, keepdims=True)
    mrco_ = np.mean(rco_, axis=0, keepdims=True)

    mrvp_ = np.zeros([N, T - 2])
    mtvl_ = np.zeros([N, T - 2])

    for ii in xrange(T - 2):
        t = ii + 3
        mrvp_[:, ii] = np.mean(
            rvp[:, max(1, t - 200): t], axis=1)
        mtvl_[:, ii] = np.mean(
            tvl[:, max(1, t - 200): t], axis=1)

    croo = roo - mroo
    crco = rco - mrco
    crcc_ = rcc_ - mrcc_
    croc_ = roc_ - mroc_
    crvp_ = rvp_ / mrvp_
    ctvl_ = tvl_ / mtvl_
    ind = ind[:, 3:]

    d['rcc'] = rcc
    d['rco'] = rco
    d['roc'] = roc
    d['roo'] = roo
    d['ind'] = ind
    d['croo'] = croo
    d['crco'] = crco
    d['crcc_'] = crcc_
    d['croc_'] = croc_
    d['crvp_'] = crvp_
    d['ctvl_'] = ctvl_

    # return d
    pass


if __name__ == '__main__':
    d = read_data.read()
    print calc(d)
