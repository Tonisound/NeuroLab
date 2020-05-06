function success = detect_vascular_surges(folder_name,handles,val)
% Surge Detection

success = false;
%global FILES CUR_FILE;

% If nargin > 2 batch processing
% val indicates callback provenance (0 : batch mode - 1 : user mode)
if nargin == 2
    val=1;
end

if val==0
    % Parameters
    n_aw = 1;               % Number of standard-deviations
    thresh_surge = .5;      % Proportion of pixels to detect surges
    thresh_second = 3;      % seconds - minimum duration to keep surge
    flag_tag = true;        % Overwrite Time Tags
%     flag_group = true;      % Overwrite Time Groups
else
    % Input dialog
%     prompt={'Number std-devs';'Activation threshold (%)';'Minimum Surge Duration';...
%         'Overwrite Time Tags';'Overwrite Time Groups';'Save Time Surges'};
%     name = 'Select Surge Detection Parameters';
%     defaultans = {'1.0';'0.5';'3.0';'true';'true';'true'};
    prompt={'Number std-devs';'Activation threshold (%)';'Minimum Surge Duration';'Overwrite Time Tags'};
    name = 'Select Surge Detection Parameters';
    defaultans = {'1.0';'0.5';'3.0';'true'};
    answer = inputdlg(prompt,name,[1 100],defaultans);
    if isempty(answer)
        return;
    end
    n_aw = str2double(char(answer(1)));
    thresh_surge = str2double(char(answer(2)));
    thresh_second = str2double(char(answer(3)));
    if str2num(char(answer(4)))==1
        flag_tag = true;
    else
        flag_tag = false;
    end
%     if str2num(char(answer(5)))==1
%         flag_group = true;
%     else
%         flag_group = false;
%     end

end


% Loading Doppler_film
fprintf('Loading Doppler_normalized ...\n');
Dn = load(fullfile(folder_name,'Doppler_normalized.mat'),'Doppler_normalized');
fprintf('Doppler_normalized loaded : %s\n',fullfile(folder_name,'Doppler_normalized.mat'));
Doppler_film = Dn.Doppler_normalized;
last_im = size(Doppler_film,3);

%Loading Time Ref
if exist(fullfile(folder_name,'Time_Reference.mat'),'file')
    load(fullfile(folder_name,'Time_Reference.mat'),'time_ref');
else
    errordlg('File Time_Reference.mat not found.');
    return;
end

% Loading Time Groups
if ~exist(fullfile(folder_name,'Time_Groups.mat'),'file')
    errordlg('File Time_Groups.mat not found.');
    return;
else
    tg_data = load(fullfile(folder_name,'Time_Groups.mat'),'TimeGroups_name','TimeGroups_frames','TimeGroups_duration','TimeGroups_S');
end

% Loading Time Tags
if ~exist(fullfile(folder_name,'Time_Tags.mat'),'file')
    tt_data = [];
else
    tt_data = load(fullfile(folder_name,'Time_Tags.mat'),'TimeTags','TimeTags_cell','TimeTags_images','TimeTags_strings');
end


% Picking REM and AW distribution
ind_rem = find(strcmpi(tg_data.TimeGroups_name,'rem')==1);
ind_aw = find(strcmpi(tg_data.TimeGroups_name,'aw')==1);
if length(ind_rem)~=1 
    errordlg(sprintf('%d group(s) corresponding to REM found.',length(ind_rem)));
    return;
elseif length(ind_aw)~=1
    errordlg(sprintf('%d group(s) corresponding to AW found.',length(ind_aw)));
    return
end


% Picking Whole region
l_all = findobj(handles.RightAxes,'Tag','Trace_Region');
l_all_name = [];
for i=1:length(l_all)
    l_all_name = [l_all_name;{l_all(i).UserData.Name}];
end
%ind_whole = find(strcmpi(l_all_name,'whole')==1);
ind_whole = [find(strcmpi(l_all_name,'whole')==1);find(strcmpi(l_all_name,'whole-reg')==1)];
if length(ind_whole)~=1 
    errordlg(sprintf('%d region(s) corresponding to Whole found.',length(ind_whole)));
    return;
else
    whole_mask = l_all(ind_whole).UserData.Mask;
    whole_mask(whole_mask==0) = NaN;
end


