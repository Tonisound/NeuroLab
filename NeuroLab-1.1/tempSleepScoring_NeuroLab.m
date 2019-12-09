% for use with NeuroLab 
% coded by Marta MATEI : marta.matei@hotmail.fr
% user Antoine BERGEL : antoine.bergel@espci.fr
%
% Semi-automatic sleep scoring algorithm, to detect active wake (AW), quiet
% wake (QW), rapid-eye-movement sleep (REM) and non-REM (NREM). 
% Uses LFP, EMG and accelerometer data.


%% main function
function fig = tempSleepScoring_NeuroLab(handles,val)
% needs NeuroLab to be open in Matlab
% to call it : fig = SleepScoring_NeuroLab(FILES,CUR_FILE,DIR_SAVE)

global FILES CUR_FILE DIR_SAVE;
%global FILES CUR_FILE;

% If nargin > 2 batch processing
% val indicates callback provenance (0 : batch mode - 1 : user mode)
if nargin < 2
    val=1;
end

% Initialize paths
path_traces = fullfile(DIR_SAVE,FILES(CUR_FILE).nlab,'Sources_LFP');
oldFolder = 'C:\Users\Marta\Documents\MATLAB\NeuroLab';

% check if LFP traces imported
cd(path_traces);
listing = dir('*LFP*.mat');
if isempty(listing)
    disp('LFP not found, please import LFP traces')
end

% Loading Time Reference
if exist(fullfile(DIR_SAVE,FILES(CUR_FILE).nlab,'Time_Reference.mat'),'file')
    time_references = load(fullfile(DIR_SAVE,FILES(CUR_FILE).nlab,'Time_Reference.mat'),'time_ref','time_str');
else
    errordlg('File Time_Reference.mat not found.');
    return;
end

% Loading Time Tags
if exist(fullfile(DIR_SAVE,FILES(CUR_FILE).nlab,'Time_Tags.mat'),'file')
    tdata = load(fullfile(DIR_SAVE,FILES(CUR_FILE).nlab,'Time_Tags.mat'),...
        'TimeTags','TimeTags_cell','TimeTags_strings','TimeTags_images');
else
    errordlg('File Time_Tags.mat not found.');
    return;
end

% Loading SleepScore file
if exist('C:\Users\Marta\Documents\MATLAB\NeuroLab\SleepScore.mat','file')
    load('C:\Users\Marta\Documents\MATLAB\NeuroLab\SleepScore');
else
    disp('File SleepScore.mat not found.');
end

file_info = strsplit(FILES(CUR_FILE).recording,'_');
date = file_info(1); animal_id = file_info(2); recording = file_info(3); type = file_info(4);

SleepScore(CUR_FILE) = struct('Animal_ID',animal_id,'Date',date,...
    'Recording',recording,'Type',type,...
    'REM_number',[],'REM_mean',[],'REM_tot',[],'REM_dur',[],...
    'INT_mean',[],'INT_dur',[]);

% Import traces
cd(path_traces);
list_EMG = dir('*EMG*.mat');
list_ACC = dir('*ACC*.mat');
list_GYR = dir('*GYR*.mat');
list_LFP = dir('*LFP_*.mat');


% Create figure
fig = figure('Name','Sleep Scoring Algorithm',...
    'Units','normalized',...
    'Tag','MainFigure',...
    'Position',[.1 .2 .8 .65],...
    'HandleVisibility','on',...
    'Visible','off');
fig.UserData.success = false;
fig.UserData.recording = fullfile(DIR_SAVE,FILES(CUR_FILE).nlab);

% Create panel 1 for axes (ACC + EMG + LFP + ratio)
p1 = uipanel('Parent',fig,...
    'Tag','graphpanel',...
    'Units','normalized',...
    'Position',[.01 .345 .98 .655]);

tabgp = uitabgroup('Parent',p1,...
    'Tag','tabgp',...
    'Units','normalized');

% Tab 1
t1 = uitab('Parent',tabgp,...
    'Tag','graphtab',...
    'Title','Scoring');

ax1 = axes('Parent',t1,...          % Accelerometer
    'Tag','axACC',...
    'XTickLabel',{}); 
txt1 = uicontrol('Parent',t1,...
    'Style','text',...
    'Units','normalized',...
    'String','Accelerometer');
ax2 = axes('Parent',t1,...          % EMG power
    'Tag','axEMG',...
    'XTickLabel',{}); 
txt2 = uicontrol('Parent',t1,...
    'Style','text',...
    'Units','normalized',...
    'String','EMG power');
ax3 = axes('Parent',t1,...          % LFP signal
    'Tag','axLFP',...
    'XTickLabel',{});
txt3 = uicontrol('Parent',t1,...
    'Style','text',...
    'Units','normalized',...
    'String','LFP signal');
ax4 = axes('Parent',t1,...            % theta/delta ratio
    'Tag','axRatio');
txt4 = uicontrol('Parent',t1,...
    'Style','text',...
    'Units','normalized',...
    'String','theta/delta ratio');

ax1.Position  = [.10 .74 .89 .22];
txt1.Position = [.01 .74 .06 .10];
ax2.Position  = [.10 .51 .89 .22];
txt2.Position = [.01 .51 .06 .10];
ax3.Position  = [.10 .28 .89 .22];
txt3.Position = [.01 .28 .06 .10];
ax4.Position  = [.10 .05 .89 .22];
txt4.Position = [.01 .05 .06 .10];

% Tab 2
t2 = uitab('Parent',tabgp,...
    'Tag','infotab',...
    'Title','Scoring Info');

% Durations
dur_total = uicontrol('Parent',t2,...
    'Style','text',...
    'Units','normalized',...
    'HorizontalAlignment', 'left',...
    'String','Total duration');
dur_aw = uicontrol('Parent',t2,...
    'Style','text',...
    'Units','normalized',...
    'HorizontalAlignment', 'left',...
    'String','Total AW');
dur_qw = uicontrol('Parent',t2,...
    'Style','text',...
    'Units','normalized',...
    'HorizontalAlignment', 'left',...
    'String','Total QW');
dur_nrem = uicontrol('Parent',t2,...
    'Style','text',...
    'Units','normalized',...
    'HorizontalAlignment', 'left',...
    'String','Total NREM');
dur_rem = uicontrol('Parent',t2,...
    'Style','text',...
    'Units','normalized',...
    'HorizontalAlignment', 'left',...
    'String','Total REM');

dur_total_edit = uicontrol('Parent',t2,...
    'Style','text',...
    'Units','normalized',...
    'BackgroundColor',[1, 1, 1],...
    'String',[]);
dur_aw_edit = uicontrol('Parent',t2,...
    'Style','text',...
    'Units','normalized',...
    'BackgroundColor',[1, 1, 1],...
    'String',[]);
dur_qw_edit = uicontrol('Parent',t2,...
    'Style','text',...
    'Units','normalized',...
    'BackgroundColor',[1, 1, 1],...
    'String',[]);
