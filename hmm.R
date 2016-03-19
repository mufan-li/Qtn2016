library(rstan)

# Toy Example
bull1 = rnorm( 100, 0.10, 0.15 )
bear  = rnorm( 100, -0.01, 0.30 )
bull2 = rnorm( 100, 0.10, 0.15 )
z = c(rep(1,100),rep(2,100),rep(1,100))
y = c( bull1, bear,  bull2)

K = 2 # number of states
alpha = rep(0.3, K)
N = 300

iter = 100
chains = 1
M = 50
# init=list(list(mu=-10000,sigma=10), list(mu=20, sigma=0.1))
hmm_fit <- stan(file="hmm.stan",
                   data=c("K","N","M","y","alpha"),
                   iter=iter,chains=chains)
# print(hmm_fit)
hmm_fit_df <- as.data.frame(hmm_fit)