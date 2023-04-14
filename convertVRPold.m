clear all
close all

%old vrp files contain no maxCluster colomn, causing bugs when loaded into
%FonaDyn. This script manually generates fake maxCluster and Cluster1 2 3..

file = 'F:\Classification\Generated from VRP\Male\recreated_vrp\M01\M01_classification_k=4_VRP.csv';
[names,data] = FonaDynLoadVRP(file);
[~,aColomn] = find(strcmp(names,'maxCluster'));
bColomn = length(names);
max = bColomn - aColomn;
cName = {'maxCPhon'};
for i = 1:max
    cString = ['cPhon ',num2str(i)];
    cName = [cName,cString];

end
names = [names, cName];
newVRP = [data, data(:,aColomn:bColomn)];
newFile = file(1:30);
FonaDynSaveVRP(file, names, newVRP);