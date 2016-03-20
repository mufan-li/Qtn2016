
source("MSwM_functions.R")

in_data = read.csv("in_sample_data_headers2.csv")
in_data2 = in_data[,c("Date",names(in_data)[grepl("ROC_",names(in_data))])]

pred_data = read.csv("gp_pred.csv")
pred_data = pred_data[pred_data$Stock_0_pred != 99,]
merge_data = merge(pred_data, 
					in_data2, by.x = "date", by.y = "Date")

# print(with(merge_data, sqrt(mean((Stock_0_pred - ROC_0)^2))))
# print(with(merge_data, mean(Stock_0_pred*ROC_0<0) ))
n_stock = sum(grepl("Stock_",names(pred_data)))/2-1
RMSE = c()
ER = c()

n_ema = 2

for (i in 0:n_stock) {
	y_true = merge_data[,paste0("Stock_",i,"_pred")]
	y_pred = merge_data[,paste0("ROC_",i)]

	RMSE[i+1] = sqrt(mean((y_true-y_pred)^2))
	ER[i+1] = mean(y_true * y_pred < 0)
}
cat("RMSE: ",mean(RMSE),"\n")
cat("ER: ",mean(ER),"\n")