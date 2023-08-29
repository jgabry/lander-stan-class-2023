# Lander Analytics Bayes/Stan Class 2023

### Install needed software

```r
# install R packages
install.packages(c("dplyr", "lubridate", "ggplot2", "bayesplot", "posterior", "remotes"))
remotes::install_github("stan-dev/cmdstanr")

# install cmdstan
# please reach out if you run into errors
cmdstanr::install_cmdstan(cores = 2)

# check if cmdstan installation works properly
# please reach out if you run into errors
cmdstanr::cmdstanr_example()

# optionally install rstan 
# we won't _need_ this but it has some extra features we can use if you have it installed
# if it fails to install don't worry about it
install.packages("rstan")
```

### Interactive MCMC demo

We'll use this on day 2: 

https://chi-feng.github.io/mcmc-demo/app.html


