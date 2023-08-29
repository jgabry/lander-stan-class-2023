// Varying intercepts, varying slopes, latent time trend
// Non-centered parameterization
// + forecasts for future months in generated quantities
data {
  int<lower=1> N;
  array[N] int<lower=0> complaints;
  vector<lower=0>[N] traps;

  // 'exposure'
  vector[N] log_sq_foot;

  // building-level data
  int<lower=1> K;
  int<lower=1> J;
  array[N] int<lower=1, upper=J> building_idx;
  matrix[J,K] building_data;

  // month
  int<lower=1> M;
  array[N] int<lower=1,upper=M> mo_idx;

  int<lower=1> M_forward;
  vector[J] log_sq_foot_pred;  // included in standata_hier_long list (it's same as log_sq_foot but just 1 unique value per building)
}
transformed data {
  // We could pass this in as data from R but just wanted to demonstrate
  // the transformed data block
  // We'll make predictions for traps in {0,1,...,20}, but could go further
  int N_hypo_traps = 21;
  array[N_hypo_traps] int hypo_traps =
    linspaced_int_array(N_hypo_traps, 0, N_hypo_traps - 1);
}
parameters {
  real<lower=0> inv_phi;   // 1/phi (easier to think about prior for 1/phi instead of phi)

  vector[J] mu_raw;        // N(0,1) params for non-centered param of building-specific intercepts
  real<lower=0> sigma_mu;  // sd of buildings-specific intercepts
  real alpha;              // 'global' intercept
  vector[K] zeta;          // coefficients on building-level predictors in model for mu

  vector[J] kappa_raw;       // N(0,1) params for non-centered param of building-specific slopes
  real<lower=0> sigma_kappa; // sd of buildings-specific slopes
  real beta;                 // 'global' slope on traps variable
  vector[K] gamma;           // coefficients on building-level predictors in model for kappa


  vector[M] mo_raw;               // N(0,1) params for non-centered param of AR(1) process
  real<lower=0> sigma_mo;         // sd of month-specific parameters
  real<lower=0,upper=1> rho_raw;  // used to construct AR(1) coefficient
}
transformed parameters {
  real phi = inv(inv_phi);

  // non-centered parameterization of building-specific intercepts and slopes
  vector[J] mu = alpha + building_data * zeta + sigma_mu * mu_raw;
  vector[J] kappa = beta + building_data * gamma + sigma_kappa * kappa_raw;

  // non-centered parameterization of AR(1) process priors
  real rho = 2 * rho_raw - 1;        // ensures that rho is between -1 and 1
  vector[M] mo = sigma_mo * mo_raw;  // all of them share this term
  mo[1] /= sqrt(1 - rho^2);          // mo[1] = mo[1] / sqrt(1 - rho^2)
  for (m in 2:M) {
    mo[m] += rho * mo[m-1];          // mo[m] = mo[m] + rho * mo[m-1];
  }
}
model {
  inv_phi ~ normal(0, 1);

  kappa_raw ~ normal(0,1) ;
  sigma_kappa ~ normal(0, 1);
  beta ~ normal(-0.25, 0.5);
  gamma ~ normal(0, 1);

  mu_raw ~ normal(0,1) ;
  sigma_mu ~ normal(0, 1);
  alpha ~ normal(2, 1);
  zeta ~ normal(0, 1);

  mo_raw ~ normal(0,1);
  sigma_mo ~ normal(0, 1);
  rho_raw ~ beta(10, 5);

  vector[N] eta = mu[building_idx] + kappa[building_idx] .* traps + mo[mo_idx] + log_sq_foot;
  complaints ~ neg_binomial_2_log(eta, phi);
}
generated quantities {
  // we'll predict number of complaints for each building
  // at each hypothetical number of traps for M_forward months in the future
  array[J, N_hypo_traps] int y_pred;
  vector[M_forward] mo_forward;

  // first future month depends on last observed month (the Mth month)
  // the remaining future months depends only on previous future months
  mo_forward[1] = normal_rng(rho * mo[M], sigma_mo);
  for (m in 2:M_forward) {
    mo_forward[m] = normal_rng(rho * mo_forward[m-1], sigma_mo);
  }

  for (j in 1:J) {  // loop over buildings
    for (i in 1:N_hypo_traps) { // loop over traps
      array[M_forward] int y_pred_by_month;
      for (m in 1:M_forward) {
        real eta_ijm = mu[j] + kappa[j] * hypo_traps[i] + mo_forward[m] + log_sq_foot_pred[j];
        y_pred_by_month[m] = neg_binomial_2_log_rng(eta_ijm, phi);
      }
      // total number of complaints in building j for number of traps i over M_forward months
      y_pred[j, i] = sum(y_pred_by_month);
    }
  }
}
