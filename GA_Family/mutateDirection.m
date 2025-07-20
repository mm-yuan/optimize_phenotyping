function out = mutateDirection(direction,mutation_sigma,n_offspring,seed)
% out : nDirection by dim
% direction: nDirection by dim
% mutation_sigma : dim by dim
if nargin < 4, seed = 6; end  % seed
[n_direction,~] = size(direction);
dim = size(mutation_sigma,1);
parfor i = 1:n_direction
    rng(6+seed+10*i); 
    tmp = mvnrnd(direction(i,:)',mutation_sigma,n_offspring);
    out(:,i,:) = tmp./(sqrt(sum(tmp.^2,2)));
end
if n_offspring == 1, out = squeeze(out); end
end


