%% Precision check
% Recover precision using Bayesian graphical models across range of sample
% number and precision levels

addpath('~/Dropbox/Utils/HMeta-d/Matlab/')
tau2 = [0.2 0.5 1 1.5 2];
nsamples = [10 20 30 50 100 500 1000 5000];

figure;
for k = 1:length(nsamples)
    for j = 1:length(tau2)
        
        % Generate data
        mu = 0;
        n = nsamples(k);
        X = normrnd(mu, sqrt(tau2(j)), 1, n);
        
        % Fit model
        model_file = 'Gaussian_jags.txt';
        monitorparams = {'mu', 'invTau2', 'tau2'};
        datastruct = struct('X', X, 'n', n);
        for i=1:3
            init0(i) = struct;
        end
        
        tic
        fprintf( 'Running JAGS ...\n' );
        [samples, stats] = matjags( ...
            datastruct, ...
            fullfile(pwd, model_file), ...
            init0, ...
            'doparallel' , 0, ...
            'nchains', 3,...
            'nburnin', 1000,...
            'nsamples', 5000, ...
            'thin', 1, ...
            'dic', 1,...
            'monitorparams', monitorparams, ...
            'savejagsoutput' , 0 , ...
            'verbosity' , 1 , ...
            'cleanup' , 1);
        toc
        
        recovered_tau2(j) = stats.mean.tau2;
        
    end
    plot(tau2, recovered_tau2);
    hold on
end
plot(tau2, tau2, 'k', 'LineStyle', '--', 'LineWidth', 2)
legend(nsamples)