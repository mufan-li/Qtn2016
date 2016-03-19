clear;
close all;

global N;
N = 100;

fmt = ['%s', repmat('%f%f%f%f%d%d', 1, N)];
fid = fopen('in_sample_data.txt');
data = textscan(fid, fmt, 'delimiter', ',');
datetime = data{1};

global T;
T = size(data{1}, 1);

so = zeros(N, T);
sh = zeros(N, T);
sl = zeros(N, T);
sc = zeros(N, T);
tvl = zeros(N, T);
ind = zeros(N, T);

for ii = 0 : N - 1
    so(ii + 1, :) = data{ii * 6 + 2};
    sh(ii + 1, :) = data{ii * 6 + 3};
    sl(ii + 1, :) = data{ii * 6 + 4};
    sc(ii + 1, :) = data{ii * 6 + 5};
    tvl(ii + 1, :) = data{ii * 6 + 6};
    ind(ii + 1, :) = data{ii * 6 + 7};
end

fclose(fid);
