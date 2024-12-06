function f = movie_normalized(handles,val,str_regions,str_traces)
% Opens figure to display fUS movie and selected time variables
% Interactive control of timing and scales
% save_video(fullfile(DIR_FIG,'Movie_Normalized',FILES(CUR_FILE).nlab,'CURRENT_Frames'),fullfile(DIR_FIG,'Movie_Normalized',FILES(CUR_FILE).nlab),'test');

% val indicates callback provenance (0 : batch mode - 1 : user mode)
if nargin < 2
    val = 0;
    str_regions = [];
    str_traces = [];
end

global SEED IM DIR_SAVE DIR_FIG DIR_STATS FILES CUR_FILE START_IM END_IM;

% Input dialog Initialization
prompt={'Delay to start (s)';'Window size (s)';'Show video';'Save/Display mode (disp/frames/video)'};
name = 'Select Movie Initialization Parameters';
defaultans = {'0.0';'20.0';'true';'disp'};

if val == 1
    answer = inputdlg(prompt,name,[1 100],defaultans);
    if isempty(answer)
        return;
    end
    t_start_0 = str2double(char(answer(1)));
    t_lfp_0 = str2double(char(answer(2)));
    %flag_trace = char(answer(3));
    %flag_spectro = char(answer(4));
    flag_video = char(answer(3));
    display_mode = char(answer(4));
else
    % batch mode
    t_start_0 = 0;
    t_lfp_0 = 5;
    flag_video = 'true';
    display_mode = 'video';
end

% Loading Time Reference
load(fullfile(DIR_SAVE,FILES(CUR_FILE).nlab,'Time_Reference.mat'),'time_ref','length_burst','n_burst');

% Loading Time Tags
if exist(fullfile(DIR_SAVE,FILES(CUR_FILE).nlab,'Time_Tags.mat'),'file')
    tt_data = load(fullfile(DIR_SAVE,FILES(CUR_FILE).nlab,'Time_Tags.mat'),...
        'TimeTags','TimeTags_cell','TimeTags_strings','TimeTags_images');
    flag_tag = 1;
    tt_cell = {tt_data.TimeTags(:).Tag}';
    
    % keeping TimeTags_seconds before exclusion
    tts1 = datenum(tt_data.TimeTags_strings(:,1));
    tts2 = datenum(tt_data.TimeTags_strings(:,2));
    TimeTags_seconds = [(tts1-floor(tts1)),(tts2-floor(tts2))]*24*3600;
    
    % Excluding unwanted Time Tags
    ind_keep_tt = ~contains(tt_cell,["Transition","WHOLE","TEST","BASELINE"]);
    tt_cell = tt_cell(ind_keep_tt==1);
    TimeTags_images = tt_data.TimeTags_images(ind_keep_tt==1,:);
    
    
    % Isolating Time Surges
    ind_surge = contains(tt_cell,'SURGE');
    if sum(ind_surge)>0
        flag_surge = 1;
    else
        flag_surge = 0;
    end
    TimeTags_images_surges = TimeTags_images(ind_surge==1,:);
    tt_cell_surges = tt_cell(ind_surge==1);
    TimeTags_images = TimeTags_images(ind_surge==0,:);
    tt_cell = tt_cell(ind_surge==0);
else
    flag_tag = 0;
    tt_cell = [];
    TimeTags_images = [];
end
% Loading Time Groups
if exist(fullfile(DIR_SAVE,FILES(CUR_FILE).nlab,'Time_Groups.mat'),'file')
    tg_data = load(fullfile(DIR_SAVE,FILES(CUR_FILE).nlab,'Time_Groups.mat'),...
        'TimeGroups_name','TimeGroups_frames','TimeGroups_duration','TimeGroups_S');
    flag_group = 1;
    tg_cell = tg_data.TimeGroups_name;
    
    % Excluding unwanted Time Groups
    ind_keep_tg = ~contains(tg_cell,["BASELINE","TEST","REM-SHORT","REM-LONG"]);
    tg_cell = tg_cell(ind_keep_tg==1);
    TimeGroups_S = tg_data.TimeGroups_S(ind_keep_tg==1,:);
else
    flag_group = 0;
    tg_cell = [];
    TimeGroups_S = [];
    tg_data.TimeGroups_name = [];
    tg_data.TimeGroups_frames = [];
    tg_data.TimeGroups_duration = [];
    tg_data.TimeGroups_S = [];
end

% Loading Sleep Scoring
if exist(fullfile(DIR_SAVE,FILES(CUR_FILE).nlab,'Sleep_Scoring.mat'),'file')
    ss_data = load(fullfile(DIR_SAVE,FILES(CUR_FILE).nlab,'Sleep_Scoring.mat'),...
        'channel_lfp','channel_acc','channel_emg');
else
    ss_data = [];
end
f.UserData.ss_data = ss_data;

% Loading Atlas
if exist(fullfile(DIR_SAVE,FILES(CUR_FILE).nlab,'Atlas.mat'),'file')
    atlas_data = load(fullfile(DIR_SAVE,FILES(CUR_FILE).nlab,'Atlas.mat'),...
        'AP_mm','ML_mm','AtlasName','AtlasType','Mask');
    if ~isempty(atlas_data.AP_mm)
        atlas_name = sprintf('Coronal-AP%.2fmm',atlas_data.AP_mm);
    elseif ~isempty(atlas_data.ML_mm)
        atlas_name = sprintf('Sagittal-ML%.2fmm',atlas_data.ML_mm);
    else
        atlas_name = 'Unregistered';
    end
else
    atlas_data = [];
    atlas_name = 'Unregistered';
end


% Loading Ripple Events
input_file = fullfile(DIR_SAVE,FILES(CUR_FILE).nlab,'Events','Ripples-Sqrt-All.csv');
[events,EventHeader,MetaData] = read_csv_events(input_file);


% Trace Selection
l = flipud(findobj(handles.RightAxes,'Tag','Trace_Cerep','-or','Tag','Trace_Region','-or','Tag','Trace_Mean'));
%l = findobj(handles.RightAxes,'Tag','Trace_Cerep');
str_lfp = [];
% All channels
for i=1:length(l)
    str_lfp = [str_lfp;{l(i).UserData.Name}];
    %Multiply line values by 100
    %     if strcmp(l(i).Tag,'Trace_Region')
    %         l(i).YData = 100*l(i).YData;
    %     end
end

