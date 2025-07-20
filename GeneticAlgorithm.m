%% PATHS
close all; clear all; clc

path = '/usr/local/micapollo01/MIC/DATA/STAFF/myuan0/projects/';
studypath = [path '/OptimizeSNPlibHeritability/'];
datapath = [studypath '/DATA/'];

addpath(genpath('/opt/SNPLIB/'));
addpath(genpath([path '/Software/AIDFUNCTIONS/']));
addpath(genpath([path '/Software/ImgGENESoftware/']));
addpath(genpath([studypath '/CODE/FUNCTIONS/AIDFUNCTIONS/']));
addpath(genpath([studypath '/CODE/FUNCTIONS/GA_SNPLIB/']));

load([datapath '/PHENO_GRM/EURO/FaceInputGA.mat']);
load([path '/Software/ImgGENESoftware/RegistrationAuxilliaryData/FacialTemplate_20171201.mat']);

% parpool(parcluster,60);
num_threads = 60;

%% Settings
pc =  FacePCs_US; dim = space.nrEV;
trainset = 'US_FACE';
cov=covUS(:,1:4);genomic_background=genomic_background_US;grm=GRM_US;
dim = size(pc,2);


loss = 'SNPLIB';   % SNPLIB h2
constrain = 'none';   % 'sequential' or 'minimize'  or  'none'
init_cutoff = 0; stride = 0;   % sequential training cutoff
n_iter = 500;  
n_colony = 100;
n_per_colony = 1000;
fraction_elite = 0.05;
par_mutation_sigma = 1e-4;
mutation_sigma = eye(dim) * par_mutation_sigma;

suffix = ['GA_' loss '_' trainset];
suffix = [suffix '_POP' num2str(n_per_colony) '_COL' num2str(n_colony) '_ELI' num2str(fraction_elite) '_MUT' num2str(par_mutation_sigma)]; 
if contains(constrain, 'sequential'), suffix = [suffix '_SQ_CUT' num2str(init_cutoff) '_' num2str(stride)]; end
savepath = [datapath '/GA_RESULT/' trainset '/' suffix];
if ~exist(savepath,'dir'), mkdir(savepath); mkdir([savepath '/FIG/']); end

%% Main
rng(2024); tStart = tic;  
init_directions = initializeDirection(pc,n_per_colony,n_colony); %   nPerColony by nColony by dim  
init_scores = evaluateDirection(pc,init_directions,cov,genomic_background,grm,num_threads); % nPerColony by nColony

% Track
best_score_per_colony = nan(n_iter+1,n_colony);
best_score_per_colony(1,:) = max(init_scores);
mean_score_per_colony = nan(n_iter+1,n_colony);
mean_score_per_colony(1,:) = mean(init_scores);
saveIteration([savepath '/TRACK/'],0,pc,init_scores,init_directions,best_score_per_colony,mean_score_per_colony,space);

% Iteration
directions = init_directions;
scores = init_scores;

pf = StartParforProgress(n_iter);
for iter = 1:n_iter
    directions = getNewGeneration(directions,scores,mutation_sigma,fraction_elite);
    scores = evaluateDirection(pc,directions,cov,genomic_background,grm,num_threads);
    
    best_score_per_colony(iter+1,:) = max(scores);
    mean_score_per_colony(iter+1,:) = mean(scores);

    if rem(iter,50) == 0 | iter == n_iter
        disp(['Saving results for iter ' num2str(iter) '...']);
        saveIteration([savepath '/TRACK/'],iter,pc,scores,directions,best_score_per_colony,mean_score_per_colony,space);
    end

    ReportParforProgress;
end
QuitParforProgress(pf);
tEnd = toc(tStart); time = tEnd/3600;  % hours
%% Make summary of last iteration
save([savepath '/SUMMARY'],'time','suffix','iter','scores','directions','best_score_per_colony','mean_score_per_colony');

%% Save best traits per colony
[scores_sort,idx] = max(scores);
dirs = cell2mat(arrayfun(@(x) squeeze(directions(idx(x),x,:)),1:n_colony,'UniformOutput',false));

traits_US = 1-pdist2(FacePCs_US,dirs','cosine');
traits_UK = 1-pdist2(FacePCs_UK,dirs','cosine');

save([savepath '/TRAITS'],'traits_US','traits_UK');

% PLOT FACIAL TRAIT
[best_score_sort,idx_sort] = sort(scores_sort,'descend');
best_dir_per_colony = dirs';
for col = 1:n_colony
    plotFeature_face(space, best_dir_per_colony(idx_sort(col),:), best_score_sort(col), [savepath '/FIG/Features_sort/'], ...
        ['_Top' num2str(col)], [' Top ' num2str(col)]);
end

%% END








