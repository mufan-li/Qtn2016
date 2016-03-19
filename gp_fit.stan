data {
  int<lower=1> N1;
  vector[N1] x1;
  vector[N1] y1;
}
transformed data {
  vector[N1] mu;
  for (i in 1:N1) mu[i] <- 0;
}
parameters {
  real<lower=0> eta_sq;
  real<lower=0> inv_rho_sq;
  real<lower=0> sigma_sq;
}
transformed parameters {
  real<lower=0> rho_sq;
  rho_sq <- inv(inv_rho_sq);
} 
model {
  matrix[N1,N1] Sigma;
  // off-diagonal elements
  for (i in 1:(N1-1)) {
    for (j in (i+1):N1) {
      Sigma[i,j] <- eta_sq * exp(-rho_sq * pow(fabs(x1[i] - x1[j]),2));
      Sigma[j,i] <- Sigma[i,j];
    } 
  }
  // diagonal elements
  for (k in 1:N1)
    Sigma[k,k] <- eta_sq + sigma_sq;  // + jitter
  eta_sq ~ cauchy(0,5);
  inv_rho_sq ~ cauchy(0,5);
  sigma_sq ~ cauchy(0,5);
  y1 ~ multi_normal(mu,Sigma);
}