if ~isempty(l)
    
    % initial values
    str_ref = [str_traces;str_regions;'Whole'];
    if isempty(str_ref)
        initvalues = [];
    else
        initvalues = [];
        for k=1:length(str_lfp)
            if sum(strcmp(str_ref,str_lfp(k)))>0
                initvalues = [initvalues;k];
            end
        end
    end
    % Selecting traces to display
    if val == 0
        % batch mode
        ind_lfp = initvalues;
        v = 1;
    else
        % user mode
        [ind_lfp,v] = listdlg('Name','LFP Selection','PromptString','Select traces to display',...
            'SelectionMode','multiple','ListString',str_lfp,'InitialValue',initvalues,'ListSize',[300 500]);
    end
    
    if v==0
        warning('No trace selected .\n');
        str_lfp = [];
        %return;
    else
        l = l(ind_lfp);
        str_lfp =  str_lfp(ind_lfp);
        % Finding EMG and ACCEL and put them on top
        ind_top =zeros(size(l));
        for i=1:length(l)
            if ~isempty(strfind(l(i).UserData.Name,'EMG/'))...
                    ||~isempty(strfind(l(i).UserData.Name,'ACCEL/'))...
                    ||~isempty(strfind(l(i).UserData.Name,'LFP/'))
                ind_top(i)=1;
            end
        end
        l = flipud([l(ind_top==1);l(ind_top==0)]);
        str_lfp =  flipud([str_lfp(ind_top==1);str_lfp(ind_top==0)]);
    end
end

% Loading corresponding Wavelet data
folder_wav = fullfile(DIR_STATS,'Wavelet_Analysis',FILES(CUR_FILE).nlab);
d = dir(fullfile(folder_wav,'*.mat'));
str_spec = {d(:).name}';
str_spec = regexprep(str_spec,strcat(FILES(CUR_FILE).nlab,'_Wavelet_Analysis_'),'');
% Spectrogram Selection
if ~isempty(d)
    
    % initial values (to be updated)
    str_ref = [];
    if isempty(str_ref)
        initvalues = [];
    else
        initvalues = [];
        for k=1:length(str_spec)
            if sum(strcmp(str_ref,str_spec(k)))>0
                initvalues = [initvalues;k];
            end
        end
    end
    % Selecting spectrograms to display
    if val == 0
        % batch mode
        ind_spec = initvalues;
        v = 1;
    else
        % user mode
        [ind_spec,v] = listdlg('Name','Spectrogram Selection','PromptString','Select spectrogramms to display',...
            'SelectionMode','multiple','ListString',str_spec,'InitialValue',[],'ListSize',[300 500]);
    end
    
    
    if v==0
        warning('No spectrogramm selected .\n');
        str_spec = [];
        %return;
    else
        str_spec =  str_spec(ind_spec);
        for i=1:length(str_spec)
            ii = ind_spec(i);
            data_spec = load(fullfile(folder_wav,d(ii).name),'Xdata_sub','Cdata_sub','freqdom','f_sub');
            data_spectrogram(i).name = regexprep(str_spec(i),'.mat','');
            data_spectrogram(i).Xdata = data_spec.Xdata_sub;
            data_spectrogram(i).Cdata = data_spec.Cdata_sub;
            data_spectrogram(i).freqdom = data_spec.freqdom;
            data_spectrogram(i).f_sub = data_spec.f_sub;
        end
    end
end
l1 = length(str_lfp);
l2 = length(str_spec);
L = l1+l2;

% Return if nothing selected
if L==0
    fprintf('Nothing to display : Exit.\n')
    return;
end

% Building t matrix
b = datenum(handles.TimeDisplay.UserData);
t = (b-floor(b))*24*3600;

% Loading video
if strcmp(flag_video,'true')
    
    %     % Check if Video_Axes contains video reader
    %     if isempty(handles.VideoAxes.UserData)
    %         % Check video loading option
    %         load('Preferences.mat','GImport');
    %         if strcmp(GImport.Video_loading,'skip')
    %             GImport.Video_loading = 'full';
    %         end
    %         save('Preferences.mat','GImport','-append');
    %         warning('Preferences.mat Video loading Option updated');
    %
    %         % Import Video
    %         import_video(fullfile(FILES(CUR_FILE).fullpath,FILES(CUR_FILE).video),handles);
    %     end
    %
    %     % Conversion to rgb movie
    %     if ~isempty(handles.VideoAxes.UserData.rgb_video) && handles.VideoAxes.UserData.start_im==START_IM && handles.VideoAxes.UserData.end_im==END_IM
    %         rgb_video = handles.VideoAxes.UserData.rgb_video;
    %     else
    %         fprintf('Converting video to rgb movie frames...');
    %         v = handles.VideoAxes.UserData.VideoReader;
    %         im = handles.VideoAxes.UserData.Image.CData;
    %         %rgb_video = [];
    %         rgb_video = zeros(size(im,1),size(im,2),size(im,3),END_IM-START_IM+1,'uint8');
    %
    %         h = waitbar(0,'Loading video file. Please wait.');
    %         for i = 1:END_IM-START_IM+1
    %             v.CurrentTime = t(i+START_IM-1);
    %             vidFrame = readFrame(v);
    %             %rgb_video = cat(4,rgb_video,vidFrame);
    %             rgb_video(:,:,:,i) = vidFrame;
    %             x = i/(END_IM-START_IM+1);
    %             waitbar(x,h,sprintf('%.1f %% converted to RGB movie.',100*x))
    %         end
    %         close(h);
    %         fprintf(' done.\n');
    %
    %         % Storing video
    %         handles.VideoAxes.UserData.rgb_video=rgb_video;
    %         handles.VideoAxes.UserData.start_im=START_IM;
    %         handles.VideoAxes.UserData.end_im=END_IM;
    %     end
    if isempty(handles.VideoAxes.UserData)
        bw_video = ones(1,1,END_IM-START_IM+1);
        t_str1 = [];
        t_str2 = [];
    else
        bw_video = handles.VideoAxes.UserData.all_frames;
        t_str1 = datestr(handles.VideoAxes.UserData.t_ref/(24*3600),'HH:MM:SS.FFF');
        t_str2 = datestr(handles.VideoAxes.UserData.t_video/(24*3600),'HH:MM:SS.FFF');
    end
    
else
    bw_video = ones(1,1,END_IM-START_IM+1);
    t_str1 = [];
    t_str2 = [];
end

% Saving Video frame
load('Preferences.mat','GTraces','GImport');
temp =(tt_data.TimeTags_images(:,1)-START_IM).^2+(tt_data.TimeTags_images(:,2)-END_IM).^2;
if ~isempty(tt_data.TimeTags(temp==0))
    tag = tt_data.TimeTags(temp==0).Tag;
else
    tag = 'CURRENT';
