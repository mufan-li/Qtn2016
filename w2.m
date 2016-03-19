function w2 = w2(a)
    global N;
    global T;
    global crcc_;
    global croo;
    global crco;
    global croc_;
    global ctvl_;
    global crvp_;
    x = zeros(12, N, T - 2);
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
    a = reshape(a, [12, 1, 1]);
    w2 = squeeze(sum(bsxfun(@times, a, x), 1));
end