dur_nrem_edit = uicontrol('Parent',t2,...
    'Style','text',...
    'Units','normalized',...
    'BackgroundColor',[1, 1, 1],...
    'String',[]);
dur_rem_edit = uicontrol('Parent',t2,...
    'Style','text',...
    'Units','normalized',...
    'BackgroundColor',[1, 1, 1],...
    'String',[]);

dur_total.Position = [.01 .85 .05 .035];
dur_aw.Position    = [.01 .75 .05 .035];
dur_qw.Position    = [.01 .70 .05 .035];
dur_nrem.Position  = [.01 .65 .05 .035];
dur_rem.Position   = [.01 .60 .05 .035];

dur_total_edit.Position = [.07 .85 .07 .035];
dur_aw_edit.Position    = [.07 .75 .07 .035];
dur_qw_edit.Position    = [.07 .70 .07 .035];
dur_nrem_edit.Position  = [.07 .65 .07 .035];
dur_rem_edit.Position   = [.07 .60 .07 .035];

% Percentages /total
perc_aw = uicontrol('Parent',t2,...
    'Style','text',...
    'Units','normalized',...
    'HorizontalAlignment', 'left',...
    'String','Percentage AW/total');
perc_qw = uicontrol('Parent',t2,...
    'Style','text',...
    'Units','normalized',...
    'HorizontalAlignment', 'left',...
    'String','Percentage QW/total');
perc_nrem = uicontrol('Parent',t2,...
    'Style','text',...
    'Units','normalized',...
    'HorizontalAlignment', 'left',...
    'String','Percentage NREM/total');
perc_rem = uicontrol('Parent',t2,...
    'Style','text',...
    'Units','normalized',...
    'HorizontalAlignment', 'left',...
    'String','Percentage REM/total');

perc_aw_edit = uicontrol('Parent',t2,...
    'Style','text',...
    'Units','normalized',...
    'BackgroundColor',[1, 1, 1],...
    'String',[]);
perc_qw_edit = uicontrol('Parent',t2,...
    'Style','text',...
    'Units','normalized',...
    'BackgroundColor',[1, 1, 1],...
    'String',[]);
perc_nrem_edit = uicontrol('Parent',t2,...
    'Style','text',...
    'Units','normalized',...
    'BackgroundColor',[1, 1, 1],...
    'String',[]);
perc_rem_edit = uicontrol('Parent',t2,...
    'Style','text',...
    'Units','normalized',...
    'BackgroundColor',[1, 1, 1],...
    'String',[]);

perc_aw.Position    = [.17 .75 .08 .035];
perc_qw.Position    = [.17 .70 .08 .035];
perc_nrem.Position  = [.17 .65 .08 .035];
perc_rem.Position   = [.17 .60 .08 .035];

perc_aw_edit.Position    = [.26 .75 .07 .035];
perc_qw_edit.Position    = [.26 .70 .07 .035];
perc_nrem_edit.Position  = [.26 .65 .07 .035];
perc_rem_edit.Position   = [.26 .60 .07 .035];

% Percentages /wake-sleep
perc_aw_wake = uicontrol('Parent',t2,...
    'Style','text',...
    'Units','normalized',...
    'HorizontalAlignment', 'left',...
    'String','Percentage AW/wake');
perc_qw_wake = uicontrol('Parent',t2,...
    'Style','text',...
    'Units','normalized',...
    'HorizontalAlignment', 'left',...
    'String','Percentage QW/wake');
perc_nrem_sleep = uicontrol('Parent',t2,...
    'Style','text',...
    'Units','normalized',...
    'HorizontalAlignment', 'left',...
    'String','Percentage NREM/sleep');
perc_rem_sleep = uicontrol('Parent',t2,...
    'Style','text',...
    'Units','normalized',...
    'HorizontalAlignment', 'left',...
    'String','Percentage REM/sleep');

perc_aw_wake_edit = uicontrol('Parent',t2,...
    'Style','text',...
    'Units','normalized',...
    'BackgroundColor',[1, 1, 1],...
    'String',[]);
perc_qw_wake_edit = uicontrol('Parent',t2,...
    'Style','text',...
    'Units','normalized',...
    'BackgroundColor',[1, 1, 1],...
    'String',[]);
perc_nrem_sleep_edit = uicontrol('Parent',t2,...
    'Style','text',...
    'Units','normalized',...
    'BackgroundColor',[1, 1, 1],...
    'String',[]);
perc_rem_sleep_edit = uicontrol('Parent',t2,...
    'Style','text',...
    'Units','normalized',...
    'BackgroundColor',[1, 1, 1],...
    'String',[]);

perc_aw_wake.Position    = [.36 .75 .08 .035];
perc_qw_wake.Position    = [.36 .70 .08 .035];
perc_nrem_sleep.Position  = [.36 .65 .08 .035];
perc_rem_sleep.Position   = [.36 .60 .08 .035];

perc_aw_wake_edit.Position    = [.45 .75 .07 .035];
perc_qw_wake_edit.Position    = [.45 .70 .07 .035];
perc_nrem_sleep_edit.Position  = [.45 .65 .07 .035];
perc_rem_sleep_edit.Position   = [.45 .60 .07 .035];

% Retrieve t2 variables
t2.UserData.total_duration = dur_total_edit;
t2.UserData.aw_duration = dur_aw_edit;
t2.UserData.qw_duration = dur_qw_edit;
t2.UserData.nrem_duration = dur_nrem_edit;
t2.UserData.rem_duration = dur_rem_edit;

t2.UserData.aw_percentage = perc_aw_edit;
t2.UserData.qw_percentage = perc_qw_edit;
t2.UserData.nrem_percentage = perc_nrem_edit;
t2.UserData.rem_percentage = perc_rem_edit;

t2.UserData.aw_wake_percentage = perc_aw_wake_edit;
t2.UserData.qw_wake_percentage = perc_qw_wake_edit;
t2.UserData.nrem_sleep_percentage = perc_nrem_sleep_edit;
t2.UserData.rem_sleep_percentage = perc_rem_sleep_edit;

p1.UserData.t2 = t2.UserData;

% Create panel 2 for Hypnogram
p2 = uipanel('Parent',fig,...
    'Tag','scorepanel',...
    'Units','normalized',...
    'Position',[.01 .185 .98 .16]);

ax5 = axes('Parent',p2,...            % Hypnogram
    'Tag','hypnogram');
txt5 = uicontrol('Parent',p2,...
    'Style','text',...
    'Units','normalized',...
    'String','Hypnogram');
ax5.YLim = [-.5 3.5];
ax5.YTick = 0:3;
ax5.YTickLabel = {'REM';'NREM';'QW';'AW'};

ax5.Position  = [.10 .01 .89 .98];
txt5.Position = [.01 .45 .06 .15];


% Create panel 3 for interactive parts
p3 = uipanel('Parent',fig,...
    'Tag','actionpanel',...
    'Units','normalized',...
    'Position',[.01 .01 .98 .17]);

