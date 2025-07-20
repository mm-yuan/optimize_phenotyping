function new_directions = getNewGeneration(directions,scores,mutation_sigma,fraction_elite)
[n_per_colony,n_colony,dim] = size(directions);
fitness = scores./sum(scores,1);

n_elite = ceil(fraction_elite*n_per_colony);
n_offspring = n_per_colony - n_elite;
[~,idx_elite] = maxk(fitness,n_elite);

new_directions = nan(n_per_colony,n_colony,dim);
parfor i = 1:n_colony
    idx = randsample(1:n_per_colony,n_offspring,true,fitness(:,i));
    offspring_directions = mutateDirection(squeeze(directions(idx,i,:)),mutation_sigma,1);
    elite_directions = squeeze(directions(idx_elite(:,i),i,:));
    new_directions(:,i,:) = cat(1,elite_directions,offspring_directions);
end
end