function success = detect_leftright_runs(folder_name,handles,val)
% Time Group Edition

%global DIR_SAVE FILES CUR_FILE;
%folder_name = fullfile(DIR_SAVE,FILES(CUR_FILE).nlab;
success = false;

% If nargin > 2 batch processing
% val indicates callback provenance (0 : batch mode - 1 : user mode)
if nargin == 2
    val=1;
end

% Loading Time Tags
if ~exist(fullfile(folder_name,'Time_Tags.mat'),'file')
    errordlg(sprintf('Missing File Time_Tags.mat %s',folder_name));
    return;
else
    tt_data = load(fullfile(folder_name,'Time_Tags.mat'),'TimeTags','TimeTags_cell','TimeTags_images','TimeTags_strings');
end

% Loading Time Groups
if ~exist(fullfile(folder_name,'Time_Groups.mat'),'file')
    tg_data.TimeGroups_name=[];
    tg_data.TimeGroups_frames=[];
    tg_data.TimeGroups_duration=[];
    tg_data.TimeGroups_S=[];
else
    tg_data = load(fullfile(folder_name,'Time_Groups.mat'),'TimeGroups_name','TimeGroups_frames','TimeGroups_duration','TimeGroups_S');
end

% Check if existing groups
all_group_name = {'LEFT_RUNS';'RIGHT_RUNS'};

% Finding time indices
[burst_left,burst_right] = get_indices_turns(folder_name,handles);

if isempty(burst_left) && isempty(burst_left)
    warning('No left/right runs found in Burst Time Tags. [%s]',folder_name);
    return;
end

ind_left = contains({tt_data.TimeTags(:).Tag}',burst_left);
ind_right = contains({tt_data.TimeTags(:).Tag}',burst_right);
all_indices = [ind_left,ind_right];


% Filling table 2
TimeGroups_name = [];
TimeGroups_frames = [];
TimeGroups_duration = [];
TimeGroups_S = [];
for i=1:length(all_group_name)
    group_name = all_group_name(i);
    indices = find(all_indices(:,i)==1);
    
    n_frames = sum(tt_data.TimeTags_images(indices,2)+1-tt_data.TimeTags_images(indices,1));
    duration_s = sum(datenum(tt_data.TimeTags_strings(indices,2))-datenum(tt_data.TimeTags_strings(indices,1)));
    duration = datestr(duration_s,'HH:MM:SS.FFF');
    %t2_Data = {group_name,sprintf('%d',n_frames),duration};
    
    S.Name = {tt_data.TimeTags(indices).Tag}';
    S.Selected = indices;
    S.TimeTags_strings = tt_data.TimeTags_strings(indices,:);
    S.TimeTags_images = tt_data.TimeTags_images(indices,:);
    
    % Forming Time Groups elements
    if sum(strcmp(tg_data.TimeGroups_name,group_name))>0
        ind_replace = find(strcmp(tg_data.TimeGroups_name,group_name)==1);
        tg_data.TimeGroups_name(ind_replace(1)) = group_name;
        tg_data.TimeGroups_frames(ind_replace(1)) = {sprintf('%d',n_frames)};
        tg_data.TimeGroups_duration(ind_replace(1)) = {duration};
        tg_data.TimeGroups_S(ind_replace(1)) = S;
        if length(ind_replace)>1
            tg_data.TimeGroups_name(ind_replace(2:end)) = [];
            tg_data.TimeGroups_frames(ind_replace(2:end)) = [];
            tg_data.TimeGroups_duration(ind_replace(2:end)) = [];
            tg_data.TimeGroups_S(ind_replace(2:end)) = [];
        end
    else
        TimeGroups_name = [TimeGroups_name;group_name];
        TimeGroups_frames = [TimeGroups_frames;{sprintf('%d',n_frames)}];
        TimeGroups_duration = [TimeGroups_duration;{duration}];
        TimeGroups_S = [TimeGroups_S;S];
    end
end


% Adding to existing group
TimeGroups_name = [tg_data.TimeGroups_name;TimeGroups_name];
TimeGroups_frames = [tg_data.TimeGroups_frames;TimeGroups_frames];
TimeGroups_duration = [tg_data.TimeGroups_duration;TimeGroups_duration];
TimeGroups_S = [tg_data.TimeGroups_S;TimeGroups_S];

% Saving
save(fullfile(folder_name,'Time_Groups.mat'),'TimeGroups_name','TimeGroups_frames','TimeGroups_duration','TimeGroups_S');
fprintf('Left (%02d) /Right (%02d) runs successfully detected [%s].\n',sum(ind_left),sum(ind_right),folder_name);
fprintf('===> Saved at %s.mat\n',fullfile(folder_name,'Time_Groups.mat'));

success = true;

end

function [burst_left,burst_right] = get_indices_turns(folder_name,myhandles)

%global DIR_SAVE FILES CUR_FILE LAST_IM;
%folder_name = fullfile(DIR_SAVE,FILES(CUR_FILE).nlab;
burst_left = [];
burst_right = [];

% Loading Episodes
if exist(fullfile(folder_name,'Spikoscope_Episodes.mat'),'file')
    data_e = load(fullfile(folder_name,'Spikoscope_Episodes.mat'));
else
    return;
end
% Loading Time Tags
if exist(fullfile(folder_name,'Time_Tags.mat'),'file')
    data_t = load(fullfile(folder_name,'Time_Tags.mat'),'TimeTags_strings','TimeTags');
else
    return;
end

% lines name
l  = findobj(myhandles.RightAxes,'Tag','Trace_Cerep');
l_name = [];
for i = 1:length(l)
    l_name = [l_name; {l(i).UserData.Name}];
end
% lines
ind_x = contains(l_name,'X(m)');
l_x = l(ind_x);
ind_y = contains(l_name,'Y(m)');
l_y = l(ind_y);
ind_s = contains(l_name,'SPEED');
l_s = l(ind_s);

if isempty([l_x;l_y;l_s])
    return;
end

% checking that l_x greater than l_y
if mean(l_y.YData,'omitnan')>mean(l_x.YData,'omitnan')
    l_temp = l_x;
    l_x = l_y;
    l_y = l_temp;
end
% Length corrections
if length(l_x.UserData.X)~=length(l_x.UserData.Y)
    lmin = min(length(l_x.UserData.X),length(l_x.UserData.Y));
    l_x.UserData.X =l_x.UserData.X(1:lmin);
    l_x.UserData.Y =l_x.UserData.Y(1:lmin);
end
if length(l_y.UserData.X)~=length(l_y.UserData.Y)
    lmin = min(length(l_y.UserData.X),length(l_y.UserData.Y));
    l_y.UserData.X =l_y.UserData.X(1:lmin);
    l_y.UserData.Y =l_y.UserData.Y(1:lmin);
end
if length(l_s.UserData.X)~=length(l_s.UserData.Y)
    lmin = min(length(l_s.UserData.X),length(l_s.UserData.Y));
    l_s.UserData.X =l_s.UserData.X(1:lmin);
    l_s.UserData.Y =l_s.UserData.Y(1:lmin);
end

% left/right turns
all_episodes = {data_e.episodes(:).shortname}';
%episode_name1 = 'AfterA_(s)';
episode_name1 = 'Cross level_(s)';
ind_episode = find(strcmp(all_episodes,episode_name1)==1);
if isempty(ind_episode)
    return;
elseif length(ind_episode)>1
    ind_episode=ind_episode(1);
end
episode1 = data_e.episodes(ind_episode);

% Time Tags
% restricting data_t to fUS-Burst
ind_keep = contains({data_t.TimeTags(:).Tag}','Burst');
data_t.TimeTags_strings = data_t.TimeTags_strings(ind_keep,:);
data_t.TimeTags = data_t.TimeTags(ind_keep);
%burst_name = cell(size(data_t.TimeTags));

temp = datenum(data_t.TimeTags_strings(:,1));
tts_1 = (temp-floor(temp))*24*3600;
temp = datenum(data_t.TimeTags_strings(:,2));
tts_2 = (temp-floor(temp))*24*3600;

flag_burst = false(size(episode1.Y));
all_turns = cell(size(episode1.Y));
for i =1:length(episode1.Y)
    
    % Checking l_x.UserData slope
    t_e1 = episode1.Y(i);
    [~,ind_e1] = min((l_x.UserData.X-(t_e1-2)).^2);
    [~,ind_e2] = min((l_x.UserData.X-(t_e1+2)).^2);
    if sum(diff(l_x.UserData.Y(ind_e1:ind_e2)))>0
        turn = {'left'};
    else
        turn = {'right'};
    end
    all_turns(i) = {turn};
    
    % Finding corresponding burst
    ind_burst = find(((tts_1-t_e1).*(tts_2-t_e1))<=0);
    if ~isempty(ind_burst)
        flag_burst(i) = true;
        %num_burst
        if strcmp(turn,'left')
            burst_left = [burst_left;{data_t.TimeTags(ind_burst(1)).Tag}];
        else
            burst_right = [burst_right;{data_t.TimeTags(ind_burst(1)).Tag}];
        end
    end
end

end