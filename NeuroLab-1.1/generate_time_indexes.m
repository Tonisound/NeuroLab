function success = generate_time_indexes(savedir,handles,val)
% Generate Time indexes from Time Tags
% Loading Time Tags and build Time Variable equals 1 for all frames in tags
% Overwrite previous variables

success = false;
%global FILES CUR_FILE;

% If nargin > 2 batch processing
% val indicates callback provenance (0 : batch mode - 1 : user mode)
if nargin == 2
    val = 1;
end

% % Loading Time Groups
% if ~exist(fullfile(savedir,'Time_Groups.mat'),'file')
%     tg_data.TimeGroups_name = [];
%     tg_data.TimeGroups_frames = [];
%     tg_data.TimeGroups_duration = [];
%     tg_data.TimeGroups_S = [];
% else
%     tg_data = load(fullfile(savedir,'Time_Groups.mat'),...
%         'TimeGroups_name','TimeGroups_frames','TimeGroups_duration','TimeGroups_S');
% end

% Loading Time Tags
if ~exist(fullfile(savedir,'Time_Tags.mat'),'file')
    errordlg(sprintf('Impossible to generate Time Indexes: Time_Tags.mat file not found [%s].',savedir));
    return;
else
    tt_data = load(fullfile(savedir,'Time_Tags.mat'),...
        'TimeTags','TimeTags_cell','TimeTags_images','TimeTags_strings');
    if isempty(tt_data.TimeTags_strings)
        errordlg(sprintf('Impossible to generate Time Indexes: Empty file Time_Tags.mat [%s].',savedir));
        return;
    end
end

% Buildin time reference
n_images = size(handles.TimeDisplay.UserData,1);
delta_t = .001;
t_max = handles.TimeDisplay.UserData(end,:);
t_min = handles.TimeDisplay.UserData(1,:);
A = datenum([{t_min};tt_data.TimeTags_strings(:,1)]);
B = datenum([{t_max};tt_data.TimeTags_strings(:,2)]);
t_start = min((A-floor(A))*24*3600);
t_end = max((B-floor(B))*24*3600);
t_ref = (t_start:delta_t:t_end)';

% Loading Preferences.mat
load('Preferences.mat','GColors');
ind_keep = false(length(GColors.TimeGroups),1);
for i=1:length(GColors.TimeGroups)
    if GColors.TimeGroups(i).Checked
        ind_keep(i) = true;
    end
end
tg_modified = GColors.TimeGroups(ind_keep);
if isempty(tg_modified)
    fprintf('No checked time groups in Preferences Menu.\n')
    return;
end

% % Removing Time groups from tg_data
% ind_remove = false(size(tg_data.TimeGroups_name,1),1);
% for i = 1:length(tg_modified)
%     if ~isempty(strcmp(tg_data.TimeGroups_name,tg_modified(i).Name))
%         ind_remove(strcmp(tg_data.TimeGroups_name,tg_modified(i).Name)) = true;
%     end
% end
% list_removed = tg_data.TimeGroups_name(ind_remove);
% tg_data.TimeGroups_name = tg_data.TimeGroups_name(~ind_remove);
% tg_data.TimeGroups_frames = tg_data.TimeGroups_frames(~ind_remove);
% tg_data.TimeGroups_duration = tg_data.TimeGroups_duration(~ind_remove);
% tg_data.TimeGroups_S = tg_data.TimeGroups_S(~ind_remove);

% Building Time Indexes from TimeTags
all_names = {tg_modified(:).Name}';
all_strings = {tg_modified(:).String}';
all_tags = {tt_data.TimeTags(:).Tag}';

% Storing results
S = struct('Name',[],'index1',[],'index2',[]);
counter = 0;

for i=1:size(all_names,1)
    % Looking for multiple patterns
    all_patterns = regexp(char(all_strings(i)),'/','split');
    indices = find(startsWith(all_tags,all_patterns)==1);
    if isempty(indices)
        continue;
    else
        counter = counter+1;
    end
    
    A = datenum(tt_data.TimeTags_strings(indices,1));
    B = datenum(tt_data.TimeTags_strings(indices,2));
    tts1 = (A-floor(A))*24*3600;
    tts2 = (B-floor(B))*24*3600;
    tt_images1 = tt_data.TimeTags_images(indices,1);
    tt_images2 = tt_data.TimeTags_images(indices,2);

    S(counter).Name = char(all_names(i));
    S(counter).Color = tg_modified(i).Color;

    % Building index1
    index1 = false(n_images,1);
    for j=1:length(tt_images1)
        index1(tt_images1(j):tt_images2(j))=true;
    end
    S(counter).index1 = index1;
    
    % Building index2
    index2 = false(size(t_ref));
    for j=1:length(tts1)
        [~,ind_tts1] = min((t_ref-tts1(j)).^2);
        [~,ind_tts2] = min((t_ref-tts2(j)).^2);
        index2(ind_tts1:ind_tts2)=true;
    end
    S(counter).index2 = index2;
    
    % Delete Previous Data if exists
    l = findobj(handles.RightAxes,'Tag','Trace_Cerep');
    flag_update = false;
    for k = 1:length(l)
        if ~isempty(strfind(l(k).UserData.Name,sprintf('Index-%s',S(counter).Name)))
            delete(l(k));
            flag_update = true;
        end
    end
    
    % Creating line to keep a trace
    hl = line('XData',(1:n_images)',...
        'YData',double(index1),...
        'Color',S(counter).Color,...
        'LineWidth',1,...
        'Tag','Trace_Cerep',...
        'Visible','on',...
        'HitTest','off',...
        'Parent', handles.RightAxes);
    s.Name = sprintf('Index-%s',S(counter).Name);
    s.Selected = 0;
    s.X = t_ref;
    s.Y = double(index2);
    hl.UserData = s;
    
    if flag_update
        fprintf('Time Index successfully updated (%s).\n',s.Name);
    else
        fprintf('Time Index successfully created (%s).\n',s.Name);
    end
