function saveIteration(path,iter,obs,scores,directions,best_score_per_colony,mean_score_per_colony,space,constrain,sq,best_cor,mean_cor)

if nargin < 9, constrain = 'none'; end
if nargin < 9, sq = []; end
if nargin < 9, best_cor = [];mean_cor=[]; end


        if isempty(sq)
            savepath = [path '/ITERATION' num2str(iter) filesep];
        else
            savepath = [path '/STEP' num2str(sq) '/ITERATION' num2str(iter) filesep];
        end
        if ~exist(savepath,'dir'), mkdir(savepath); end

        %% SAVE DATA  
        if ~isempty(sq)
            if rem(iter,50) == 0, save([savepath filesep 'SUMMARY'], ...
                    'sq','iter','directions','scores','best_cor','mean_cor','-v7.3');end
        else 
            if rem(iter,10) == 0, save([savepath filesep 'SUMMARY'], ...
                    'iter','directions','scores', 'best_score_per_colony','mean_score_per_colony','-v7.3');end
        end
        %% Compute trait
        if strcmp('sequential', constrain) 
            [maxval, idx_best] = max(scores);
            tmp_best_dir = directions(idx_best,:);
        else
            if strcmp('none', constrain)
                maxval = max(scores,[],'all');
            end
            [row,col] = find(scores == maxval,1,'first');
            tmp_best_dir = squeeze(directions(row,col,:))';
        end
        best_trait = 1-pdist2(obs,tmp_best_dir,'cosine');
        idx_score = maxval;
        
        %% Histogram
        f = figure; hold on
        histogram(best_trait, 'FaceColor', [0.5273    0.8047    0.9766])
        title(['Histogram of trait at best direction iteration' num2str(iter)]);
        print(f,[savepath 'iter' num2str(iter) '_hist'],'-dpng','-r300');
        %% PLOT TRAIT
        if contains(path,'VAULT')
            plotFeature_vault(space, tmp_best_dir, idx_score, savepath, [], []);
        elseif contains(path,'FACE')
            plotFeature_face(space, tmp_best_dir, idx_score, savepath, [], []);
        elseif contains(path,'NOSE')
            plotFeature_nose(space, tmp_best_dir, idx_score, savepath, [], []);
        end
        close all
        %% PLOT FITNESS
        if iter == 0, return; end

        f = figure; plot(best_score_per_colony); xlabel('Iteration'); ylabel('SNPLIB H2'); set(gca,'FontSize',18);
        print(f,[savepath filesep 'iter' num2str(iter) '_best_scores'],'-dpng','-r300');

        f = figure; plot(mean_score_per_colony); xlabel('Iteration'); ylabel('SNPLIB H2'); set(gca,'FontSize',18);
        print(f,[savepath filesep 'iter' num2str(iter) '_mean_scores'],'-dpng','-r300');
     
        close all
        %% PLOT CorrMat
        if isempty(sq), return; end
        if sq == 1, return; end

        f = figure; plot(best_cor); xlabel('Iteration'); ylabel('Distance to other directions'); set(gca,'FontSize',18);
        if ~isempty(sq) title(['Step ' num2str(sq) ' Best']);else title('Training Best');end
        % Average absolute cosine distance to previous best directions'
        print(f,[savepath 'iter' num2str(iter) '_best_cor'],'-dpng','-r300');

        f = figure; plot(mean_cor); xlabel('Iteration'); ylabel('Distance to other directions'); set(gca,'FontSize',18);
        if ~isempty(sq) title(['Step ' num2str(sq) ' Mean']);else title('Training Mean');end
        print(f,[savepath 'iter' num2str(iter) '_mean_cor'],'-dpng','-r300');

        close all
end
