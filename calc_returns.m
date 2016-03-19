so__ = [so, zeros(N, 1)];
sc__ = [sc, zeros(N, 1)];
so_ = [zeros(N, 1), so];
sc_ = [zeros(N, 1), sc];
rcc = sc__ ./ sc_ - 1;
rcc = rcc(:, 1 : T);
rco = so__ ./ sc_ - 1;
rco = rco(:, 1 : T);
roc = sc ./ so - 1;
roo = so__ ./ so_ - 1;
roo = roo(:, 1 : T);
rvp = 1 / (4 * log(2)) * (log(sh) - log(sl)) .^ 2;

rcc_ = rcc(:, 2 : T - 1);
rco_ = rco(:, 2 : T - 1);
roc_ = roc(:, 2 : T - 1);
roo_ = roo(:, 2 : T - 1);
rvp_ = rvp(:, 2 : T - 1);
tvl_ = tvl(:, 2 : T - 1);

rcc = rcc(:, 3 : T);
rco = rco(:, 3 : T);
roc = roc(:, 3 : T);
roo = roo(:, 3 : T);
% rvp = rvp(:, 3 : T);
% tvl = tvl(:, 3 : T);

mrcc = mean(rcc, 1);
mroc = mean(roc, 1);
mroo = mean(roo, 1);
mrco = mean(rco, 1);

mrcc_ = mean(rcc_, 1);
mroc_ = mean(roc_, 1);
mroo_ = mean(roo_, 1);
mrco_ = mean(rco_, 1);

mrvp_ = zeros(N, T - 2);
mtvl_ = zeros(N, T - 2);
for ii = 1 : T - 2
    t = ii + 2;
    mrvp_(:, ii) = mean(rvp(:, t - max(1, t - 200) : t - 1), 2);
    mtvl_(:, ii) = mean(tvl(:, t - max(1, t - 200) : t - 1), 2);
end

global croo;
croo = bsxfun(@minus, roo, mroo);
global crco;
crco = bsxfun(@minus, rco, mrco);
global crcc_;
crcc_ = bsxfun(@minus, rcc_, mrcc_);
global croc_;
croc_ = bsxfun(@minus, roc_, mroc_);
global crvp_;
crvp_ = bsxfun(@rdivide, rvp_, mrvp_);
global ctvl_;
ctvl_ = bsxfun(@rdivide, tvl_, mtvl_);
