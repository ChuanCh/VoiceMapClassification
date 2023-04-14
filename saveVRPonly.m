%% collect data
clear all; close all;
% kmeans++ clustering for kinderEGG

type = {'Male'; 'Female'; 'Children'; 'All'};
for t = 4 : length(type)
KinderEGG_dir = string(join(['E:\Classification\data\',type(t)],''));
% KinderEGG_dir = 'C:\Users\admin\Desktop\Classification\data\Male';
pdf_dir = string(join(['E:\Classification\generated from VRP\',type(t),'\Clustering plot'], ''));
recreated_vrp = string(join(['E:\Classification\generated from VRP\',type(t),'\recreated_vrp'], ''));
% recreated_log = string(join(['C:\Users\admin\Desktop\Classification\test',type(t),'\recreated_log'], ''));
subject_vrp = string(join(['E:\Classification\generated from VRP\',type(t),'\Clustering by subject'], ''));
main_folder = string(join(['E:\Classification\generated from VRP\',type(t)], ''));
% 
file_dir = dir(KinderEGG_dir);
global sysFolderN 
sysFolderN = 0;
[data, indices] = extractData(file_dir, 'vrp');
data(:, [4, 11:end]) = [];

[metricsName, metricsRep, subplotNames] = decideMetrics(data, 'vrp');

vrp_mat = [];
cluster_index = [];
centroid_excel = [];
BIC_temp = 1;
BIC = [];
for k=2:6
[idx, C_original, trained_data, cluster_names] = KmeansTraining(metricsRep, k, data);
names = ['MIDI','dB','Total', 'Crest','SpecBal','CPPs','Entropy','dEGGmax',...
    'Qcontact','maxCluster', string(cluster_names)];
trained_data(:, 3) = 100;

end
% log_start = 1;
% for ind = 1:length(indices)
%     new_log = trained_data(log_start:indices(ind), :);
%     new_log_name = [file_dir(ind+sysFolderN).name, '_classification_VRP_Log.aiff'];
%     new_log_dir = fullfile(KinderEGG_dir, file_dir(ind+sysFolderN).name, new_log_name);
%     audiowrite(new_log_dir, new_log, 44100);
%     log_start = log_start + indices(ind);
% end

% [trained_data, cluster_index] = log2vrp(indices, trained_data, k);

%% dfs
start_point = 0;
for j=1:length(indices)
%     f = figure;
%     f.Position = [10 10 800 1800];
%     tiledlayout(4,2, 'Padding', 'none', 'TileSpacing', 'compact');
    log_range = trained_data(start_point+1 : start_point+indices(j),:);
%     log_range = fakeCyle(log_range, k);
%     for s = 1:8
%         if s == 2
%             theta = ((0:1:6)/6)*2*pi;
%             angles = 0:60:360;
%             marks = ['o';'*';'+';'^';'x';'d';'.'; '_'; '^';'v';'o'];
%             centroids = C_original;
%             %find value max in original data\
% 
%             for c = 1:size(centroids,2)
%                 colomnMax = max(centroids(:,c));
%                 colomnMin = min(centroids(:,c));
%                 centroids(:,c) = (centroids(:,c)-colomnMin)./(colomnMax-colomnMin);
%             end
%             centroids = [centroids, centroids(:,1)];
%             rMax = max(max(centroids));
%             colors = getColorFriendly(size(centroids, 1)); 
%             subplot(4,2,2);
%             labels = {'Crest'; 'SB'; 'CPP'; 'CSE'; 'Q_{\Delta}'; 'Q_{ci}'};
% %             labels = {'CSE'; 'Q_{\Delta}'; 'Q_{ci}'};
%             for L = 1:size(labels)
%                 labels{L} = join([string(labels(L)) ':' roundn(min(C_original(:, L)), -2) '~' roundn(max(C_original(:, L)), -2)], '');
%             end
%         %     pax = polaraxes; 
%         %     polaraxes(pax); 
%             for i = 1 : size(centroids, 1)
%                 polarplot(theta, centroids(i,:), 'LineWidth', 2, 'Color', colors(i,:), 'Marker', marks(i));  
%                 ax = gca;
%                 ax.ThetaTick = angles;
%                 ax.ThetaTickLabel = labels;
%                 hold on
%             end
%             rlim([-0.1 rMax]);
%             title 'Centroid Polar'
%         else
%             mSymbol = FonaDynPlotVRP(log_range, names, string(subplotNames(s)), subplot(4,2,s), 'ColorBar', 'on','PlotHz', 'on', 'MinCycles', 5);  
%             pbaspect([1.5 1 1]);
%             xlabel('Hz');
%             ylabel('dB');
%             grid on
%             if isequal(string(subplotNames(s)) ,'maxCluster')
%                 subtitle('Phonation Clusters');
%             else
%                 subtitle(string(subplotNames(s)));
%             end
%         end
%     end
    
    vrp_dir = fullfile(recreated_vrp, file_dir(j+sysFolderN).name);
    if ~exist(vrp_dir, 'dir')
        mkdir (vrp_dir)
    end
    
    
    vrp_file = join([vrp_dir, '\', file_dir(j+sysFolderN).name, '_classification_k=', string(k), '_VRP.csv'], '');
    %save generated VRP
    FonaDynSaveVRP(vrp_file, names, log_range);
       
    sgtitle(file_dir(j+sysFolderN).name);
    start_point = start_point + indices(j);
    
    pdf_file = join([pdf_dir, '\',file_dir(j+sysFolderN).name, '_vrp_k=', string(k)],'');
    pdf_dir_s = join([subject_vrp,'\',file_dir(j+sysFolderN).name], '');
    if ~exist(pdf_dir_s, 'dir')
        mkdir(pdf_dir_s)
    end
    pdf_file_s = join([pdf_dir_s, '\',file_dir(j+sysFolderN).name, '_vrp_k=', string(k)],'');
%     set(gcf,'PaperOrientation','portrait');
%     set(gcf, 'PaperSize', [30, 40]);
%     
    
    % save pdf
%     print(gcf, pdf_file_s,'-dpdf','-r600', '-bestfit');
    close gcf;
end
centroid_excel = [centroid_excel; C_original; nan, nan, nan, nan,nan,nan];
centroid_file = join([main_folder, '\centroids.csv'], '');
writematrix(centroid_excel, centroid_file);
end


%% plot the whole vrp
% mean_vrp = zeros(15000,15);
% for x = 1:100
%     for y = 1:150
%         pair = find(vrp_mat(:,1) == x & vrp_mat(:,2) == y);
%         if ~isempty(pair)
%             mean_vrp(n, 1:2) = [x,y];
%             mean_vrp(n, 3) = sum(vrp_mat(pair, 11:15), 'all');
%             mean_vrp(n, 4:9) = mean(vrp_mat(pair, 4:9), 1);
%             mean_vrp(n, 11:end) = sum(vrp_mat(pair, 11:15), 1);
%             mean_vrp(n, 10) = find(mean_vrp(n, 11:end) == max(mean_vrp(n, 11:end)),1);
%             n = n+1;
%         end
%     end
% end
% mean_vrp(all(mean_vrp==0,2),:)=[];
% names = {'MIDI','dB','Total', 'Crest','SpecBal','CPPs','Entropy','dEGGmax',...
%     'Qcontact','maxCluster','Cluster 1','Cluster 2','Cluster 3','Cluster 4','Cluster 5'};
% mSymbol = FonaDynPlotVRP(mean_vrp, names, 'maxCluster', figure, 'Range', [29, 90, 28, 120], 'ColorBar', 'on','PlotHz', 'on');  
% %     title(text);
% xlabel('Hz');
% ylabel('dB');
% grid on
% subtitle('Average VRP');
% 
% % save as pdfs
% pdf_file = join([pdf_dir, '/','AverageVRP']);
% print(gcf, pdf_file,'-dpdf','-r600');
% close gcf;    


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
%             metricsName = {'CSE';'Qd';'Qc';'Clustering'};
%             metricsRep = data(:,(4:9));
            metricsRep = data(:,(4:9));
            subplotNames = {'maxCluster'; 'polar'; 'Crest';'Qcontact'; 'SpecBal';'dEGGmax'; 'CPPs';'Entropy';};
%             subplotNames = {'maxCluster'; 'polar'; 'Qcontact'; 'dEGGmax';'Entropy'};
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

    [idx, C] = kmeans(metricsStd, k, 'Display','final','OnlinePhase', 'on','Replicates', 50, 'MaxIter',100000);
%     [idx, C] = kmedoids(metricsStd, k);
    
    marks = ['bo';'r*';'m+';'g^';'yx'; 'k.'; 'w_'; 'c|' ; 'bs'; 'rd'; ];
    [trained_data, Dic] = setClustersPos(data, idx, k);
    
    for kk =1:k
        cluster_name =join(['Cluster ', string(kk)], '');
        cluster_names = [cluster_names, cluster_name];
    end
    C_original = C .* metricsDev + metricsM;
    C_original = mapminmax('reverse', C_original',PS);
    C_original = C_original';
%     C_original(:,5) = 10 .^(C_original(:,5));
    C_original = C_original(Dic, :);
end

function [idx, C_original, trained_data, cluster_names] = FuzzyCmeans(metricsRep, k, data)
    %k=Integer or Array, if k = range(Array), training by different ks, then save as different filename
    % log for degg
%     metricsRep(:,5) = log10(metricsRep(:,5));
    [metricsStd, PS] = mapminmax(metricsRep',0,1);
    metricsStd = metricsStd';
    [metricsStd, metricsM, metricsDev] = zscore(metricsStd);
    cluster_names = [];
    idx = [];
    [C, U] = fcm(metricsStd, k);
    U = U';
    for i = 1:size(U,1)
        idx(i) = find(U(i, :) == max(U(i, :)));
    end
    idx = idx';
    idx = [idx, U];
    [trained_data, Dic] = setClustersPos(data, idx, k);
    
    for kk =1:k
        cluster_name =join(['Cluster ', string(kk)], '');
        cluster_names = [cluster_names, cluster_name];
    end
    C_original = C .* metricsDev + metricsM;
    C_original = mapminmax('reverse', C_original',PS);
    C_original = C_original';
%     C_original(:,5) = 10 .^(C_original(:,5));
    C_original = C_original(Dic, :);
end


function [log_range] = fakeCyle(log_range,k)
    log_range(:, (end+1:end+k)) = zeros(size(log_range,1), k);
    for i = 1:k
        idx = find(log_range(:, 10) == i);
        log_range(idx, 10+i) = log_range(idx, 3);
    end
end

function [vrp_mat, cluster_index] = log2vrp(indices, log_metrics, k)
    start_point = 0;
    vrp_mat = [];
    cluster_index = [];
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
% function [trained, Dic] = setClustersPos(data, idx, k)
%     meanValue = [];
%     trained = data;
%     indice = idx(:,1);
%     cluster = idx(:, 2:end);
%     new = [];
% %     trained(:, end+1) = zeros(size(trained,1), 1);
%     for i = 1:k
%         meanValue(i) = mean(data(indice == i, 2));
%     end
%     [meanValue_sorted, Dic] = sort(meanValue);
%     for d = 1:length(Dic)
%         new(:,d) = cluster(:,Dic(d));
%     end
%     
%     for i = 1:size(new,1)
%         indice(i) = find(new(i, :) == max(new(i, :)));
%     end
%     new = round(new * 100);
%     trained = [trained, indice, new];
% %     for ii = 1:k
% %         for j = 1:k
% %             if meanValue(j) == meanValue_sorted(ii)
% %                 idx(indice ==j, end) = ii;
% %             end
% %         end
% %     end
% end

function [log_metrics, Dic] = setClustersPos(data, idx, k)
    meanValue = [];
    log_metrics = data;
    log_metrics(:, end+1) = zeros(size(log_metrics,1), 1);
    for ii = 1:k
        meanValue(ii) = mean(data(idx == ii, 3));
    end
    [order, Dic] = sort(meanValue);
    for iii = 1:k
        for jj = 1:k
            if meanValue(jj) == order(iii)
                log_metrics(idx==jj, end) = iii;
            end
        end
    end
end

function [axisl, axisb, axisw, axish] = getSubplotWH(n, ncols, nrows)
    axisw = (1 / ncols) * 0.95;
    axish = (1 / nrows) * 0.9;
    row = floor(n /(ncols+1) ) +1;
    col = mod(n-1, ncols) +1;
    axisl = (axisw+0.02) * (col - 1);
    axisb = (axish+0.02) * (row-1);
end

function [Fx, Fy] = getGradient(data)
    Fx = [];
    Fy = [];
    for col = 1:6
        dx = [];
        dy = [];
        xmin = min(data(:,1));
        xmax = max(data(:,1));
        ymin = min(data(:,2));
        ymax = max(data(:,2));
        ym = data(:, 2);
        xm = data(:, 1);
        zm = data(:, col+3);
        FDATATEST=scatteredInterpolant(xm, ym, zm, 'nearest', 'none');
        dspl=1.0;  % use 1 for contours/quivers
        df0=1.0;
        [xq,yq]=meshgrid(xmin:df0:xmax, ymin:dspl:ymax);
        vq=FDATATEST(xq,yq);
        [px,py] = gradient(vq,5,5);
        for i = 1:size(data,1)
            x = data(i,1)-xmin+1;
            y = data(i,2)-ymin+1;
            if isnan(px(y,x))
                px(y,x) = 0;
            end
            if isnan(py(y,x))
                py(y,x) = 0;
            end
            dx = [dx; px(y,x)];
            dy = [dy; py(y,x)];
        end
        Fx = [Fx, dx];
        Fy = [Fy, dy];
    end
end