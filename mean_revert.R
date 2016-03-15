# mean revert model

# # Toy Example
# N = 50
# S0 = 20
# mu = 20
# alpha = 0.5
# sigma = 1

# S = c(S0)
# for (i in 2:(2*N)) {
# 	S[i] = S[i-1] + alpha * (mu - S[i-1]) + rnorm(1,0,sigma)
# }
# y = S[N+1:N]
# # plot(ts(S))

in_sample_data <- read.csv('in_sample_data.csv')
S = in_sample_data$oil_spot / in_sample_data$oil_futures
L = length(S)
N = L/2

iter = 200
chains = 1

results = NULL

for (i in 1:20) {
	y = S[i:(N+i-1)]
	# init=list(list(mu=-10000,sigma=10), list(mu=20, sigma=0.1))
	mean_revert_fit <- stan(file="mean_revert.stan",
	                   data=c("N","y"),
	                   init=list(list(mu=1)),
	                   iter=iter,chains=chains)
	mr_fit_df <- as.data.frame(mean_revert_fit)
	each_row <- data.frame(chg = S[N+i] - S[N+i-1], 
							pred_chg = mean(mr_fit_df$y_pred) - S[N+i-1],
							se = sd(mr_fit_df$y_pred),
							drift = mean(mr_fit_df$drift),
							mu = mean(mr_fit_df$mu),
							alpha = mean(mr_fit_df$alpha))
	results = rbind(results, each_row)
}

print(results)

