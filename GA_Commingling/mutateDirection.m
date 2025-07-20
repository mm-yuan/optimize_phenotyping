function out = mutateDirection(direction,mutation_sigma,n_offspring)
% out : nPerColony by nColony by dim
% direction: nDirection by dim
% mutation_sigma : dim by dim
[n_direction,~] = size(direction);
parfor i = 1:n_direction
    tmp = mvnrnd(direction(i,:)',mutation_sigma,n_offspring);
    out(:,i,:) = tmp./(sqrt(sum(tmp.^2,2)));
end
if n_offspring == 1, out = squeeze(out); end
end