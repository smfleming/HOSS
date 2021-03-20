# Plot summed activation in the network as a function of multivariate input

rm(list=ls())
setwd("~/Dropbox/Research/Consciousness/HOSS/JAGS/")
source("Gaussian_jags.R")

### generate data ###
mu <- 0
tau2 <- 0.5

n <- 20
X <- rnorm(n, mu, sqrt(tau2))

expOutput = Gaussian_jags(X)
expChain = as.matrix(expOutput)
mean_mu = mean(expChain[,"mu"])
mean_invtau2 = mean(expChain[,"invTau2"])

