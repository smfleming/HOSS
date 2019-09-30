HOSS_evaluate <- function(X, Aprior, Wprior)
{
  require(rjags)
  
  modelstring="
model {

  a ~ dbern(Aprior)  # aware or unaware
  w1 ~ dcat(c(1-Wprior, Wprior, 0)) # world state (only relevant if aware)
  w0 ~ dcat(c(0, 0, 1))
  w <- ifelse(a < 1, w0, w1) # condition w on A

  mu1 <- mu[w,]
  X ~ dmnorm(mu1, T)

  lambda <- 1
  T[1,1] <- lambda
  T[1,2] <- 0
  T[2,1] <- 0
  T[2,2] <- lambda

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

# Define state space
mu <- matrix(NA,3,2)
mu[1,] <- c(0.5,1.5)
mu[2,] <- c(1.5,0.5)
mu[3,] <- c(0.5,0.5)

data <- list(X=X, mu=mu, Aprior=Aprior, Wprior=Wprior)

model = jags.model( textConnection(modelstring), data=data, n.chains=nChains , n.adapt=adaptSteps )
#   Burn-in:
update(model , n.iter=burnInSteps )
expOutput = coda.samples(model , variable.names=parameters ,
                         n.iter=nIter , thin=thinSteps )
return(expOutput)
}