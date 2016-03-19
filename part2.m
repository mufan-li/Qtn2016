read_data;
calc_returns;
a0 = ones(12, 1) * 0.1;
options = optimoptions('fminunc','GradObj', 'on');
% options = optimoptions('fminunc');
fun = part2f(crcc_, croo, croc_, crco, ctvl_, crvp_, roc);
a = fminunc(fun, a0, options);

w2val = w2(a, crcc_, croo, croc_, crco, ctvl_, crvp_);
disp('a: ');
disp(a);
disp('sharpe: ');
disp(sharpe(w2val, roc, ind) * sqrt(252));
output_csv('part2.csv', datetime, w2val, roc);
