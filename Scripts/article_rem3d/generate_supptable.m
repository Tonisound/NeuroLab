file1 = 'Fig2_ALL-GROUPS_QW.mat';
file2 = 'Fig2_ALL-GROUPS_AW.mat';
file3 = 'Fig3_ALL-GROUPS.mat';
test_mean = true;

% file1
data1 = load(file1);
S = data1.S;
L = data1.L;
list_regions = L.list_regions;
list_group = L.list_group;

D1 = NaN(length(list_group),length(list_regions));
D2 = NaN(length(list_group),length(list_regions));
for i =1:length(list_group)
    for j = 1:length(list_regions)
        % mean per recording
        if test_mean
            D1(i,j) = mean(S(i,j).y_mean,'omitnan');
            D2(i,j) = std(S(i,j).y_mean)/sqrt(length(S(i,j).y_mean));
        else
            % all dots
            D1(i,j) = mean(S(i,j).y_data,'omitnan');
            D2(i,j) = std(S(i,j).y_data)/sqrt(length(S(i,j).y_data));
        end
    end
end

% Save in txt file
fid = fopen(strcat(strrep(file1,'.mat',''),'.txt'),'w');
fwrite(fid,sprintf('Region \t'));
for j =1:length(list_group)
    fwrite(fid,sprintf('%s \t ', char(list_group(j))));
end
fwrite(fid,newline);
for i =1:length(list_regions)
    fwrite(fid,sprintf('%s \t ', char(list_regions(i))));
    for j =1:length(list_group)
        fwrite(fid,sprintf('%.4f+/-%.4f \t ', D1(j,i), D2(j,i)));
    end
    if i~=length(list_group)
        fwrite(fid,newline);
    end
end

% file2
data2 = load(file2);
S = data2.S;
L = data2.L;
list_regions = L.list_regions;
list_group = L.list_group;

D1 = NaN(length(list_group),length(list_regions));
D2 = NaN(length(list_group),length(list_regions));
for i =1:length(list_group)
    for j = 1:length(list_regions)
        % mean per recording
        if test_mean
            D1(i,j) = mean(S(i,j).y_mean,'omitnan');
            D2(i,j) = std(S(i,j).y_mean)/sqrt(length(S(i,j).y_mean));
        else
            % all dots
            D1(i,j) = mean(S(i,j).y_data,'omitnan');
            D2(i,j) = std(S(i,j).y_data)/sqrt(length(S(i,j).y_data));
        end
    end
end

% Save in txt file
fid = fopen(strcat(strrep(file2,'.mat',''),'.txt'),'w');
fwrite(fid,sprintf('Region \t'));
for j =1:length(list_group)
    fwrite(fid,sprintf('%s \t ', char(list_group(j))));
end
fwrite(fid,newline);
for i =1:length(list_regions)
    fwrite(fid,sprintf('%s \t ', char(list_regions(i))));
    for j =1:length(list_group)
        fwrite(fid,sprintf('%.4f+/-%.4f \t ', D1(j,i), D2(j,i)));
    end
    if i~=length(list_group)
        fwrite(fid,newline);
    end
end
fclose(fid);
%fprintf('Data Saved in txt file [%s].\n',fullfile(folder_save,strcat(f.Name,'.txt')));


% file3
data3 = load(file3);
S = data3.S;
L = data3.L;
list_regions = L.list_regions;
list_group = L.list_ref;

D1 = NaN(length(list_group),length(list_regions));
D2 = NaN(length(list_group),length(list_regions));
for i =1:length(list_group)
    for j = 1:length(list_regions)
        D1(i,j) = mean(S(i,j).r_max,'omitnan');
        D2(i,j) = std(S(i,j).r_max)/sqrt(length(S(i,j).r_max));
    end
end

% Save in txt file
fid = fopen(strcat(strrep(file3,'.mat',''),'.txt'),'w');
fwrite(fid,sprintf('Region \t'));
for j =1:length(list_group)
    fwrite(fid,sprintf('%s \t ', char(list_group(j))));
end
fwrite(fid,newline);
for i =1:length(list_regions)
    fwrite(fid,sprintf('%s \t ', char(list_regions(i))));
    for j =1:length(list_group)
        fwrite(fid,sprintf('%.4f+/-%.4f \t ', D1(j,i), D2(j,i)));
    end
    if i~=length(list_group)
        fwrite(fid,newline);
    end
end
fclose(fid);