% Extracting AW movie
TimeTags_images = tg_data.TimeGroups_S(ind_aw).TimeTags_images;
AW_images = zeros(last_im,1);
for i =1:size(TimeTags_images,1)
    for j = 1:last_im
        if (j-TimeTags_images(i,1))*(j-TimeTags_images(i,2))<=0
            AW_images(j)=1;
        end
    end 
end
%Doppler_AW = Doppler_film(:,:,AW_images).*whole_mask;
IM_AW = mean(Doppler_film(:,:,AW_images==1),3,'omitnan').*whole_mask;
STD_AW = std(Doppler_film(:,:,AW_images==1),[],3,'omitnan').*whole_mask;


% Extracting REM movie
TimeTags_images = tg_data.TimeGroups_S(ind_rem).TimeTags_images;
REM_images = zeros(last_im,1);
Doppler_REM = NaN(size(Doppler_film));
for i =1:size(TimeTags_images,1)
    for j = 1:last_im
        if (j-TimeTags_images(i,1))*(j-TimeTags_images(i,2))<=0
            REM_images(j)=1;
            Doppler_REM(:,:,j)=Doppler_film(:,:,j).*whole_mask;
        end
    end 
end
IM_REM = mean(Doppler_film(:,:,REM_images==1),3,'omitnan').*whole_mask;
STD_REM = std(Doppler_film(:,:,REM_images==1),[],3,'omitnan').*whole_mask;


% Computing Differential Movie
n_whole = sum(sum(whole_mask==1));
ind_surge = zeros(last_im,1);
ratio_surge = zeros(last_im,1);
intensity_surge = zeros(last_im,1);

%IM_DIFF = sign(Doppler_REM-(IM_AW+n_aw*STD_AW));
%IM_DIFF_Q = Doppler_REM-(IM_AW+n_aw*STD_AW);
IM_DIFF_Q = Doppler_REM;
IM_DIFF = (Doppler_REM-(IM_AW+n_aw*STD_AW))>0;
for i=1:last_im
    temp = IM_DIFF(:,:,i)==1;
    if (sum(temp(:))/n_whole) >= thresh_surge
        ind_surge(i) = 1;
    end
end
% ratio_surge
IM_DIFF_ALL = sign(Doppler_film-(IM_AW+n_aw*STD_AW));
for i=1:last_im
    temp = IM_DIFF_ALL(:,:,i)==1;
    ratio_surge(i) = sum(temp(:))/n_whole;
    intensity_surge(i) = mean(mean(IM_DIFF_Q(:,:,i),'omitnan'),'omitnan');
end

% Converting ind_surge in TimeTags_images & TimeTags_strings
TimeTags_strings_all  = handles.TimeDisplay.UserData;
TimeTags_images_phasic = [];
TimeTags_strings_phasic = [];
count = 1;
while count < last_im
    if ind_surge(count)==0
        count = count+1;
    else
        ind_start = count;
        t_start = TimeTags_strings_all(count,:);
        while ind_surge(count)==1 && count<last_im
            count = count+1;
        end
        ind_end = count-1;
        t_end = TimeTags_strings_all(count-1,:);
        TimeTags_images_phasic = [TimeTags_images_phasic;ind_start,ind_end];
        TimeTags_strings_phasic = [TimeTags_strings_phasic;[{t_start},{t_end}]];
        fprintf('>> Surge Detected [%s - %s]\n',t_start,t_end);
    end
end
% Removing short surges if ind_surge not empty
delta_t = time_ref.Y(2)-time_ref.Y(1);
if sum(ind_surge)>0  
    min_frames = ceil(thresh_second/delta_t);
    ind_remove = (TimeTags_images_phasic(:,2)-TimeTags_images_phasic(:,1)<min_frames);
    % Updating ind_surge
    rm_frames = TimeTags_images_phasic(ind_remove,:);
    rm_strings = TimeTags_strings_phasic(ind_remove,:);
    for i=1:size(rm_frames,1)
        ind_surge(rm_frames(i,1):rm_frames(i,2))=0;
        fprintf('Removing Short Surge [%s - %s]\n',char(rm_strings(i,1)),char(rm_strings(i,2)));
    end
    % Updating TimeTags_images_phasic & TimeTags_strings_phasic
    TimeTags_images_phasic(ind_remove,:)=[];
    TimeTags_strings_phasic(ind_remove,:)=[];
end

% Converting ind_tonic in TimeTags_images & TimeTags_strings
ind_tonic = REM_images-ind_surge;
ind_add = [abs(diff(ind_surge));0]+ [0;abs(diff(ind_surge))];
ind_tonic = (ind_tonic+ind_add)>0;
TimeTags_images_tonic = [];
TimeTags_strings_tonic = [];
count = 1;

