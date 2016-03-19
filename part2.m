function part2()
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

    function a = train(crcc_, croo, croc_, crco, ctvl_, crvp_, roc)
        a0 = ones(12, 1) * 0.1;
        options = optimoptions('fminunc','GradObj', 'on');
        % options = optimoptions('fminunc');
        fun = part2f(crcc_, croo, croc_, crco, ctvl_, crvp_, roc);
        a = fminunc(fun, a0, options);
        w2val = w2(a, crcc_, croo, croc_, crco, ctvl_, crvp_);
        disp('a:');
        disp(a);
        disp('sharpe:');
        disp(sharpe(w2val, roc) * sqrt(252));
    end

    split = 200;
    tcrcc_ = crcc_(:, split : end);
    tcroo = croo(:, split : end);
    tcroc_ = croc_(:, split : end);
    tcrco = crco(:, split : end);
    tctvl_ = ctvl_(:, split : end);
    tcrvp_ = crvp_(:, split : end);
    troc = roc(:, split : end);
    vcrcc_ = crcc_(:, 1 : split);
    vcroo = croo(:, 1 : split);
    vcroc_ = croc_(:, 1 : split);
    vcrco = crco(:, 1 : split);
    vctvl_ = ctvl_(:, 1 : split);
    vcrvp_ = crvp_(:, 1 : split);
    vroc = roc(:, 1 : split);

    % a = ones(12, 1);
    % w2val = w2(a, crcc_, croo, croc_, crco, ctvl_, crvp_);
    % disp(sharpe(w2val, roc));

    disp('validation');
    disp('training...');
    a = train(tcrcc_, tcroo, tcroc_, tcrco, tctvl_, tcrvp_, troc);
    w2val = w2(a, vcrcc_, vcroo, vcroc_, vcrco, vctvl_, vcrvp_);
    disp('validation sharpe:');
    disp(sharpe(w2val, vroc) * sqrt(252));
    output_csv('data_part2_val.team_A.csv', datetime, w2val, vroc);
    output_coeff('coeff_part2_val.team_A.csv', 'a', a);

    disp('train all...');
    a = train(crcc_, croo, croc_, crco, ctvl_, crvp_, roc);
    w2val = w2(a, crcc_, croo, croc_, crco, ctvl_, crvp_);
    output_csv('data_part2.team_A.csv', datetime, w2val, roc);
    output_coeff('coeff_part2.team_A.csv', 'a', a);
end
