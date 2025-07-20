function [h, r, So_Sp] = evaluateDirection(obs,directions,constrain)

if nargin < 3, constrain = 'none'; end
if ndims(directions)==3, n_colony = size(directions,2); else n_colony = 1;end

n_pairs = size(obs,1)/2;
n_per_colony = size(directions,1);

h = nan(n_per_colony,n_colony);
r = nan(n_per_colony,n_colony);
So_Sp = nan(n_per_colony,n_colony);


% % Random Sampling Technique (RST) 
% % using only a random subset of the training data for fitness evaluation, changing this subset during the evolution

% rng(6+seed+n_fold); n_val = randi([600,770]); % number of samples in this random subset varying 
% idx_sub = randsample(1:n_pairs,n_val);
% idx_f = idx_sub; idx_c = idx_sub+length(idx_sub);

idx_f=1:1:n_pairs; idx_c = (n_pairs+1):1:size(obs,1);

if strcmp('mismatch', constrain) 
    idx_f = idx_f(randperm(n_pairs));
end


if n_colony == 1
    trait = 1-pdist2(obs, directions,'cosine');
    [h,r,~,~,So_Sp] = computeH2mat(trait,n_per_colony,idx_c,idx_f);
else
    parfor i = 1:n_colony
        trait = 1-pdist2(obs,squeeze(directions(:,i,:)),'cosine');
        [h(:,i),r(:,i),~,~,So_Sp(:,i)] = computeH2mat(trait,n_per_colony,idx_c,idx_f);
    end
end




end

