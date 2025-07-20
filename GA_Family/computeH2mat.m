function [h,r,So,Sp,So_Sp] = computeH2mat(trait,n_per_colony,idx_c,idx_f)

h = nan(n_per_colony,1);
r = nan(n_per_colony,1);
So = nan(n_per_colony,1);
Sp = nan(n_per_colony,1);
So_Sp = nan(n_per_colony,1);

parfor j=1:n_per_colony
        [h(j),r(j),So(j),Sp(j),So_Sp(j),~] = regH2(trait(idx_c,:), trait(idx_f,:),j);
end

end
