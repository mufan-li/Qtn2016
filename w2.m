function [w2val, dw2da] = w2(a, crcc_, croo, croc_, crco, ctvl_, crvp_, ind)
    N = size(ctvl_, 1);
    T = size(ctvl_, 2);
    M = size(a, 1);
    x = zeros(M, N, T);
    x(1, :, :) = crcc_ / N;
    x(2, :, :) = croo / N;
    x(3, :, :) = croc_ / N;
    x(4, :, :) = crco / N;
    x(5, :, :) = ctvl_ .* crcc_ / N;
    x(6, :, :) = ctvl_ .* croo / N;
    x(7, :, :) = ctvl_ .* croc_ / N;
    x(8, :, :) = ctvl_ .* crco / N;
    x(9, :, :) = crvp_ .* crcc_ / N;
    x(10, :, :) = crvp_ .* croo / N;
    x(11, :, :) = crvp_ .* croc_ / N;
    x(12, :, :) = crvp_ .* crco / N;
    if nargin > 7
        x(13, :, :) = crcc_ .* ind / N;
        x(14, :, :) = croo .* ind/ N;
        x(15, :, :) = croc_ .* ind / N;
        x(16, :, :) = crco .* ind / N;
        x(17, :, :) = ctvl_ .* crcc_ .* ind / N;
        x(18, :, :) = ctvl_ .* croo .* ind / N;
        x(19, :, :) = ctvl_ .* croc_ .* ind / N;
        x(20, :, :) = ctvl_ .* crco .* ind / N;
        x(21, :, :) = crvp_ .* crcc_ .* ind / N;
        x(22, :, :) = crvp_ .* croo .* ind / N;
        x(23, :, :) = crvp_ .* croc_ .* ind / N;
        x(24, :, :) = crvp_ .* crco .* ind / N;
    end
    a = reshape(a, [M, 1, 1]);
    w2val = squeeze(sum(bsxfun(@times, a, x), 1));
    dw2da = x;
end
