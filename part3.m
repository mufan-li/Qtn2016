function part3()
    d = read_data();
    d = calc_returns(d);
    datetime = d.datetime;
    rcc = d.rcc;
    rco = d.rco;
    roc = d.roc;
    roo = d.roo;
    ind = d.ind;
    croo  = d.croo;
    crco  = d.crco;
    crcc_ = d.crcc_;
    croc_ = d.croc_;
    crvp_ = d.crvp_;
    ctvl_ = d.ctvl_;

    function a = train(crcc_, croo, croc_, crco, ctvl_, crvp_, roc, ind)
        a0 = ones(12, 1) * 0.01;
        options = optimoptions('fminunc');
        % options = optimoptions('fminunc','GradObj', 'on');
        fun = part3f(crcc_, croo, croc_, crco, ctvl_, crvp_, roc, ind);
        a = fminunc(fun, a0, options);
        w2val = w2(a, crcc_, croo, croc_, crco, ctvl_, crvp_);
        disp('a:');
        disp(a);
        disp('sharpe:');
        disp(sharpe(w2val, roc, ind) * sqrt(252));
    end

    split = 200;
    tcrcc_ = crcc_(:, split : end);
    tcroo = croo(:, split : end);
    tcroc_ = croc_(:, split : end);
    tcrco = crco(:, split : end);
    tctvl_ = ctvl_(:, split : end);
    tcrvp_ = crvp_(:, split : end);
    troc = roc(:, split : end);
    tind = ind(:, split : end);
    vcrcc_ = crcc_(:, 1 : split);
    vcroo = croo(:, 1 : split);
    vcroc_ = croc_(:, 1 : split);
    vcrco = crco(:, 1 : split);
    vctvl_ = ctvl_(:, 1 : split);
    vcrvp_ = crvp_(:, 1 : split);
    vroc = roc(:, 1 : split);
    vind = ind(:, 1 : split);
    
    disp('validation');
    disp('training...');
    a = train(tcrcc_, tcroo, tcroc_, tcrco, tctvl_, tcrvp_, troc, tind);
    w2val = w2(a, vcrcc_, vcroo, vcroc_, vcrco, vctvl_, vcrvp_);
    disp('validation sharpe:');
    disp(sharpe(w2val, vroc, vind) * sqrt(252));
    output_csv('data_part3_val.team_A.csv', datetime, w2val, vroc, vind);
    output_coeff('coeff_part3_val.team_A.csv', 'a', a);

    disp('train all...');
    a = train(crcc_, croo, croc_, crco, ctvl_, crvp_, roc, ind);
    w2val = w2(a, crcc_, croo, croc_, crco, ctvl_, crvp_);
    output_csv('data_part3.team_A.csv', datetime, w2val, roc, ind);
    output_coeff('coeff_part3.team_A.csv', 'b', a);
end