% Avoiding bug if ind_tonic(end)==1
if ind_tonic(end)==1
    ind_tonic(end)=0;
end

while count<length(ind_tonic)
    if ind_tonic(count) == 0 
        count = count+1;
    else
        frame_start = count;
        t_start = TimeTags_strings_all(count,:);
        while ind_tonic(count) ==1 
            count = count+1;
        end
        frame_end = count-1;
        t_end = TimeTags_strings_all(count-1,:);
        TimeTags_images_tonic = [TimeTags_images_tonic;[frame_start,frame_end]];
        TimeTags_strings_tonic = [TimeTags_strings_tonic;[{t_start},{t_end}]];
    end
end

% Save TimeTags if ind_surge is not empty
if sum(ind_surge)==0
    n_phasic = 0;
    n_tonic = sum(REM_images);
    TimeTags_strings = [];
    TimeTags_images = zeros(0,2);
    TimeTags = struct('Episode',[],'Tag',[],'Onset',[],'Duration',[],'Reference',[]);
    TimeTags_cell = cell(1,6);
    TimeTags_cell(1,:) = {'Episode','Tag','Onset','Duration','Reference','Tokens'}; 
    fprintf('No surges detected for threshold %.1f and sigma %.1f.\n',thresh_surge,n_aw);   
else
    % TimeTags_dur
    tts1 = datenum(TimeTags_strings_phasic(:,1));
    tts2 = datenum(TimeTags_strings_phasic(:,2));
    TimeTags_seconds_phasic = [(tts1-floor(tts1)),(tts2-floor(tts2))]*24*3600;
    TimeTags_dur_phasic = datestr((TimeTags_seconds_phasic(:,2)-TimeTags_seconds_phasic(:,1))/(24*3600),'HH:MM:SS.FFF');
    % TimeTags_cell & TimeTags
    n_phasic = size(TimeTags_images_phasic,1);
    TimeTags_phasic = struct('Episode',[],'Tag',[],'Onset',[],'Duration',[],'Reference',[]);
    TimeTags_cell_phasic = cell(n_phasic,6);
    for k=1:n_phasic
        % tag = sprintf('SURGE%d(%.1f/%.1f)',k,thresh_surge,n_aw);
        tag = sprintf('REMPHASIC-%03d',k);
        onset = char(TimeTags_strings_phasic(k,1));
        dur = char(TimeTags_dur_phasic(k,:));
        TimeTags_cell_phasic(k,:) = {'',tag,onset,dur,onset,''};
        TimeTags_phasic(k,1).Episode = '';
        TimeTags_phasic(k,1).Tag = tag;
        TimeTags_phasic(k,1).Onset = onset;
        TimeTags_phasic(k,1).Duration = dur;
        TimeTags_phasic(k,1).Reference = onset;
        TimeTags_phasic(k,1).Tokens = '';
    end 
    
    % TimeTags_dur
    tts1 = datenum(TimeTags_strings_tonic(:,1));
    tts2 = datenum(TimeTags_strings_tonic(:,2));
    TimeTags_seconds_tonic = [(tts1-floor(tts1)),(tts2-floor(tts2))]*24*3600;
    TimeTags_dur_tonic = datestr((TimeTags_seconds_tonic(:,2)-TimeTags_seconds_tonic(:,1))/(24*3600),'HH:MM:SS.FFF');
    % TimeTags_cell & TimeTags
    n_tonic = size(TimeTags_images_tonic,1);
    TimeTags_tonic = struct('Episode',[],'Tag',[],'Onset',[],'Duration',[],'Reference',[]);
    TimeTags_cell_tonic = cell(n_tonic,6);
    for k=1:n_tonic
        % tag = sprintf('TONIC%d(%.1f/%.1f)',k,thresh_surge,n_aw);
        tag = sprintf('REMTONIC-%03d',k);
        onset = char(TimeTags_strings_tonic(k,1));
        dur = char(TimeTags_dur_tonic(k,:));
        TimeTags_cell_tonic(k,:) = {'',tag,onset,dur,onset,''};
        TimeTags_tonic(k,1).Episode = '';
        TimeTags_tonic(k,1).Tag = tag;
        TimeTags_tonic(k,1).Onset = onset;
        TimeTags_tonic(k,1).Duration = dur;
        TimeTags_tonic(k,1).Reference = onset;
        TimeTags_tonic(k,1).Tokens = '';
    end 
    
    % Erase previous TimeTags if flag_tag
    if flag_tag
        temp ={tt_data.TimeTags(:).Tag}';
        ind_keep = ~contains(temp,["SURGE","TONIC","REMPHASIC-","REMTONIC-"]);
        tt_data.TimeTags_images = tt_data.TimeTags_images(ind_keep,:);
        tt_data.TimeTags_strings = tt_data.TimeTags_strings(ind_keep,:);
        tt_data.TimeTags_cell = [tt_data.TimeTags_cell(1,:);tt_data.TimeTags_cell(find(ind_keep==1)+1,:)];
        tt_data.TimeTags = tt_data.TimeTags(ind_keep);    
    end
    % Saving Surges as TimeTags.mat
    TimeTags_images = [tt_data.TimeTags_images;TimeTags_images_phasic;TimeTags_images_tonic];
    TimeTags_strings = [tt_data.TimeTags_strings;TimeTags_strings_phasic;TimeTags_strings_tonic];
    TimeTags_cell = [tt_data.TimeTags_cell;TimeTags_cell_phasic;TimeTags_cell_tonic];
    TimeTags = [tt_data.TimeTags;TimeTags_phasic;TimeTags_tonic];
    save(fullfile(folder_name,'Time_Tags.mat'),'TimeTags','TimeTags_cell','TimeTags_strings','TimeTags_images');
    fprintf('===> Saved at %s.mat\n',fullfile(folder_name,'Time_Tags.mat'));
    
