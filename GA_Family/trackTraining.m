function trackTraining(path,template,space,suffix,loss,constrain,sq,iter,obs,scores,directions, ...
                       best_r,mean_r,best_h,mean_h,best_Sop,mean_Sop,best_cor,mean_cor,best_dir)

        if isempty(sq)
            savepath = [path '/ITERATION' num2str(iter) filesep];
        else
            savepath = [path '/STEP' num2str(sq) '/ITERATION' num2str(iter) filesep];
        end
        if ~exist(savepath,'dir'), mkdir(savepath); end

        %% SAVE DATA  
        if rem(iter,500) == 0 
                save([savepath filesep 'SUMMARY'],'suffix','sq','iter', ...
                'best_r','mean_r','best_h','mean_h','best_Sop','mean_Sop','best_cor','mean_cor','best_dir','-v7.3');
        end

        %% Compute trait
        idx_f=1:1:(size(obs,1)/2); idx_c = (size(obs,1)/2+1):1:size(obs,1);
        if strcmp('sequential', constrain) 
            [maxval, idx_best] = max(scores);
            tmp_best_dir = directions(idx_best,:);
        else
            if strcmp('none', constrain) | strcmp('mismatch', constrain)
                maxval = max(scores,[],'all');
            elseif strcmp('minimize', constrain)
                maxval = min(scores,[],'all');
            end
            [row,col] = find(scores == maxval,1,'first');
            tmp_best_dir = squeeze(directions(row,col,:))';
        end
        best_trait = 1-pdist2(obs,tmp_best_dir,'cosine');

        %% Histogram
        f = figure; hold on
        histogram(best_trait(idx_c), 'FaceColor', [0 0 0.9])
        histogram(best_trait(idx_f), 'FaceColor', [0.5273    0.8047    0.9766])
        title(['Histogram of best direction at iteration' num2str(iter)]);
        legend({'Children', 'Father'});
        print(f,[savepath 'iter' num2str(iter) '_hist'],'-dpng','-r300');
        
        %% PLOT FACIAL TRAIT
        if ~isempty(sq)
            plotFeature(template, space, tmp_best_dir, maxval, savepath, ['_Step' num2str(sq)], [' Step ' num2str(sq)]);
        else
            plotFeature(template, space, tmp_best_dir, maxval, savepath, [], []);
        end
        
        %% PLOT CorrMat

        f = figure; plot(best_cor); xlabel('Iteration'); ylabel('Distance to other directions'); set(gca,'FontSize',18);
        if ~isempty(sq) title(['Step ' num2str(sq) ' Best']);else title('Training Best');end
        % Average absolute cosine distance to previous best directions'
        print(f,[savepath 'iter' num2str(iter) '_best_cor'],'-dpng','-r300');

        f = figure; plot(mean_cor); xlabel('Iteration'); ylabel('Distance to other directions'); set(gca,'FontSize',18);
        if ~isempty(sq) title(['Step ' num2str(sq) ' Mean']);else title('Training Mean');end
        print(f,[savepath 'iter' num2str(iter) '_mean_cor'],'-dpng','-r300');

        close all;

        %% PLOT FITNESS

        f = figure; plot(best_r); xlabel('Iteration'); ylabel(loss); set(gca,'FontSize',18);
        if ~isempty(sq) title(['Step ' num2str(sq) ' Best']);else title('Training Best');end
        print(f,[savepath 'iter' num2str(iter) '_best_r'],'-dpng','-r300');

        f = figure; plot(mean_r); xlabel('Iteration'); ylabel(loss); set(gca,'FontSize',18);
        if ~isempty(sq) title(['Step ' num2str(sq) ' Mean']);else title('Training Mean');end
        print(f,[savepath 'iter' num2str(iter) '_mean_r'],'-dpng','-r300');

        close all;

        %% PLOT H2

        f = figure; plot(best_h); xlabel('Iteration'); ylabel('H2'); set(gca,'FontSize',18);
        if ~isempty(sq) title(['Step ' num2str(sq) ' Best']);else title('Training Best');end
        print(f,[savepath 'iter' num2str(iter) '_best_h'],'-dpng','-r300');

        f = figure; plot(mean_h); xlabel('Iteration'); ylabel('H2'); set(gca,'FontSize',18);
        if ~isempty(sq) title(['Step ' num2str(sq) ' Mean']);else title('Training Mean');end
        print(f,[savepath 'iter' num2str(iter) '_mean_h'],'-dpng','-r300');

        close all;

         %% PLOT So/Sp  

        f = figure; plot(best_Sop); xlabel('Iteration'); ylabel('So/Sp'); set(gca,'FontSize',18);
        print(f,[savepath 'iter' num2str(iter) '_best_Sop'],'-dpng','-r300');

        f = figure; plot(mean_Sop); xlabel('Iteration'); ylabel('So/Sp'); set(gca,'FontSize',18);
        print(f,[savepath 'iter' num2str(iter) '_mean_Sop'],'-dpng','-r300');

        close all;


end
