function success = import_lfpconfig(folder_name,handles)
% Load LFP Configuration from NConfig

global SEED_CONFIG FILES CUR_FILE
success = false;

% Pick file
filter = {'*.txt'};
title = sprintf('[%s] Choose NConfig file',folder_name);
defname = SEED_CONFIG;
%defname = fullfile(SEED_CONFIG,'Phd-fUS-Video');
[file,path]  = uigetfile(filter,title,defname);

if isempty(file) || sum(path==0)
    choice = questdlg('Do you wish to discard current LFP configuration ?',...
        'User Confirmation','OK','Cancel','Cancel');
    if ~isempty(choice) && strcmp(choice,'OK')
        FILES(CUR_FILE).ncf = [];
        save('Files.mat','FILES','-append');
        fprintf('Files.mat updated.\n');
    end
    return;
end

% Open file
filename = fullfile(path,file);
fileID = fopen(filename);
channel_type = [];
channel_list = [];
channel_id = [];
ind_channel = [];
% takes first line as header
fgetl(fileID);
while ~feof(fileID)
    hline = fgetl(fileID);
    cline = regexp(hline,'\t','split');
    c1 = strtrim(cline(1));
    c2 = strtrim(cline(2));
    c2 = strrep(c2,'_','-');
    c3 = strtrim(cline(3));
    ind_channel = [ind_channel;eval(char(c1))];
    channel_id = [channel_id;c2];
    channel_type = [channel_type;c3];
    channel_list = [channel_list;{sprintf('%s/%s',char(c3),char(c2))}];
end
fclose(fileID);

% Update Files;mat
FILES(CUR_FILE).ncf = file;
save('Files.mat','FILES','-append');
fprintf('Files.mat updated.\n');
% Update Config.mat
data_c = load(fullfile(folder_name,'Config.mat'),'File');
File = data_c.File;
File.ncf = file;
save(fullfile(folder_name,'Config.mat'),'File','-append');
fprintf('File Config.mat appended [%s].\n',folder_name);

% Save Nconfig.mat
save(fullfile(folder_name,'Nconfig.mat'),...
    'ind_channel','channel_id','channel_list','channel_type');
fprintf('===> Channel Configuration saved at %s.\n',fullfile(folder_name,'Nconfig.mat'));

success = true;

end