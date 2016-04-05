library(MSwM)
library(ggplot2)
source('MSwM_functions.R')

# # generate data
# bull1 = rnorm( 100, 0.10, 0.15 )
# bear  = rnorm( 100, -0.01, 0.30 )
# bull2 = rnorm( 100, 0.10, 0.15 )
# true.states = c(rep(1,100),rep(2,100),rep(1,100))
# returns = c( bull1, bear,  bull2 )

# mod = lm(returns ~ 1)
# mod.mswm = msmFit(mod,k=2,p=0,sw=c(T,T),control=list(parallel=F))
# summary(mod.mswm)

# plotProb(mod.mswm,which=1)
# plotProb(mod.mswm,which=2)

# real data
# setwd("~/GitHub/Qtn2016/")
input_data = read.csv("in_sample_data_headers2.csv")
pred_df = NULL
N_in = 500
n_diff= 0
n_ema = 1
j = 15
N_pred = 500
dim_h = 1
y_name = paste0("ROC_",j)
x_names = paste0(c("ROC_","RCC_","RVP_","ROO_","RCO_"),j)


for (i in 1:N_pred) {
	# cat("Iteration:",i,"\n")
	N_begin = i
	N_end = i + N_in

	if (i==1) {
		each_train_data = create_df(input_data,N_begin,N_in,
							y_name=y_name,x_names=x_names,
							n_diff=n_diff,n_ema=n_ema)
		data_mod.mswm = msmFit_df(each_train_data,k=dim_h,p=0)

		state_prob = data_mod.mswm@Fit@filtProb
		trans_prob = data_mod.mswm@transMat
		state_prob_cur = state_prob[nrow(state_prob),]
		state_prob_next = trans_prob %*% state_prob_cur
	}

	prev_pred_data = create_df(input_data,N_begin,N_in+1,
					y_name=y_name,x_names=x_names,
					n_diff=n_diff,n_ema=n_ema)[N_in,]
	prev_pred_vec = as.numeric(prev_pred_data)
	prev_pred_vec[1] = 1

	each_pred_data = create_df(input_data,N_begin,N_in+1,
					y_name=y_name,x_names=x_names,
					n_diff=n_diff,n_ema=n_ema)[N_in+1,]
	each_pred_vec = as.numeric(each_pred_data)
	each_pred_vec[1] = 1

	if (i>1) {
		state_prob_prev = state_prob_cur
		# E-step, find state_prob_cur
		cur_sd = data_mod.mswm@std
		cur_mean = c()
		cur_lh = c()
		for (nh in 1:dim_h) {
			cur_mean = c(cur_mean,
						sum(data_mod.mswm@Coef[nh,] * prev_pred_vec))
			cur_lh = c(cur_lh,
						dnorm(prev_pred_data$y, 
						mean = cur_mean[nh], sd = cur_sd[nh]) )
		}
		
		unnorm_posterior = trans_prob %*% state_prob_prev * cur_lh
		state_prob_cur = as.numeric(unnorm_posterior / 
									sum(unnorm_posterior))
		
		# inference step in state_prob_next
		state_prob_next = trans_prob %*% state_prob_cur
	}
	# summary(data_mod.mswm)
	# plotProb(data_mod.mswm,which=1)

	# Prediction

	# Fields of data_mod.mswm object
	# data_mod.mswm@Fit@filtProb
	# data_mod.mswm@Fit@smoProb
	# data_mod.mswm@Coef
	# data_mod.mswm@std
	# data_mod.mswm@seCoef
	# data_mod.mswm@transMat

	# N_begin = round(nrow(input_data)/2,0)
	# N_end = nrow(input_data)

	y_regimes = c()
	for (nh in 1:dim_h) {
		y_regimes = c(y_regimes, 
					sum(data_mod.mswm@Coef[nh,] * each_pred_vec))
	}

	# row of y_true
	nth_row = as.integer(rownames(each_pred_data))+1
	if (n_diff>0) {
		y_true = diff(input_data[0:n_diff + nth_row,y_name],n_diff)
	} else {
		y_true = input_data[nth_row,y_name]
	}
	
	y_pred = rm_ema(y_regimes %*% state_prob_next, 
					prev_pred_data$y, n_ema)
	sd_pred = rm_ema(data_mod.mswm@std %*% state_prob_next,
					0, n_ema)
	each_pred = data.frame(x = nth_row,
				y_true = y_true, 
				y_pred = y_pred,
				sd = sd_pred)
	pred_df = rbind(pred_df, each_pred)
}

pred_plot2 = ggplot(pred_df,aes(x=x)) + 
	geom_ribbon(aes(ymin=y_pred-sd*1.96,ymax=y_pred+sd*1.96), 
			fill = "grey70", alpha = 0.5) +
	geom_point(aes(y=y_pred), color = "red") +
	geom_point(aes(y=y_true))
# print(pred_plot2)

cat("RMSE: ", with(pred_df, sqrt(mean((y_true - y_pred)^2))), "\n")
cat("ER: ", with(pred_df, mean((y_true * y_pred)<0) /
						mean((y_true * y_pred)!=0)), "\n")








