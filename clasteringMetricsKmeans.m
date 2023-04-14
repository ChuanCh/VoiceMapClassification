%% collect data
clear all; close all;
% kmeans++ clustering for kinderEGG


% log_dir = 'L:\fonadyn\Huanchen\Zurich\all\021\021_W1_Log.aiff';
KinderEGG_dir = 'C:\Users\admin\Desktop\Classification\data\Male';
pdf_dir = 'C:\Users\admin\Desktop\Classification';
recreated_vrp = 'C:\Users\admin\Desktop\Classification';
% KinderEGG_dir = '/Volumes/voicelab/fonadyn/Huanchen/Zurich/CalibratedForMean';
% pdf_dir = '/Volumes/voicelab/fonadyn/Huanchen/KinderEGG/';
% log_dir = 'L:\fonadyn\Huanchen\KinderEGG\B01\190417_153225_B01_VRP1_C_Log.aiff';

% vrp_dir = 'L:\fonadyn\Huanchen\KinderEGG\data\M07\M07-full_raw_VRP.csv';

% arranged by    Crest, SB,  CPP, CSE, Qdelta, Qci
init_centroids =[0.5, 0.2, 0.2, 0.8, 0.3,    0.5; %pre-contacting
                 0.5, 0.1, 0.2, 1,   0.5,    0.3; %transition
                 0.5, 0.2, 0.5, 0.3, 0.8,    0.4; %loose
                 0.5, 0.5, 0.1, 0.8, 0.8,    0.5; %firm
                 0.5, 0.8, 0.1, 0.8, 1.1,    0.6];%hard

%put all data into one var
file_dir = dir(KinderEGG_dir);
global sysFolderN 
sysFolderN = 0;
[data, indices] = extractData(file_dir, 'vrp');




%% data and indices
% data = readmatrix('/Volumes/voicelab/fonadyn/Huanchen/KinderEGG/alldata.txt');
% indices = readmatrix('/Volumes/voicelab/fonadyn/Huanchen/KinderEGG/allindices.txt');

%% plot vrp clusterings

% metricsName = {'Crest'; 'specbal';'CPPs';'CSE';'Qd';'Qc';'Clustering'};
% metricsRep = csv_data(:,5:10);
% %resize Crest
% metricsRep(:,1) = metricsRep(:,1) / 10.0;
% %resize SB
% metricsRep(:,1) = metricsRep(:,2) / 40.0 + 1;
% %resize CPPs
% metricsRep(:,2) = metricsRep(:,3) / 20.0;
% %resize CSE
% metricsRep(:,3) = metricsRep(:,4) / 10.0;
% %resize Qdelta
% metricsRep(:,4) = log10(max(metricsRep(:,5), 1));
% % data = audioread(log_dir, 'native');
% 
% 
% % [~,ax] = plotmatrix(metrics_T); plot scatter matrix
% % for i=1:length(metricsName)
% %     ylabel(ax(i,1),metricsName(i));
% %     xlabel(ax(8,i),metricsName(i));
% % end
% % title('Scatter Matrix');
% 
% k = 5;
% m = size(metricsRep,2);
% % [idx, C] = kmeans(metricsRep,k, 'Display','final','MaxIter',10000, 'start', init_centroids);
% [idx, C] = kmeans(metricsRep,k, 'Display','final','MaxIter',10000,'Replicates',50, 'start', init_centroids);
% % [idx, C] = dbscan(metricsRep,0.1,3);
% p = 1;
% marks = ['bo';'r*';'m+';'g^';'yx'];
% csv_data(:,end+1) = idx;
% 
% names = {'MIDI','dB','Total','Clarity','Crest','SpecBal','CPPs','Entropy','dEGGmax',...
%     'Qcontact','Icontact','maxCluster','Cluster 1','Cluster 2','Cluster 3','Cluster 4','Cluster 5','Clustering'};
% start_point = 0;
% C_original = C;
% C_original(:,1) = C_original(:,1) * 10.0;
% C_original(:,2) = (C_original(:,2)-1) * 40.0;
% C_original(:,3) = C_original(:,3) * 20.0;
% C_original(:,4) = C_original(:,4) * 10.0;
% C_original(:,5) = 10 .^ C_original(:,5);
% 
% for t = 1:5
%     format bank;
%     text{t} = ['Cluster ', num2str(t),': SB = ',num2str(roundn(C_original(t,1),-2)),' CPPs = ', ...
%         num2str(roundn(C_original(t,2),-2)), ' CSE = ', num2str(roundn(C_original(t,3),-2)), ' Qd = ',...
%         num2str(roundn(C_original(t,4),-2)), ' Qc = ', num2str(roundn(C_original(t,5),-2))];
% end
% 
% for j=1:length(file_indices)
%     csv_range = csv_data(start_point+1 : start_point+file_indices(j),:);
%     mSymbol = FonaDynPlotVRP(csv_range, names, 'Clustering', figure, 'ColorBar', 'on','Mesh', 'on','PlotHz', 'on');  
% %     title(text);
%     xlabel('Hz');
%     ylabel('dB');
%     subtitle(file_dir(j+2).name);
%     start_point = start_point + file_indices(j);
%     
%     % save as pdfs
%     pdf_file = join([pdf_dir, '/',file_dir(j+2).name],'');
%     print(gcf, pdf_file,'-dpdf','-r600', '-fillpage');
%     close gcf;
% end


