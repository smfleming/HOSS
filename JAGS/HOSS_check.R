# Plot summed activation in the network as a function of multivariate input

rm(list=ls())
setwd("~/Dropbox/Research/Consciousness/HOSS theory/JAGS scripts/")
source("HOSS_evaluate.R")

Aprior = 0.2
Wprior = 0.7
X = c(0.4, 0.8)
expOutput = HOSS_evaluate(X, Aprior, Wprior)
expChain = as.matrix(expOutput)
p_a = mean(expChain[,"a"])
p_w = NULL
p_w[1] = sum(expChain[,"w"]==1)/(length(expChain[,"w"]))
p_w[2] = sum(expChain[,"w"]==2)/(length(expChain[,"w"]))
p_w[3] = sum(expChain[,"w"]==3)/(length(expChain[,"w"]))