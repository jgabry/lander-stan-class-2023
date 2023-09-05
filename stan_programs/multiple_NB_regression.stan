// negative binomial multiple regression
// need to add the missing lines of code (see comments below)
data {
  int<lower=1> N;
  array[N] int<lower=0> complaints;
  vector<lower=0>[N] traps;
  vector<lower=0,upper=1>[N] live_in_super;
  vector[N] log_sq_foot;
}
parameters {
  real alpha;
  real beta;
  real beta_super;
  real<lower=0> inv_phi;
  // declare inv_phi, which is constrained to be positive
  // (easier to think about prior on 1/phi than phi in this case)
}
transformed parameters {
  vector[N] eta = alpha + beta * traps + beta_super * live_in_super + log_sq_foot;
  real<lower=0> phi = inv(inv_phi);  // inv(x) = 1/x
}
model {
  // change likelihood to neg_binomial_2_log
  complaints ~ neg_binomial_2_log(eta, phi);

  inv_phi ~ normal(0, 1);
  alpha ~ normal(2, 1);
  beta ~ normal(-0.25, 0.5);
  beta_super ~ normal(-0.5, 1);
}
generated quantities {
  array[N] int y_rep = neg_binomial_2_log_rng(eta, phi);
}
