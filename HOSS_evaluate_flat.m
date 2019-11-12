function [post_W, KL_W] = HOSS_evaluate_flat(X, mu, Sigma, Wprior)
%% Inference on 2D Bayes net for asymmetric inference on presence vs. absence
%
% SF 2019

%% Initialise variables and conditional prob tables
p_W = Wprior; % prior on perceptual states W marginalising over A (used for calculating KL divergence)

% First compute likelihood of observed X for each possible W (P(X|mu_w, Sigma))
for m = 1:size(mu,1)
    lik_X_W(m) = mvnpdf(X, mu(m,:), Sigma);
end
p_X_W = lik_X_W./(sum(lik_X_W)); % renormalise to get P(X|W)

%% Posterior over W (P(W|X=x)
post_W = p_X_W.*p_W;
post_W = post_W./sum(post_W); % normalise

%% KL divergences
KL_W = sum(post_W.*(log(post_W./p_W)));