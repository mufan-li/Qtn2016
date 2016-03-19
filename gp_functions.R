library(TTR)
library(rstan)
library(ggplot2)

parse_results <- function(df, name, fn_str = "mean") {
	strlen <- nchar(name)
	name_list <- names(df)[substr(names(df),1,strlen+1) == 
							paste0(name,"[")]
	parse_value <- paste0(name,"<- rep(0,length(name_list))")
  	eval(parse(text = parse_value))

	for (each_name in name_list) {
		parse_value <- paste0(each_name,"<-",
						fn_str,"(df[,\"",each_name,"\"])")
		eval(parse(text = parse_value))
	}
	parse_value <- paste0("return(",name,")")
	eval(parse(text = parse_value))
}

gp_pred <- function(y, y0) {
	n_ema = 2
	y1 = EMA(y0, n = n_ema)
	y1 = y1[n_ema:length(y1)]

	N1 = length(y1)
	x1 = 1:N1
	D = 1
	iter = 50
	chains = 1
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
	iter = 50
	chains = 1

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
	ret_df = data.frame(y_true = y[N1 + 1], y_pred = y2, sd = y2sd)
	return(ret_df)
}
