function d = calc_returns(d)
    N = d.N;
    T = d.T;
    so = d.so;
    sh = d.sh;
    sl = d.sl;
    sc = d.sc;
    tvl = d.tvl;
    ind = d.ind;

    so__ = [so, zeros(N, 1)];
    sc__ = [sc, zeros(N, 1)];
    so_ = [zeros(N, 1), so];
    sc_ = [zeros(N, 1), sc];
    rcc = sc__ ./ sc_ - 1;
    rcc = rcc(:, 1 : T);
    rco = so__ ./ sc_ - 1;
    rco = rco(:, 1 : T);
    roc = sc ./ so - 1;
    roo = so__ ./ so_ - 1;
    roo = roo(:, 1 : T);
    rvp = 1 / (4 * log(2)) * (log(sh) - log(sl)) .^ 2;

    rcc_ = rcc(:, 2 : T - 1);
    rco_ = rco(:, 2 : T - 1);
    roc_ = roc(:, 2 : T - 1);
    roo_ = roo(:, 2 : T - 1);
    rvp_ = rvp(:, 2 : T - 1);
    tvl_ = tvl(:, 2 : T - 1);

    rcc = rcc(:, 3 : T);
    rco = rco(:, 3 : T);
    roc = roc(:, 3 : T);
    roo = roo(:, 3 : T);

    mrcc = mean(rcc, 1);
    mroc = mean(roc, 1);
    mroo = mean(roo, 1);
    mrco = mean(rco, 1);

    mrcc_ = mean(rcc_, 1);
    mroc_ = mean(roc_, 1);
    mroo_ = mean(roo_, 1);
    mrco_ = mean(rco_, 1);

    mrvp_ = zeros(N, T - 2);
    mtvl_ = zeros(N, T - 2);
    for ii = 1 : T - 2
        t = ii + 2;
        mrvp_(:, ii) = mean(rvp(:, max(1, t - 200) : t - 1), 2);
        mtvl_(:, ii) = mean(tvl(:, max(1, t - 200) : t - 1), 2);
    end

    croo = bsxfun(@minus, roo, mroo);
    crco = bsxfun(@minus, rco, mrco);
    crcc_ = bsxfun(@minus, rcc_, mrcc_);
    croc_ = bsxfun(@minus, roc_, mroc_);
    crvp_ = bsxfun(@rdivide, rvp_, mrvp_);
    ctvl_ = bsxfun(@rdivide, tvl_, mtvl_);
    ind = ind(:, 3 : T);

    d.rcc = rcc;
    d.rco = rco;
    d.roc = roc;
    d.roo = roo;
    d.ind = ind;
    d.croo  = croo;
    d.crco  = crco;
    d.crcc_ = crcc_;
    d.croc_ = croc_;
    d.crvp_ = crvp_;
    d.ctvl_ = ctvl_;
end
