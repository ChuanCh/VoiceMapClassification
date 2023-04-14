%% collect data
clear all; close all;
% kmeans++ clustering for kinderEGG

type = {'Male'; 'Female'; 'Children';'All'};
for t = 1 : length(type)
KinderEGG_dir = string(join(['E:\Classification\data\',type(t)],''));
pdf_dir = string(join(['E:\Classification\Generated from VRP\',type(t),'\Cluster by subject'], ''));
pdf_dir_k = string(join(['E:\Classification\Generated from VRP\',type(t),'\Cluster'], ''));
recreated_vrp = string(join(['E:\Classification\Generated from VRP\',type(t),'\recreated_vrp'], ''));
main_folder = string(join(['E:\Classification\Generated from VRP\',type(t)], ''));

file_dir = dir(KinderEGG_dir);
global sysFolderN 
sysFolderN = 0;
[data, indices] = extractData(file_dir, 'vrp');
data(:, [4, 11:end]) = [];
[metricsName, metricsRep, subplotNames] = decideMetrics(data, 'vrp');
vrp_mat = [];
cluster_index = [];
centroid_excel = {};
for k=2:6

    [idx, C_original, trained_data, cluster_names] = KmeansTraining(metricsRep, k, data);
    names = ['MIDI','dB','Total', 'Crest','SpecBal','CPPs','Entropy','dEGGmax',...
        'Qcontact','maxCluster', string(cluster_names)];
    
    trained_data = combineVRP(trained_data, k);
    
%     trained_data = fakeCyle(trained_data, k);
    mSymbol = FonaDynPlotVRP(trained_data, names, 'maxCluster', subplot(4,2,k-1), 'ColorBar', 'on','PlotHz', 'off', 'MinCycles', 5);
    subtitle(['k=', char(string(k))]);
    pbaspect([1.5 1 1]);
    xlabel('midi');
    ylabel('dB');
    grid on
end
% save as pdfs
pdf_file = join([main_folder, '\Union',char(type(t))], '');
set(gcf,'PaperOrientation','portrait');
set(gcf, 'PaperSize', [30, 40]);
print(gcf, pdf_file,'-dpdf','-r600', '-bestfit');
close gcf;
end

function [mean_vrp] = combineVRP(vrp_mat, k)
    mean_vrp = zeros(15000,10+k);
    vrp_mat = [vrp_mat, zeros(size(vrp_mat,1),k)];
    n = 1;
    for x = 1:100
        for y = 1:150
            pair = find(vrp_mat(:,1) == x & vrp_mat(:,2) == y);
            if ~isempty(pair)
                mean_vrp(n, 1:2) = [x,y];
                mean_vrp(n, 3) = sum(vrp_mat(pair, 3));
                mean_vrp(n, 4:9) = mean(vrp_mat(pair, 4:9), 1);
                for i = 1:length(pair)
                    addPosition = vrp_mat(pair(i), 10);
                    vrp_mat(pair, 10+addPosition) = vrp_mat(pair, 3);
                end
                mean_vrp(n, 11:end) = sum(vrp_mat(pair, 11:end), 1);
                mean_vrp(n, 10) = find(mean_vrp(n, 11:end) == max(mean_vrp(n, 11:end)),1);
                n = n+1;
            end
            
        end
    end
    
    mean_vrp(n, 11:end) = sum(vrp_mat(pair, 11:end), 1);
    mean_vrp(all(mean_vrp==0, 2),:)=[];
end


function [data, indices] = extractData(DIR, type, varargin)
%type = 'vrp' or 'log'
global sysFolderN
file_indices = [];
csv_data = [];
log_indices = [];
log_data = [];

    for i = 1:length(DIR)
        % Remove system folders.
        if(isequal(DIR(i).name,'.')||... 
           isequal(DIR(i).name,'..')||...
           isequal(DIR(i).name,'.DS_Store')||...
           ~DIR(i).isdir)
            sysFolderN = sysFolderN +1;
        end

        s = [DIR(1).folder '/' DIR(i).name '/']; 
        Folders = dir(s);
        n = 0;
            switch type
                case 'vrp'
                for iCount = 1:length(Folders)
                    % decide to use csv or log, in this case, use full_raw_VRP.csv
                    if endsWith(Folders(iCount).name, 'csv') && contains(Folders(iCount).name,'full') 
                        file_name = string(Folders(iCount).name);
                        file_path = join([s, file_name],'');
                        [~,vrp_array] = FonaDynLoadVRP(file_path);
                        %delete extreme values
%                         vrp_array = rmoutliers(vrp_array, 'mean');
                        file_index = size(vrp_array,1);
                        file_indices = [file_indices, file_index];
                        csv_data = [csv_data; vrp_array];
                    end
                end
                data = csv_data;
                indices = file_indices;

                case 'log'
                for iCount = 1:length(Folders)
                    if endsWith(Folders(iCount).name, 'aiff') && contains(Folders(iCount).name,'VRP')
                        file_name = string(Folders(iCount).name);
                        file_path = join([s, file_name],'');
                        % can add varargin here, to detect if FD is needed.
                        [logPlus] = FonaDyn230AugmentLogFile(file_path, 0);
                        %delete extreme values
                        logPlus = rmoutliers(logPlus, 'mean');
                        %如果一个文件里面有两个，把data和index合并
                        log_index = size(logPlus,1);
                        log_indices = [log_indices, log_index];
                        log_data = [log_data; logPlus];
                        if n > 0
                            log_indices(i-sysFolderN) = sum(log_indices(i-sysFolderN:end));
                            log_indices(i-sysFolderN + 1) = [];
                        end
                        n = n+1;
                    end
                end
                data = log_data;
                indices = log_indices;
            end
    end
end


function [metricsName, metricsRep, subplotNames] = decideMetrics(data, type)
    switch type
        case 'log'
            metricsName = {'Crest'; 'SB';'CPP';'CSE';'Qd';'Qc';'Clustering'};
            metricsRep = data(:,[5 6 7 9 11 12]);
            subplotNames = {'maxCluster'; 'polar'; 'Crest';'Qcontact'; 'SpecBal';'dEGGmax'; 'CPPs';'Entropy';};
        case 'vrp'
            metricsName = {'Crest'; 'SB';'CPP';'CSE';'Qd';'Qc';'Clustering'};
%             metricsName = {'Crest'; 'SB';'CPP';'Clustering'};
            metricsRep = data(:,(4:9));
%             metricsRep = data(:,(4:6));
            subplotNames = {'maxCluster'; 'polar'; 'Crest';'Qcontact'; 'SpecBal';'dEGGmax'; 'CPPs';'Entropy';};
%             subplotNames = {'maxCluster'; 'polar'; 'Crest'; 'SpecBal'; 'CPPs'};
    end
end


function [idx, C_original, trained_data, cluster_names] = KmeansTraining(metricsRep, k, data)
    %k=Integer or Array, if k = range(Array), training by different ks, then save as different filename
    % log for degg
    metricsRep(:,5) = log10(metricsRep(:,5));
    [metricsStd, PS] = mapminmax(metricsRep',0,1);
    metricsStd = metricsStd';
    [metricsStd, metricsM, metricsDev] = zscore(metricsStd);
    cluster_names = [];

    [idx, C] = kmeans(metricsStd, k, 'Display','final','OnlinePhase', 'on','Replicates', 10, 'MaxIter',100000);
    
    marks = ['bo';'r*';'m+';'g^';'yx'; 'k.'; 'w_'; 'c|' ; 'bs'; 'rd'; ];
    [trained_data, Dic] = setClustersPos(data, idx, k);
    
    for kk =1:k
        cluster_name =join(['Cluster ', string(kk)], '');
        cluster_names = [cluster_names, cluster_name];
    end
    C_original = C .* metricsDev + metricsM;
    C_original = mapminmax('reverse', C_original',PS);
    C_original = C_original';
    C_original(:,5) = 10 .^(C_original(:,5));
    C_original = C_original(Dic, :);
end

function [log_range] = fakeCyle(log_range,k)
    log_range(:, (end+1:end+k)) = zeros(size(log_range,1), k);
    for i = 1:k
        idx = find(log_range(:, 10) == i);
        log_range(idx, 10+i) = log_range(idx, 3);
    end
end

function [vrp_mat, start_point, cluster_index] = log2vrp(indices, log_metrics)
    start_point = 0;
    for j=1:length(indices)
        log_range = log_metrics(start_point+1 : start_point+indices(j),:);
        log_range(:,2:3) = round(log_range(:,2:3));
        midi = unique(log_range(:,2));
        spl = unique(log_range(:,3));
        sizeStart = size(vrp_mat,1);
        for n = 1:length(spl)
            for m = 1:length(midi)        
                a = find(log_range(:,2) == midi(m) & log_range(:,3) == spl(n));
                cluster_m = zeros(1,10+k);
                
                if ~isempty(a)
                    cluster_m(1) = midi(m);
                    cluster_m(2) = spl(n);
                    for p = 1:length(a)
                        index = log_range(a(p),35)+10;
                        cluster_m(index) = cluster_m(index) + 1;
                    end
                    cluster_m(4:9) = mean(log_range(a,[5 6 7 9 11 12]));
                    %10+k represents 10th slot in vrp file, and following k
                    %clusters.
                    maxCluster = find((cluster_m(11:10+k) == max(cluster_m(11:10+k))));
                    pos = randi(length(maxCluster));
                    cluster_m(10) = maxCluster(pos);
                    cluster_m(3) = sum(cluster_m(11:10+k));
                    vrp_mat = [vrp_mat; cluster_m];
                end
            end
        end
        sizeEnd = size(vrp_mat,1);
        cluster_index = [cluster_index, sizeEnd-sizeStart];
        start_point = start_point + indices(j);
    end
end


%set clusters color by the vertical position, so bottom cluster is always No.1
function [trained, Dic] = setClustersPos(data, idx, k)
    meanValue = [];
    trained = data;
    trained(:, end+1) = zeros(size(trained,1), 1);
    for i = 1:k
        meanValue(i) = mean(data(idx == i, 2));
    end
    [order, Dic] = sort(meanValue);
    for ii = 1:k
        for j = 1:k
            if meanValue(j) == order(ii)
                trained(idx==j, end) = ii;
            end
        end
    end
%     meanSPL = [];
%     meanF0 = [];
%     trained = data;
%     for i = 1:k
%         meanSPL(i) = mean(data(idx == i, 2));
%         meanF0(i) = mean(data(idx == i,1));
%     end
%     [order1, Dic1] = sort(meanSPL);
%     [order2, Dic2] = sort(meanF0);
%     meansquare = Dic1 .* Dic2;
%     [order, Dic] = sort(meansquare);
%     for ii = 1:k
%         for j = 1:k
%             if meansquare(j) == order(ii)
%                 trained(idx==j, 10) = ii;
%             end
%         end
%     end
end


function [axisl, axisb, axisw, axish] = getSubplotWH(n, ncols, nrows)
    axisw = (1 / ncols) * 0.95;
    axish = (1 / nrows) * 0.9;
    row = floor(n /(ncols+1) ) +1;
    col = mod(n-1, ncols) +1;
    axisl = (axisw+0.02) * (col - 1);
    axisb = (axish+0.02) * (row-1);
end