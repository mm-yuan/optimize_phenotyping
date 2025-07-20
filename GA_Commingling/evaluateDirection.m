function out = evaluateDirection(obs,directions)
[n_per_colony,n_colony] = size(directions,[1 2]);
out = nan(n_per_colony,n_colony);
    parfor i = 1:n_colony
        tmp = 1-pdist2(obs,squeeze(directions(:,i,:)),'cosine');
        out(:,i) = abs(mean(tmp)-median(tmp))./std(tmp);
    end
end