% Pie charts
ax6 = axes('Parent',p3,...
    'Tag','axtotal');
txt6 = uicontrol('Parent',p3,...
    'Style','text',...
    'Units','normalized',...
    'String','% duration over total');
ax7 = axes('Parent',p3,...
    'Tag','axwake');
txt7 = uicontrol('Parent',p3,...
    'Style','text',...
    'Units','normalized',...
    'String','% aw/qw over wake');
ax8 = axes('Parent',p3,...
    'Tag','axsleep');
txt8 = uicontrol('Parent',p3,...
    'Style','text',...
    'Units','normalized',...
    'String','% nrem/rem over sleep');

ax6.Position = [.30 .10 .10 .70];
ax7.Position = [.40 .10 .10 .70];
ax8.Position = [.50 .10 .10 .70];

txt6.Position = [.30 .85 .10 .10];
txt7.Position = [.40 .85 .10 .10];
txt8.Position = [.50 .85 .10 .10];

% Pop-up menus
PopupListACC = uicontrol('Parent',p3,...
    'Style','popupmenu',...
    'Tag','ListACC',...
    'Units','normalized',...
    'String',{list_ACC.name,list_GYR.name},...
    'ToolTipString','Select mouvement sensing channel to plot');

PopupListEMG = uicontrol('Parent',p3,...
    'Style','popupmenu',...
    'Tag','ListEMG',...
    'Units','normalized',...
    'String',{list_EMG.name},...
    'ToolTipString','Select mouvement sensing channel to plot');

PopupListLFP = uicontrol('Parent',p3,...
    'Style', 'popupmenu',...
    'Tag','ListLFP',...
    'Units','normalized',...
    'String',{list_LFP.name},...
    'ToolTipString','Select LFP channel to plot');

% Threshold edits
% SelectEpoch = uicontrol('Parent',p3,...
%     'Style','edit',...
%     'String',EpochSize,...
%     'ToolTipString','Enter the epoch size, in ms',...
%     'Units','normalized',...
%     'CallBack', {@SelectEpoch_Callback,ax5});

% Action buttons
EpochSize = 3000;
SelectEpoch = uicontrol('Parent',p3,...
    'Style','edit',...
    'Tag','Epoch',...
    'String',EpochSize,...
    'ToolTipString','Enter the epoch size, in ms',...
    'Units','normalized');

Overwrite = uicontrol('Parent',p3,...
    'Style','checkbox',...
    'Tag','Overwrite',...
    'String', 'Overwrite Time Tags',...
    'Units','normalized',...
    'ToolTipString','Press to replace existing Time Tags when selecting "Save Time Tags"');
fig.UserData.overwrite = 0;

SaveTimeTags = uicontrol('Parent',p3,...
    'Style','pushbutton',...
    'Tag','SaveTimeTags',...
    'String', 'Save Time Tags',...
    'Units','normalized',...
    'HandleVisibility','on',...
    'ToolTipString','Press to edit the Time_tags file');

GetTimeTags = uicontrol('Parent',p3,...
    'Style','pushbutton',...
    'Tag','GetTimeTags',...
    'String', 'Retrieve Time Tags',...
    'Units','normalized',...
    'HandleVisibility','on',...
    'ToolTipString','Press to retrieve the previous sleep score');

Reset = uicontrol('Parent',p3,...
    'Style','pushbutton',...
    'Tag','Reset',...
    'String', 'Reset',...
    'Units','normalized',...
    'ToolTipString','Press to reset score');

%Position
PopupListACC.Position  = [.01 .80 .10 .18];
PopupListEMG.Position  = [.01 .59 .10 .18];
PopupListLFP.Position  = [.01 .38 .10 .18];
SelectEpoch.Position   = [.01 .05 .10 .18];
Overwrite.Position     = [.885 .60 .01 .15];
SaveTimeTags.Position  = [.80 .52 .08 .30];
GetTimeTags.Position   = [.70 .52 .08 .30];
Reset.Position         = [.80 .18 .08 .30];

% Callback attribution
handles2 = guihandles(fig);
PopupListACC.Callback  = {@PopupListACC_Callback,handles2};
PopupListEMG.Callback  = {@PopupListEMG_Callback,handles2};
PopupListLFP.Callback  = {@PopupListLFP_Callback,handles2};
SelectEpoch.Callback   = {@SelectEpoch_Callback,handles2};
Overwrite.Callback     = {@Overwrite_Callback,handles2};
SaveTimeTags.Callback  = {@SaveTimeTags_Callback,handles2,time_references,tdata,DIR_SAVE,FILES,CUR_FILE};
GetTimeTags.Callback   = {@GetTimeTags_Callback,handles2,tdata};
Reset.Callback         = {@Reset_Callback,handles2};

% Retrieve variables
fig.UserData.p1 = p1.UserData;
fig.UserData.path_traces = path_traces;
fig.UserData.list_EMG = list_EMG;
fig.UserData.list_ACC = list_ACC;
fig.UserData.list_GYR = list_GYR;
fig.UserData.list_LFP = list_LFP;
fig.UserData.EpochSize = EpochSize;

fig.UserData.SleepScore = SleepScore;

reset(handles2)

linkaxes([ax1,ax2,ax3,ax4,ax5],'x');
ax1.XLim = [fig.UserData.MOVdata.x_start,fig.UserData.MOVdata.x_end];
fig.Visible = 'on';
set(fig, 'KeyPressFcn', @myKeyPressFcn)
cd(oldFolder);
fig.UserData.clicks = 0;

% graphical rendering
drawnow;
% batch mode
if val==0
    batch_Callback(handles2,tdata,time_references,DIR_SAVE,FILES,CUR_FILE);
end

end

function batch_Callback(handles,tdata,time_references,DIR_SAVE,FILES,CUR_FILE)
fig = handles.MainFigure;
fprintf('processing recording : [recording %s]\n',fig.UserData.recording);

% fig.UserData.overwrite = 1;

% h3 = findobj(gcf,'Tag','GetTimeTags') %get handle of the push button
% h = @GetTimeTags_Callback
% feval(h,[],[],handles,tdata);
% 
% h3bis = h3.Callback
% feval('get',h3)



% create file to get values for Komagata figures
for i = 1:size(tdata.TimeTags,1)
comp(i) = strcmpi(tdata.TimeTags(i).Onset,'00:00:00.001');
end
f = find(comp == 1,50,'first');

