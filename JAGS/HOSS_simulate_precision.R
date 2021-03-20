# Plot summed activation in the network as a function of multivariate input

rm(list=ls())
setwd("~/Dropbox/Research/Consciousness/HOSS/JAGS/")
source("HOSS_evaluate_precision.R")

# Define state space
Aprior <- c(0.25, 0.25, 0.25, 0.25) # [high SNR, present; high SNR, absent; low SNR, present; low SNR, absent]
Wprior = 0.5

high_mu <- matrix(NA,3,2)
high_mu[1,] <- c(0.5,2)  # w2 (high SNR)
high_mu[2,] <- c(2,0.5)  # w1 (high SNR)
high_mu[3,] <- c(0.5,0.5) # noise (high SNR)

low_mu <- matrix(NA,3,2)
low_mu[1,] <- c(0.5,1) # w2 (low SNR)
low_mu[2,] <- c(1,0.5) # w1 (low SNR)
low_mu[3,] <- c(0.5,0.5) # noise (low SNR)

X = c(4, 4)
expOutput = HOSS_evaluate_precision(X, Aprior, Wprior, high_mu, low_mu)
expChain = as.matrix(expOutput)

# Extract posteriors
p_a <- matrix(NA,2,2)
p_a[1,1] <- sum(expChain[,"a"]==1)/(length(expChain[,"a"]))
p_a[1,2] <- sum(expChain[,"a"]==2)/(length(expChain[,"a"]))
p_a[2,1] <- sum(expChain[,"a"]==3)/(length(expChain[,"a"]))
p_a[2,2] <- sum(expChain[,"a"]==4)/(length(expChain[,"a"]))
marginal_presence <- colSums(p_a)
marginal_gain <- rowSums(p_a)

p_w = NULL
p_w[1] = sum(expChain[,"w"]==1)/(length(expChain[,"w"]))
p_w[2] = sum(expChain[,"w"]==2)/(length(expChain[,"w"]))
p_w[3] = sum(expChain[,"w"]==3)/(length(expChain[,"w"]))