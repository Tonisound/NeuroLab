function success = generate_time_groups(savedir,handles,val)
% Update Time Groups from Time Tags

success = false;
%global FILES CUR_FILE;

% If nargin > 2 batch processing
% val indicates callback provenance (0 : batch mode - 1 : user mode)
if nargin == 2
    val=1;
end

% %Loading Time Ref
% if exist(fullfile(savedir,'Time_Reference.mat'),'file')
%     load(fullfile(savedir,'Time_Reference.mat'),'time_ref');
% else
%     errordlg('File Time_Reference.mat not found.');
%     return;
% end

% Loading Time Groups
if ~exist(fullfile(savedir,'Time_Groups.mat'),'file')
    errordlg('File Time_Groups.mat not found.');
    return;
else
    tg_data = load(fullfile(savedir,'Time_Groups.mat'),'TimeGroups_name','TimeGroups_frames','TimeGroups_duration','TimeGroups_S');
end

% Loading Time Tags
if ~exist(fullfile(savedir,'Time_Tags.mat'),'file')
    tt_data = [];
else
    tt_data = load(fullfile(savedir,'Time_Tags.mat'),...
        'TimeTags','TimeTags_cell','TimeTags_images','TimeTags_strings');
end

% Loading Preferences.mat
load('Preferences.mat','GColors');
ind_keep = false(length(GColors.TimeGroups),1);
for i=1:length(GColors.TimeGroups)
    if GColors.TimeGroups(i).Checked
        ind_keep(i)=true;
    end
end
tg_modified = GColors.TimeGroups(ind_keep);
if isempty(tg_modified)
    fprintf('No checked time groups in Preferences Menu.\n')
    return;
end

% Removing Time groups from tg_data
ind_remove = false(size(tg_data.TimeGroups_name,1),1);
for i = 1:length(tg_modified)
    if ~isempty(strcmp(tg_data.TimeGroups_name,tg_modified(i).Name))
        ind_remove(strcmp(tg_data.TimeGroups_name,tg_modified(i).Name)) = true;
    end
end
list_removed = tg_data.TimeGroups_name(ind_remove);
tg_data.TimeGroups_name = tg_data.TimeGroups_name(~ind_remove);
tg_data.TimeGroups_frames = tg_data.TimeGroups_frames(~ind_remove);
tg_data.TimeGroups_duration = tg_data.TimeGroups_duration(~ind_remove);
tg_data.TimeGroups_S = tg_data.TimeGroups_S(~ind_remove);


% Building from TimeTags
all_names = {tg_modified(:).Name}';
all_strings = {tg_modified(:).String}';
all_tags = {tt_data.TimeTags(:).Tag}';

TimeGroups_name = [];
TimeGroups_frames = [];
TimeGroups_duration = [];
TimeGroups_S = [];

for i=1:size(all_names,1)
    %indices = find(contains(all_tags,all_strings(i))==1);
    indices = find(startsWith(all_tags,all_strings(i))==1);
    if isempty(indices)
        continue;
    end
    group_name = all_names(i);
    n_frames = sum(tt_data.TimeTags_images(indices,2)+1-tt_data.TimeTags_images(indices,1));
    duration_s = sum(datenum(tt_data.TimeTags_strings(indices,2))-datenum(tt_data.TimeTags_strings(indices,1)));
    duration = datestr(duration_s,'HH:MM:SS.FFF');
    % Struct S
    S.Name = {tt_data.TimeTags(indices).Tag}';
    S.Selected = indices;
    S.TimeTags_strings = tt_data.TimeTags_strings(indices,:);
    S.TimeTags_images = tt_data.TimeTags_images(indices,:);
    
    % Building objects
    TimeGroups_name = [TimeGroups_name;group_name];
    TimeGroups_frames = [TimeGroups_frames;{sprintf('%d',n_frames)}];
    TimeGroups_duration = [TimeGroups_duration;{duration}];
    TimeGroups_S = [TimeGroups_S;S];  
end

% Concatenate & save
list_added = TimeGroups_name;
TimeGroups_name = [tg_data.TimeGroups_name;TimeGroups_name];
TimeGroups_frames = [tg_data.TimeGroups_frames;TimeGroups_frames];
TimeGroups_duration = [tg_data.TimeGroups_duration;TimeGroups_duration];
TimeGroups_S = [tg_data.TimeGroups_S;TimeGroups_S];

if ~isempty(list_removed)
    fprintf('Time Groups Removed: [');
    for i =1:length(list_removed)-1
        fprintf('%s - ',char(list_removed(i)));
    end
    fprintf('%s].\n',char(list_removed(end)));
end
if ~isempty(list_added)
    fprintf('Time Groups Added: [');
    for i =1:length(list_added)-1
        fprintf('%s - ',char(list_added(i)));
    end
    fprintf('%s].\n',char(list_added(end)));
end
save(fullfile(savedir,'Time_Groups.mat'),'TimeGroups_name','TimeGroups_frames','TimeGroups_duration','TimeGroups_S');
fprintf('===> Saved at %s.mat\n',fullfile(savedir,'Time_Groups.mat'));

success = true;

end