end
save_dir = fullfile(DIR_FIG,'Movie_Normalized',FILES(CUR_FILE).nlab);
work_dir = fullfile(DIR_FIG,'Movie_Normalized',FILES(CUR_FILE).nlab,strcat(tag,'_Frames'));
add_dir = fullfile(DIR_FIG,'Movie_Normalized',FILES(CUR_FILE).nlab,strcat(tag,'_AdditionalFrames'));
if strcmp(display_mode,'frames')||strcmp(display_mode,'video')
    % Removing old folder
    if ~isdir(save_dir)
        mkdir(save_dir);
    else
        rmdir(save_dir,'s');
        mkdir(save_dir);
    end
    if ~isdir(work_dir)
        mkdir(work_dir);
    else
        rmdir(work_dir,'s');
    end
    % Button status
    button_visible = 'off';
else
    button_visible = 'on';
end


% Building figure
str= strtrim(handles.CenterPanelPopup.String(handles.CenterPanelPopup.Value,:));
f = figure('Name',sprintf('fUS-EEG Recording - %s (%s)',FILES(CUR_FILE).nlab,str),...
    'Units','normalized',...
    'MenuBar','none',...
    'Colormap',handles.MainFigure.Colormap,...
    'KeyPressFcn',{@f_keypress_fcn},...
    'Toolbar','none');
f.UserData.success = false;
f.UserData.atlas_data = atlas_data;
f.UserData.atlas_name = atlas_name;

e0 = uicontrol(f,'Units','normalized','Style','edit','Tag','Edit0',...
    'String','','TooltipString','pause between frame (s)');
% Time Tags
t1 = uicontrol(f,'Units','normalized','Style','text',...
    'String','','FontWeight','bold','TooltipString','Time');
t2 = uicontrol(f,'Units','normalized','Style','text',...
    'String','','TooltipString','# Frame');
t3 = uicontrol(f,'Units','normalized','Style','text',...
    'String','','TooltipString','Time Tag');
t4 = uicontrol(f,'Units','normalized','Style','text',...
    'String','','TooltipString','Surge');
t5 = uicontrol(f,'Units','normalized','Style','text',...
    'String','','TooltipString','');
t6 = uicontrol(f,'Units','normalized','Style','text',...
    'String','','TooltipString','');
t7 = uicontrol(f,'Units','normalized','Style','text',...
    'String','','TooltipString','');
t8 = uicontrol(f,'Units','normalized','Style','text',...
    'String','','TooltipString','');
% Time Groups
ttg = gobjects(8,1);
ttg(1) = uicontrol(f,'Units','normalized','Style','text',...
    'String','','TooltipString','Time Group 1');
ttg(2) = uicontrol(f,'Units','normalized','Style','text',...
    'String','','TooltipString','Time Group 2');
ttg(3) = uicontrol(f,'Units','normalized','Style','text',...
    'String','','TooltipString','Time Group 3');
ttg(4) = uicontrol(f,'Units','normalized','Style','text',...
    'String','','TooltipString','Time Group 4');
ttg(5) = uicontrol(f,'Units','normalized','Style','text',...
    'String','','TooltipString','Time Group 5');
ttg(6) = uicontrol(f,'Units','normalized','Style','text',...
    'String','','TooltipString','Time Group 6');
ttg(7) = uicontrol(f,'Units','normalized','Style','text',...
    'String','','TooltipString','Time Group 7');
ttg(8) = uicontrol(f,'Units','normalized','Style','text',...
    'String','','TooltipString','Time Group 8');
% Scale
t_factor = 1;
t100 = uicontrol(f,'Units','normalized','Style','text',...
    'TooltipString','Scale','String','','BackgroundColor','k');
t101 = uicontrol(f,'Units','normalized','Style','text',...
    'String',sprintf('%d s',t_factor),'FontSize',6);
% Display Controls
cb1 = uicontrol(f,'Units','normalized',...
    'Style','Checkbox','TooltipString','CLimMode Movies');
if val ==0
    cb_atlas_value=1;
else
    cb_atlas_value=handles.AtlasBox.Value;
end
cb_atlas = uicontrol(f,'Units','normalized','Value',cb_atlas_value,...
    'Style','Checkbox','TooltipString','Atlas Display');
e1 = uicontrol(f,'Units','normalized','Style','edit',...
    'String',sprintf('%.1f',handles.CenterAxes.CLim(1)),...
    'Visible','off','TooltipString','CLim min');
e2 = uicontrol(f,'Units','normalized','Style','edit',...
    'String',sprintf('%.1f',handles.CenterAxes.CLim(2)),...
    'Visible','off','TooltipString','CLim max');
cb2 = uicontrol(f,'Units','normalized','Style','Checkbox',...
    'TooltipString','YLimMode traces');
e3 = uicontrol(f,'Units','normalized','Style','edit',...
    'Visible','off','TooltipString','CLim autoscale factor');
cb3 = uicontrol(f,'Units','normalized','Style','Checkbox',...
    'TooltipString','CLimMode Spectrograms');
e4 = uicontrol(f,'Units','normalized','Style','edit',...
    'Visible','off','TooltipString','CLim min');
e5 = uicontrol(f,'Units','normalized','Style','edit',...
    'Visible','off','TooltipString','CLim max');

%Parameters
%margin = .01;
margin = .001;
all_axes = [];
all_spectraxes = [];
all_images = [];

% Initialization
% t_lfp_0 = 5;
% t_start_0 = 0;
factor_zoom = 1.1;
t_start= t_start_0;
f.UserData.flag = 1;
f.UserData.t_video = .1;                % Video Speed
e0.String = sprintf('%.3f',f.UserData.t_video);
f.UserData.t_lfp = t_lfp_0;             % Temporal window
f.UserData.add_dir = add_dir;
f.UserData.filename = FILES(CUR_FILE).nlab;
f.UserData.extension = GTraces.ImageSaveExtension;
f.UserData.format = GTraces.ImageSaveFormat;
f.UserData.button_visible = button_visible;
f.UserData.factor_zoom = factor_zoom;

% Pausing Parameters
flag_pause = true;
frame_pause = 3819;
zoom_min = .5;%s
zoom_max = t_lfp_0;
count_save = 0;

clim_default = 'manual';
ylim_default = 'manual';
if strcmp(clim_default,'manual')
    cb1.Value = 0;
    cb1.String = 'auto';
    e1.Visible = 'on';
    e2.Visible = 'on';
    cb3.Value = 0;
    cb3.String = 'auto';
    e4.Visible = 'on';
    e5.Visible = 'on';
else
    cb1.Value = 1;
    cb1.String = 'manual';
    cb3.Value = 1;
    cb3.String = 'manual';
