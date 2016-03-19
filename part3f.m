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
