%% test of polar plotting of cluster centroids
% Here: six metrics and angles (Crest is set to 0.5)

theta = [((0:1:6)/6)*2*pi] ;
angles = 0:60:360;

% data = [ CPP, SB, Qci, CSE, Qdelta, Crest, CPP ];
centroids  = [ 0.23 0.27 0.48 0.43 0.38 0.50 0.23 ;
               0.18 0.39 0.48 0.49 0.82 0.50 0.18 ;
               0.38 0.33 0.40 0.10 0.70 0.50 0.38 ;
               0.29 0.67 0.46 0.38 0.41 0.50 0.29 ;
               0.50 0.62 0.43 0.05 0.82 0.50 0.50 ];

colors = colormapFD(size(centroids, 1), 0.7); 
figure
pax = polaraxes; 
polaraxes(pax); 
for i = 1 : size(centroids, 1)
    polarplot(theta, centroids(i,:), 'LineWidth', 2, 'Color', colors(i,:));  
    hold on
end
rlim(pax, [0 1]);
pax.ThetaTick = angles;
labels = { 'CPPs', 'SB', 'Q_{ci}', 'CSE', 'Q_{\Delta}', 'Crest' };
pax.ThetaTickLabel = labels;
title 'polarcentroids.m'
    