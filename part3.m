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
    
    function fun = part3f(crcc_, croo, croc_, crco, ctvl_, crvp_, roc, ind)
        N = size(ctvl_, 1);
        T = size(ctvl_, 2);
        has_ind = nargin > 7;

        function [f, g] = obj(a)
            [w2val, dw2da] = w2(a, crcc_, croo, croc_, crco, ctvl_, crvp_);
            if has_ind
                [sr, dsrdw] = sharpe(w2val, roc, ind);
            else
                [sr, dsrdw] = sharpe(w2val, roc);
            end
            f = -sr;
            dsrdw_ = reshape(dsrdw, [1, N, T]);
            g = bsxfun(@times, dsrdw_, dw2da);
            g = reshape(sum(sum(g, 2), 3), size(a));
            g = -g;
        end

        fun = @(a) obj(a);
    end

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

    T = size(crcc_, 2);
    % tsplit = 200 : T;
    % vsplit = 1 : 200;
    tsplit = 1 : T - 200;
    vsplit = T - 200 : T;
    tcrcc_ = crcc_(:, tsplit);
    tcroo = croo(:, tsplit);
    tcroc_ = croc_(:, tsplit);
    tcrco = crco(:, tsplit);
    tctvl_ = ctvl_(:, tsplit);
    tcrvp_ = crvp_(:, tsplit);
    troc = roc(:, tsplit);
    tind = ind(:, tsplit);
    vcrcc_ = crcc_(:, vsplit);
    vcroo = croo(:, vsplit);
    vcroc_ = croc_(:, vsplit);
    vcrco = crco(:, vsplit);
    vctvl_ = ctvl_(:, vsplit);
    vcrvp_ = crvp_(:, vsplit);
    vroc = roc(:, vsplit);
    vind = ind(:, vsplit);
    
    disp('validation');
    disp('training...');
    a = train(tcrcc_, tcroo, tcroc_, tcrco, tctvl_, tcrvp_, troc, tind);
    w2val = w2(a, vcrcc_, vcroo, vcroc_, vcrco, vctvl_, vcrvp_);
    disp('validation sharpe:');
    disp(sharpe(w2val, vroc, vind) * sqrt(252));
    output_csv('data_part3_val.team_A.csv', datetime, w2val, vroc, vind);
    output_coeff('coeff_part3_val.team_A.csv', 'b', a);

    disp('train all...');
    a = train(crcc_, croo, croc_, crco, ctvl_, crvp_, roc, ind);
    w2val = w2(a, crcc_, croo, croc_, crco, ctvl_, crvp_);
    output_csv('data_part3.team_A.csv', datetime, w2val, roc, ind);
    output_coeff('coeff_part3.team_A.csv', 'b', a);
end
