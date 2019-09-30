%% Visualise 2D Gaussian model
%
% Visualisation for 2D model used in state space project
%
% Steve Fleming 2018

% Precision of the grid
xgrid = 0:0.02:10;

% Widths
lw1 = 4;
lw2 = 2;

% Create 3 likelihood functions
mu = [3.5 7; 7 3.5; 3.5 3.5];  % possible Gaussians over X corresponding to each world state
Sigma = [1 0; 0 1];

figure;
for i = 1:3
       [X1,X2] = meshgrid(xgrid', xgrid');
       X = [X1(:) X2(:)];
       p = mvnpdf(X, mu(i,:), Sigma);
       hold on
       mesh(X1,X2,reshape(p,length(xgrid),length(xgrid)));
end
xlabel('X1')
ylabel('X2')
set(gca, 'FontSize', 14)
grid on
view(-45, 45)