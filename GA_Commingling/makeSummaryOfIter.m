function makeSummaryOfIter(path,iter,scores,directions,obs,space)

savepath = [path '/SUMMARY_ITER' num2str(iter) filesep];
if ~exist(savepath,'dir'), mkdir(savepath); end
if ~exist([savepath 'GaussianMixture/'],'dir'), mkdir([savepath 'GaussianMixture/']); end
if ~exist([savepath 'Features/'],'dir'), mkdir([savepath 'Features/']); end
if ~exist([savepath 'AvgTailShape/'],'dir'), mkdir([savepath 'AvgTailShape/']); end

if contains(path,'FACE'),load('/usr/local/micapollo01/MIC/DATA/STAFF/myuan0/projects/Software/ImgGENESoftware/RegistrationAuxilliaryData/FacialTemplate_20171201.mat');end
load('/usr/local/micapollo01/MIC/DATA/STAFF/myuan0/projects/Software/AIDFUNCTIONS/myToolboxes/COLORMAPS/InOutColorMap2.mat');

view = {'halfleft','front'};
n_img = length(view);rot = cell(1,n_img);
for i = 1:n_img
    switch lower(view{i})
        case 'face'
            rot{i} = roty(-30);
        case 'left'
            rot{i} = roty(-90);
        case 'right'
            rot{i} = roty(90);
        case 'front'
            rot{i} = roty(0);
        case 'back'
            rot{i} = roty(180);
        case 'top'
            rot{i} = rotz(90)*rotx(90); % to match right
        case 'halfright'
            rot{i} = roty(45);
        case 'halfleft'
            rot{i} = roty(-45);
        otherwise
            rot{i} = roty(90);
    end
end

[~,n_colony,~] = size(directions);
%% Cormat
[~,top_100_idx_per_colony] = maxk(scores,100);
tmp = arrayfun(@(x) squeeze(directions(top_100_idx_per_colony(:,x),x,:))',1:n_colony,'UniformOutput',false);
selected_dir = cell2mat(tmp);
relmat = 1-pdist2(selected_dir',selected_dir','cosine');
f = figure; imagesc(relmat); 
cmap=InOutColorMap2;
colormap(gca,cmap); caxis([-1 1]); colorbar;
print(f,[savepath 'CosineMatrix'],'-dpng','-r300');
%% Figures
[max_score_per_colony,i_max_score_per_colony] = max(scores);
[~,tmp] = sort(max_score_per_colony,'descend');
ranking = arrayfun(@(x) find(tmp==x),1:n_colony);
for i = 1:n_colony
    idx_dir = squeeze(directions(i_max_score_per_colony(i),i,:))';
    dist = 1-pdist2(obs,idx_dir,'cosine');
    idx_score = (median(dist)-mean(dist))/std(dist);
    % Plot Gaussian mixture for each colony
    GMM = cell(1,3);
    for g = 1:3
        GMM{g} = fitgmdist(dist,g,'Options',statset('MaxIter',1000));
    end
    AIC = cellfun(@(x) x.AIC,GMM);
    [~,n_comp] = min(AIC);
    gmm = GMM{n_comp};
    f = figure;
    histogram(dist,50,'Normalization', 'pdf', 'EdgeColor', 'none'); hold on
    x = linspace(min(dist),max(dist),10000);
    for K = 1:gmm.NumComponents
        tmp = pdf('Normal', x, gmm.mu(K), gmm.Sigma(K)^0.5);
        plot(x,tmp*gmm.ComponentProportion(K),'LineWidth',3);
    end
    xlabel('Mahalanobis angle'); set(gca,'FontSize',18);
    print(f,[savepath 'GaussianMixture/top_' num2str(ranking(i)) '_score_' num2str(abs(idx_score)) '.png'],'-dpng','-r300');
    close all
    % Plot features
    if contains(path,'VAULT')
        plotFeature_vault(space, idx_dir, idx_score, ...
                    [savepath '/Features/'], ['Top_' num2str(ranking(i))], [' Top ' num2str(ranking(i))]);
    elseif contains(path,'FACE')
        plotFeature(Template, space, idx_dir, idx_score, ...
               [savepath '/Features/'], ['Top_' num2str(ranking(i))], [' Top ' num2str(ranking(i))]);
    end
    
    % Plot tail avg shape
    [~,top_faces] = maxk(sign(idx_score)*dist,3);
    avg_top_face = space.AvgVertices + Vec2Struc(space,space.EigVec*mean(space.Tcoeff(top_faces,:))');
    obj = clone(space.RefScan); obj.Material = 'Dull';obj.SingleColor = [0.8 0.8 0.8];

    f=figure('Color',[1 1 1],'InvertHardcopy','off'); clf(f);
    p = panel(f); p.pack(1,n_img); p.margin = 5;
    obj.ColorMode = 'Single';
    for img = 1:n_img
        p(1,img).select(); peer = gca;cla(peer); axis(peer,'image'); hold on;
        peer.XColor = [1 1 1]; peer.YColor = [1 1 1]; peer.XTick = []; peer.YTick = [];
        rotobj = clone(obj); rotobj.Vertices = rot{img}*avg_top_face;
        rotobj.Axes = peer; rotobj.Visible = true; rotobj.Selected = true;
        light = camlight(peer,'headlight'); set(light,'Position',get(peer,'CameraPosition'));
    end
    print(f,[savepath 'AvgTailShape/top_' num2str(ranking(i)) '_score_' num2str(abs(idx_score)) '.png'],'-dpng','-r300');
    close all

end

end
