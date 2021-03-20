%% Simulate trial sequence for imaging experiment with variable priors
% on presence/absence and category

clear all

% Create 3 likelihood functions
mu = [0.5 1.5; 1.5 0.5; 0.5 0.5];  % possible Gaussians over X corresponding to each world state
Sigma = [0.1 0; 0 0.1];

Ntrials = 600;
Nsubj = 30;

% Index into mu
cond = [ones(1,Ntrials/3) ones(1,Ntrials/3).*2 ones(1,Ntrials/3).*3];
Aprior = [0.8 0.2];
Wprior = [0.8 0.2];

for s = 1:Nsubj
    % Generate sensory samples
    for i = 1:length(cond)
        X(i,:) = mvnrnd(mu(cond(i),:), Sigma, 1);
    end
    j=1;
    for a = 1:length(Aprior)
        for w = 1:length(Wprior)
            % Invert model for each trial under different priors
            for i = 1:length(cond)
                [post_w, post_A, KL_w(i), KL_A(i)] = HOSS_evaluate(X(i,:), mu, Sigma, Aprior(a), Wprior(w));
                decisionA(i) = post_A(2) > 0.5;
                decisionW(i) = post_w(2) >= post_w(1);
            end
            
            % Note could also split here by response (H/M/CR/FA) and/or
            % exclude errors if necessary 
            KL_w_vector(j,1,s) = mean(KL_w(decisionA == 1 & decisionW == 1));
            KL_A_vector(j,1,s) = mean(KL_A(decisionA == 1 & decisionW == 1));
            KL_w_vector(j,2,s) = mean(KL_w(decisionA == 1 & decisionW == 0));
            KL_A_vector(j,2,s) = mean(KL_A(decisionA == 1 & decisionW == 0));
            KL_w_vector(j,3,s) = mean(KL_w(decisionA == 0));
            KL_A_vector(j,3,s) = mean(KL_A(decisionA == 0));
            j=j+1;
        end
    end
end

mean_KL_w_vector = nanmean(KL_w_vector, 3);
sem_KL_w_vector = nanstd(KL_w_vector, 0, 3)./sqrt(Nsubj);
mean_KL_A_vector = nanmean(KL_A_vector, 3);
sem_KL_A_vector = nanstd(KL_A_vector, 0, 3)./sqrt(Nsubj);

figure;
subplot(1,2,1)
bar(mean_KL_w_vector)
legend('a1/w1', 'a1/w2', 'a0')
set(gca, 'XTick', 1:4, 'XTickLabel', {'a1w1', 'a1w2', 'a0w1', 'a0w2'})
subplot(1,2,2)
bar(mean_KL_A_vector)
legend('a1/w1', 'a1/w2', 'a0')
set(gca, 'XTick', 1:4, 'XTickLabel', {'a1w1', 'a1w2', 'a0w1', 'a0w2'})