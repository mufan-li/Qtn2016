library(gdata)

input_data = read.csv("in_sample_data_headers2.csv")

y = input_data[-1,"ROC_0"]
col_names = c()
for (j in 0:99) {
	col_names = c(col_names,
				paste0(c("ROC_","RCC_","RVP_","ROO_","RCO_"),j))
}

x = input_data[-nrow(input_data),col_names]
x$y = y
lm_mod = lm(y~., x[1:500,])

# max(as.numeric(lm_mod$residuals))
coefs = as.matrix(lm_mod$coefficients)
coefs[is.na(coefs)] = 0
x2 = as.matrix(x[501:1000,-ncol(x)])

concat_data <- cbindX(1,x2)
y_pred = 