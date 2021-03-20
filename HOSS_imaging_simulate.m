%% Simulate trial sequence for imaging experiment with variable priors
% on presence/absence and category

clear all

% Create 3 likelihood functions
mu = [0.5 1.5; 1.5 0.5; 0.5 0.5];  % possible Gaussians over X corresponding to each world state
Sigma = [0.1 0; 0 0.1]; % controls accuracy -> smaller sigma = higher acc

Ntrials = 600;
Nsubj = 30;

% Index into mu
cond = [ones(1,Ntrials/3) ones(1,Ntrials/3).*2 ones(1,Ntrials/3).*3];
Aprior = [0.8 0.2];
Wprior = [0.8 0.2];

%% Hierarchical model 

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
                decisionW(i) = post_w(1) >= post_w(2);
            end
            
            % compute decision
            decision = zeros(1,length(cond));
            decision(decisionA == 1 & decisionW == 1) = 1;
            decision(decisionA == 1 & decisionW == 0) = 2;
            decision(decisionA == 0) = 3;
           
            % compute accuracy
            C = decision == cond;
            for r = 1:3
                accHM(s,j,r) = sum(cond==r & C)/sum(cond==r);
            end            
            
            % calculate total surpisal
            KL_T = KL_w + KL_A;                   
            
             % We only take correct trials here 
            KL_w_vector(j,1,s) = mean(KL_w(decision == 1 & C));
            KL_A_vector(j,1,s) = mean(KL_A(decision == 1 & C));
            KL_w_vector(j,2,s) = mean(KL_w(decision == 2 & C));
            KL_A_vector(j,2,s) = mean(KL_A(decision == 2 & C));
            KL_w_vector(j,3,s) = mean(KL_w(decision == 3 & C));
            KL_A_vector(j,3,s) = mean(KL_A(decision == 3 & C));
            
            KL_T_vector(j,1,s) = mean(KL_T(decision == 1 & C));
            KL_T_vector(j,2,s) = mean(KL_T(decision == 2 & C));
            KL_T_vector(j,3,s) = mean(KL_T(decision == 3 & C));
            j=j+1;
        end
    end
end


figure;
subplot(2,2,1)
bar(nanmean(KL_w_vector,3))
legend('a1/w1', 'a1/w2', 'a0'); title('Layer W')
set(gca, 'XTick', 1:4, 'XTickLabel', {'a1w1', 'a1w2', 'a0w1', 'a0w2'})
subplot(2,2,2)
bar(nanmean(KL_A_vector,3))
legend('a1/w1', 'a1/w2', 'a0'); title('Layer A')
set(gca, 'XTick', 1:4, 'XTickLabel', {'a1w1', 'a1w2', 'a0w1', 'a0w2'})
subplot(2,2,3)
bar(nanmean(KL_T_vector,3))
legend('a1/w1', 'a1/w2', 'a0'); title('Total')
set(gca, 'XTick', 1:4, 'XTickLabel', {'a1w1', 'a1w2', 'a0w1', 'a0w2'})

%% Create simulation data - flat model 

% create flat prior per response by combining A and w predictions
for w = 1:2
    for a = 1:2         
        Fprior(a,w,1) = Aprior(a)*Wprior(w);
        Fprior(a,w,2) = Aprior(a)*(1-Wprior(w));
        Fprior(a,w,3) = 1-Aprior(a);
    end
end

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
                [post_F, KL_F(i)] = HOSS_evaluate_flat(X(i,:), mu, Sigma, squeeze(Fprior(a,w,:))');
                [~,decisionF(i)] = max(post_F);   
            end
            
            % determine accuracy
            C = decisionF == cond;
            for r = 1:3
                accFM(s,j,r) = sum(cond==r & C)/sum(cond==r);
            end
            
            % Only look at correct trials here
            KL_F_vector(j,1,s) = mean(KL_F(decisionF == 1 & C));
            KL_F_vector(j,2,s) = mean(KL_F(decisionF == 2 & C));
            KL_F_vector(j,3,s) = mean(KL_F(decisionF == 3 & C));            
           
            j=j+1;
        end
    end
end

subplot(2,2,4)
bar(nanmean(KL_F_vector,3))
legend('a1/w1', 'a1/w2', 'a0'); title('Flat model')
set(gca, 'XTick', 1:4, 'XTickLabel', {'a1w1', 'a1w2', 'a0w1', 'a0w2'})