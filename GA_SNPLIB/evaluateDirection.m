function out = evaluateDirection(obs,directions,cov,genomic_background,grm,num_threads,n_per_fold,V,D)

if nargin < 6, num_threads = 50; end
if nargin < 7, n_per_fold = 'all'; end
if nargin < 8, V=[];D=[]; end

% obs=pc; directions = init_directions;


if ndims(directions)==3, n_colony = size(directions,2); else n_colony = 1;end
n_per_colony = size(directions,1);

out = nan(n_per_colony,n_colony);
if n_colony == 1
    trait = 1-pdist2(obs, directions,'cosine');
    if isequal(n_per_fold, 'all') % use all sample
        [~, h2_r] = CalcUniHeritabilityLight(trait,cov,genomic_background,grm,num_threads,V,D); 
        out = h2_r;
    else % compute h2 in fold
        h2_r = SNPlibUniHeritabilityNfold(trait,cov,genomic_background,grm,num_threads,n_per_fold,V,D);
        % out = median(h2_r);
        out = min(h2_r);
    end
    
else
    % constrain = 'none';
    for i = 1:n_colony
        trait = 1-pdist2(obs,squeeze(directions(:,i,:)),'cosine');
        if isequal(n_per_fold, 'all')  % use all sample
            [~, h2_r] = CalcUniHeritabilityLight(trait,cov,genomic_background,grm,num_threads,V,D);         
            out(:,i) = h2_r;
        else % compute h2 in fold
            h2_r = SNPlibUniHeritabilityNfold(trait,cov,genomic_background,grm,num_threads,n_per_fold,V,D);
          %  out(:,i) = median(h2_r);
            out(:,i) = min(h2_r);
        end
    end

end

end



