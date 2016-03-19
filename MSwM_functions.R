# helper functions
library(TTR)

create_df <- function(input_data, N_begin, N_in, 
						y_name="oil_spot",
						x_names=c("oil_futures", "c0", "c1"),
						n_diff=1, n_ema=1) {
	# row_inds start at 1
	row_inds = 1:(N_in+n_diff+n_ema-1)+N_begin-1

	temp_data = cbind(
			data.frame(y = input_data[row_inds+1,y_name]),
			input_data[row_inds,x_names]
		)
	
	for (each_name in names(temp_data)) {
		temp_vec = temp_data[,each_name]
		
		if (n_diff > 0) 
			temp_vec = diff(temp_vec,n_diff)

		temp_vec = EMA(temp_vec,n_ema)
		
		temp_data[n_diff+1:(N_in+n_ema-1),each_name] = temp_vec
	}
	
	out_data = temp_data[n_diff+n_ema-1+1:N_in,]
	return(out_data)
}

msmFit_df <- function(df, k=2, p=1, parallel=F) {
	# data_mod = lm(y~x0+x1+x2+z0)
	data_mod <- lm(y ~ ., data = df)
	data_mod.mswm = 0

	i = 0
	while (typeof(data_mod.mswm) == typeof(0)) {
		i = i+1
		# cat(i,"\n")
		data_mod.mswm = tryCatch({
		    msmFit(data_mod, k=k, p=p,
		    	sw=rep(T,i),
		    	control=list(parallel=parallel))
		}, error = function(e) {
		    0
		})
	}

	return(data_mod.mswm)
}

rm_ema <- function(pred_ema, prev_ema, n_ema) {
	if (n_ema == 1) {
		return(pred_ema)
	}
	M = 2 / (n_ema + 1)
	pred_point = (pred_ema - prev_ema / (1-M)) / M
	return(pred_point)
}










