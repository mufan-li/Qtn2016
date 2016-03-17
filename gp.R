library(rstan)
library(ggplot2)
library(TTR)
source("gp_functions.R")
#################
# GP Regression
#################

# set.seed(6)
# init_n = 80
# bull1 = rnorm( init_n, 0, 1 )
# # bear  = rnorm( init_n, -0.01, 0.30 )
# bear  = rnorm( init_n, 0, 2 )
# bull2 = rnorm( init_n, 0, 1 )
# z1 = c(rep(1,init_n),rep(2,init_n),rep(1,init_n))
# y0 = cumsum(c( bull1, bear,  bull2))

in_data = read.csv("in_sample_data.csv")

pred_df = NULL
N_in = 100
for (i in 200:220) {
	y = in_data$oil_spot[0:120 + i]
	y0 = y[1:N_in]
	# each_pred = gp_pred(y, y0)

	n_ema = 2
	y1 = EMA(y0, n = n_ema)
	y1 = y1[n_ema:length(y1)]

	N1 = length(y1)
	x1 = 1:N1
	D = 1
	iter = 200
	chains = 2
	# init=list(list(mu=-10000,sigma=10), list(mu=20, sigma=0.1))
	gp_fit <- stan(file="gp_fit.stan",
	                   data=c("N1","x1","y1"),
	                   iter=iter,chains=chains)
	# print(gp_fit)
	gp_fit_df <- as.data.frame(gp_fit)

	eta_sq <- mean(gp_fit_df$eta_sq)
	sigma_sq <- mean(gp_fit_df$sigma_sq)
	inv_rho_sq <- mean(gp_fit_df$inv_rho_sq)

	#################
	# GP Prediction
	#################

	N2 = 1
	x2 = array(N1+(1:N2), dim = length(N1+(1:N2)))
	iter = 200
	chains = 2

	gp_pred <- stan(file="gp_pred.stan",
	                   data=c("N1","x1","y1","N2","x2",
	                   		"eta_sq","sigma_sq","inv_rho_sq"),
	                   iter=iter,chains=chains)
	# print(gp_pred)
	gp_pred_df <- as.data.frame(gp_pred)

	#################
	# Plot Results
	#################

	y2 = parse_results(gp_pred_df, "y2", fn_str = "mean")
	y2sd = parse_results(gp_pred_df, "y2", fn_str = "sd")

	# pred_plot = ggplot(NULL) +
	# 	geom_ribbon(aes(x=x2,ymin=y2-y2sd*1.96,ymax=y2+y2sd*1.96), 
	# 		fill = "grey70") +
	# 	geom_point(aes(x=x2,y=y2), color = "red") +
	# 	geom_point(aes(x=(-(N2*5):N2+N1),y=y[-(N2*5):N2+N1]))
	# print(pred_plot)

	# print(y[N1+1])
	# print(y2)
	# print(y2sd)
	each_pred = data.frame(x = i+N_in+1, y_true = y[N1 + 1], 
							y_pred = y2, sd = y2sd)

	pred_df = rbind(pred_df, each_pred)
}

pred_plot2 = ggplot(pred_df,aes(x=x)) + 
	geom_ribbon(aes(ymin=y_pred-sd*1.96,ymax=y_pred+sd*1.96), 
			fill = "grey70") +
	geom_point(aes(y=y_pred), color = "red") +
	geom_point(aes(y=y_true))
print(pred_plot2)