%     %Save TimeGroups
%     if flag_group
%         ind_keep = ~contains(tg_data.TimeGroups_name,["REMPHASIC";"REMTONIC"]);
%         tg_data.TimeGroups_name = tg_data.TimeGroups_name(ind_keep);
%         tg_data.TimeGroups_frames = tg_data.TimeGroups_frames(ind_keep);
%         tg_data.TimeGroups_duration = tg_data.TimeGroups_duration(ind_keep);
%         tg_data.TimeGroups_S = tg_data.TimeGroups_S(ind_keep);
%     end
%     % Saving Surges as TimeGroups.mat
%     name_phasic = {'REMPHASIC'};
%     frames_phasic = {sprintf('%d',sum(ind_surge))};
%     duration_phasic = {datestr(sum(TimeTags_seconds_phasic(:,2)-TimeTags_seconds_phasic(:,1))/(24*3600),'HH:MM:SS.FFF')};
%     S_phasic.Selected = length(tt_data.TimeTags)+(1:n_phasic)';
%     S_phasic.Name = {TimeTags(S_phasic.Selected).Tag}';
%     S_phasic.TimeTags_strings = TimeTags_strings_phasic;
%     S_phasic.TimeTags_images = TimeTags_images_phasic;
%     
%     % Saving tonic events as TimeGroups.mat
%     name_tonic = {'REMTONIC'};
%     frames_tonic = {sprintf('%d',sum(ind_tonic))};
%     duration_tonic = {datestr(sum(TimeTags_seconds_tonic(:,2)-TimeTags_seconds_tonic(:,1))/(24*3600),'HH:MM:SS.FFF')};
%     S_tonic.Selected = length(tt_data.TimeTags)+n_phasic+(1:n_tonic)';
%     S_tonic.Name = {TimeTags(S_tonic.Selected).Tag}';
%     S_tonic.TimeTags_strings = TimeTags_strings_tonic;
%     S_tonic.TimeTags_images = TimeTags_images_tonic;
%     
%     % Concatenate
%     TimeGroups_name = [tg_data.TimeGroups_name;name_phasic;name_tonic];
%     TimeGroups_frames = [tg_data.TimeGroups_frames;frames_phasic;frames_tonic];
%     TimeGroups_duration = [tg_data.TimeGroups_duration;duration_phasic;duration_tonic];
%     TimeGroups_S = [tg_data.TimeGroups_S;S_phasic;S_tonic];
%     save(fullfile(folder_name,'Time_Groups.mat'),'TimeGroups_name','TimeGroups_frames','TimeGroups_duration','TimeGroups_S');
%     fprintf('===> Saved at %s.mat\n',fullfile(folder_name,'Time_Groups.mat'));
end


