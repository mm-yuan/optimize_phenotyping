function saveIteration(path,iter,obs,scores,directions,best_scores,mean_scores,space)
        savepath = [path num2str(iter) filesep];
        if ~exist(savepath,'dir'), mkdir(savepath); end

        if contains(path,'FACE'),load('/usr/local/micapollo01/MIC/DATA/STAFF/myuan0/projects/Software/ImgGENESoftware/RegistrationAuxilliaryData/FacialTemplate_20171201.mat');end
        %% SAVE DATA  
        if rem(iter,50) == 0 
            save([savepath filesep 'SUMMARY'],'directions','scores','-v7.3');
        end

        %% PLOT GAUSSIAN MIXTURE
        maxval = max(scores,[],'all');
        [row,col] = find(scores == maxval,1,'first');
        best_dir = squeeze(directions(row,col,:))';
        dist = 1-pdist2(obs,best_dir,'cosine');
        idx_score = (median(dist)-mean(dist))/std(dist);
        GMM1 = fitgmdist(dist,1,'Options',statset('MaxIter',1000));
        GMM2 = fitgmdist(dist,2,'Options',statset('MaxIter',1000));
        GMM3 = fitgmdist(dist,3,'Options',statset('MaxIter',1000));
        [~,i] = min([GMM1.AIC GMM2.AIC GMM3.AIC]);
        switch i
            case 1
                GMM = GMM1;
            case 2
                GMM = GMM2;
            case 3
                GMM = GMM3;
        end
        f = figure;
        histogram(dist,50,'Normalization', 'pdf', 'EdgeColor', 'none'); hold on
        x = linspace(min(dist),max(dist),10000);
        for K = 1: GMM.NumComponents
            tmp = pdf('Normal', x, GMM.mu(K), GMM.Sigma(K)^0.5);
            plot(x,tmp*GMM.ComponentProportion(K),'LineWidth',3);
        end
        xlabel('Mahalanobis angle'); set(gca,'FontSize',18);
        print(f,[savepath 'iter' num2str(iter) '_Gaussian_Mixture_AIC_' num2str(GMM.AIC)],'-dpng','-r300');
        
        %% PLOT TRAIT
        if contains(path,'VAULT')
            plotFeature_vault(space, best_dir, idx_score, savepath, [], []);
        elseif contains(path,'FACE')
            plotFeature(Template, space, best_dir, idx_score, savepath, [], []);
        elseif contains(path,'NOSE')
            plotFeature_nose(space, best_dir, idx_score, savepath, [], []);
        end

        %% PLOT FITNESS
        if iter == 0, return; end

        f = figure; plot(best_scores); xlabel('Iteration'); ylabel('Skewness'); set(gca,'FontSize',18);
        print(f,[savepath 'iter' num2str(iter) '_best_scores'],'-dpng','-r300');

        f = figure; plot(mean_scores); xlabel('Iteration'); ylabel('Skewness'); set(gca,'FontSize',18);
        print(f,[savepath 'iter' num2str(iter) '_mean_scores'],'-dpng','-r300');
        close all

end
