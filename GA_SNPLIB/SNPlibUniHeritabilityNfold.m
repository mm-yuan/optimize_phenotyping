function out = SNPlibUniHeritabilityNfold(trait,cov,genomic_background,grm,num_threads,n_per_fold,V,D)

if nargin < 7, V=[];D=[]; end

nsample = size(trait,1);
n_fold = ceil(nsample/n_per_fold); 
foldId = kron(1:n_fold, ones(1,n_per_fold));  % input data already shuffled, keep order to match pre-computed V/D
foldId = foldId(1:nsample);

for f=1:n_fold

    idx_fold = find(foldId==f);

    trait_f = trait(idx_fold,:);   
    genomic_background_f = genomic_background(idx_fold,:);
    cov_f = cov(idx_fold,:);grm_f = grm(idx_fold,idx_fold);
    if ~isempty(V), V_f = cell2mat(V(f));D_f = cell2mat(D(f)); 
    else, V_f=[];D_f=[];end

    [~, h2_r] = CalcUniHeritabilityLight(trait_f,cov_f,genomic_background_f,grm_f,num_threads,V_f,D_f); 
    out(f,:) = h2_r; 
end

end
