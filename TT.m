classdef TT

    properties
    end
    
    methods (Static)
        
        % real: [N, T] actual values
        % pred: [N, T] predictions
        % err_m: [N, 1] mean of error (over T)
        % err_var: [N, 1] variance of error (over T)
        % err_dir: [N, 1] proportion of sgn(real) != sgn(pred)
        function [err_m, err_var, err_dir] = err_sta(real, pred)
            [N, T] = size(real);
            err = pred - real;
            err_m = mean(err, 2);
            % error_tilde = error - ones([N, 1]) * err_m;
            error_tilde = err - err_m * ones([1, T]);
            err_var = mean(error_tilde .* error_tilde, 2);
            err_dir = mean(mean(pred .* real < 0));
        end
        
        % d: data
        % s: start index
        % e: end index
        % ds: retrieved data section
        function ds = data_section(d, s, e)
            ds.datetime = d.datetime(s : e);
            ds.N = d.N;
            ds.T = e - s + 1;
            ds.so = d.so(:, s : e);
            ds.sh = d.sh(:, s : e);
            ds.sl = d.sl(:, s : e);
            ds.sc = d.sc(:, s : e);
            ds.tvl = d.tvl(:, s : e);
            ds.ind = d.ind(:, s : e);
            ds.rcc = d.rcc(:, s : e);
            ds.rco = d.rco(:, s : e);
            ds.roc = d.roc(:, s : e);
            ds.roo = d.roo(:, s : e);
            ds.rvp = d.rvp(:, s : e);
            ds.crcc = d.rcc(:, s : e);
            ds.crco = d.rco(:, s : e);
            ds.croc = d.roc(:, s : e);
            ds.croo = d.croo(:, s : e);
            ds.crvp = d.crvp(:, s : e);
            ds.ctvl = d.ctvl(:, s : e);
        end
        
        % Retrieve a subset of the data containing selected stocks
        % d: data
        % s: start index
        % e: end index
        % ds: retrieved data section
        function ds = data_sect_stock(d, s, e)
            ds.datetime = d.datetime;
            ds.N = e - s + 1;
            ds.T = d.T;
            ds.so = d.so(s : e, :);
            ds.sh = d.sh(s : e, :);
            ds.sl = d.sl(s : e, :);
            ds.sc = d.sc(s : e, :);
            ds.tvl = d.tvl(s : e, :);
            ds.ind = d.ind(s : e, :);
            ds.rcc = d.rcc(s : e, :);
            ds.rco = d.rco(s : e, :);
            ds.roc = d.roc(s : e, :);
            ds.roo = d.roo(s : e, :);
            ds.rvp = d.rvp(s : e, :);
            ds.crcc = d.rcc(s : e, :);
            ds.crco = d.rco(s : e, :);
            ds.croc = d.roc(s : e, :);
            ds.croo = d.croo(s : e, :);
            ds.crvp = d.crvp(s : e, :);
            ds.ctvl = d.ctvl(s : e, :);
        end
        
        function d = init_data()
            d = TT.read_data('in_sample_data.txt');
            d = TT.calc_returns(d);
        end
        
        % d: struct of data
        % filename: source file
        function d = read_data(filename)
            N = 100;

            fmt = ['%s', repmat('%f%f%f%f%d%d', 1, N)];
            fid = fopen(filename);
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
        
        % populate relevant information
        function d = calc_returns(d)
            N = d.N;
            T = d.T;
            so = d.so;
            sh = d.sh;
            sl = d.sl;
            sc = d.sc;

            so__ = [so, zeros(N, 1)];
            sc__ = [sc, zeros(N, 1)];
            so_ = [zeros(N, 1), so];
            sc_ = [zeros(N, 1), sc];
            rcc = sc__ ./ sc_ - 1;
            d.rcc = rcc(:, 1 : T);
            rco = so__ ./ sc_ - 1;
            d.rco = rco(:, 1 : T);
            d.roc = sc ./ so - 1;
            roo = so__ ./ so_ - 1;
            d.roo = roo(:, 1 : T);
            d.rvp = 1 / (4 * log(2)) * (log(sh) - log(sl)) .^ 2;

            mrcc = mean(d.rcc, 1);
            mroc = mean(d.roc, 1);
            mroo = mean(d.roo, 1);
            mrco = mean(d.rco, 1);
            
            mrvp = zeros(N, T);
            mtvl = zeros(N, T);
            for ii = 1 : T
                mrvp(:, ii) = mean(d.rvp(:, max(1, ii-200) : ii - 1), 2);
                mtvl(:, ii) = mean(d.tvl(:, max(1, ii-200) : ii - 1), 2);
            end

            d.croo = bsxfun(@minus, d.roo, mroo);
            d.crco = bsxfun(@minus, d.rco, mrco);
            d.crcc = bsxfun(@minus, d.rcc, mrcc);
            d.croc = bsxfun(@minus, d.roc, mroc);
            d.crvp = bsxfun(@rdivide, d.rvp, mrvp);
            d.ctvl = bsxfun(@rdivide, d.tvl, mtvl);
        end
        
                
        % w: [N, T] weights
        % roc: [N, T] return open-close
        % ind: [N, T] direction indicator
        % rp: [1, T] daily return
        function rp = getrp(w, roc, ind)
            wr = w;
            if nargin > 2
                wr = max(wr .* ind, 0) .* ind;
            end
            rp = sum(wr .* roc, 1) ./ max(sum(abs(wr), 1), 1e-7);
        end
        
        % rp: [1, T] daily return
        % sr: [1] sharp ratio
        function sr = getsr(rp)
            rp_m = mean(rp);
            rp_std = std(rp) + 1e-7;
            sr = rp_m / rp_std * sqrt(252);
        end
        
        % rv: [N, T] N-dim RV, each represented by T sample points
        % rv_m: [N, 1] mean
        % rv_cov: [N, N] covariance
        function [rv_m, rv_cov] = rvstats(rv)
            T = size(rv, 2);
            rv_m = mean(rv, 2);
            rv_tilde = rv - rv_m * ones([1, T]);
            rv_cov = rv_tilde * transpose(rv_tilde) / T; 
        end
        
        function prod = Dot(IND, i, j)
            prod = transpose(IND(:,i)) * IND(:,j);
        end
        
        % size(RV) = [sample_num, RV_dim]
        function RV_mean = SampleMean(RV)
            RV_mean = mean(RV, 1);
        end
        
        function RV_cov = SampleCov(RV)
            [sample_num, RV_dim] = size(RV);
            RV_mean = TT.SampleMean(RV);
            RV_tilt = RV - ones(sample_num, 1) * RV_mean;
            RV_cov = transpose(RV_tilt) * RV_tilt / sample_num;
        end
        
        function Autocor = SampleAutocor(RV)
            [sample_num, RV_dim] = size(RV);
            autocor_len = floor(sample_num / 2 - 1);
            Autocor = zeros([autocor_len, RV_dim]);
            for i = 1 : autocor_len
                for j = 1 : RV_dim
                    Autocor(i,j) = transpose(RV(1:sample_num - i,j)) * RV(1+i:sample_num,j) / (sample_num - i - 1);
                end
            end
        end
        
        % Compute sharp ratio on the return
        function SR = computeSR(Return)
            SR = TT.SampleMean(Return) / sqrt(TT.SampleCov(Return)) * sqrt(252);
        end
        
        
    end

end