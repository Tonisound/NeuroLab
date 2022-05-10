function success = detect_sleep_events(folder_name,handles,val)
% Detect Sleep Events from Time_Groups.mat

success = false;
load('Preferences.mat','GImport');

% If nargin > 2 batch processing
% val indicates callback provenance (0 : batch mode - 1 : user mode)
if nargin == 2
    val = 1;
end    

% % Loading Time Reference
% if exist(fullfile(folder_name,'Time_Reference.mat'),'file')
%     data_tr = load(fullfile(folder_name,'Time_Reference.mat'));
% else
%     errordlg(sprintf('Missing Time Reference file [%s].',F.nlab));
%     return;
% end
% 
% % Loading Time Tags
% if exist(fullfile(folder_name,'Time_Tags.mat'),'file')
%     data_tt = load(fullfile(folder_name,'Time_Tags.mat'));
% else
%     warning(sprintf('Missing Time_Tags file [%s].',F.nlab));
%     data_tt = [];
% end

% Loading Time Groups
if exist(fullfile(folder_name,'Time_Groups.mat'),'file')
    data_tg = load(fullfile(folder_name,'Time_Groups.mat'));
else
    warning(sprintf('Missing Time_Groups file [%s].',F.nlab));
    data_tg = [];
end

% Finding episode names
load('Preferences.mat','GColors');
all_episodes = {GColors.TimeGroups(:).Name}';
episodes = struct('ID',{},'shortname',{},'fullname',{},'parent',{},...
    'X',{},'Y',{},'X_ind',{},'X_im',{},'Y_im',{},'nb_samples',{});

count = 0;
for i =1:length(all_episodes)
    ind_episode = find(strcmp(data_tg.TimeGroups_name,all_episodes(i))==1);
    if ~isempty(ind_episode)
        TimeGroups_S = data_tg.TimeGroups_S(ind_episode);
        n_ep = size(TimeGroups_S.TimeTags_strings,1);
        temp = datenum(TimeGroups_S.TimeTags_strings(:,1));
        tts1 = (temp-floor(temp))*24*3600;
        temp = datenum(TimeGroups_S.TimeTags_strings(:,2));
        tts2 = (temp-floor(temp))*24*3600;
        
        count = count+1;
        episodes(count).shortname = sprintf('%s_Start(s)',char(all_episodes(i)));
        episodes(count).parent = 'TimeGroups.mat';
        episodes(count).fullname = strcat(episodes(count).parent,'/',episodes(count).shortname);
        episodes(count).X = (1:n_ep)';
        episodes(count).Y = tts1;
        episodes(count).X_ind = episodes(count).X;
        episodes(count).X_im = episodes(count).X;
        episodes(count).Y_im = episodes(count).Y;
        episodes(count).nb_samples = n_ep;
        
        count = count+1;
        episodes(count).shortname = sprintf('%s_End(s)',char(all_episodes(i)));
        episodes(count).parent = 'TimeGroups.mat';
        episodes(count).fullname = strcat(episodes(count).parent,'/',episodes(count).shortname);
        episodes(count).X = (1:n_ep)';
        episodes(count).Y = tts2;
        episodes(count).X_ind = episodes(count).X;
        episodes(count).X_im = episodes(count).X;
        episodes(count).Y_im = episodes(count).Y;
        episodes(count).nb_samples = n_ep;
    end
end

% Save NeuroLab_Episodes.mat
fprintf('===> Sleep Events saved at %s.mat\n',fullfile(folder_name,'NeuroLab_Episodes.mat'));
save(fullfile(folder_name,'NeuroLab_Episodes.mat'),'episodes','-v7.3');

% Updating success
success = true;

end


function okButton_callback(~,~,handles)

f = handles.LocomotionFigure;
folder_name = f.UserData.folder_name;
all_trials = handles.Table1.UserData.all_trials;
all_ab = handles.Table1.UserData.all_ab;
all_cross = handles.Table1.UserData.all_cross;
n_ep = length(all_cross);
X_speed =  handles.Table1.UserData.X_speed;

if isempty(handles.Table1.Data)
    warning('No Locomotion events to save. [%s]',f.UserData.folder_name);
    close(f);
    return;
end

threshold_speed = str2double(handles.Edit1.String);
min_path = str2double(handles.Edit2.String);
max_duration = str2double(handles.Edit3.String);
save(fullfile(folder_name,'LocomotionInfo.mat'),...
    'threshold_speed','min_path','max_duration','-v7.3');
fprintf('===> Locomotion Information saved at %s.mat\n',fullfile(folder_name,'LocomotionInfo.mat'));



end