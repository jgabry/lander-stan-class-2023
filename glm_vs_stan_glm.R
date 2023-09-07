# regular glm vs stan_glm
fit_glm <- glm(mpg ~ wt, data = mtcars)
predict(fit_glm, newdata = data.frame(wt = 3))

library(rstanarm)
fit_stan_glm <- stan_glm(mpg ~ wt, data = mtcars)

# we get a full predictive distribution
hist(posterior_predict(fit_stan_glm, newdata = data.frame(wt = 3)))

# compare to frequentist prediction, which is just a single number
# (full histogram vs just the red line)
abline(v = predict(fit_glm, newdata = data.frame(wt = 3)), col = "red")

# what's the probability the mpg is > 22?
# how would you even answer this coherently given the frequentist model?
# with the bayesian model just check the proportion of predictions greater than 22
predicted_mpg <- posterior_predict(fit_stan_glm, newdata = data.frame(wt = 3))
mean(predicted_mpg > 22)