end

% Adding SLEEP if REM and NREM are found
% Delete Previous Data if exists
l = findobj(handles.RightAxes,'Tag','Trace_Cerep');
ind_rem = [];
ind_rem_tonic = [];
ind_rem_phasic = [];
ind_rem_phasic2 = [];
ind_nrem = [];
ind_sleep = [];
ind_qw = [];
ind_aw = [];
ind_wake = [];
for k = 1:length(l)
    if strcmp(l(k).UserData.Name,'Index-REM')
        ind_rem = [ind_rem;k];
    elseif strcmp(l(k).UserData.Name,'Index-REM-TONIC')
        ind_rem_tonic = [ind_rem_tonic;k];
    elseif strcmp(l(k).UserData.Name,'Index-REM-PHASIC')
        ind_rem_phasic = [ind_rem_phasic;k];
    elseif strcmp(l(k).UserData.Name,'Index-REM-PHASIC-2')
        ind_remp_phasic2 = [ind_remp_phasic2;k];
    elseif strcmp(l(k).UserData.Name,'Index-NREM')
        ind_nrem = [ind_nrem;k];
    elseif strcmp(l(k).UserData.Name,'Index-SLEEP')
        ind_sleep = [ind_sleep;k];
    elseif strcmp(l(k).UserData.Name,'Index-AW')
        ind_aw = [ind_aw;k];
    elseif strcmp(l(k).UserData.Name,'Index-QW')
        ind_qw = [ind_qw;k];
    elseif strcmp(l(k).UserData.Name,'Index-WAKE')
        ind_wake = [ind_wake;k];
    end
end

% Building Index-SLEEP
if ~isempty(ind_rem) && ~isempty(ind_nrem)  
    % Creating line
    hl = line('XData',(1:n_images)',...
        'YData',double((l(ind_rem(1)).YData+l(ind_nrem(1)).YData)>0),...
        'Color',(l(ind_rem(1)).Color+l(ind_nrem(1)).Color)/2,...
        'LineWidth',1,...
        'Tag','Trace_Cerep',...
        'Visible','on',...
        'HitTest','off',...
        'Parent', handles.RightAxes);
    s.Name = sprintf('Index-SLEEP');
    s.Selected = 0;
    s.X = t_ref;
    s.Y = hl.YData;
    hl.UserData = s;
    % Message user
    if ~isempty(ind_sleep)
        fprintf('Time Index successfully updated (Index-SLEEP).\n');
    else
        fprintf('Time Index successfully created (Index-SLEEP).\n');
    end
end

% Building Index-WAKE
if ~isempty(ind_aw) && ~isempty(ind_qw)
    % Creating line
    hl = line('XData',(1:n_images)',...
        'YData',double((l(ind_qw(1)).YData+l(ind_aw(1)).YData)>0),...
        'Color',(l(ind_qw(1)).Color+l(ind_aw(1)).Color)/2,...
        'LineWidth',1,...
        'Tag','Trace_Cerep',...
        'Visible','on',...
        'HitTest','off',...
        'Parent', handles.RightAxes);
    s.Name = sprintf('Index-WAKE');
    s.Selected = 0;
    s.X = t_ref;
    s.Y = hl.YData;
    hl.UserData = s;
    % Message user
    if ~isempty(ind_wake)
        fprintf('Time Index successfully updated (Index-WAKE).\n');
    else
        fprintf('Time Index successfully created (Index-WAKE).\n');
    end
end

% Building Index-REM-PHASIC
if ~isempty(ind_rem) && ~isempty(ind_rem_phasic)  
    % Creating line
    hl = line('XData',(1:n_images)',...
        'YData',double((l(ind_rem(1)).YData+l(ind_rem_phasic(1)).YData)),...
        'Color',(l(ind_rem(1)).Color+l(ind_rem_phasic(1)).Color)/2,...
        'LineWidth',1,...
        'Tag','Trace_Cerep',...
        'Visible','on',...
        'HitTest','off',...
        'Parent', handles.RightAxes);
    s.Name = sprintf('Index-REM-PHASIC-2');
    s.Selected = 0;
    s.X = t_ref;
    s.Y = hl.YData;
    hl.UserData = s;
    % Message user
    if ~isempty(ind_sleep)
        fprintf('Time Index successfully updated (Index-REM-PHASIC-2).\n');
    else
        fprintf('Time Index successfully created (Index-REM-PHASIC-2).\n');
    end
end

% removing Index-SLEEP
% removing Index-WAKE
delete(l([ind_sleep;ind_wake;ind_rem_phasic2]));

success = true;

end