function out = initializeDirection(pc,n_offspring,initialization,constrain,n_colony,seed)

if nargin < 5, n_colony = []; end 
if nargin < 6, seed = 6; end   

mu = mean(pc);dim = size(pc,2);

if strcmp('random_sampled', initialization) 

    if strcmp('sequential', constrain)  % out : nPerColony by dim 
        n_step = 1;
    else   % out : nPerColony by nColony by dim 
        n_step = n_colony;
    end

    parfor i = 1:n_step
        rng(6+seed+10*i); 
        tmp = mvnrnd(mu,diag(ones(dim,1)),n_offspring);
        out(:,i,:) = tmp./(sqrt(sum(tmp.^2,2)));
    end
    if n_step == 1, out = squeeze(out); end
    if n_offspring == 1, out = squeeze(out); end
end

end
