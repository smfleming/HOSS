%% Demo of hierarchical inference on stimulus presence
%
% Calculates probability of "seen" response (inference on p(A)) given input
% X, and KL divergence for full network and top-level node
%
% Steve Fleming 2018

clear all
close all

% Precision of the grid
xgrid = 0:0.01:2;
mu = [0.5 1.5; 1.5 0.5; 0.5 0.5];  % possible Gaussians over X corresponding to each world state
Sigma = [1 0; 0 1];

% Widths
lw1 = 4;
lw2 = 2;

for i = 1:length(xgrid)
    for j = 1:length(xgrid)
        
        X = [xgrid(i) xgrid(j)];
        [post_w, post_A, KL_w(i,j), KL_A(i,j)] = HOSS_evaluate(X, mu, Sigma, 0.5, 0.5);
        
        confW(i,j) = max([post_w(1) post_w(2)]);
        posteriorAware(i,j) = post_A(2);
        
    end
end

KL_A_absent = mean(KL_A(posteriorAware < 0.5));
KL_A_present = mean(KL_A(posteriorAware >= 0.5));
KL_w_absent = mean(KL_w(posteriorAware < 0.5));
KL_w_present = mean(KL_w(posteriorAware >= 0.5));

figure;
subplot(1,2,1)
contourf(xgrid, xgrid, posteriorAware);
box off
axis square
colorbar
xlabel('X1')
ylabel('X2')
title('Posterior probability "seen"')
set(gca, 'FontSize', 14)

subplot(1,2,2)
contourf(xgrid, xgrid, confW);
hold on
contour(xgrid, xgrid, posteriorAware, [0.5 0.5], 'LineWidth', lw1, 'Color', [1 1 1])
box off
axis square
colorbar
xlabel('X1')
ylabel('X2')
title('Confidence in identity')
set(gca, 'FontSize', 14)

figure;
subplot(1,2,1)
contourf(xgrid, xgrid, KL_w);
box off
axis square
colorbar
xlabel('X1')
ylabel('X2')
title('K-L divergence, perceptual states')
set(gca, 'FontSize', 14)

subplot(1,2,2)
contourf(xgrid, xgrid, KL_A);
box off
axis square
colorbar
xlabel('X1')
ylabel('X2')
title('K-L divergence, awarenesss state')
set(gca, 'FontSize', 14)

figure;
set(gcf, 'Position', [500 500 900 300])
subplot(1,2,1)
bar([KL_w_absent KL_w_present], 'k')
box off
ylabel('K-L divergence, W states')
set(gca, 'FontSize', 18, 'XTickLabel', {'unseen', 'seen'})

subplot(1,2,2)
bar([KL_A_absent KL_A_present], 'k')
box off
ylabel('K-L divergence, A states')
set(gca, 'FontSize', 18, 'XTickLabel', {'unseen', 'seen'})