function [H2,R2,So,Sp,So_Sp,pval] = regH2(dataC,dataP,idx)
% Regression to estimate heritability 

% OUTPUT
% - R2 = percentage variance explained 
% - h2 = heritability ifv #PLS components

% INPUT
% dataC = PCA scores child
% dataP = PCA scores parent
% idx = index module

% dataC = FacePCs_C; 
% dataP = FacePCs_F; 

Xo = dataC(:,idx);
Xp = dataP(:,idx);

stats = regstats(Xo,Xp,'linear');
R2 = stats.rsquare;
pval = stats.tstat.pval(2);

% lm = fitlm(Xp,Xo);
% R2 = lm.Rsquared.Ordinary;
% pval = lm.Coefficients.pValue(2);

if R2<0, R2=0;end  % minimize r

Xomean = mean(Xo);
Xpmean = mean(Xp);
So = sum((pdist2(Xo,Xomean,'euclidean')).^2);
Sp = sum((pdist2(Xp,Xpmean,'euclidean')).^2);
So_Sp = sqrt(So/Sp);
Bop = sqrt(R2)*So_Sp;
H2 = Bop*2;




end
