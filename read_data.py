import numpy as np

def read():
    N = 100
    T = 1003
    date = []
    so = np.zeros([N, T]);
    sh = np.zeros([N, T]);
    sl = np.zeros([N, T]);
    sc = np.zeros([N, T]);
    tvl = np.zeros([N, T]);
    ind = np.zeros([N, T]);

    with open('in_sample_data.txt') as f:
        for tt, line in enumerate(f):
            cols = line.split(',')
            date.append(cols[0])
            for ii in xrange(N):
                so[ii, tt] = float(cols[ii * 6 + 1])
                sh[ii, tt] = float(cols[ii * 6 + 2])
                sl[ii, tt] = float(cols[ii * 6 + 3])
                sc[ii, tt] = float(cols[ii * 6 + 4])
                tvl[ii, tt] = float(cols[ii * 6 + 5])
                ind[ii, tt] = float(cols[ii * 6 + 6])

    d = {}
    d['date'] = date
    d['so'] = so
    d['sh'] = sh
    d['sl'] = sl
    d['sc'] = sc
    d['tvl'] = tvl
    d['ind'] = ind
    d['N'] = N
    d['T'] = T

    return d

if __name__ == '__main__':
    read()
