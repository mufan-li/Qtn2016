data {
  int<lower=1> K; // # states
  int<lower=1> N; // length
  vector[N] y; // time series
  // int z[N]; // hidden series

  vector<lower=0>[K] alpha; // transit prior
}
parameters {
  simplex[K] P[K]; // transition prob
  vector[K] mu;
  vector<lower=0>[K] sigma;
}
// transformed parameters {
//   matrix[N,N] Y;
//   Y <- u * v';
// }
model {
  real acc[K];
  real gamma[N,K];

  for (k in 1:K)
    P[k] ~ dirichlet(alpha);

  //for (n in 2:N)
  //  z[n] ~ categorical(P[z[n-1]]);
  
  //for (n in 1:N)
  //  y[n] ~ normal(mu[z[n]],sigma[z[n]]);

  for (k in 1:K)
    gamma[1,k] <- normal_log(y[1],mu[k],sigma[k]);

  for (t in 2:N) {
    for (k in 1:K) {
      for (j in 1:K)
        acc[j] <- gamma[t-1,j] + log(P[j,k]) + 
                  normal_log(y[t],mu[k],sigma[k]);
      gamma[t,k] <- log_sum_exp(acc);
    }
  }

  increment_log_prob(log_sum_exp(gamma[N]));
}


