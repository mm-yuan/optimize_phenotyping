%% PATHS
close all; clear all; clc

path = '/DATASERVER/MIC/GENERAL/STAFF/myuan0/projects/';
studypath = [path '/OptimizePhenotyping/OptimizeSNPlibHeritability/'];
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


loss = 'SNPLIB';   % SNPLIB h2
constrain = 'sequential';   % 'sequential' or 'minimize'  or  'none'
init_cutoff = 0.1; stride = 1e-4;   % sequential training cutoff
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


best_score_per_colony = nan(n_iter+1,n_colony);
mean_score_per_colony = nan(n_iter+1,n_colony);
best_cor = nan(n_iter,n_colony-1); mean_cor = nan(n_iter,n_colony-1);
best_dir = nan(n_colony,dim); % best direction among n_per_colony during training

%% Main
tStart = tic;  
for sq = 1:n_colony
    
    init_directions = initializeDirection(pc,n_per_colony,n_colony,constrain,sq);   %  nPerColony by dim 
    init_scores = evaluateDirection(pc,init_directions,cov,genomic_background,grm,num_threads); %  nPerColony

    best_score_per_colony(1,sq) = max(init_scores);
    mean_score_per_colony(1,sq) = mean(init_scores);


directions = init_directions;
scores = init_scores;
cutoff = init_cutoff + (sq-1)*(-1)*stride;

pf = StartParforProgress(n_iter);
for iter = 1:n_iter
    disp(['Training for population ' num2str(sq) ' iter ' num2str(iter) '...']);
    disp(datetime);

    directions = getNewGeneration(directions,scores,mutation_sigma,fraction_elite,constrain,sq,best_dir,cutoff);
    scores = evaluateDirection(pc,directions,cov,genomic_background,grm,num_threads);

    [best_score_per_colony(iter+1,sq), idx_best] = max(scores);
    mean_score_per_colony(iter+1,sq) = mean(scores);

    if sq ~= 1
        relmat = 1-pdist2(directions,best_dir(1:(sq-1),:),'cosine');
        avg_rel = mean(abs(relmat),2);
        best_cor(iter,sq-1) = avg_rel(idx_best); mean_cor(iter,sq-1) = mean(avg_rel);
    end

    if iter == n_iter
        % save best dir for checking distances with next step
        best_dir(sq,:) = directions(idx_best,:);  
    end

    if rem(iter,50) == 0 | iter == n_iter
        disp(['Saving results for iter ' num2str(iter) '...']);
        saveIteration([savepath '/TRACK/'],iter,pc,scores,directions,best_score_per_colony,mean_score_per_colony,space,constrain,sq,best_cor,mean_cor); 
    end

    ReportParforProgress;
end
QuitParforProgress(pf);
end

%%
save([savepath '/SUMMARY'],'suffix','iter','sq','best_dir','best_score_per_colony','mean_score_per_colony','best_cor','mean_cor');

% PLOT FACIAL TRAIT
[best_score_sort,idx_sort] = sort(best_score_per_colony(end,:),'descend');
for col = 1:n_colony
    plotFeature_face(space, best_dir(idx_sort(col),:), best_score_sort(col), [savepath '/FIG/Features_sort2/'], ...
        ['_Top' num2str(col)], [' Top ' num2str(col)]);
end

% Compute traits
traits_US = 1-pdist2(FacePCs_US,best_dir,'cosine');
traits_UK = 1-pdist2(FacePCs_UK,best_dir,'cosine');
save([savepath '/TRAITS_USUK2'],'suffix','traits_US','traits_UK');

% % ALSPACb2409 traits
% in = load([path '/OptimizeH2_GA_Family/GeneticAlgorithm/DATA/PHENO/FACE_USUK_ALSPACb2409_PCAspace.mat']);
% 
% traits_F = 1-pdist2(in.FacePCs_F,best_dir,'cosine');  
% traits_C = 1-pdist2(in.FacePCs_C,best_dir,'cosine');
% 
% save([savepath '/TRAITS_ALSPACb2409'],'suffix','traits_F','traits_C');
% 
% % Apply on Technopolis
% in2=load([path '/OptimizeH2_GA_Family/GeneticAlgorithm/DATA/PHENO/FACE_TechnopolisPC.mat']);
% 
% traits_F = 1-pdist2(in2.FacePCs_F,best_dir,'cosine');
% traits_M = 1-pdist2(in2.FacePCs_M,best_dir,'cosine');
% traits_C = 1-pdist2(in2.FacePCs_C,best_dir,'cosine');
% 
% save([savepath '/TRAITS_Technopolis.mat'],'suffix','traits_F','traits_M','traits_C');

%% END
