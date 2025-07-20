function out = initializeDirection(pc,n_offspring,n_colony,constrain,seed)

if nargin < 4, constrain='non'; end 
if nargin < 5, seed = 2024; end   

mu = mean(pc);dim = size(pc,2);

    if strcmp('sequential', constrain)  % out : nPerColony by dim 
        n_step = 1;
    else   % out : nPerColony by nColony by dim 
        n_step = n_colony;
    end

    for i = 1:n_step
        rng(6+seed+10*i); 
        tmp = mvnrnd(mu,diag(ones(dim,1)),n_offspring);
        out(:,i,:) = tmp./(sqrt(sum(tmp.^2,2)));
    end
    if n_step == 1, out = squeeze(out); end
    if n_offspring == 1, out = squeeze(out); end


end
