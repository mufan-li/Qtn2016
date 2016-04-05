data {
  int<lower=1> K; // # states
  int<lower=1> N; // length
  int<lower=1> M; // # prediction samples
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
  
  # for (n in 1:N)
  #  y[n] ~ normal(mu[z[n]],sigma[z[n]]);

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

generated quantities {
  int<lower=1,upper=K> z[N];
  real log_p_z;

  int<lower=1,upper=K> z_new;
  real y_new;
  {
    int back_ptr[N,K];
    real best_logp[N,K];
    real best_total_logp;
    
    for (k in 1:K)
      best_logp[1,k] <- normal_log(y[1],mu[k],sigma[k]);

    for (t in 2:N) {
      for (k in 1:K) {
        best_logp[t,k] <- negative_infinity();
        for (j in 1:K) {
          real logp;
          logp <- best_logp[t-1,j]
                  + log(P[j,k]) + normal_log(y[t],mu[k],sigma[k]);
          if (logp > best_logp[t,k]) {
            back_ptr[t,k] <- j;
            best_logp[t,k] <- logp;
          }
        } 
      }
    }

    log_p_z <- max(best_logp[N]);
    
    for (k in 1:K)
      if (best_logp[N,k] == log_p_z)
        z[N] <- k;
    
    for (t in 1:(N-1))
      z[N - t] <- back_ptr[N - t + 1, z[N - t + 1]];
  }

  z_new <- categorical_rng(P[z[N]]);
  y_new <- normal_rng(mu[z_new], sigma[z_new]);
}


