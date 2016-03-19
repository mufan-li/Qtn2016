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
input_data = read.csv("in_sample_data.csv")
pred_df = NULL
N_in = 100
n_diff= 1
n_ema = 2
y_name = "oil_spot"

for (i in 1200:1220) {
	cat("Iteration:",i,"\n")
	N_begin = i
	N_end = i + N_in

	each_train_data = create_df(input_data,N_begin,N_in,
						y_name=y_name,n_diff=n_diff,n_ema=n_ema)
	data_mod.mswm = msmFit_df(each_train_data,k=2,p=0)
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

	state_prob = data_mod.mswm@Fit@filtProb
	trans_prob = data_mod.mswm@transMat
	state_prob_n = trans_prob %*% state_prob[nrow(state_prob),]

	# N_begin = round(nrow(input_data)/2,0)
	# N_end = nrow(input_data)
	each_pred_data = create_df(input_data,N_begin,N_in+1,
					y_name=y_name,n_diff=n_diff,n_ema=n_ema)[N_in+1,]
	each_pred_vec = as.numeric(each_pred_data)
	each_pred_vec[1] = 1

	prev_pred_data = create_df(input_data,N_begin,N_in+1,
					y_name=y_name,n_diff=n_diff,n_ema=n_ema)[N_in,]

	y_regimes = c(sum(data_mod.mswm@Coef[1,] * each_pred_vec),
		sum(data_mod.mswm@Coef[2,] * each_pred_vec) )

	# row of y_true
	nth_row = as.integer(rownames(each_pred_data))+1
	if (n_diff>0) {
		y_true = diff(input_data[0:n_diff + nth_row,y_name],n_diff)
	} else {
		y_true = input_data[nth_row,y_name]
	}
	
	y_pred = rm_ema(y_regimes %*% state_prob_n, 
					prev_pred_data$y, n_ema)

	each_pred = data.frame(x = nth_row,
				y_true = y_true, 
				y_pred = y_pred,
				sd = data_mod.mswm@std %*% state_prob_n)
	pred_df = rbind(pred_df, each_pred)
}

pred_plot2 = ggplot(pred_df,aes(x=x)) + 
	geom_ribbon(aes(ymin=y_pred-sd*1.96,ymax=y_pred+sd*1.96), 
			fill = "grey70", alpha = 0.5) +
	geom_point(aes(y=y_pred), color = "red") +
	geom_point(aes(y=y_true))
print(pred_plot2)








