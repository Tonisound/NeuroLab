function import_lfpconfig(folder_name,handles)
% Load LFP Configuration from NConfig

global SEED_CONFIG FILES CUR_FILE

% Pick file
filter = {'*.txt'};
title = 'Choose NConfig file';
defname = SEED_CONFIG;
[file,path]  = uigetfile(filter,title,defname);

if isempty(file)
    return;
end

% Open file
filename = fullfile(path,file);

fileID = fopen(filename);
channel_type = [];
channel_list = [];
channel_id = [];
ind_channel = [];
while ~feof(fileID)
    hline = fgetl(fileID);
    cline = regexp(hline,'\t','split');
    c1 = strtrim(cline(1));
    c2 = strtrim(cline(2));
    channel_id = [channel_id;c1];
    channel_type = [channel_type;c2];
    ind_channel = [ind_channel;eval(char(c1))];
    channel_list = [channel_list;{sprintf('%s/%03d',char(c2),eval(char(c1)))}];
end
fclose(fileID);

%Saving config file
FILES(CUR_FILE).ncf = file;
save('Files.mat','FILES','-append');
fprintf('Files.mat updated.\n');
save(fullfile(folder_name,'Nconfig.mat'),...
    'ind_channel','channel_id','channel_list','channel_type');
fprintf('===> Channel Configuration saved at %s.\n',fullfile(folder_name,'Nconfig.mat'));

end