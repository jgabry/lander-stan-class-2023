// simple poisson regression
data {
  int<lower=1> N;
  vector<lower=0>[N] traps;
  array[N] int<lower=0> complaints;
}
parameters {
  real alpha;
  real beta;
}
model {
  complaints ~ poisson_log(alpha + beta * traps);  // poisson(exp(alpha + beta * traps));
  alpha ~ normal(2, 1);
  beta ~ normal(-0.25, 0.5);
}
generated quantities {
  array[N] int y_rep = poisson_log_rng(alpha + beta * traps);
}
