function [sr, dsrdw, mrp, srp] = sharpe(w, roc, ind)
    N = size(w, 1);
    T = size(w, 2);
    % [1, T]
    if nargin > 2
        w = max(w .* ind, 0) .* ind;
    end

    % [N, T]
    absw = abs(w);
    % [1, T]
    absw_sum = sum(absw, 1) + 1e-7;
    % [1, T]
    rocw = sum(w .* roc, 1);
    % [1, T]
    rp = rocw ./ absw_sum;
    % [1, 1]
    mrp = mean(rp);
    srp = std(rp) + 1e-7;
    sr = mrp / srp;
    % [N, T]
    drpdw = bsxfun(@rdivide, ...
        bsxfun(@times, roc, absw_sum) - bsxfun(@times, rocw, sign(w)), ...
        absw_sum .^ 2);
    dmrpdw = 1 / T * drpdw;
    dsrpdw = 1 / (T - 1) / srp * bsxfun(@times, (rp - mrp), drpdw);
    dsrdw = (dmrpdw * srp - dsrpdw * mrp) / (srp ^ 2);
    
    if nargin > 2
        dsrdw = dsrdw .* ((w .* ind) > 0);
    end
end
