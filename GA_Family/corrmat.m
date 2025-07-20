function out = corrmat(directions)

[n_per_colony,n_colony] = size(directions,[1 2]);
out = nan(n_per_colony,n_colony);

    parfor i = 1:n_colony

        idx = 1:n_colony;
        idx(find(idx==i))=[];

        other_colony = arrayfun(@(x) squeeze(directions(:,x,:))',idx,'UniformOutput',false);
        other_colony_dir = cell2mat(other_colony);

        relmat = 1-pdist2(other_colony_dir',squeeze(directions(:,i,:)),'cosine');

        out(:,i) = mean(abs(relmat));
    end

end