ind = 1;
for j = f(end):size(tdata.TimeTags,1)
    
    a = ~isempty(strfind(tdata.TimeTags(j).Tag,'AW'))+...
        ~isempty(strfind(tdata.TimeTags(j).Tag,'QW'))+...
        ~isempty(strfind(tdata.TimeTags(j).Tag,'NREM'))+...
        ~isempty(strfind(tdata.TimeTags(j).Tag,'REM'));
    
    if a ==1
        
        t_start = tdata.TimeTags_strings(j,1);
        t_end = tdata.TimeTags_strings(j,2);
        x(ind,2) = ([3600, 60, 1] * reshape(sscanf(t_start{:}, '%g:'), 3, []))*1000;
        x(ind,3) = ([3600, 60, 1] * reshape(sscanf(t_end{:}, '%g:'), 3, []))*1000;
        
        tag = strsplit(tdata.TimeTags(j).Tag,'-');
        if strcmpi(tag(1),'AW')
            x(ind,1) = 3;
        elseif strcmpi(tag(1),'QW')
            x(ind,1) = 2;
        elseif strcmpi(tag(1),'NREM')
            x(ind,1) = 1;
        elseif strcmpi(tag(1),'REM')
            x(ind,1) = 0;
        end
        ind = ind + 1;
               
    end
       
end




rem_index = find(x(:,1)==0);
rem_num = size(rem_index,1); % number of REM episodes

% duration in seconds of each REM episode
rem_dur = zeros(size(rem_index));
for i = 1:size(rem_index,1)
    rem_dur(i) = (x(rem_index(i),3) - x(rem_index(i),2))/1000;
end

% total REM duration
rem_tot = sum(rem_dur(:)); % in seconds

% mean REM duration
rem_mean = rem_tot/size(rem_index,1); % in seconds

% intervals
if size(rem_index,1) >1
for i = 2:size(rem_index,1)
    int_dur(i-1) = (x(rem_index(i),2)-x(rem_index(i-1),3))/1000; % in seconds
end
end

try
% mean interval duration
int_mean = sum(int_dur(:))/size(int_dur(:),1);
catch
int_dur = [];
int_mean = [];
end
% SleepScore(end) = struct('Animal_ID',animal_id,'Date',date,...
%     'REM_number',[],'REM_mean',[],'REM_tot',[],'REM_dur',[],...
%     'INT_mean',[],'INT_dur',[]);

SleepScore = fig.UserData.SleepScore;

SleepScore(CUR_FILE).REM_number = rem_num;
SleepScore(CUR_FILE).REM_mean   = rem_mean;
SleepScore(CUR_FILE).REM_tot    = rem_tot;
SleepScore(CUR_FILE).REM_dur    = rem_dur;
SleepScore(CUR_FILE).INT_mean   = int_mean;
SleepScore(CUR_FILE).INT_dur    = int_dur;

save('C:\Users\Marta\Documents\MATLAB\NeuroLab\SleepScore','SleepScore');

pause(1)





% % get rid of double data
% for i = 1:size(tdata.TimeTags,1)
% comp(i) = strcmpi(tdata.TimeTags(i).Onset,'00:00:00.001');
% end
% f = find(comp == 1,50,'first');
% 
% if ~isempty(strfind(tdata.TimeTags(1).Tag,'Whole'))
%     ind = 2;
% else 
%     init =1;
% end
% 
% if length(f)>1
%     tdata.TimeTags(ind:f(end)-1) = [];
%     tdata.TimeTags_cell(ind+1:f(end),:) = [];
%     tdata.TimeTags_images(ind:f(end)-1,:) = [];
%     tdata.TimeTags_strings(ind:f(end)-1,:) = [];
% end


% GetTimeTags_Callback([],[],handles,tdata)
% pause(1)
% SaveTimeTags_Callback([],[],handles,time_references,tdata,DIR_SAVE,FILES,CUR_FILE)
% pause(1)

% folder_name = fullfile(DIR_SAVE,FILES(CUR_FILE).nlab);
% % Loading Time Groups
% if ~exist(fullfile(folder_name,'Time_Groups.mat'),'file')
%     errordlg('File Time_Groups.mat not found.');
%     return;
% else
%     tg_data = load(fullfile(folder_name,'Time_Groups.mat'),'TimeGroups_name','TimeGroups_frames','TimeGroups_duration','TimeGroups_S');
% end
% 
% % Loading Time Tags
% if ~exist(fullfile(folder_name,'Time_Tags.mat'),'file')
%     tt_data = [];
% else
%     tt_data = load(fullfile(folder_name,'Time_Tags.mat'),'TimeTags','TimeTags_cell','TimeTags_images','TimeTags_strings');
% end
% 
% 
% %Erase previous TimeTags if flag_tag
% if flag_tag
%     temp ={tt_data.TimeTags(:).Tag}';
%     ind_keep = ~contains(temp,["SURGE","TONIC"]);
%     tt_data.TimeTags_images = tt_data.TimeTags_images(ind_keep,:);
%     tt_data.TimeTags_strings = tt_data.TimeTags_strings(ind_keep,:);
%     tt_data.TimeTags_cell = [tt_data.TimeTags_cell(1,:);tt_data.TimeTags_cell(find(ind_keep==1)+1,:)];
%     tt_data.TimeTags = tt_data.TimeTags(ind_keep);
% end
% % Saving Surges as TimeTags.mat
% TimeTags_images = [tt_data.TimeTags_images;TimeTags_images_phasic;TimeTags_images_tonic];
% TimeTags_strings = [tt_data.TimeTags_strings;TimeTags_strings_phasic;TimeTags_strings_tonic];
% TimeTags_cell = [tt_data.TimeTags_cell;TimeTags_cell_phasic;TimeTags_cell_tonic];
% TimeTags = [tt_data.TimeTags;TimeTags_phasic;TimeTags_tonic];
% save(fullfile(folder_name,'Time_Tags.mat'),'TimeTags','TimeTags_cell','TimeTags_strings','TimeTags_images');
% fprintf('===> Saved at %s.mat\n',fullfile(folder_name,'Time_Tags.mat'));
% 
% %Save TimeGroups
% if flag_group
%     ind_keep = ~contains(tg_data.TimeGroups_name,["REM-PHASIC";"REM-TONIC"]);
%     tg_data.TimeGroups_name = tg_data.TimeGroups_name(ind_keep);
%     tg_data.TimeGroups_frames = tg_data.TimeGroups_frames(ind_keep);
%     tg_data.TimeGroups_duration = tg_data.TimeGroups_duration(ind_keep);
%     tg_data.TimeGroups_S = tg_data.TimeGroups_S(ind_keep);
% end
% % Saving Surges as TimeGroups.mat
% name_phasic = {'REM-PHASIC'};
% frames_phasic = {sprintf('%d',sum(ind_surge))};
% duration_phasic = {datestr(sum(TimeTags_seconds_phasic(:,2)-TimeTags_seconds_phasic(:,1))/(24*3600),'HH:MM:SS.FFF')};
% S_phasic.Selected = length(tt_data.TimeTags)+(1:n_phasic)';
% S_phasic.Name = {TimeTags(S_phasic.Selected).Tag}';
% S_phasic.TimeTags_strings = TimeTags_strings_phasic;
% S_phasic.TimeTags_images = TimeTags_images_phasic;
% 
% % Saving tonic events as TimeGroups.mat
% name_tonic = {'REM-TONIC'};
% frames_tonic = {sprintf('%d',sum(ind_tonic))};
% duration_tonic = {datestr(sum(TimeTags_seconds_tonic(:,2)-TimeTags_seconds_tonic(:,1))/(24*3600),'HH:MM:SS.FFF')};
% S_tonic.Selected = length(tt_data.TimeTags)+n_phasic+(1:n_tonic)';
% S_tonic.Name = {TimeTags(S_tonic.Selected).Tag}';
% S_tonic.TimeTags_strings = TimeTags_strings_tonic;
% S_tonic.TimeTags_images = TimeTags_images_tonic;
% 
% % Concatenate
% TimeGroups_name = [tg_data.TimeGroups_name;name_phasic;name_tonic];
% TimeGroups_frames = [tg_data.TimeGroups_frames;frames_phasic;frames_tonic];
% TimeGroups_duration = [tg_data.TimeGroups_duration;duration_phasic;duration_tonic];
% TimeGroups_S = [tg_data.TimeGroups_S;S_phasic;S_tonic];
% save(fullfile(folder_name,'Time_Groups.mat'),'TimeGroups_name','TimeGroups_frames','TimeGroups_duration','TimeGroups_S');
% fprintf('===> Saved at %s.mat\n',fullfile(folder_name,'Time_Groups.mat'));

