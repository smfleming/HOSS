HOSS_evaluate_precision <- function(X, Aprior, Wprior, high_mu, low_mu)
{
  require(rjags)
  
  modelstring="
model {
  
  # Two dimensional prior over both presence and signal-to-noise ratio
  a ~ dcat(Aprior)

  w1 ~ dcat(c(1-Wprior, Wprior, 0)) # world state (only relevant if aware)
  w0 ~ dcat(c(0, 0, 1))

  w <- ifelse(a == 1 || a == 3, w1, w0) # condition w on A

  mu <- ifelse(a < 3, high_mu, low_mu)

  lambda <- 1
  T[1,1] <- lambda
  T[1,2] <- 0
  T[2,1] <- 0
  T[2,2] <- lambda
  
  mu1 <- mu[w,]
  X ~ dmnorm(mu1, T)
}
"

# Run chain for experimental data
parameters = c("a", "w")  # The parameter(s) to be monitored.
adaptSteps = 1000              # Number of steps to "tune" the samplers.
burnInSteps = 1000            # Number of steps to "burn-in" the samplers.
nChains = 3                   # Number of chains to run.
numSavedSteps=5000           # Total number of steps in chains to save.
thinSteps=1                   # Number of steps to "thin" (1=keep every step).
nIter = ceiling( ( numSavedSteps * thinSteps ) / nChains ) # Steps per chain.

data <- list(X=X, Aprior=Aprior, Wprior=Wprior, high_mu=high_mu, low_mu=low_mu)

model = jags.model( textConnection(modelstring), data=data, n.chains=nChains , n.adapt=adaptSteps )
#   Burn-in:
update(model , n.iter=burnInSteps )
expOutput = coda.samples(model , variable.names=parameters ,
                         n.iter=nIter , thin=thinSteps )
return(expOutput)
}