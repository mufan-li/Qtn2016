library(rstan)
library(ggplot2)
library(TTR)
source("gp_functions.R")
source("MSwM_functions.R")
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

in_data = read.csv("in_sample_data_headers2.csv")
out_df = NULL
n_stock_begin = 0
n_stock_end = 99
N_in = 10

for (j in n_stock_begin:n_stock_end) {

	pred_df = NULL

	for (i in 1:(nrow(in_data)-N_in)) {
		y = in_data[0:N_in + i,paste0("ROC_",j)]
		y = cumprod(y+1)
		y0 = y[1:N_in]
		# each_pred = gp_pred(y, y0)

		n_ema = 2
		y1 = EMA(y0, n = n_ema)
		y1 = y1[n_ema:length(y1)]

		N1 = length(y1)
		x1 = 1:N1
		D = 1
		iter = 100
		chains = 1
		# init=list(list(mu=-10000,sigma=10), list(mu=20, sigma=0.1))
		
		temp_fit = NULL
		while (is.null(temp_fit)) {
			temp_fit = tryCatch({
			    stan(file="gp_fit.stan",
		                   data=c("N1","x1","y1"),
		                   iter=iter,chains=chains)
			}, error = function(e) {
			    NULL
			})
		}

		gp_fit <- temp_fit

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

		iter = 100
		chains = 1
		
		temp_pred = NULL
		while (is.null(temp_pred)) {
			temp_pred = tryCatch({
			    stan(file="gp_pred.stan",
		                   data=c("N1","x1","y1","N2","x2",
		                   		"eta_sq","sigma_sq","inv_rho_sq"),
		                   iter=iter,chains=chains)
			}, error = function(e) {
			    NULL
			})
		}

		gp_pred <- temp_pred

		# print(gp_pred)
		gp_pred_df <- as.data.frame(gp_pred)

		#################
		# Plot Results
		#################

		y2 = parse_results(gp_pred_df, "y2", fn_str = "mean")
		y2 = rm_ema(y2, y1[N1], n_ema)

		y2sd = parse_results(gp_pred_df, "y2", fn_str = "sd")
		y2sd = rm_ema(y2sd, 0, n_ema)
		# pred_plot = ggplot(NULL) +
		# 	geom_ribbon(aes(x=x2,ymin=y2-y2sd*1.96,ymax=y2+y2sd*1.96), 
		# 		fill = "grey70") +
		# 	geom_point(aes(x=x2,y=y2), color = "red") +
		# 	geom_point(aes(x=(-(N2*5):N2+N1),y=y[-(N2*5):N2+N1]))
		# print(pred_plot)

		# print(y[N1+1])
		# print(y2)
		# print(y2sd)

		# remove cumprod
		each_pred = data.frame(x = i+N_in+1, y_true = y[N1+1]/y[N1]-1, 
								y_pred = y2/y[N1]-1, sd = y2sd/y[N1])

		pred_df = rbind(pred_df, each_pred)
	}

	# pred_plot2 = ggplot(pred_df,aes(x=x)) + 
	# 	geom_ribbon(aes(ymin=y_pred-sd*1.96,ymax=y_pred+sd*1.96), 
	# 			fill = "grey70", alpha=0.5) +
	# 	geom_point(aes(y=y_pred), color = "red") +
	# 	geom_point(aes(y=y_true))
	# print(pred_plot2)

	cat("RMSE:", with( pred_df, sqrt(mean((y_true-y_pred)^2)) ) ,"\n")
	# cat("ER:", with(pred_df, mean(
	# 	(diff(y_true) * (y_pred[-1]-y_true[-length(y_true)]) )<0
	# )), "\n")
	cat("ER:", with(pred_df, mean( (y_true * y_pred)<0) ), "\n")

	temp_df = pred_df[,3:4]
	names(temp_df) = paste0("Stock_",j,c("_pred","_sigma"))

	temp_empty_df = data.frame(x = rep(0,N_in), y = rep(0.1,N_in))
	names(temp_empty_df) = paste0("Stock_",j,c("_pred","_sigma"))

	temp_out_df = rbind(temp_empty_df, temp_df)

	if (is.null(out_df)) {
		temp_out_df$Date = in_data$Date
		out_df = temp_out_df[,c(3,1,2)]
	} else {
		out_df = cbind(out_df,temp_out_df)
	}

}

write.csv(out_df,"gp_pred_stan.csv")















