clear all;
subject = [];
accuracy = [];
for k = 2:6
    log_dir = 'E:\Classification\Generated from Logfile(base)\Male\recreated_vrp\';
    vrp_dir = 'E:\Classification\generated from VRP\Male\recreated_vrp\';
    vrp_folder = dir(vrp_dir);
    for i = 1:length(vrp_folder)
        % Remove system folders.
        if(isequal(vrp_folder(i).name,'.')||... 
           isequal(vrp_folder(i).name,'..')||...
           ~vrp_folder(i).isdir)
        continue
        end
        subject_name = vrp_folder(i).name;
        log_2_dir = fullfile(log_dir,subject_name);
        vrp_2_dir = fullfile(vrp_dir,subject_name);
        k_string = ['k=',char(string((k)))];
        log_2_folder = dir(log_2_dir);
        vrp_2_folder = dir(vrp_2_dir);
        subject = [subject; [subject_name, '_',char(string(k))]];
        for c = 1:length(log_2_folder)
            if contains(log_2_folder(c).name, k_string)
                [~, vrpArray_log] = FonaDynLoadVRP(fullfile(log_2_dir,log_2_folder(c).name));
            end
        end
        [vrpArray_log, ~] = setClustersPos(vrpArray_log, vrpArray_log(:,11), k);
        for c = 1:length(vrp_2_folder)
            if contains(vrp_2_folder(c).name, k_string)
                [~, vrpArray_vrp] = FonaDynLoadVRP(fullfile(vrp_2_dir,vrp_2_folder(c).name));
            end
        end
        [vrpArray_vrp, ~] = setClustersPos_copy(vrpArray_vrp, vrpArray_vrp(:,10), k);
        accuracy_count = 0;
        [a,b,c] = intersect(vrpArray_log(:,1:2), vrpArray_vrp(:,1:2),'rows');
        for j = 1:length(b)
            if vrpArray_log(b(j),11) == vrpArray_vrp(c(j), 10)
                accuracy_count = accuracy_count+1;
            end
        end
        accuracy = [accuracy; accuracy_count / size(a,1)];
    end
end

function [trained, Dic] = setClustersPos(data, idx, k)
    meanSPL = [];
    meanF0 = [];
    trained = data;
    for i = 1:k
        meanSPL(i) = mean(data(idx == i, 2));
        meanF0(i) = mean(data(idx == i,1));
    end
    [order1, Dic1] = sort(meanSPL);
    [order2, Dic2] = sort(meanF0);
    meansquare = Dic1 .* Dic2;
    [order, Dic] = sort(meansquare);
    for ii = 1:k
        for j = 1:k
            if meansquare(j) == order(ii)
                trained(idx==j, 11) = ii;
            end
        end
    end
end

function [trained, Dic] = setClustersPos_copy(data, idx, k)
    meanSPL = [];
    meanF0 = [];
    trained = data;
    for i = 1:k
        meanSPL(i) = mean(data(idx == i, 2));
        meanF0(i) = mean(data(idx == i,1));
    end
    [order1, Dic1] = sort(meanSPL);
    [order2, Dic2] = sort(meanF0);
    meansquare = Dic1 .* Dic2;
    [order, Dic] = sort(meansquare);
    for ii = 1:k
        for j = 1:k
            if meansquare(j) == order(ii)
                trained(idx==j, 10) = ii;
            end
        end
    end
end