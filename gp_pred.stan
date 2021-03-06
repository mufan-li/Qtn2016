data {
  int<lower=1> N1;
  vector[N1] x1;
  vector[N1] y1;
  int<lower=1> N2;
  vector[N2] x2;

  real<lower=0> eta_sq;
  real<lower=0> inv_rho_sq;
  real<lower=0> sigma_sq;
}
transformed data {
  int<lower=1> N;
  vector[N1+N2] x;
  vector[N1+N2] mu;
  cov_matrix[N1+N2] Sigma;
  
  real<lower=0> rho_sq;
  rho_sq <- inv(inv_rho_sq);

  N <- N1 + N2;
  for (n in 1:N1) x[n] <- x1[n];
  for (n in 1:N2) x[N1 + n] <- x2[n];
  for (i in 1:N) mu[i] <- 0;
  for (i in 1:N)
    for (j in 1:N)
      Sigma[i,j] <- eta_sq * exp(-rho_sq * pow(fabs(x[i] - x[j]),2))
                    + if_else(i==j, sigma_sq, 0.0);
}
parameters {
  vector[N2] y2;
}
model {
  vector[N] y;
  for (n in 1:N1) y[n] <- y1[n];
  for (n in 1:N2) y[N1 + n] <- y2[n];
  y ~ multi_normal(mu,Sigma);
}