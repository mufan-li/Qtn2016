classdef TradeMeanVar
    
    properties
    end
    
    properties (Constant)
        lambda = 0.1; % Variance penalty
    end
    
    methods (Static)
        
        % roc_m: [N, 1] of mean
        % roc_cov: [N, N] covariance
        % ind: [N, 1] indicator
        function w = optw(roc_m, roc_cov, ind)
            % w: [N, 1] trading weights
            % Maximize: obj = @(w) sum(w .* roc_m) - TradeMeanVar.lambda * transpose(w) * roc_cov * w;
            % Constraint: w .* ind >= 0
            
            N = size(roc_m, 1);
            
            A = zeros([0, N]);
            b = zeros([N, 0]);
            if nargin > 2
                A = -diag(ind);
                b = zeros([N, 1]);
            end
            
            w = quadprog(roc_cov, - roc_m / 2 / TradeMeanVar.lambda, A, b);
        end
        
        % roc_m: [N, T] predicted mean
        % roc_cov: [N, N, T] predicted cov
        % ind: [N, T] indicator (optional)
        % T: total duration with valid predication
        % w: [N, T] weights of all stocks
        function w = getw(roc_m, roc_cov, ind)
            [N, T] = size(roc_m);
            w = zeros([N, T]);
            if nargin > 2
                for t = 1 : T
                    w(:, t) = TradeMeanVar.optw(roc_m(:, t), roc_cov(:, :, t), ind(:, t));
                end
            else
                for t = 1 : T
                    w(:, t) = TradeMeanVar.optw(roc_m(:, t), roc_cov(:, :, t));
                end
            end
        end
        
        
        function test(d)
            dv = TT.data_section(d, 1, 200);
            dt = TT.data_section(d, 201, 1003);
            
            a = PredLinear.train(dt.roc, dt.rcc, dt.rvp);
            predv = PredLinear.predict(a, dv.roc, dv.rcc, dv.rvp);
            predv = predv(:, 1 + PredLinear.lag : end);
            rocv = dv.roc(:, 1 + PredLinear.lag : end);
            indv = dv.ind(:, 1 + PredLinear.lag : end);
            [roct_m, roct_cov] = TT.rvstats(dt.roc);
            covv = repmat(roct_cov, [1, 1, dv.T]);
            
            % Use training cov to approximate the validation cov
            w = TradeMeanVar.getw(predv, covv);%, indv);
            rp = TT.getrp(w, rocv);%, indv);
            sr = TT.getsr(rp);
            
            display('Sharp ratio');
            display(sr);
        end
        
    end
end