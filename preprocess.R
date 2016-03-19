
in_data = read.csv("in_sample_data.txt",header=F)

row = names(in_data)
row[1] = "Date"
for (i in 0:99) {
	row[1 + i*6 + 1] = paste0("SO_",i)
	row[1 + i*6 + 2] = paste0("SH_",i)
	row[1 + i*6 + 3] = paste0("SL_",i)
	row[1 + i*6 + 4] = paste0("SC_",i)
	row[1 + i*6 + 5] = paste0("TVL_",i)
	row[1 + i*6 + 6] = paste0("IND_",i)
}
names(in_data) = row
write.csv(in_data,"in_sample_data_headers.csv")

for (i in 0:99) {
	each_col = in_data[,paste0("SC_",i)] / in_data[,paste0("SO_",i)]-1
	in_data[,paste0("ROC_",i)] = each_col

	each_col = exp(diff(log(in_data[,paste0("SC_",i)]))) - 1
	in_data[,paste0("RCC_",i)] = c(0,each_col)

	# in_data[,paste0("RCCC_",i)] = cumprod(c(1,1+each_col))

	each_col = 1/(4 * log(2)) *
				(log(in_data[,paste0("SH_",i)]) -
				log(in_data[,paste0("SL_",i)]) )^2
	in_data[,paste0("RVP_",i)] = each_col
}
write.csv(in_data,"in_sample_data_headers2.csv")

