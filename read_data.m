function d = read_data()
    N = 100;

    fmt = ['%s', repmat('%f%f%f%f%d%d', 1, N)];
    fid = fopen('in_sample_data.txt');
    data = textscan(fid, fmt, 'delimiter', ',');
    datetime = data{1};

    T = size(data{1}, 1);

    d = {};
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

    d.datetime = datetime;
    d.N = N;
    d.T = T;
    d.so = so;
    d.sh = sh;
    d.sl = sl;
    d.sc = sc;
    d.tvl = tvl;
    d.ind = ind;
end
