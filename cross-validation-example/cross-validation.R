library(loo)

pois_cv <- cmdstan_model("cross-validation-example/multiple_poisson_regression_cv.stan")
nb_cv <- cmdstan_model("cross-validation-example/multiple_NB_regression_cv.stan")

fit_pois_cv <- pois_cv$sample(data = standata_simple)
fit_nb_cv <- nb_cv$sample(data = standata_simple)

# model with highest ELPD (~ expected predictive performance) is negative binomial
loo_compare(fit_pois_cv$loo(), fit_nb_cv$loo())
