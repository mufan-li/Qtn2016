function sr = sharpe(w, roc)
    rp = sum(w .* roc, 1) ./ (sum(abs(w), 1) + 1e-7);
    sr = mean(rp) / (std(rp) + 1e-7);
end
