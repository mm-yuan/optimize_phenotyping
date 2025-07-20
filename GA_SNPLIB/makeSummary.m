function makeSummary(path,iter,space,best_dir,best_score_per_colony,mean_score_per_colony,sq,best_cor,mean_cor)
if nargin < 7, sq = []; end
if nargin < 7, best_cor = [];mean_cor=[]; end

        if isempty(sq)
            savepath = [path '/ITERATION' num2str(iter) filesep];
        else
            savepath = [path '/STEP' num2str(sq) '/ITERATION' num2str(iter) filesep];
        end
        if ~exist(savepath,'dir'), mkdir(savepath); end
        %% SAVE DATA  
        if isempty(sq)
            save([savepath filesep 'BEST'],'iter','best_dir','best_score_per_colony'); 
            [best_score_sort,idx_sort] = sort(best_score_per_colony,'descend');
        else 
            save([savepath filesep 'SUMMARY'],'iter','sq','best_dir','best_cor','mean_cor', ...
            'best_score_per_colony','mean_score_per_colony');  
            [best_score_sort,idx_sort] = sort(best_score_per_colony(end,1:sq),'descend');
        end
        %% PLOT TRAIT FEATURE
        for col = 1:length(idx_sort)
            if contains(path,'VAULT')
                plotFeature_vault(space, best_dir(idx_sort(col),:), best_score_sort(col), ...
                    [savepath '/Features_sort/'], ['_Top' num2str(col)], [' Top ' num2str(col)]);
            elseif contains(path,'FACE')
                plotFeature_face(space, best_dir(idx_sort(col),:), best_score_sort(col), ...
                    [savepath '/Features_sort/'], ['_Top' num2str(col)], [' Top ' num2str(col)]);
            elseif contains(path,'NOSE')
                plotFeature_nose(space, best_dir(idx_sort(col),:), best_score_sort(col), ...
                    [savepath '/Features_sort/'], ['_Top' num2str(col)], [' Top ' num2str(col)]);
            end
        end
        close all;
end