end
cb2.String = ylim_default;
cb2.Value = 1;
e3.String = '4.0';
% Storing TimeGroups in controls
for i = 1:min(length(ttg),length(tg_cell))
    tt_images = TimeGroups_S(i).TimeTags_images;
    ttg(i).UserData.tt_images = tt_images;
    ttg(i).String = char(tg_cell(i));
    index_timegroup = NaN(size(t));
    for j = 1:length(t)
        if sum((tt_images(:,1)-j).*(tt_images(:,2)-j)<=0)>0
            index_timegroup(j)=1;
        else
            index_timegroup(j)=0;
        end
    end
    ttg(i).UserData.index_timegroup = index_timegroup;
end
% Storing corresponding time tags
all_str = cell(size(t));
%all_str = cellstr(repmat(' ',size(t)));
if flag_tag ==1
    for i =START_IM:END_IM
        str = tt_cell((TimeTags_images(:,1)-i).*(TimeTags_images(:,2)-i)<=0);
        if ~isempty(str)
            all_str(i) = str(1);
        else
            all_str(i) = {''};
        end
    end
else
    for i =START_IM:END_IM
        all_str(i) = {''};
    end
end
t3.UserData.all_str = all_str;
% Displaying Time Surges
all_str = cell(size(t));
if flag_surge ==1
    for i =START_IM:END_IM
        str = tt_cell_surges((TimeTags_images_surges(:,1)-i).*(TimeTags_images_surges(:,2)-i)<=0);
        if ~isempty(str)
            all_str(i) = str(1);
        else
            all_str(i) = {''};
        end
    end
else
    for i =START_IM:END_IM
        all_str(i) = {''};
    end
end
t4.UserData.all_str = all_str;

% Movies
ax_im = axes('Parent',f,...
    'CLimMode',handles.CenterAxes.CLimMode,...
    'CLim',handles.CenterAxes.CLim,...
    'TickLength',[0 0],'FontSize',8);
ax_im2 = axes('Parent',f,...
    'CLimMode','manual',...
    'CLim',handles.CenterAxes.CLim,...
    'TickLength',[0 0],'FontSize',8);
colormap(ax_im2,'gray');

ax_im3 = copyobj(handles.RightAxes,f);
ax_im3.XLim = [START_IM END_IM];
set(ax_im3,'XTick',[],'XTickLabel',[],'YTick',[],'YTickLabel',[]);
ax_im3.XLabel.String = [];

% Making time patches Visible
all_tp = findobj(ax_im3,'Tag','TimePatch');
for k=1:length(all_tp)
    all_tp(k).Visible = 'on';
end

delete(findobj(ax_im3.Children,'Type','Line','-not','Tag','Trace_Mean','-not','Tag','Cursor'));
l_mean = findobj(ax_im3,'Tag','Trace_Mean');
l_mean.Visible = 'on';
l_cursor = findobj(ax_im3,'Tag','Cursor');
l_cursor.Color = 'r';
l_cursor.LineWidth = 2;
uistack(l_cursor,'top');
l_cursor.Visible = 'on';

% Scaling axes
c1 = min(l_mean.YData,[],'omitnan');
c2 = max(l_mean.YData,[],'omitnan');
ax_im3.YLim = [c1 c2];

% First Image
im = imagesc(IM(:,:,START_IM),'Parent',ax_im,'Tag','MainImage');
boxCrop_Callback(handles.CropBox,[],ax_im,fullfile(DIR_SAVE,FILES(CUR_FILE).nlab));
set(ax_im,'XTickLabel','','XTick','','YTick','','YTickLabel','');
colormap(ax_im,'hot');

e1.String = c1;
e2.String = c2;
ax_im.CLim = [c1 c2];
% Ubuntu bug fix
% cbar = colorbar(ax_im,'Parent',f,'FontSize',8);
cbar = colorbar(ax_im,'Parent',f);
cbar.FontSize=8;
% Second Image
% im2 = imagesc(Doppler_Surge(:,:,START_IM),'Parent',ax_im2);
% set(ax_im2,'XTickLabel','','XTick','','YTick','','YTickLabel','');
% ax_im2.CLim = [-1,1];
% colormap(ax_im2,'parula');

% image(rgb_video(:,:,:,1),'Parent',ax_im2);
im2 = imagesc(bw_video(:,:,1),'Parent',ax_im2);
ax_im2.Visible = 'off';
colormap(ax_im2,'gray');
axis(ax_im2,'equal');

% adding Atlas
am = findobj(handles.CenterAxes,'Tag','AtlasMask');
am = copyobj(am,ax_im);
cb_atlas.Callback = {@boxAtlas_Callback,ax_im};
boxAtlas_Callback(cb_atlas,[],ax_im);
% am.Color = [.5 .5 .5];
am.Color = 'w';
am.Color(4) = .4;

% Color tag patches
default_color = [.5 .5 .5];
default_face_alpha = 0;
alpha_value = 0.25;
patch_colors = repmat(default_color,[size(TimeTags_seconds,1),1]);
face_alpha = default_face_alpha*ones(size(TimeTags_seconds,1),1);
edge_color = 'none';
y_inf = 1e6;

% % Group Coloring
% g_colors = get(groot,'defaultAxesColorOrder');
% g_colors(5,:) = f.Colormap(1,:);
% %g_list = {'QW','REM-TONIC','NREM','REM-PHASIC','AW'};
% g_list = {'QW','AW','NREM','REM'};
% g_colors(4,:) = g_colors(2,:);
% for i=1:length(g_list)
%     ind_group = strcmp(tg_data.TimeGroups_name,char(g_list(i)));
%     if sum(ind_group)~=0
%         ind_tags = tg_data.TimeGroups_S(ind_group).Selected;
%         %ind_tags = contains(tt_data.TimeTags,char(g_list(i)));
%         patch_colors(ind_tags,:) = repmat(g_colors(i,:),[length(ind_tags),1]);
%         % Highlight REM-PHASIC
%         if strcmp(g_list(i),'REM-PHASIC')
%             face_alpha(ind_tags) = .75;
%         else
%             face_alpha(ind_tags) = alpha_value;
%         end
%     end
% end

