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
    if isempty(FILES(CUR_FILE).ncf)
        return;
    else
        choice = questdlg('Do you wish to discard current LFP configuration ?',...
            'User Confirmation','OK','Cancel','Cancel');
        if ~isempty(choice) && strcmp(choice,'OK')
            FILES(CUR_FILE).ncf = [];
            save('Files.mat','FILES','-append');
            fprintf('Files.mat updated.\n');
        end
        return;
    end
end

% Open file
filename = fullfile(path,file);
fileID = fopen(filename);
channel_type = [];
channel_list = [];
channel_id = [];
ind_channel = [];
ind_channel_diff = [];
mainlfp = [];
mainacc = [];
mainemg = [];
% takes first line as header
fgetl(fileID);
while ~feof(fileID)
    hline = fgetl(fileID);
    cline = regexp(hline,'\t','split');
    c1 = strtrim(cline(1));
    c2 = strtrim(cline(2));
    c2 = strrep(c2,'_','-');
    c3 = strtrim(cline(3));
    
    % finding main channel
    if contains(char(c1),'*')
        c1 = strrep(char(c1),'*','');
        switch char(c3)
            case 'LFP'
                %mainlfp = sprintf('%03d',str2double(c1));
                mainlfp = char(c2);
            case 'ACC'
                mainacc =  char(c2);
            case 'EMG'
                mainemg = char(c2);
        end
    end
    
    % finding differential channel
    if contains(char(c1),'-')
        temp = regexp(char(c1),'-','split');
        c1a = temp(1);
        c1b = temp(2);
    else
        c1a = char(c1);
        c1b = '';
    end
    
    % ind_channel = [ind_channel;str2double(char(c1))];
    ind_channel = [ind_channel;str2double(char(c1a))];
    ind_channel_diff = [ind_channel_diff;str2double(char(c1b))];
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
    'ind_channel','ind_channel_diff','channel_id','channel_list','channel_type');
fprintf('===> Channel Configuration saved at %s.\n',fullfile(folder_name,'Nconfig.mat'));

% Saving LFP EMG main channel
data_config = load(fullfile(folder_name,'Config.mat'));
File = data_config.File;
File.mainlfp = mainlfp;
File.mainemg = mainemg;
File.mainacc = mainacc;
FILES(CUR_FILE)=File;
save(fullfile(folder_name,'Config.mat'),'File','-append');
fprintf('Config.mat file updated [%s].\n',fullfile(folder_name,'Config.mat'));

success = true;

end