%% train
metricsName = {'Crest'; 'SB';'CPP';'CSE';'Qd';'Qc';'Clustering'};
metricsRep = data(:,[5 6 7 9 11 12]);
metricsRep(:,5) = log10(metricsRep(:,5));

% data might be sparse, need to recheck here.
[metricsStd, PS] = mapminmax(metricsRep',0,1);
metricsStd = metricsStd';
[metricsStd, metricsM, metricsDev] = zscore(metricsStd);
centroid_excel = {};
% metricsStd = gpuArray(metricsStd);
for k = 5:5
    cluster_names = [];
    m = size(metricsStd,2);
    % [idx, C] = kmeans(metricsStd(:, (1:3)),k, 'Display','final', 'Replicates', 30, 'MaxIter',10000000);
    [idx, C, sumd, D] = kmeans(metricsStd, k, 'Display','final','Distance', 'sqeuclidean','OnlinePhase', 'on','Replicates', 30, 'MaxIter',10000);

    % [idx, C] = kmeans(metricsStd,k, 'Display','final','MaxIter',10000);
    % [idx, C] = dbscan(metricsRep,0.1,3);

    marks = ['bo';'r*';'m+';'g^';'yx'; 'k.'; 'w_'; 'c|' ; 'bs'; 'rd'; ];
    [log_metrics, Dic] = setClustersPos(data, idx, k);

    for kk =1:k
        cluster_name =join(['Cluster ', string(kk)], '');
        cluster_names = [cluster_names, cluster_name];
    end

    names = ['MIDI','dB','Total', 'Crest','SpecBal','CPPs','Entropy','dEGGmax',...
        'Qcontact','maxCluster', string(cluster_names)];

    C_original = C .* metricsDev + metricsM;
    C_original = mapminmax('reverse', C_original',PS);
    C_original = C_original';
    C_original(:,5) = 10 .^(C_original(:,5));
    C_original = C_original(Dic, :);
    % 
    % for t = 1:5
    %     format bank;
    %     text{t} = ['Cluster ', num2str(t),': SB = ',num2str(roundn(C_original(t,1),-2)),' CPPs = ', ...
    %         num2str(roundn(C_original(t,2),-2)), ' CSE = ', num2str(roundn(C_original(t,3),-2)), ' Qd = ',...
    %         num2str(roundn(C_original(t,4),-2)), ' Qc = ', num2str(roundn(C_original(t,5),-2))];
    % end

    
    % log_start = 1;
    % for ind = 1:length(indices)
    %     new_log = log_metrics(log_start:indices(ind), :);
    %     new_log_name = [file_dir(ind+sysFolderN).name, '_class_log.csv'];
    %     new_log_dir = fullfile(KinderEGG_dir, file_dir(ind+sysFolderN).name, new_log_name);
    %     writematrix(new_log, new_log_dir);
    %     log_start = log_start + indices(ind);
    % end


    
    start_point = 0;
    vrp_mat = [];
    cluster_index = [];

    C_original = C_original(Dic, :);

%     for j=1:length(indices)
% 
%         log_range = log_metrics(start_point+1 : start_point+indices(j),:);
%         log_range(:,2:3) = round(log_range(:,2:3));
%         midi = unique(log_range(:,2));
%         spl = unique(log_range(:,3));
%         sizeStart = size(vrp_mat,1);
%         for n = 1:length(spl)
%             for m = 1:length(midi)        
%                 a = find(log_range(:,2) == midi(m) & log_range(:,3) == spl(n));
%                 cluster_m = zeros(1,10+k);
% 
%                 if ~isempty(a)
%                     cluster_m(1) = midi(m);
%                     cluster_m(2) = spl(n);
%                     for p = 1:length(a)
%                         index = log_range(a(p),35)+10;
%                         cluster_m(index) = cluster_m(index) + 1;
%                     end
%                     cluster_m(4:9) = mean(log_range(a,[5 6 7 9 11 12]));
%                     %10+k represents 10th slot in vrp file, and following k
%                     %clusters.
%                     maxCluster = find((cluster_m(11:10+k) == max(cluster_m(11:10+k))));
%                     pos = randi(length(maxCluster));
%                     cluster_m(10) = maxCluster(pos);
%                     cluster_m(3) = sum(cluster_m(11:10+k));
%                     vrp_mat = [vrp_mat; cluster_m];
% 
%                 end
%             end
%         end
%         sizeEnd = size(vrp_mat,1);
%         cluster_index = [cluster_index, sizeEnd-sizeStart];
%         start_point = start_point + indices(j);
%     end

  
    start_point = 0;
    for j=1:length(indices)
        f = figure;
        f.Position = [10 10 800 1800];
        tiledlayout(4,2, 'Padding', 'none', 'TileSpacing', 'compact');
        log_range = log_metrics(start_point+1 : start_point+indices(j),:);
        for s = 1:8
            subplotNames = {'maxCluster'; 'polar'; 'Crest';'Qcontact'; 'SpecBal';'dEGGmax'; 'CPPs';'Entropy';};
            if s == 2
                theta = [((0:1:6)/6)*2*pi];
                angles = 0:60:360;
                marks = ['o';'*';'+';'^';'x';'d';'.'; '_'; '^';'v';'o'];
                centroids = C_original;
                %find value max in original data\

                for c = 1:size(centroids,2)
                    colomnMax = max(centroids(:,c));
                    colomnMin = min(centroids(:,c));
                    centroids(:,c) = (centroids(:,c)-colomnMin)./(colomnMax-colomnMin);
                end
                centroids = [centroids, centroids(:,1)];
                rMax = max(max(centroids));
                colors = getColorFriendly(size(centroids, 1)); 
                subplot(4,2,2);
                labels = {'Crest'; 'SB'; 'CPP'; 'CSE'; 'Q_{\Delta}'; 'Q_{ci}'};
    %             labels = {'Crest', 'SpecBal', 'CPPs', 'Entropy', 'dEGGmax', 'Qcontact'};
                for L = 1:size(labels)
                    labels{L} = join([string(labels(L)) ':' roundn(min(C_original(:, L)), -2) '~' roundn(max(C_original(:, L)), -2)], '');
                end
            %     pax = polaraxes; 
            %     polaraxes(pax); 
                for i = 1 : size(centroids, 1)
                    polarplot(theta, centroids(i,:), 'LineWidth', 2, 'Color', colors(i,:), 'Marker', marks(i));  
                    ax = gca;
                    ax.ThetaTick = angles;
                    ax.ThetaTickLabel = labels;
                    hold on
                end
                rlim([-0.1 rMax]);
                title 'Centroid Polar'
            else
                mSymbol = FonaDynPlotVRP(log_range, names, string(subplotNames(s)), subplot(4,2,s), 'ColorBar', 'on','PlotHz', 'on', 'MinCycles', 5);  
                pbaspect([1.5 1 1]);
                xlabel('Hz');
                ylabel('dB');
                grid on
                if isequal(string(subplotNames(s)) ,'maxCluster')
                    subtitle('Phonation Clusters');
                else
                    subtitle(string(subplotNames(s)));
                end
            end
        end
        
        csv_dir = join([recreated_vrp, '\', file_dir(j+sysFolderN).name, '\', file_dir(j+sysFolderN).name, '-classification-k=', string(k), '.csv'], '');
        FonaDynSaveVRP(csv_dir, names, log_range);

        sgtitle(file_dir(j+sysFolderN).name);
        start_point = start_point + cluster_index(j);

        % save as pdfs
        pdf_file = join([pdf_dir, '/',file_dir(j+sysFolderN).name, '-k=', string(k)],'');
    %     set(gcf,'PaperPositionMode','Auto'); 
    %     set(gcf,'PaperPosition',[4.65,-2.32,20.38,25.65]);
        set(gcf,'PaperOrientation','portrait');
        set(gcf, 'PaperSize', [30, 40]);
        print(gcf, pdf_file,'-dpdf','-r600', '-bestfit');
        close gcf;
    end
    centroid_excel{k} = C_original;
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

%set clusters color by the vertical position, so bottom cluster is always No.1
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

function [centroids_new] = setCentroidsPos(data, centroids)
    %暂时先只管选的这六个参数，以后再改
end

function [axisl, axisb, axisw, axish] = getSubplotWH(n, ncols, nrows)
    axisw = (1 / ncols) * 0.95;
    axish = (1 / nrows) * 0.9;
    row = floor(n /(ncols+1) ) +1;
    col = mod(n-1, ncols) +1;
    axisl = (axisw+0.02) * (col - 1);
    axisb = (axish+0.02) * (row-1);
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
                        vrp_array = rmoutliers(vrp_array, 'mean');
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