fig.UserData.success = true;
end

%% compute functions

function reset(handles)
val = 1;
MOV(handles,val)
ACC(handles,val)
LFP(handles,val)
GetScore(handles)
end

function MOV(handles,val)
fig = handles.MainFigure;
ax2 = handles.axEMG;
cla(ax2)
% get variables
EpochSize = fig.UserData.EpochSize;
% Plot MOV/LFP traces
if ~isempty(fig.UserData.list_EMG)
    data = load(fullfile(fig.UserData.path_traces,fig.UserData.list_EMG(val).name));
else
    data = load(fullfile(fig.UserData.path_traces,fig.UserData.list_ACC(val).name));
    disp('No EMG data found, used ACC data instead')
end
time = data.x_start:data.f:data.x_end;

% Get EMG power in 50-150 Hz band
EMG = [50 150];
EMG_power = zeros(1,size(data.Y,1));
fs = 1/data.f;

i=1;
while i<size(data.Y,1)
    EMG_power(i:min(i+EpochSize,end)) = bandpower(data.Y(i:min(i+EpochSize,end)),fs,EMG);
    i = min(i+EpochSize,size(data.Y,1));
end

line(time,EMG_power,'Color',[.5 .5 .5],'Parent',ax2)

% Thresh MOV
powerthresh = min(EMG_power)+0.05*std(EMG_power);
t_lineMOV = line([data.x_start data.x_end],[powerthresh powerthresh],...
    'LineWidth',1,'Color',[0.75, 0, 0.75],'Parent', ax2,...
    'HitTest', 'on');
t_lineMOV.ButtonDownFcn = {@thresh_bd,handles};

fig.UserData.MOVdata = data;
fig.UserData.EMG_power = EMG_power;
fig.UserData.t_lineMOV = t_lineMOV;
fig.UserData.timeMOV = time;
fig.UserData.m_thresh = powerthresh;

m_score(handles,powerthresh)
end

function ACC(handles,val)
fig = handles.MainFigure;
ax1 = handles.axACC;
cla(ax1)
% get variables
EpochSize = fig.UserData.EpochSize;

if  val == 1 || val == 2 || val == 3
    data = load(fullfile(fig.UserData.path_traces,fig.UserData.list_ACC(val).name));
elseif  val == 4 || val == 5 || val == 6
    val = val -3;
    data = load(fullfile(fig.UserData.path_traces,fig.UserData.list_GYR(val).name));
end
time = data.x_start:data.f:data.x_end;
line(time,abs(data.Y),'Color',[0, 0.5, 0],'Parent',ax1)

[up,~] = envelope(abs(data.Y),EpochSize*3,'rms');
line(time,up,'Color','r','Parent',ax1)

% Thresh ACC
accthresh = mean(up);
% accthresh = 1*std(up);
t_lineACC = line([data.x_start data.x_end],[accthresh accthresh],...
    'LineWidth',1,'Color',[0.75, 0, 0.75],'Parent', ax1,...
    'HitTest', 'on');
t_lineACC.ButtonDownFcn = {@thresh_bd,handles};

fig.UserData.ACCdata = data;
fig.UserData.ACCdataup = up;
fig.UserData.t_lineACC = t_lineACC;
fig.UserData.timeACC = time;
fig.UserData.acc_thresh = accthresh;

acc_score(handles,accthresh)
end

function LFP(handles,val)
fig = handles.MainFigure;
ax3 = handles.axLFP;
ax4 = handles.axRatio;
cla(ax3) ; cla(ax4)
EpochSize = fig.UserData.EpochSize;
data = load(fullfile(fig.UserData.path_traces,fig.UserData.list_LFP(val).name));

% plot the selected LFP channel
time = data.x_start:data.f:data.x_end;
line(time,data.Y,'Color','k','Parent',ax3)

% Compute Theta/Delta ratio
theta = [6 10];
delta = [1 4];
fs = 1/data.f;

theta_power = zeros(1,size(data.Y,1));
delta_power = zeros(1,size(data.Y,1));
ratio = zeros(1,size(data.Y,1));

i=1;
while i<size(data.Y,1)
    theta_power(i:min(i+EpochSize,end)) = bandpower(data.Y(i:min(i+EpochSize,end)),fs,theta);
    delta_power(i:min(i+EpochSize,end)) = bandpower(data.Y(i:min(i+EpochSize,end)),fs,delta);
    ratio(i:min(i+EpochSize,end)) = theta_power(i:min(i+EpochSize,end))/delta_power(i:min(i+EpochSize,end));
    i = min(i+EpochSize,size(data.Y,1));
end

% enveloping theta/delta ratio
% [s_ratio,~] = envelope(ratio,EpochSize*3,'rms');
% s_ratio = ratio .* s_ratio;

%simplifying theta/delta ratio
s_ratio = smoothdata(ratio,'gaussian',EpochSize*10);

line(time,ratio,'Color',[.5 .5 .5],'Parent',ax4)
line(time,s_ratio,'Color','r','Parent',ax4)

% Thresh theta/delta UP
ratiothresh = min(s_ratio)+.5*std(s_ratio); %ratiothresh = mean(s_ratio)-0.1*std(s_ratio); %ratiothresh = mean(up)+0.1*std(up);
t_lineRatio = line([data.x_start data.x_end],[ratiothresh ratiothresh],...
    'LineWidth',1,'Color',[0.75, 0, 0.75],'Parent', ax4,...
    'HitTest', 'on');
t_lineRatio.ButtonDownFcn = {@thresh_bd,handles};

fig.UserData.LFPdata = data;
fig.UserData.ratio = s_ratio;
fig.UserData.t_lineRatio = t_lineRatio;
fig.UserData.timeLFP = time;
fig.UserData.t_thresh = ratiothresh;
fig.UserData.fs = fs;

t_score(handles,ratiothresh)
end

