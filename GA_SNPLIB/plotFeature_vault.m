function plotFeature_vault(space, idx_dir, score, savepath, fname, txt)
if ~exist(savepath,'dir'), mkdir(savepath); end

load('/DATASERVER/MIC/GENERAL/STAFF/myuan0/projects/OptimizePhenotyping/OptimizeSNPlibHeritability/DATA/PHENO_GRM/UKB/TemplateVaultUKB.mat');
Template = refscan;

factor = 1;
sx = 5; sy = 3;
n = size(Template.Vertices,1);
m = inf; M = -inf;

obj = clone(space.RefScan); obj.Material = 'Dull';
if ~isempty(score), tmp = sign(score)*3*idx_dir'.*space.EigStd;
else tmp = 3*idx_dir'.*space.EigStd; end
obj.Vertices = space.AvgVertices + Vec2Struc(space,space.EigVec*tmp);
val = vNormalDistances(obj,clone(space.RefScan));

%%
obj = Template.clone;
obj.Vertices = space.AvgVertices - Vec2Struc(space,space.EigVec*tmp);
obj.Vertices = obj.Vertices*roty(90);
obj.ViewMode = 'Solid';obj.Material = 'Dull';obj.SingleColor = [0.8 0.8 0.8];
v = viewer(obj);

obj = Template.clone;
obj.Vertices = space.AvgVertices + Vec2Struc(space,space.EigVec*tmp);
obj.Vertices = obj.Vertices*roty(90);
obj.Vertices(:,2) = obj.Vertices(:,2) - ones(n,1)*(1*sy);
obj.ViewMode = 'Solid';obj.Material = 'Dull';obj.SingleColor = [0.8 0.8 0.8];
v = viewer(obj, v);

obj = Template.clone;
obj.Vertices = space.Average.Vertices;
obj.Vertices = obj.Vertices*roty(90);
obj.Vertices(:,2) = obj.Vertices(:,2) - ones(n,1)*(2*sy);
obj.VertexValue = factor * val;
obj.ViewMode = 'Solid';obj.Material = 'Dull';obj.ColorMode = 'Indexed'; 
v = viewer(obj, v);

% view from side
obj = Template.clone;
obj.Vertices = space.AvgVertices - Vec2Struc(space,space.EigVec*tmp);
obj.Vertices(:,1) = obj.Vertices(:,1) - ones(n,1)*(1*sx);
obj.Vertices = obj.Vertices*rotx(-90);
obj.ViewMode = 'Solid';obj.Material = 'Dull';obj.SingleColor = [0.8 0.8 0.8];
v = viewer(obj, v);

obj = Template.clone;
obj.Vertices = space.AvgVertices + Vec2Struc(space,space.EigVec*tmp);
obj.Vertices(:,1) = obj.Vertices(:,1) - ones(n,1)*(1*sx);
obj.Vertices(:,3) = obj.Vertices(:,3) + ones(n,1)*(1*sy);
obj.Vertices = obj.Vertices*rotx(-90);
obj.ViewMode = 'Solid';obj.Material = 'Dull';obj.SingleColor = [0.8 0.8 0.8];
v = viewer(obj, v);

obj = Template.clone;
obj.Vertices = space.Average.Vertices;
obj.Vertices(:,1) = obj.Vertices(:,1) - ones(n,1)*(1*sx);
obj.Vertices(:,3) = obj.Vertices(:,3) + ones(n,1)*(2*sy);
obj.Vertices = obj.Vertices*rotx(-90);
obj.VertexValue = factor * val;
obj.ViewMode = 'Solid';obj.Material = 'Dull';obj.ColorMode = 'Indexed'; 
v = viewer(obj, v); v.BackgroundColor = [1 1 1];
v.SceneLight.Visible = 1;v.SceneLightLinked = true;

m = min(m, min(obj.VertexValue)); M = max(M, max(obj.VertexValue));
% caxis([m, M]);
caxis([-M, M]);
v.RenderAxes.LineWidth = 0.2;
cb = colorbar(v.RenderAxes,'color',[1,1,1]);  
set(cb,'FontSize',8);
% title(['Trait Score ' num2str(abs(score)) txt]);
title(txt);
load('/usr/local/micapollo01/MIC/DATA/STAFF/myuan0/projects/Software/AIDFUNCTIONS/myToolboxes/COLORMAPS/InOutColorMap2.mat');
cmap=InOutColorMap2;colormap(gca,cmap); colorbar;
set(v.Figure,'InvertHardCopy','off'); 
% print(v.Figure,'-dpng','-r300',[savepath '/Features' fname '_Score' num2str(abs(score)) '.png']); 
print(v.Figure,'-dpng','-r300',[savepath '/Features' fname '.png']); 
% exportgraphics

close all;
end