% Group Coloring
load('Preferences.mat','GColors');
g_list = {'QW','AW','NREM','REM'};
for i=1:length(g_list)
    ind_group = strcmp(tg_data.TimeGroups_name,char(g_list(i)));
    if sum(ind_group)~=0
        ind_tags = tg_data.TimeGroups_S(ind_group).Selected;
        % finding color in GColors
        ind_group = find(strcmp({GColors.TimeGroups(:).Name}',char(g_list(i))));
        if isempty(ind_group)
            continue;
        else
            patch_colors(ind_tags,:) = repmat(GColors.TimeGroups(ind_group).Color,[length(ind_tags),1]);
            face_alpha(ind_tags) = GColors.TimeGroups(ind_group).Transparency;
        end
    end
end


% Axes Traces
for i=1:l1
    ax = axes('Position',[.38 .025+(i-1)*.95/L+margin .5 .95/L-2*margin],'Parent',f,'FontSize',8);
    grid(ax,'on');
    scale = uicontrol(f,'Units','normalized','Style','text','TooltipString','Scale',...
        'String','','BackgroundColor','k','Position',[.905 .1+(i-1)*.8/L+margin .001 .8/L-margin]);
    scale.Position(4)=0; % to remove if using scales
    ax.Tag = sprintf('Ax%d',i);
    ax.XAxis.Visible = 'off';
    ax.YLabel.String = char(str_lfp(i));
    
%     % Bold if channel used for sleep scoring
%     if strcmp(char(strrep(str_lfp(i),'/','_')),char(ss_data.channel_lfp)) || strcmp(char(strrep(str_lfp(i),'\','_')),char(ss_data.channel_lfp))
%         ax.YLabel.FontWeight = 'bold';
%         ax.YLabel.String = sprintf('%s\n(Scoring)', ax.YLabel.String);
%     end
    
    set(ax,'XTickLabel','','XTick','');
    %     ax.YAxis.Visible = 'off';
    %     set(ax,'YTick','');
    set(ax,'YTickLabel','');
    ax.TickLength(1)=0;
    
    %Y-Scale
    t200 = uicontrol(f,'Units','normalized','Style','text',...
        'TooltipString','Scale','String','','BackgroundColor','k');
    t201 = uicontrol(f,'Units','normalized','Style','text',...
        'String','','FontSize',6,'HorizontalAlignment','left');
    %     t201 = text(.888,ax.Position(2),'x');
    t200.Position = [.884 ax.Position(2) .001 ax.Position(4)];
    t201.Position = [.886 ax.Position(2) .02 ax.Position(4)];
    
    
    %Plotting tag patches
    for j=1:size(TimeTags_seconds,1)
        x = [TimeTags_seconds(j,1),TimeTags_seconds(j,2),TimeTags_seconds(j,2),TimeTags_seconds(j,1)];
        y = [-y_inf,-y_inf,y_inf,y_inf];
        %Patch
        patch('XData',x,...
            'YData',y,...
            'FaceColor',patch_colors(j,:),...
            'EdgeColor',edge_color,...
            'FaceAlpha',face_alpha(j),...
            'Tag',sprintf('Patch%d_%d',i,j),...
            'Parent',ax);
    end
    
    % Plotting line
    try
        X = l(i).UserData.X;
        Y = l(i).UserData.Y;
    catch
        X = t(~isnan(l(i).XData))';
        Y = l(i).YData(~isnan(l(i).XData))';
    end
    delta_x = X(2)-X(1);
    line('XData',X,'YData',Y,'Parent',ax,'Color',l(i).Color);
    
    ax.XLim = [t(START_IM);t(END_IM)];
    
    % Plotting Cursor
    y_inf = 100000;
    c = line([NaN NaN],[-y_inf y_inf],'Parent',ax,'LineWidth',1,'Color',[.5 .5 .5],'Tag','Cursor');
    c.Tag = sprintf('Cursor%d',i);
    
    % Storing data
    all_axes = [all_axes;ax];
    % ax.UserData.X = X;
    % Adding NaN values to fit Y if not starting at 0
    X_sup = (flip(X(1)-delta_x:-delta_x:0))';
    Y_sup = NaN(size(X_sup));
    Y = [Y_sup;Y(:);NaN(1e6,1)];
    
    ax.UserData.Y = Y;
    ax.UserData.Tag = l(i).Tag;
    X_post = X(end)+(delta_x:delta_x:delta_x*1e6)';
    ax.UserData.X = [X_sup;X(:);X_post];
    
%     s = Y(floor(t(START_IM)/delta_x):floor(t(END_IM)/delta_x),1);
    s = Y(max(1,floor(t(START_IM)/delta_x)):floor(t(END_IM)/delta_x),1);
    ax.UserData.series = s;
    ax.UserData.delta_x = delta_x;
    ax.UserData.mean = mean(s);
    ax.UserData.stdev = std(s);
    ax.UserData.scale = scale;
    ax.UserData.color = l(i).Color;
    ax.UserData.t200 = t200;
    ax.UserData.t201 = t201;
end
% Spectrograms
for i=l1+1:L
    ax = axes('Position',[.4 .1+(i-1)*.8/L+margin .5 .8/L-2*margin],'Parent',f,'XTickLabel','','FontSize',8);
    ii = i-l1;
    ax.Tag = sprintf('Ax%d',i);
    ax.XAxis.Visible = 'off';
    ax.YLabel.String = char(data_spectrogram(ii).name);
    
    % Plotting spectro
    X = data_spectrogram(ii).Xdata;
    Y = data_spectrogram(ii).freqdom;
    Z = data_spectrogram(ii).Cdata;
    delta_x = X(2)-X(1);
    %Gaussian smoothing
    exp_cor = .25;
    t_smooth = 1;
    step = t_smooth/delta_x;
    % Correction
    correction = repmat((data_spectrogram(ii).freqdom(:).^exp_cor),1,size(Z,2));
    correction = correction/correction(end,1);
    Z = imgaussfilt(Z,[1 step]).*correction;
    e4.String = sprintf('%.1f',min(Z(:)));
    e5.String = sprintf('%.1f',max(Z(:)));
    
    % Adding NaN values to fit Y if not starting at 0
    X_sup = (flip(X(1)-delta_x:-delta_x:0))';
    Z_sup = NaN(length(Y),length(X_sup));
    X_end = (X(end)+delta_x:delta_x:t(end))';
    Z_end = NaN(length(Y),length(X_end));
    Z = cat(2,Z_sup,Z,Z_end);
    X = [X_sup(:);X(:);X_end(:)];
    %plotting
    im3 = imagesc('XData',X,'YData',Y,'CData',Z,'Parent',ax);
    cursor = line('Parent',ax,'LineWidth',1,'Color',[.5 .5 .5]);
    spectro = line('Parent',ax,'LineWidth',1,'Color','w');
    ax.XLim = [t(START_IM);t(END_IM)];
    ax.YLim = [Y(1),Y(end)];
    ax.YDir = 'normal';
    
    % Plotting Cursor
    c = line([NaN NaN],[-y_inf y_inf],'Parent',ax,'LineWidth',1,'Color',[.5 .5 .5]);
    c.Tag = sprintf('Cursor%d',i);
    
    % Storing data
    all_spectraxes = [all_spectraxes;ax];
    all_images = [all_images;im3];
    %ax.UserData.X = [X_sup;X];
    ax.UserData.Z = Z;
    ax.UserData.delta_x = delta_x;
    ax.UserData.cursor = cursor;
    ax.UserData.spectro = spectro;
end


% Figure Position
% f.Position = [.1 .1 .6 .6];
f.OuterPosition =[0 0 1 1];
ax_im.Position = [.05 .425 .3 .425];
ax_im2.Position = [.05 .025 .3 .375];
ax_im3.Position = [.05 .875 .3 .075];
cbar.Position = [.03 .425 .015 .425];

e0.Position = [.91 .925 .08 .05];
t1.Position = [.91 .85 .08 .05];
t2.Position = [.91 .8 .08 .05];
t3.Position = [.91 .75 .08 .05];
t4.Position = [.91 .7 .08 .05];
t5.Position = [.91 .65 .08 .05];
t6.Position = [.91 .6 .08 .05];
t7.Position = [.91 .55 .08 .05];
t8.Position = [.91 .5 .08 .05];

ttg(1).Position = [.91 .45 .08 .04];
ttg(2).Position = [.91 .4 .08 .04];
ttg(3).Position = [.91 .35 .08 .04];
ttg(4).Position = [.91 .3 .08 .04];
ttg(5).Position = [.91 .25 .08 .04];
ttg(6).Position = [.91 .2 .08 .04];
ttg(7).Position = [.91 .15 .08 .04];
ttg(8).Position = [.91 .1 .08 .04];

% t100.Position = [.55 .05 .45 .005];
% t101.Position = [.55 .055 .4 .045];
cb1.Position = [.01 .01 .1 .05];
e1.Position = [.005 .025 .04 .05];
e2.Position = [.005 .075 .04 .05];
cb2.Position = [.92 .01 .08 .05];
e3.Position = [.955 .06 .04 .05];
cb3.Position = [.01 .9 .1 .05];
cb_atlas.Position = [.01 .95 .05 .05];
e4.Position = [.005 .85 .04 .05];
e5.Position = [.005 .9 .04 .05];
t100.Position = [.88-(.45*t_factor)/(2*f.UserData.t_lfp) .0025 (.45*t_factor)/(2*f.UserData.t_lfp) .0025];
t101.Position = [.88-(.45*t_factor)/(2*f.UserData.t_lfp) .005 (.45*t_factor)/(2*f.UserData.t_lfp) .015];

% Visible status
cb1.Visible = button_visible;
cb2.Visible = button_visible;
cb3.Visible = button_visible;
t3.Visible = button_visible;
t4.Visible = button_visible;
f.UserData.controls = [cb1;cb2;cb3;t3;t4];

% Movie
i = START_IM;

while i>=START_IM && i<=END_IM
    if ishandle(f)
        tic;
        f.UserData.i = i;
        t_lfp = f.UserData.t_lfp;
        
        t_video = str2double(e0.String);
        f.UserData.t_video = t_video;
        %t_video = f.UserData.t_video;
        %Update timing
        t1.String = sprintf('%s',datestr(t(i)/(24*3600),'HH:MM:SS.FFF'));
        t2.String = sprintf('%d/%d',i,END_IM);
        % Update movie
        im.CData = IM(:,:,i);
        % image(bw_video(:,:,:,i+1-START_IM),'Parent',ax_im2);
        % imagesc(bw_video(:,:,i),'Parent',ax_im2);
        
        try
            t7.String = sprintf('LFP time:\n%s',t_str1(i,:));
            t8.String = sprintf('Video time:\n%s',t_str2(i,:));
        catch
            t7.String = 'No Video';
            t8.String = 'No Video';
        end
        % Update video
        im2.CData = bw_video(:,:,i);
        colormap(ax_im2,'gray');
        axis(ax_im2,'equal');
        ax_im2.Visible = 'off';
        
        % Cursor
        l_cursor.XData = [i i];
        l_cursor.YData = [ax_im3.YLim(1) ax_im3.YLim(2)];
        
        %         % Atlas
        %         if (val==0) && (i<=START_IM+100)
        %             cb_atlas.Value = 1;
        %         else
        %             cb_atlas.Value = handles.AtlasBox.Value;
        %         end
        %         boxAtlas_Callback(cb_atlas,[],ax_im);
        
        % Plotting traces
        for j=1:length(all_axes)
            ax = all_axes(j);
            X = ax.UserData.X;
            Y = ax.UserData.Y;
            delta_x = ax.UserData.delta_x;
            cla(ax);
            
            %Data
            %ind_0 = floor(t(i)/delta_x);
            %Y0 = Y(floor(ind_0-t_lfp/delta_x):floor(ind_0+t_lfp/delta_x));
            
            % Bug correction : Select Y by indexing X
            [~,ind_1] = min((X-(t(i)-t_lfp)).^2);
            [~,ind_2] = min((X-(t(i)+t_lfp)).^2);
            Y0 = Y(ind_1:ind_2);
            
            %coefficients
            A = (length(Y0)-1)/(2*t_lfp);
            B = 1-A*(t(i)-t_lfp);
            %Patch
            for k=1:size(TimeTags_seconds,1)
                x_1 = A*TimeTags_seconds(k,1)+B;
                x_2 = A*TimeTags_seconds(k,2)+B;
                x = [x_1,x_2,x_2,x_1];
                y = [-y_inf,-y_inf,y_inf,y_inf];
                %Patch
                patch('XData',x,...
                    'YData',y,...
                    'FaceColor',patch_colors(k,:),...
                    'EdgeColor',edge_color,...
                    'FaceAlpha',face_alpha(k),...
                    'Tag',sprintf('Patch%d_%d',j,k),...
                    'Parent',ax);
            end
            %Trace
            line(1:length(Y0),Y0,'Parent',ax,'Tag','Trace',...
                'LineWidth',.5,'Color',ax.UserData.color);
            
            % Show Ripple Events
            if ~isempty(events)
%                 n_events = size(events,2);
                t_ripples_start = events(:,1);
                t_ripples = events(:,2);
                t_ripples_end = events(:,3);
                ind_keep = find(sign((t_ripples-(t(i)-t_lfp)).*(t_ripples-(t(i)+t_lfp)))<=0);

                if ~isempty(ind_keep)
                    for k=1:length(ind_keep)
                        t_rip = t_ripples(ind_keep(k));
                        x_rip = (t_rip-(t(i)-t_lfp))/(2*t_lfp);
                        t_rip_start = t_ripples_start(ind_keep(k));
                        x_rip_start = (t_rip_start-(t(i)-t_lfp))/(2*t_lfp);
                        t_rip_end = t_ripples_end(ind_keep(k));
                        x_rip_end = (t_rip_end-(t(i)-t_lfp))/(2*t_lfp);

                        patch('XData',[.5+x_rip_start*length(Y0) .5+x_rip_start*length(Y0) .5+x_rip_end*length(Y0) .5+x_rip_end*length(Y0)],...
                            'YData',[ax.YLim(1) ax.YLim(2) ax.YLim(2) ax.YLim(1)],...
                            'FaceColor',[.5 .5 .5],'EdgeColor',[.5 .5 .5],'FaceAlpha',.5,'Parent',ax);
                        line('XData',[.5+x_rip*length(Y0) .5+x_rip*length(Y0)],'YData',[ax.YLim(1) ax.YLim(2)],...
                            'LineWidth',1,'LineStyle','-','Color','r','Parent',ax,'Tag','EventLine','HitTest','off');
                    end
                end
            end
            
            
            %Cursor
            line([.5+.5*length(Y0) .5+.5*length(Y0)],[-1e6  1e6],...
                'Parent',ax,'LineWidth',1,'Color',[.5 .5 .5]);
            ax.XLim = [1,length(Y0)];
            ax.UserData.Y0 = Y0;
        end
        
        % Plotting spectrogramms
        for j=1:length(all_images)
            im3 = all_images(j);
            ax = all_spectraxes(j);
            Z = ax.UserData.Z;
            delta_x = ax.UserData.delta_x;
            
            ind_0 = floor(t(i)/delta_x);
            X0 = floor(ind_0-t_lfp/delta_x):floor(ind_0+t_lfp/delta_x);
            im3.CData = Z(:,X0);
            
            im3.XData = 1:length(X0);
            ax.XLim = [1,length(X0)];
            ax.UserData.cursor.XData = [.5+.5*length(X0) .5+.5*length(X0)];
            ax.UserData.cursor.YData = [-1e3 1e3];
            ax.UserData.spectro.XData = (mean(im3.CData,2,'omitnan')/max(im3.CData(:)))*length(X0)/5;
            ax.UserData.spectro.YData = im3.YData;
        end
        
        % Displaying corresponding time tags
        str = t3.UserData.all_str(i);
        t3.String = char(str);
        % Displaying corresponding time surges
        str = t4.UserData.all_str(i);
        t4.String = char(str);
        % Displaying Time Groups
        for j = 1:min(length(ttg),length(tg_cell))
            if ttg(j).UserData.index_timegroup(i)>0
                ttg(j).BackgroundColor = 'k';
                ttg(j).ForegroundColor = 'w';
            else
                ttg(j).BackgroundColor = 'w';
                ttg(j).ForegroundColor = 'k';
            end
        end
        
        % Only on event
        % Scale Position
        t100.Position = [.88-(.45*t_factor)/(2*t_lfp) .0025 (.45*t_factor)/(2*t_lfp) .0025];
        t101.Position = [.88-(.45*t_factor)/(2*t_lfp) .005 (.45*t_factor)/(2*t_lfp) .015];
        % CLimMode
        if cb1.Value
            ax_im.CLimMode = 'auto';
            cb1.String = 'auto';
            e1.Visible = 'off';
            e2.Visible = 'off';
        else
            ax_im.CLimMode = 'manual';
            cb1.String = 'manual';
            ax_im.CLim = [str2double(e1.String),str2double(e2.String)];
            e1.Visible = f.UserData.button_visible;
            e2.Visible = f.UserData.button_visible;
            
        end
        % YLimMode
        all_lfp_lims = [];
        all_lfp_axes = [];
        for j=1:length(all_axes)
            ax = all_axes(j);
            cur_label = char(str_lfp(j));
            if ~cb2.Value
                cb2.String = 'auto';
                ax.YLimMode = 'auto';
                e3.Visible = 'off';
                lim_inf = min(ax.UserData.Y0(:));
                lim_sup = max(ax.UserData.Y0(:));
            else
                cb2.String = 'manual';
                ax.YLimMode = 'manual';
                e3.Visible = f.UserData.button_visible;
                
                %                 as_factor = str2double(e3.String);
                switch ax.UserData.Tag
                    case 'Trace_Cerep'
                        % new scaling (IQ range)
                        temp = prctile(ax.UserData.series(:),[5 95]);
                        iq_r = temp(2)-temp(1);
                        lim_inf = temp(1)-.5*iq_r;
                        lim_sup = temp(2)+.5*iq_r;
                        %                         % old scaling (std-based)
                        %                         lim_inf = ax.UserData.mean-as_factor*ax.UserData.stdev;
                        %                         lim_sup = ax.UserData.mean+as_factor*ax.UserData.stdev;
                        
                        if startsWith(cur_label,'LFP')
                            all_lfp_axes = [all_lfp_axes;ax];
                            all_lfp_lims = [all_lfp_lims;lim_inf,lim_sup];
                        end
                        
                    case {'Trace_Mean';'Trace_Pixel';'Trace_Region';'Trace_Box'}
                        
                        % new scaling (IQ range)
                        temp = prctile(ax.UserData.series(:),[0 99]);
                        iq_r = temp(2)-temp(1);
                        lim_inf = temp(1);
                        lim_sup = temp(2)+.5*iq_r;
                        %                         % old scaling (min-max)
                        %                         lim_inf = min(ax.UserData.series(:));
                        %                         lim_sup = max(ax.UserData.series(:));
                        %                         % lim_inf = lim_inf - .1*(lim_sup-lim_inf);
                        %                         % lim_sup = lim_sup + .1*(lim_sup-lim_inf);
                end
                
            end
            % YLim
            if lim_inf<lim_sup
                ax.YLim = [lim_inf, lim_sup];
            else
                ax.YLim = [0,1];
            end
            % Y-Scale
            delta_y=lim_sup-lim_inf;
            exp_scale = floor(log(delta_y)/log(10));
            floor_scale = 10^exp_scale;
            if delta_y>0
                ax.UserData.t200.Position(4) = ax.Position(4)*floor_scale/delta_y;
                ax.UserData.t201.Position(4) = ax.Position(4)*floor_scale/(1.5*delta_y);
            end
            %             ax.UserData.t201.String = sprintf('10^%d',exp_scale);
            ax.UserData.t201.String = sprintf('%.0f',floor_scale);
            %             set(ax.UserData.t201,'Rotate',90);
        end
        
        % Rescaling LFP axes
        if ~isempty(all_lfp_lims)
            lim_inf = min(all_lfp_lims(:,1));
            lim_sup = max(all_lfp_lims(:,2));
            delta_y=lim_sup-lim_inf;
            exp_scale = floor(log(delta_y)/log(10));
            floor_scale = 10^exp_scale;
        end
        for j=1:size(all_lfp_axes,1)
            ax_lfp = all_lfp_axes(j);
            try
                ax_lfp.YLim = [lim_inf, lim_sup];
            catch
                ax_lfp.YLim = [lim_inf, lim_sup];
            end
            % Y-Scale
            ax_lfp.UserData.t200.Position(4) = ax_lfp.Position(4)*floor_scale/delta_y;
            ax_lfp.UserData.t201.Position(4) = ax_lfp.Position(4)*floor_scale/(1.5*delta_y);
            %             ax_lfp.UserData.t201.String = sprintf('10^%d',exp_scale);
            ax_lfp.UserData.t201.String = sprintf('%.0f',floor_scale);
            %             set(ax_lfp.UserData.t201,'Rotate',90);
        end
        
        % CLimMode
        if cb3.Value
            cb3.String = 'auto';
            e4.Visible = 'off';
            e5.Visible = 'off';
        else
            cb3.String = 'manual';
            e4.Visible = f.UserData.button_visible;
            e5.Visible = f.UserData.button_visible;
        end
        % CLimMode
        for j=1:length(all_spectraxes)
            ax  = all_spectraxes(j);
            if cb3.Value
                ax.CLimMode = 'auto';
            else
                ax.CLimMode = 'manual';
                ax.CLim = [str2double(e4.String),str2double(e5.String)];
            end
        end
        
        % Delay to start
        if i==START_IM
            count = t_start;
            while count>0
                t3.String = count;
                count = count-1;
                drawnow;
                pause(1);
            end
        else
            t_elapsed = toc;
            if t_video-t_elapsed>0
                if strcmp(display_mode,'disp')
                    %pause(t_video-t_elapsed);
                else
                    % Saving
                    pic_name = strcat(sprintf('%s_Frame%05d',FILES(CUR_FILE).nlab,i),GTraces.ImageSaveExtension);
                    if exist(fullfile(work_dir,pic_name),'file')
                        pic_name = strcat(sprintf('%s_Frame%05d_%03d',FILES(CUR_FILE).nlab,i,count_save),GTraces.ImageSaveExtension);
                    end
                    saveas(f,fullfile(work_dir,pic_name),GTraces.ImageSaveFormat);
                    fprintf('Saving frame %s.\n',pic_name);
                    if i == END_IM
                        %close(f);
                        if strcmp(display_mode,'video')
                            %                             save_video(work_dir,save_dir,sprintf('%s_EEG-fUS-VIDEO_%s',FILES(CUR_FILE).nlab,tag));
                            save_video(work_dir,save_dir,sprintf('[%s]%s-%s',f.UserData.atlas_name,FILES(CUR_FILE).nlab,tag),25);
                        end
                        f.UserData.success = true;
                        return;
                    end
                end
            else
                warning('losing pace -> slowing down');
                f.UserData.t_video = 2*f.UserData.t_video;
                e0.String = sprintf('%.3f',f.UserData.t_video);
            end
        end
        
        % Iterate i depending on f.UserData.flag value
        switch f.UserData.flag
            case 1
                if i == frame_pause && flag_pause && strcmp(display_mode,'save')
                    %pause
                    if f.UserData.t_lfp > zoom_min
                        f.UserData.t_lfp = f.UserData.t_lfp/f.UserData.factor_zoom;
                        count_save = count_save+1;
                        fprintf('Zoom in %.2f.\n',f.UserData.t_lfp);
                    else
                        f.UserData.t_lfp = zoom_max;
                        fprintf('Zoom out %.2f.\n',f.UserData.t_lfp);
                        count_save = 0;
                        i = i+1;
                        flag_pause = false;
                    end
                elseif i~=END_IM
                    i=i+1;
                else
                    i=i-1;
                    f.UserData.flag = 0;
                end
            case -1
                if i~=START_IM
                    i=i-1;
                else
                    i=i+1;
                    f.UserData.flag = 0;
                end
            case -100
                %close(f);
                return;
            case 10
                i = min(i+100,END_IM);
                f.UserData.flag = 1;
            case -10
                i = max(i-100,START_IM);
                f.UserData.flag = 1;
        end
        %toc
    else
        return;
    end
    
end

f.UserData.success = true;
% close(f);

end

function f_keypress_fcn(hObj,evnt)

%hObj.UserData.flag
%evnt.Key
e0 = findobj(hObj,'Tag','Edit0');
switch evnt.Key
    case 'uparrow'
        hObj.UserData.flag=10;
    case 'downarrow'
        hObj.UserData.flag=-10;
    case 'rightarrow'
        hObj.UserData.flag=1;
    case 'leftarrow'
        hObj.UserData.flag=-1;
    case 'space'
        hObj.UserData.flag =(hObj.UserData.flag-1)^2;
    case 'q'
        hObj.UserData.flag =-100;
    case 'm'
        hObj.UserData.t_video = 2*hObj.UserData.t_video;
        e0.String = sprintf('%.3f',hObj.UserData.t_video);
    case 'p'
        hObj.UserData.t_video = hObj.UserData.t_video/2;
        e0.String = sprintf('%.3f',hObj.UserData.t_video);
    case 'a'
        hObj.UserData.t_lfp = hObj.UserData.t_lfp/hObj.UserData.factor_zoom;
    case 'z'
        hObj.UserData.t_lfp = hObj.UserData.t_lfp*hObj.UserData.factor_zoom;
    case 's'
        add_dir = hObj.UserData.add_dir;
        number = hObj.UserData.i;
        filename = hObj.UserData.filename;
        extension = hObj.UserData.extension;
        format = hObj.UserData.format;
        if ~exist(add_dir,'dir')
            mkdir(add_dir)
        end
        count = 1;
        pic_name = strcat(sprintf('%s_Frame%05d_%03d',filename,number,count),extension);
        while exist(fullfile(add_dir,pic_name),'file')
            count = count+1;
            pic_name = strcat(sprintf('%s_Frame%05d_%03d',filename,number,count),extension);
        end
        %pic_name = strcat(sprintf('%s_Frame%05d_%03d',filename,number,count),extension);
        saveas(hObj,fullfile(add_dir,pic_name),format);
        fprintf('[Saving Frame %s, format %s]\n',fullfile(add_dir,pic_name),format);
    case 'v'
        button_visible = hObj.UserData.button_visible;
        controls = hObj.UserData.controls;
        if strcmpi(button_visible,'on')
            for i=1:length(controls)
                controls(i).Visible = 'off';
            end
            hObj.UserData.button_visible = 'off';
        else
            hObj.UserData.button_visible = 'on';
            for i=1:length(controls)
                controls(i).Visible = 'on';
            end
        end
        
end

end
