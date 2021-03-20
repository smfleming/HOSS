%% State space experiment simulation
%
% Calculates KL divergence for each of stim x response categories in Y/N
% detection case
%
% Calls stateSpace_inferece.m
%
% Steve Fleming 2018

% First run model forward to generate X's on each trial

clear all
close all

% Create 3 likelihood functions
mu = [0.5 1.5; 1.5 0.5; 0.5 0.5];  % possible Gaussians over X corresponding to each world state

% Set up experiment parameters
Nsubjects = 30;
Ntrials = 600;
cond = [ones(1,Ntrials/3) ones(1,Ntrials/3).*2 ones(1,Ntrials/3).*3]; % half present, half absent

% Set precision values we are going to loop over
gamma = linspace(0.1, 10, 6);
for y = 1:length(gamma)
    
    Sigma = [1./sqrt(gamma(y)) 0; 0 1./sqrt(gamma(y))];
    for s = 1:Nsubjects
        % Generate sensory samples
        for i = 1:length(cond)
            X(i,:) = mvnrnd(mu(cond(i),:), Sigma, 1);
        end
        
        % Invert model for each trial
        for i = 1:length(cond)
            [post_w, post_A, KL_w(i), KL_A(i)] = HOSS_evaluate(X(i,:), mu, Sigma, 0.5, 0.5);
            posteriorAware(i) = post_A(2);
        end
        
        % Get mean KL_w and KL_w per subject, stim condition and response - order
        % is [CR M H FA] (i.e. absent response followed by present response)
        binaryAware = posteriorAware > 0.5;
        mean_KL_w(s,1) = mean(KL_w(binaryAware == 0 & cond == 3));
        mean_KL_w(s,2) = mean(KL_w(binaryAware == 0 & (cond == 1 | cond == 2)));
        mean_KL_w(s,3) = mean(KL_w(binaryAware == 1 & (cond == 1 | cond == 2)));
        mean_KL_w(s,4) = mean(KL_w(binaryAware == 1 & cond == 3));
        
        mean_KL_A(s,1) = mean(KL_A(binaryAware == 0 & cond == 3));
        mean_KL_A(s,2) = mean(KL_A(binaryAware == 0 & (cond == 1 | cond == 2)));
        mean_KL_A(s,3) = mean(KL_A(binaryAware == 1 & (cond == 1 | cond == 2)));
        mean_KL_A(s,4) = mean(KL_A(binaryAware == 1 & cond == 3));
        
        prob_y(s) = mean(binaryAware(cond == 1 | cond == 2));
    end
    
    all_KL_w_yes(y) = mean(mean(mean_KL_w(:,[3 4])));
    sem_KL_w_yes(y) = mean(std(mean_KL_w(:,[3 4]))./sqrt(Nsubjects));
    all_KL_w_no(y) = mean(mean(mean_KL_w(:,[1 2])));
    sem_KL_w_no(y) = mean(std(mean_KL_w(:,[1 2]))./sqrt(Nsubjects));
    all_KL_A_yes(y) = mean(mean(mean_KL_A(:,[3 4])));
    sem_KL_A_yes(y) = mean(std(mean_KL_A(:,[3 4]))./sqrt(Nsubjects));
    all_KL_A_no(y) = mean(mean(mean_KL_A(:,[1 2])));
    sem_KL_A_no(y) = mean(std(mean_KL_A(:,[1 2]))./sqrt(Nsubjects));
    all_prob_y(y) = mean(prob_y);
end

figure; 
set(gcf, 'Position', [500 500 1200 350])
subplot(1,3,1)
plot(gamma, all_prob_y, 'LineWidth', 2)
set(gca, 'FontSize', 14)
ylabel('Prob. report "seen" for w_1 or w_2')
xlabel('SOA (precision)')
box off

subplot(1,3,2)
errorbar(gamma, all_KL_w_yes, sem_KL_w_yes, 'LineWidth', 2)
hold on
errorbar(gamma, all_KL_w_no, sem_KL_w_no, 'LineWidth', 2)
legend('Seen', 'Unseen')
legend boxoff
set(gca, 'FontSize', 14)
ylabel('K-L divergence, perceptual states')
xlabel('SOA (precision)')
box off

subplot(1,3,3)
errorbar(gamma, all_KL_A_yes, sem_KL_A_yes, 'LineWidth', 2)
hold on
errorbar(gamma, all_KL_A_no, sem_KL_A_no, 'LineWidth', 2)
legend('Seen', 'Unseen')
legend boxoff
set(gca, 'FontSize', 14)
ylabel('K-L divergence, awareness state')
xlabel('SOA (precision)')
box off