function m_score(handles,thresh)
fig = handles.MainFigure;
EMG_power = fig.UserData.EMG_power;
data = fig.UserData.MOVdata;


m = zeros(1,size(data.Y,1));
m(EMG_power>=thresh) = 1;

% smoothing EMG score :
diffm = diff(m);
f_diffm = find(diffm);
df_diffm = diff(f_diffm);

m_corrected = m;
for i = 1:size(df_diffm,2)
    if df_diffm(i) <= 3000
        m_corrected(f_diffm(i):f_diffm(i+1)) = m(f_diffm(i));
    end
end
m = m_corrected;
fig.UserData.m = m;
end

function acc_score(handles,thresh)
fig = handles.MainFigure;
up = fig.UserData.ACCdataup;
data = fig.UserData.ACCdata;

acc = zeros(1,size(data.Y,1));
acc(up>=thresh) = 1;

% smoothing EMG score :
diffa = diff(acc);
f_diffa = find(diffa);
df_diffa = diff(f_diffa);

acc_corrected = acc;
for i = 1:size(df_diffa,2)
    if df_diffa(i) <= 3000
        acc_corrected(f_diffa(i):f_diffa(i+1)) = acc(f_diffa(i));
    end
end
acc = acc_corrected;
fig.UserData.acc = acc;
end

function t_score(handles,thresh)
fig = handles.MainFigure;
ratio = fig.UserData.ratio;

t = zeros(1,size(ratio,2));
t(ratio>=thresh) = 1;

%smoothing theta/delta score :
difft = diff(t);
f_difft = find(difft);
df_difft = diff(f_difft);

t_corrected = t;
for i = 1:size(df_difft,2)
    if df_difft(i) <= 3000
        t_corrected(f_difft(i):f_difft(i+1)) = t(f_difft(i));
    end
end
t = t_corrected;
fig.UserData.t = t;
end

function GetScore(handles)
fig = handles.MainFigure;
m = fig.UserData.m;
acc = fig.UserData.acc;
t = fig.UserData.t;
score = zeros(1,size(fig.UserData.LFPdata.Y,1)); % QW by default
for i = 1:size(fig.UserData.LFPdata.Y,1)
    if (acc(i) == 1 || (t(i) == 1 && m(i) == 1))
        score(i) = 3; % AW
    elseif (m(i) == 1 && acc(i) == 0)
        score(i) = 2; % QW
    elseif (m(i) == 0 && t(i) == 0)
        score(i) = 1; % NREM
    elseif (m(i) == 0 && t(i) == 1)
        score(i) = 0; % REM
    end
end
score_lim = find(diff(score));
score_tag = zeros(size(score_lim,2),3);
for i=1:size(score_lim,2)
    score_tag(i,1) = score(score_lim(i)); 
    if i == 1 
        score_tag(i,2) = 1; 
        score_tag(i,3) = score_lim(i);
    elseif i == size(score_lim,2)
        score_tag(i,2) = score_lim(i-1)+1;
        score_tag(i,3) = size(score,2);
        if score_lim(i) < size(score,2)
            score_tag(i+1,1) = score(end);
            score_tag(i+1,2) = score_lim(i)+1;
            score_tag(i+1,3) = size(score,2);
        end
    else
        score_tag(i,2) = score_lim(i-1)+1;
        score_tag(i,3) = score_lim(i);
    end
        
    if score(i) == 0
        score_tag(i,1) = score(score_lim(i)); 
    elseif score(i) == 1
        score_tag(i,1) = score(score_lim(i)); 
    elseif score(i) == 2
        score_tag(i,1) = score(score_lim(i)); 
    end
    
end
fig.UserData.score = score;
fig.UserData.score_tag = score_tag;
ShowScore(handles)
end

function ShowScore(handles)
fig = handles.MainFigure;
ax5 = handles.hypnogram;
ax6 = handles.axtotal;
ax7 = handles.axwake;
ax8 = handles.axsleep;
cla(ax5)

score = fig.UserData.score;
score_tag = fig.UserData.score_tag;

% define colors
aw_color = [0, 0.4470, 0.7410];
qw_color = [0.4660, 0.6740, 0.1880];
nrem_color = [0.9290, 0.6940, 0.1250];
rem_color = [0.8500, 0.3250, 0.0980];

fs = fig.UserData.fs;
% put background colors corresponding to the scoring
for i = 1 : size(score_tag,1)
    if score_tag(i) == 0
        pos = [score_tag(i,2)/fs -0.5 (score_tag(i,3)-score_tag(i,2))/fs 4];
        rectangle('Position', pos,'EdgeColor',rem_color,'FaceColor',rem_color,'Parent',ax5)
    elseif score_tag(i) == 1
        pos = [score_tag(i,2)/fs -0.5 (score_tag(i,3)-score_tag(i,2))/fs 4];
        rectangle('Position', pos,'EdgeColor',nrem_color,'FaceColor',nrem_color,'Parent',ax5)
    elseif score_tag (i) == 2
        pos = [score_tag(i,2)/fs -0.5 (score_tag(i,3)-score_tag(i,2))/fs 4];
        rectangle('Position', pos,'EdgeColor',qw_color,'FaceColor',qw_color,'Parent',ax5)
    elseif score_tag (i) == 3
        pos = [score_tag(i,2)/fs -0.5 (score_tag(i,3)-score_tag(i,2))/fs 4];
        rectangle('Position', pos,'EdgeColor',aw_color,'FaceColor',aw_color,'Parent',ax5)
    end
end

% computing total states time:
dur_total = size(score,2);
dur_aw    = sum(score(:) == 3);
dur_qw    = sum(score(:) == 2);
dur_nrem  = sum(score(:) == 1);
dur_rem   = sum(score(:) == 0);

dur_total_time = datestr((dur_total/1000)/(24*3600),'HH:MM:SS.FFF');
dur_aw_time = datestr((dur_aw/1000)/(24*3600),'HH:MM:SS.FFF');
dur_qw_time = datestr((dur_qw/1000)/(24*3600),'HH:MM:SS.FFF');
dur_nrem_time = datestr((dur_nrem/1000)/(24*3600),'HH:MM:SS.FFF');
dur_rem_time = datestr((dur_rem/1000)/(24*3600),'HH:MM:SS.FFF');

fig.UserData.p1.t2.total_duration.String = dur_total_time;
fig.UserData.p1.t2.aw_duration.String = dur_aw_time;
fig.UserData.p1.t2.qw_duration.String = dur_qw_time;
fig.UserData.p1.t2.nrem_duration.String = dur_nrem_time;
fig.UserData.p1.t2.rem_duration.String = dur_rem_time;

% computing percentages / total
percentage_aw = 100*dur_aw/(dur_total);
percentage_qw = 100*dur_qw/(dur_total);
percentage_nrem = 100*dur_nrem/(dur_total);
percentage_rem = 100*dur_rem/(dur_total);

