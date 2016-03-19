function fun = part2f(crcc_, croo, croc_, crco, ctvl_, crvp_, roc)
    N = size(ctvl_, 1);
    T = size(ctvl_, 2);

    function [f, g] = obj(a)
        [w2val, dw2da] = w2(a, crcc_, croo, croc_, crco, ctvl_, crvp_);
        [sr, dsrdw] = sharpe(w2val, roc);
        w2val = w2(a, crcc_, croo, croc_, crco, ctvl_, crvp_);
        sr = sharpe(w2val, roc);
        f = -sr;
        dsrdw_ = reshape(dsrdw, [1, N, T]);
        g = bsxfun(@times, dsrdw_, dw2da);
        g = reshape(sum(sum(g, 2), 3), size(a));
        g = -g;
    end

    fun = @(a) obj(a);
end
