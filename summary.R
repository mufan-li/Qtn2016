
source("MSwM_functions.R")

in_data = read.csv("in_sample_data_headers2.csv")
in_data2 = in_data[,c("Date",names(in_data)[grepl("ROC_",names(in_data))])]

pred_data = read.csv("lstm_pred.csv")

names(pred_data)[grepl("ROC_",names(pred_data))] = 
	gsub("ROC","ROC_MR",names(pred_data)[grepl("ROC_",names(pred_data))])

pred_data = pred_data[pred_data$Stock_0_pred != 99,]
merge_data = merge(pred_data, in_data2, 
				by.x = names(pred_data)[1], by.y = "Date")

# merge_data = merge_data[1:100,]

# print(with(merge_data, sqrt(mean((Stock_0_pred - ROC_0)^2))))
# print(with(merge_data, mean(Stock_0_pred*ROC_0<0) ))

n_stock = sum(grepl("Stock_",names(pred_data)))/2
RMSE = c()
ER = c()

n_ema = 2

for (i in 0:(n_stock-1)) {
	y_pred = merge_data[,paste0("Stock_",i,"_pred")]
	y_true = merge_data[,paste0("ROC_",i)]

	RMSE[i+1] = sqrt(mean((y_true-y_pred)^2))
	ER[i+1] = sum(y_true * y_pred < 0)/sum(y_true != 0)
	cat(sum(y_true * y_pred < 0),sum(y_true != 0), "\n")
}
cat("RMSE: ",mean(RMSE),"\n")
cat("ER: ",mean(ER),"\n")