fig.UserData.p1.t2.aw_percentage.String = num2str(percentage_aw);
fig.UserData.p1.t2.qw_percentage.String = num2str(percentage_qw);
fig.UserData.p1.t2.nrem_percentage.String = num2str(percentage_nrem);
fig.UserData.p1.t2.rem_percentage.String = num2str(percentage_rem);

% computing percentages /wake-sleep
percentage_aw_wake = 100*dur_aw/(dur_aw + dur_qw);
percentage_qw_wake = 100*dur_qw/(dur_aw + dur_qw);
percentage_nrem_sleep = 100*dur_nrem/(dur_nrem + dur_rem);
percentage_rem_sleep = 100*dur_rem/(dur_nrem + dur_rem);

fig.UserData.p1.t2.aw_wake_percentage.String = num2str(percentage_aw_wake);
fig.UserData.p1.t2.qw_wake_percentage.String = num2str(percentage_qw_wake);
fig.UserData.p1.t2.nrem_sleep_percentage.String = num2str(percentage_nrem_sleep);
fig.UserData.p1.t2.rem_sleep_percentage.String = num2str(percentage_rem_sleep);

% display percentages in pie charts
try
pie_total = pie([percentage_aw,percentage_qw,percentage_nrem,percentage_rem],'Parent',ax6);
pie_wake = pie([percentage_aw_wake,percentage_qw_wake],'Parent',ax7);
pie_sleep = pie([percentage_nrem_sleep,percentage_rem_sleep],'Parent',ax8);
catch
end
% adjust pie colors
try
pie_total(1).FaceColor = aw_color; pie_total(3).FaceColor = qw_color; pie_total(5).FaceColor = nrem_color; pie_total(7).FaceColor = rem_color;
pie_wake(1).FaceColor = aw_color; pie_wake(3).FaceColor = qw_color; 
pie_sleep(1).FaceColor = nrem_color; pie_sleep(3).FaceColor = rem_color; 
catch
end
line(fig.UserData.timeLFP,score,'Color','k','Parent',ax5);

end

function RecapData(handles,CUR_FILE)
fig = handles.MainFigure;
score_tag = fig.UserData.score_tag;

rem_index = find(score_tag(:,1)==0);
rem_num = size(rem_index,1); % number of REM episodes

% duration in seconds of each REM episode
rem_dur = zeros(size(rem_index));
for i = 1:size(rem_index,1)
    rem_dur(i) = (score_tag(rem_index(i),3) - score_tag(rem_index(i),2))/1000;
end

% total REM duration
rem_tot = sum(rem_dur(:)); % in seconds

% mean REM duration
rem_mean = rem_tot/size(rem_index,1); % in seconds

% intervals
if size(rem_index,1) >1
for i = 2:size(rem_index,1)
    int_dur(i-1) = (score_tag(rem_index(i),2)-score_tag(rem_index(i-1),3))/1000; % in seconds
end
end

try
% mean interval duration
int_mean = sum(int_dur(:))/size(int_dur,1);
catch
int_dur = [];
int_mean = [];
end
% SleepScore(end) = struct('Animal_ID',animal_id,'Date',date,...
%     'REM_number',[],'REM_mean',[],'REM_tot',[],'REM_dur',[],...
%     'INT_mean',[],'INT_dur',[]);

SleepScore = fig.UserData.SleepScore;

SleepScore(CUR_FILE).REM_number = rem_num;
SleepScore(CUR_FILE).REM_mean   = rem_mean;
SleepScore(CUR_FILE).REM_tot    = rem_tot;
SleepScore(CUR_FILE).REM_dur    = rem_dur;
SleepScore(CUR_FILE).INT_mean   = int_mean;
SleepScore(CUR_FILE).INT_dur    = int_dur;

save('C:\Users\Marta\Documents\MATLAB\NeuroLab\SleepScore','SleepScore');
end

%% button down functions

function thresh_bd(src,event,handles)
% event
fig = handles.MainFigure;
graph = event.Source.Parent.Tag;
switch graph
    case 'axACC'
        n=1;
        fig.WindowButtonMotionFcn = {@thresh_ACC,handles,n};
    case 'axEMG'
        n=2;
        fig.WindowButtonMotionFcn = {@thresh_MOV,handles,n};
    case 'axRatio'
        n=3;
        fig.WindowButtonMotionFcn = {@thresh_ratio,handles,n};
end

fig.WindowButtonUpFcn = {@thresh_bu,handles,n};
end

function thresh_bu(src,event,handles,n)
% event
fig = handles.MainFigure;
fig.WindowButtonMotionFcn = '';
thresh = fig.UserData.thresh(n);

if n == 1
    acc_score(handles,thresh);
    disp('ACC threshold changed')
elseif n == 2
    m_score(handles,thresh);
    disp('MOV threshold changed')
elseif n ==3
    t_score(handles,thresh);
    disp('Theta/delta ratio threshold changed')
end

GetScore(handles)
end

function thresh_MOV(~,~,handles,n)
fig = handles.MainFigure;
ax = handles.axEMG;
coord = get(ax,'CurrentPoint');
fig.UserData.t_lineMOV.YData = [coord(1,2) coord(2,2)];
fig.UserData.thresh(n) = coord(1,2);
end

function thresh_ACC(~,~,handles,n)
fig = handles.MainFigure;
ax = handles.axACC;
coord = get(ax,'CurrentPoint');
fig.UserData.t_lineACC.YData = [coord(1,2) coord(2,2)];
fig.UserData.thresh(n) = coord(1,2);
end

function thresh_ratio(~,~,handles,n)
fig = handles.MainFigure;
ax = handles.axRatio;
coord = get(ax,'CurrentPoint');
fig.UserData.t_lineRatio.YData = [coord(1,2) coord(2,2)];
fig.UserData.thresh(n) = coord(1,2);
end

%% callback functions

function PopupListACC_Callback(~,event,handles)
% fig = handles.MainFigure;
ax1 = handles.axACC;
ax5 = handles.hypnogram;
cla(ax1) ; cla(ax5)

val = event.Source.Value;
str = event.Source.String;
disp(['Selection: ' str{val}]);

ACC(handles,val);
GetScore(handles)
end

function PopupListEMG_Callback(~,event,handles)
% fig = handles.MainFigure;
ax2 = handles.axEMG;
ax5 = handles.hypnogram;
cla(ax2) ; cla(ax5)

val = event.Source.Value;
str = event.Source.String;
disp(['Selection: ' str{val}]);

MOV(handles,val);
GetScore(handles)
end

function PopupListLFP_Callback(~,event,handles)
% fig = handles.MainFigure;
ax3 = handles.axLFP;
ax4 = handles.axRatio;
ax5 = handles.hypnogram;
cla(ax3) ; cla(ax4) ; cla(ax5)

val = event.Source.Value;
str = event.Source.String;
disp(['Selection: ' str{val}]);

LFP(handles,val)
GetScore(handles)
end

function SelectEpoch_Callback(src,~,handles)
fig = handles.MainFigure;
% select the size of the epochs, in ms
input = get(src,'String');
display(input);
fig.UserData.EpochSize = str2double(input);
GetScore(handles)
end

