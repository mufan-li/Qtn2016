classdef PredLinear

    properties
    end
    
    properties (Constant)
        lag = 1; % Number of previous data points required for prediction
        obs_size = 4;
    end
    
    methods (Static)
        
        % size(roc) = [1, T]
        function obs = observation(roc, rcc, rvp)
            [N, T] = size(roc);
            obs = zeros([PredLinear.obs_size, T - PredLinear.lag]);
            obs(1, :) = ones([1, T - PredLinear.lag]);
            obs(2, :) = roc(1, 1 : T - PredLinear.lag);
            %obs(3, :) = rcc(1, 1 : T - PredLinear.lag);
            obs(4, :) = rvp(1, 1 : T - PredLinear.lag);
        end
        
        function [a, pred] = train(roc, rcc, rvp)
            [N, T] = size(roc);
            target = roc(:, 1 + PredLinear.lag : T);
            a = zeros([N, PredLinear.obs_size]);
            pred = zeros([N, T]);
            for i = 1 : N
                obs = PredLinear.observation(roc(i, :), rcc(i, :), rvp(i, :));
                a(i, :) = transpose(target(i, :)) \ transpose(obs);
                pred(i, 1 + PredLinear.lag : T) = a(i, :) * obs;
            end
        end
        
        function pred = predict(a, roc, rcc, rvp)
            [N, T] = size(roc);
            pred = zeros([N, T]);
            for i = 1 : N
                obs = PredLinear.observation(roc(i, :), rcc(i, :), rvp(i, :));
                pred(i, 1 + PredLinear.lag : T) = a(i, :) * obs;
            end
        end
        
        % d is the data set
        function predv = test(d)
            dv = TT.data_section(d, 1, 200);
            dt = TT.data_section(d, 201, 1003);
            [a, predt] = PredLinear.train(dt.roc, dt.rcc, dt.rvp);
            predv = PredLinear.predict(a, dv.roc, dv.rcc, dv.rvp);
            rocv = dv.roc;
            predv = predv(:, 1 + PredLinear.lag : end);
            rocv = rocv(:, 1 + PredLinear.lag : end);
            [err_m, err_var, err_dir] = TT.err_sta(rocv, predv);
            display('Error std');
            display(mean(sqrt(err_var)));
            display('Error direction');
            display(err_dir);
        end

    end
end