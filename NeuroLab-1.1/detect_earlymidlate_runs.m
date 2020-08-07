function success = detect_earlymidlate_runs(folder_name,handles,val)
% Time Group Edition 10_FIRST 10_MID 10_LAST
% Time Tags Edition RUN_ALL 10_FIRST 10_MID 10_LAST

success = false;

% If nargin > 2 batch processing
% val indicates callback provenance (0 : batch mode - 1 : user mode)
if nargin == 2
    val=1;
end

% Loading Time Reference
if ~exist(fullfile(folder_name,'Time_Reference.mat'),'file')
    errordlg(sprintf('Missing File Time_Reference.mat [%s]',folder_name));
    return;
else
    data_tr = load(fullfile(folder_name,'Time_Reference.mat'));
end

% Loading Time Tags
if ~exist(fullfile(folder_name,'Time_Tags.mat'),'file')
    errordlg(sprintf('Missing File Time_Tags.mat [%s]',folder_name));
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
    tg_data = load(fullfile(folder_name,'Time_Groups.mat'),...
        'TimeGroups_name','TimeGroups_frames','TimeGroups_duration','TimeGroups_S');
end

% Check if existing groups
all_group_name = {'10_FIRST';'10_MID';'10_LAST'};
ind_allruns = contains({tt_data.TimeTags(:).Tag}',[{'RUN-'};{'Burst'}]);
if isempty(ind_allruns)
    warning('No Runs found in file Time_Tags.mat [%s].',folder_name);
    return;
end

% Finding relevant time tags
tts1 = datenum(tt_data.TimeTags_strings(:,1));
tts2 = datenum(tt_data.TimeTags_strings(:,2));
TimeTags_seconds = [(tts1-floor(tts1)),(tts2-floor(tts2))]*24*3600;

ind_early =(sum(TimeTags_seconds<(15*60),2)==2).*ind_allruns;
ind_mid =((sum(TimeTags_seconds>(15*60),2)==2).*(sum(TimeTags_seconds<(30*60),2)==2)).*ind_allruns;
ind_late =(sum(TimeTags_seconds>(30*60),2)==2).*ind_allruns;
all_indices = [ind_early,ind_mid,ind_late];
% t1_early = min(TimeTags_seconds(ind_early,1));
% t2_early = max(TimeTags_seconds(ind_early,2));
% t1_mid = min(TimeTags_seconds(ind_mid,1));
% t2_mid = max(TimeTags_seconds(ind_mid,2));
% t1_late = min(TimeTags_seconds(ind_late,1));
% t2_late = max(TimeTags_seconds(ind_late,2));
% all_times = [t1_early t2_early;t1_mid t2_mid;t1_late t2_late];

% Filling Time Group material 
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
fprintf('Early (%02d) - Mid (%02d) - Late (%02d) runs successfully detected [%s].\n',sum(ind_early),sum(ind_mid),sum(ind_late),folder_name);
fprintf('===> Saved at %s.mat\n',fullfile(folder_name,'Time_Groups.mat'));


% % Adding Time Tags
% % Building TimeTags from all_times
% % TimeTags_strings
% TimeTags_strings = [datestr(all_times(:,1)/(24*3600),'HH:MM:SS.FFF'),datestr(all_times(:,2)/(24*3600),'HH:MM:SS.FFF')];
% TimeTags_seconds = all_times;
% TimeTags_dur = datestr((TimeTags_seconds(:,2)-TimeTags_seconds(:,1))/(24*3600),'HH:MM:SS.FFF');
% 
% % TimeTags_cell & TimeTags
% TimeTags = struct('Episode',[],'Tag',[],'Onset',[],'Duration',[],'Reference',[]);
% TimeTags_cell = cell(4,6);
% TimeTags_cell(1,:) = {'Episode','Tag','Onset','Duration','Reference','Tokens'};
% 
% k=1;
% TimeTags_cell(1,:) = {'','RUN_ALL',char(TimeTags_strings(k,1)),char(TimeTags_dur(k,:)),char(TimeTags_strings(k,1)),''};
% TimeTags(1,1).Episode = '';
% TimeTags(1,1).Tag = 'RUN_ALL';
% TimeTags(1,1).Onset = char(TimeTags_strings(k,1));
% TimeTags(1,1).Duration = char(TimeTags_dur(k,:));
% TimeTags(1,1).Reference = char(TimeTags_strings(k,1));
% TimeTags(1,1).Tokens = '';
% 
% % TimeTags_images
% TimeTags_images = zeros(n_ep,2);
% set(handles.TimeDisplay,'String',datestr(data_tr.time_ref.Y(CUR_IM)/(24*3600),'HH:MM:SS.FFF'));
% tts = datenum(f.UserData.TimeDisplay);
% for k=1:size(TimeTags_strings,1)
%     min_time = tts1(k);
%     max_time = tts2(k);
%     [~, ind_min_time] = min(abs(tts-datenum(min_time)));
%     [~, ind_max_time] = min(abs(tts-datenum(max_time)));
%     %TimeTags_strings(k,:) = {min_time,max_time};
%     TimeTags_images(k,:) = [ind_min_time,ind_max_time];
% end
% 
% % Loading Time Tags
% if isempty(tt_data)
%     save(fullfile(folder_name,'Time_Tags.mat'),'TimeTags','TimeTags_cell','TimeTags_strings','TimeTags_images');
%     fprintf('===> Time Tags saved at %s.\n',fullfile(folder_name,'Time_Tags.mat'));
% else
%     % Overwrite        
%     all_strings = {'RUN-'};
%     temp ={tt_data.TimeTags(:).Tag}';
%     ind_keep = ~contains(temp,all_strings);
%     tt_data.TimeTags_images = tt_data.TimeTags_images(ind_keep,:);
%     tt_data.TimeTags_strings = tt_data.TimeTags_strings(ind_keep,:);
%     tt_data.TimeTags_cell = [tt_data.TimeTags_cell(1,:);tt_data.TimeTags_cell(find(ind_keep==1)+1,:)];
%     tt_data.TimeTags = tt_data.TimeTags(ind_keep);
%     
%     % Concatenate
%     TimeTags_images = [tt_data.TimeTags_images;TimeTags_images];
%     TimeTags_strings = [tt_data.TimeTags_strings;TimeTags_strings];
%     TimeTags_cell = [TimeTags_cell(1,:);tt_data.TimeTags_cell(2:end,:);TimeTags_cell(2:end,:)];
%     TimeTags = [tt_data.TimeTags;TimeTags];
%     save(fullfile(folder_name,'Time_Tags.mat'),'TimeTags','TimeTags_cell','TimeTags_strings','TimeTags_images');
%     fprintf('===> Time Tags overwritten [%s].\n',fullfile(folder_name,'Time_Tags.mat'));  
% end

success = true;

end