function Reset_Callback(~,~,handles)
% fig = handles.MainFigure;
reset(handles)
end

function Overwrite_Callback(~,event,handles)
fig = handles.MainFigure;
if event.Source.Value == 1
disp('Overwriting Time_Tags file')
else
disp('Keeping the previous Time_Tags values')
end

fig.UserData.overwrite = event.Source.Value;
end

function SaveTimeTags_Callback(~,~,handles,time_references,tdata,DIR_SAVE,FILES,CUR_FILE)
fig = handles.MainFigure;
score_tag = fig.UserData.score_tag;

% to overwrite data
if fig.UserData.overwrite == 1
    n = 0;
    TimeTags = [];
    TimeTags_strings = [];
    TimeTags_images = [];
    TimeTags_cell(2:end,:) = [];
    %erase dupplicated data
    f = find(score_tag(:,2) == 1,50,'first');
    if length(f)>1
    score_tag(1:max(f)-1,:) = [];
    end
else
    n = length(tdata.TimeTags);
    TimeTags = tdata.TimeTags;
    TimeTags_strings = tdata.TimeTags_strings;
    TimeTags_images = tdata.TimeTags_images;
    TimeTags_cell = tdata.TimeTags_cell;
end

it_rem = 1;
it_nrem = 1;
it_aw = 1;
it_qw = 1;

for i = 1:size(score_tag,1)

% t_start = score_tag(i,2)/1000/60;
% t_end = score_tag(i,3)/1000/60;

    if score_tag(i,1) == 0
        tag = ['REM-' num2str(it_rem,'%03.f')];
        it_rem = it_rem +1;
    elseif score_tag(i,1) == 1
        tag = ['NREM-' num2str(it_nrem,'%03.f')];
        it_nrem = it_nrem +1;
    elseif score_tag(i,1) == 2
        tag = ['QW-' num2str(it_qw,'%03.f')];
        it_qw = it_qw +1;
    elseif score_tag(i,1) == 3
        tag = ['AW-' num2str(it_aw,'%03.f')];
        it_aw = it_aw +1;
    end

t_start = datestr((score_tag(i,2)/1000)/(24*3600),'HH:MM:SS.FFF');
t_end = datestr((score_tag(i,3)/1000)/(24*3600),'HH:MM:SS.FFF');

tts1 = score_tag(i,2)/1000;
tts2 = score_tag(i,3)/1000;

%TimeTags_strings
TimeTags_strings = [TimeTags_strings;[{t_start},{t_end}]];
TimeTags_seconds = [tts1,tts2];
TimeTags_dur = datestr((TimeTags_seconds(:,2)-TimeTags_seconds(:,1))/(24*3600),'HH:MM:SS.FFF');
% TimeTags_images
[~, ind_min_time] = min(abs(time_references.time_ref.Y-TimeTags_seconds(1)));
[~, ind_max_time] = min(abs(time_references.time_ref.Y-TimeTags_seconds(2)));
TimeTags_images = [TimeTags_images;[ind_min_time,ind_max_time]];

% TimeTags_cell & TimeTags
TimeTags_cell = [TimeTags_cell;{'',tag,t_start,char(TimeTags_dur),t_start,''}];
TimeTags(n+1,1).Episode = '';
TimeTags(n+1,1).Tag = tag;
TimeTags(n+1,1).Onset = t_start;
TimeTags(n+1,1).Duration = char(TimeTags_dur);
TimeTags(n+1,1).Reference = t_start;
TimeTags(n+1,1).Tokens = '';

n=n+1;

end

% Saving
save(fullfile(DIR_SAVE,FILES(CUR_FILE).nlab,'Time_Tags.mat'),'TimeTags','TimeTags_cell','TimeTags_strings','TimeTags_images');
fprintf('===> Saved at %s.mat\n',fullfile(DIR_SAVE,FILES(CUR_FILE).nlab,'Time_Tags.mat'));
RecapData(handles,CUR_FILE);
disp('SleepScore file updated')
end

function GetTimeTags_Callback(~,~,handles,tdata)
fig = handles.MainFigure;
score = zeros(1,size(fig.UserData.t,2)); % QW by default

% if ~isempty(strfind(tdata.TimeTags(1).Tag,'Whole'))
%     init = 2;
% else 
%     init =1;
% end

score_tag = ones(size(tdata.TimeTags,1),3);
s = {'AW','QW','NREM','REM'};
ind = 1;
for i = 1:size(tdata.TimeTags,1)
    if ~isempty(strcmpi(tdata.TimeTags(i).Tag,s))
        
        t_start = tdata.TimeTags_strings(i,1);
        t_end = tdata.TimeTags_strings(i,2);
        score_tag(ind,2) = ([3600, 60, 1] * reshape(sscanf(t_start{:}, '%g:'), 3, []))*1000;
        score_tag(ind,3) = ([3600, 60, 1] * reshape(sscanf(t_end{:}, '%g:'), 3, []))*1000;
        
        tag = strsplit(tdata.TimeTags(i).Tag,'-');
        if strcmpi(tag(1),'AW')
            score_tag(ind,1) = 3;
        elseif strcmpi(tag(1),'QW')
            score_tag(ind,1) = 2;
        elseif strcmpi(tag(1),'NREM')
            score_tag(ind,1) = 1;
        elseif strcmpi(tag(1),'REM')
            score_tag(ind,1) = 0;
        end
        
        a = double(score_tag(ind,2));
        b = double(score_tag(ind,3));
        score(a:b) = score_tag(ind,1);
        
%         init = init + 1;
        ind  = ind + 1;
    end
end

% score_tag = ones(size(tdata.TimeTags,1),3);
% ind = 1;
% while init <=size(tdata.TimeTags,1)
%     t_start = tdata.TimeTags_strings(init,1);
%     t_end = tdata.TimeTags_strings(init,2);
%     score_tag(ind,2) = ([3600, 60, 1] * reshape(sscanf(t_start{:}, '%g:'), 3, []))*1000;
%     score_tag(ind,3) = ([3600, 60, 1] * reshape(sscanf(t_end{:}, '%g:'), 3, []))*1000;
%         
%     tag = strsplit(tdata.TimeTags(init).Tag,'-');
%     if strcmpi(tag(1),'AW')
%         score_tag(ind,1) = 3;
%     elseif strcmpi(tag(1),'QW')
%         score_tag(ind,1) = 2;
%     elseif strcmpi(tag(1),'NREM')
%         score_tag(ind,1) = 1;
%     elseif strcmpi(tag(1),'REM')
%         score_tag(ind,1) = 0;
%     end
%     
%     a = double(score_tag(ind,2));
%     b = double(score_tag(ind,3));
%     score(a:b) = score_tag(ind,1);
%     
%     init = init + 1;
%     ind  = ind + 1;
% end

fig.UserData.score = score;
fig.UserData.score_tag = score_tag;
ShowScore(handles)
end


















