read_data;
calc_returns;
obj = @(a) -sharpe(w2(a), roc);
% a0 = zeros(12, 1);
a0 = ones(12, 1) * 0.1;
a = fminunc(obj, a0);
disp(a);
disp(sharpe(w2(a), roc));
