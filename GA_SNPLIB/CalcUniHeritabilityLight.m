function [h2_f,h2_r] = CalcUniHeritabilityLight(traits,covariates,genomic_background,relationship_matrix,num_threads,V,D)
if nargin<5
    num_threads = feature('numcores');
end
if nargin<6, V=[];D=[];end 
if isempty(V), svd=1; else, svd=0; end % if no pre-computed V/D, apply eig() 

% traits=trait_f;covariates=cov_f;genomic_background=genomic_background_f;relationship_matrix=grm_f;V=V_f;D=D_f;

num_samples = size(traits,1);
if svd==1, [V,D] = eig(relationship_matrix,'vector');end

[~,ind] = sort(D,'descend');
D = D(ind);
V = V(:,ind);
cov = [ones(num_samples,1),covariates,genomic_background];
X = V'*cov;
Y = V'*zscore(traits);
[vars,~] = CalcUniLMM_(Y,X,D,num_threads);
h2_r = vars(2,:).^2;
% h2_f NOT used in optimization
h2_f=[];
% Y = zscore(traits);
% X = [ones(num_samples,1),covariates];
% Hat = eye(size(Y,1))-X/(X'*X)*X';
% res = Hat*Y;
% res = res.^2;
% v = sum(res,1);
% h2_f = v/(num_samples-size(X,2))-vars(1,:).^2;
end