% Delete Previous Data if exists
l = findobj(handles.RightAxes,'Tag','Trace_Cerep');
for i = 1:length(l)
    if ~isempty(strfind(l(i).UserData.Name,sprintf('Index-Surge/(%.1f-%.1f)',thresh_surge,n_aw)))...
            ||~isempty(strfind(l(i).UserData.Name,sprintf('Ratio-Surge/(%.1f)',n_aw)))...
            ||~isempty(strfind(l(i).UserData.Name,sprintf('IndexSurge/(%.1f-%.1f)',thresh_surge,n_aw)))...
            ||~isempty(strfind(l(i).UserData.Name,sprintf('RatioSurge/(%.1f)',n_aw)))
        delete(l(i));
    end
end


% Creating line to keep a trace 
hl = line('XData',1:last_im,...
    'YData',ind_surge*thresh_surge,...
    'Color','k',...
    'LineWidth',1,...
    'Tag','Trace_Cerep',...
    'Visible','on',...
    'HitTest','off',...
    'Parent', handles.RightAxes);
s.Name = sprintf('Index-Surge/(%.1f-%.1f)',thresh_surge,n_aw);
s.Selected = 0;
s.X = time_ref.Y;
s.Y = ind_surge;
% Adding NaN to have zero-start
X_sup = (fliplr(time_ref.Y(1)-delta_t:-delta_t:0))';
s.X = [X_sup;s.X];
s.Y = [NaN(size(X_sup));s.Y];
hl.UserData = s;

hr = line('XData',1:last_im,...
    'YData',ratio_surge,...
    'Color',[.5 .5 .5],...
    'LineWidth',1,...
    'Tag','Trace_Cerep',...
    'Visible','on',...
    'HitTest','off',...
    'Parent', handles.RightAxes);
s.Name = sprintf('Ratio-Surge/(%.1f)',n_aw);
s.Selected = 0;
s.X = time_ref.Y;
s.Y = ratio_surge;
% Adding NaN to have zero-start
X_sup = (fliplr(time_ref.Y(1)-delta_t:-delta_t:0))';
s.X = [X_sup;s.X];
s.Y = [NaN(size(X_sup));s.Y];
hr.UserData = s;

% Saving Surges info in struct
S_surges  = struct('name',[],'recording',[],'episode',[],'animal',[],...
    'im_start',[],'im_end',[],'duration',[],...
    'mean_intensity',[],'max_intensity',[],'mean_ratio',[],'max_ratio',[]);
for i=1:n_phasic
    temp = regexp(folder_name,filesep,'split');
    im_start = TimeTags_images_phasic(i,1);
    im_end = TimeTags_images_phasic(i,2);
    ind_keep = (im_start>=tt_data.TimeTags_images(:,1))&(im_end<=tt_data.TimeTags_images(:,2))&(contains({tt_data.TimeTags(:).Tag}','REM'));
    tags = {TimeTags(ind_keep==1).Tag}';
    if length(tags)==1
        episode = char(tags);
    elseif length(tags)>1
        episode = char(tags(1));
    else
        episode = '';
    end
    S_surges(i).name = TimeTags_phasic(i).Tag;
    S_surges(i).recording = strrep(char(temp(end)),'_gfus','');
    S_surges(i).episode = episode;
    S_surges(i).animal = '';
    S_surges(i).im_start = im_start;
    S_surges(i).im_end = im_end;
    S_surges(i).duration = TimeTags_seconds_phasic(i,2)-TimeTags_seconds_phasic(i,1);
    S_surges(i).mean_intensity = mean(intensity_surge(im_start:im_end));
    S_surges(i).max_intensity = max(intensity_surge(im_start:im_end));
    S_surges(i).mean_ratio = mean(ratio_surge(im_start:im_end));
    S_surges(i).max_ratio = max(ratio_surge(im_start:im_end));
end

% Saving Time_Surges.mat
%IM_DIFF = IM_DIFF(:,:,REM_images==1);
Doppler_Surge = IM_DIFF_ALL;
save(fullfile(folder_name,'Time_Surges.mat'),'n_aw','thresh_surge','thresh_second',...
    'AW_images','IM_AW','STD_AW','REM_images','IM_REM','STD_REM',...
    'ind_surge','ind_tonic','n_phasic','n_tonic','S_surges',...
    'TimeTags','TimeTags_cell','TimeTags_strings','TimeTags_images',...
    'ratio_surge','intensity_surge','whole_mask','n_whole','Doppler_Surge','-v7.3');
fprintf('===> Saved at %s.mat\n',fullfile(folder_name,'Time_Surges.mat'));

success = true;

end