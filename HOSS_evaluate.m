function [post_W, post_A, KL_W, KL_A] = HOSS_evaluate(X, mu, Sigma, Aprior, Wprior)
%% Inference on 2D Bayes net for asymmetric inference on presence vs. absence
%
% SF 2019

%% Initialise variables and conditional prob tables
p_A = [1-Aprior Aprior];            % prior on awareness state A
p_W_a1 = [Wprior 1-Wprior 0];       % likelihood of world states W given a1
p_W_a0 = [0 0 1];           % likelihood of world states W given a0
p_W = (p_W_a1 + p_W_a0)./2; % prior on perceptual states W marginalising over A (used for calculating KL divergence)

%% Posterior over A (P(A|X=x) marginalising over W
% First compute likelihood of observed X for each possible W (P(X|mu_w, Sigma))
for m = 1:size(mu,1)
    lik_X_W(m) = mvnpdf(X, mu(m,:), Sigma);
end
p_X_W = lik_X_W./(sum(lik_X_W)); % renormalise to get P(X|W)
% Combine with likelihood of each world state w given awareness state A
lik_W_A(1,:) = p_X_W.*p_W_a0.*p_A(1);
lik_W_A(2,:) = p_X_W.*p_W_a1.*p_A(2);
post_A = sum(lik_W_A'); % sum over W
post_A = post_A./sum(post_A); % normalise

%% Posterior over W (P(W|X=x) marginalising over A
post_W = sum(lik_W_A); % sum over A
post_W = post_W./sum(post_W); % normalise

%% KL divergences
KL_W = sum(post_W.*(log(post_W./p_W)));
KL_A = sum(post_A.*(log(post_A./p_A)));
