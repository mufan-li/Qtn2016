NSTOCKS = 100;

fmt = ['%s', repmat('%f%f%f%f%d%d', 1, NSTOCKS)];
fid = fopen('in_sample_data.txt');
data = textscan(fid, fmt, 'delimiter', ',');
datetime = data{1};

NTIME = size(data{1}, 1);

so = zeros(NSTOCKS, NTIME);
sh = zeros(NSTOCKS, NTIME);
sl = zeros(NSTOCKS, NTIME);
sc = zeros(NSTOCKS, NTIME);
tvl = zeros(NSTOCKS, NTIME);
ind = zeros(NSTOCKS, NTIME);

for ii = 0 : NSTOCKS - 1
    so(ii + 1, :) = data{ii * 6 + 2};
    sh(ii + 1, :) = data{ii * 6 + 3};
    sl(ii + 1, :) = data{ii * 6 + 4};
    sc(ii + 1, :) = data{ii * 6 + 5};
    tvl(ii + 1, :) = data{ii * 6 + 6};
    ind(ii + 1, :) = data{ii * 6 + 7};
end
