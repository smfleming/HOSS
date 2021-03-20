load dic
model in "/Users/sfleming/Dropbox/Research/Consciousness/HOSS/JAGS/Gaussian_jags.txt"
data in jagsdata.R
compile, nchains(1)
parameters in jagsinit1.R
initialize
update 1000
monitor set mu, thin(1)
monitor set invTau2, thin(1)
monitor set tau2, thin(1)
monitor deviance
update 5000
coda *, stem('CODA1')
