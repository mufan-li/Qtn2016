data {
  int<lower=1> N; // length
  vector[N] y; // time series
}

parameters {
  real<lower=0> alpha;
  real drift;
  real<lower=0.5,upper=1.5> mu;
  real<lower=0> sigma;
}

// transformed parameters {
//   matrix[N,N] Y;
//   Y <- u * v';
// }

model {
  for (i in 2:N) {
    y[i] ~ normal(y[i-1] + alpha * (mu - y[i-1]) + drift ,sigma);
  }
}

generated quantities {
  real y_pred;
  y_pred <- normal_rng(y[N] + alpha * (mu - y[N]) ,sigma);
}