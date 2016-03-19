read_data;
calc_returns;
a0 = ones(12, 1) * 0.1;
% a0 = rand(12, 1) * 0.1;
% options = optimoptions('fminunc','GradObj', 'on');
options = optimoptions('fminunc');
fun = part3f(crcc_, croo, croc_, crco, ctvl_, crvp_, roc, ind);
% fun = part3f(crcc_, croo, croc_, crco, ctvl_, crvp_, roc);
a = fminunc(fun, a0, options);

% a = a0;
% da = zeros(12, 1);
% [l, da2] = fun(a);
% for ii = 1 : 12
%     a(ii) = a(ii) + 1e-7;
%     l_ = fun(a);
%     a(ii) = a(ii) - 2e-7;
%     l_2 = fun(a);
%     da(ii) = (l_ - l_2) / 2e-7;
%     a(ii) = a(ii) + 1e-7;
% end
% da ./ da2

w2val = w2(a, crcc_, croo, croc_, crco, ctvl_, crvp_);
disp('a: ');
disp(a);
disp('sharpe: ');
disp(sharpe(w2val, roc, ind) * sqrt(252));
output_csv('part3.csv', datetime, w2val, roc);
