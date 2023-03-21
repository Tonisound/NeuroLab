function f = script_browse_correlation(rec_list,str_save)
% Script Browsing Correlation


% Selecting str_save
global STR_SAVE;
if nargin <2
    if exist(STR_SAVE)
        str_save = STR_SAVE;
       
    else
        str_save = uigetdir(pwd,'Select NEUROLAB folder');
        if isempty(str_save)
            return;
        end    
    end
end
dir_save = fullfile(str_save,'NLab_DATA');
data_dir = fullfile(str_save,'NLab_Statistics','fUS_Correlation');
fig_dir = fullfile(str_save,'NLab_Figures','fUS_Correlation');
rec_dir = fullfile(str_save,'NLab_Files','NReclists');
config_dir = fullfile(str_save,'NLab_Files','NConfigs');

% Checking recording list
if nargin < 1
    d_list = dir(fullfile(rec_dir,'*.txt'));
    d_list = d_list(arrayfun(@(x) ~strcmp(x.name(1),'.'),d_list));
    
    if isempty(d_list)
        errordlg('No Recording list found [%s].',rec_dir);
        return;
    else
        [ind_list,v] = listdlg('Name','List Selection','PromptString','Select recording list',...
            'SelectionMode','single','ListString',{d_list(:).name},'InitialValue','','ListSize',[300 500]);
        if isempty(ind_list)||v==0
            return;
        else
            rec_list = char(d_list(ind_list).name);
        end
    end
    
elseif ~strcmpi(rec_list,'all') && ~exist(fullfile(rec_dir,rec_list))
    errordlg('Recording list not found [%s].',fullfile(rec_dir,rec_list));
    return;
end

% Building list_files from rec_list
if strcmpi(rec_list,'all')
    % Select all files
    d = dir(data_dir);
    d = d(arrayfun(@(x) ~strcmp(x.name(1),'.'),d));
    list_files = {d(:).name}';
else
    % Extracting list_files
    fid = fopen(fullfile(rec_dir,rec_list),'r');
    list_files = [];
    while ~feof(fid)
        line_ex = fgetl(fid);
        temp = regexp(line_ex,'/|\','split');
        list_files = [list_files;{strrep(char(temp(end)),'_nlab','')}];
    end
    fclose(fid);
end

% Searching all_files that match list_files in data_dir
d = dir(data_dir);
d = d(arrayfun(@(x) ~strcmp(x.name(1),'.'),d));
all_files = {d(contains({d(:).name}',list_files)).name}';
% Searching all_timeframes and all_references
all_timeframes = [];
all_references = [];
for i=1:length(all_files)
    d = dir(fullfile(data_dir,char(all_files(i))));
    d = d(arrayfun(@(x) ~strcmp(x.name(1),'.'),d));
    cur_timeframes = {d(:).name}';
    for j=1:length(cur_timeframes)
        
        dd = dir(fullfile(data_dir,char(all_files(i)),char(cur_timeframes(j))));
        dd = dd(arrayfun(@(x) ~strcmp(x.name(1),'.'),dd));
        cur_references = {dd(:).name}';
        all_references = [all_references;cur_references];
    end
    all_timeframes = [all_timeframes;cur_timeframes];
end
all_timeframes = unique(all_timeframes);
all_references = unique(all_references);

% % Searching all_timeframes
% d = dir(fullfile(data_dir,'*','*'));
% d = d(arrayfun(@(x) ~strcmp(x.name(1),'.'),d));
% all_timeframes = unique({d(:).name}');
% % Searching all_references
% d = dir(fullfile(data_dir,'*','*','*'));
% d = d(arrayfun(@(x) ~strcmp(x.name(1),'.'),d));
% all_references = unique({d(:).name}');

if isempty(all_files)
    errordlg(sprintf('No files found from %s in %s.',rec_list,data_dir));
    return;
else
    fprintf('%d files found from [%s] in [%s].\n',length(all_files),rec_list,data_dir)
end

% Building figure
f = figure('Tag','MainFigure');

% Storing data
f.UserData.str_save = str_save;
f.UserData.dir_save = dir_save;
f.UserData.data_dir = data_dir;
f.UserData.fig_dir = fig_dir;
f.UserData.rec_dir = rec_dir;
f.UserData.config_dir = config_dir;
f.UserData.recording = '';
f.UserData.timeframe = '';
f.UserData.reference = '';
clrmenu(f);
colormap(f,'jet')

pu1 = uicontrol('Units','normalized','Parent',f,'Style','popup','ToolTipString','recording','String',list_files,'Tag','Popup1');
pu1.Position = [.05 .95 .73 .04];
pu1.UserData.Restriction = [];
b11 = uicontrol('Units','normalized','Parent',f,'Style','pushbutton','String','*','ToolTipString','Selected/Total','Tag','Button11','Value',0);
b11.Position = [.79 .95 .05 .04];
b11.UserData.all_options = all_files;
b11.UserData.selected = true(size(all_files));
b11.UserData.popup = pu1;
b11.String = sprintf('%d/%d',sum(b11.UserData.selected),length(b11.UserData.selected));
b21 = uicontrol('Units','normalized','Parent',f,'Style','pushbutton','String','Batch','ToolTipString','Show selected options in batch mode','Tag','Button21','Value',0);
b21.Position = [.85 .95 .05 .04];
b21.UserData.popup = pu1;
b31 = uicontrol('Units','normalized','Parent',f,'Style','pushbutton','String','All','ToolTipString','Show all options in batch mode','Tag','Button31','Value',0,'Enable','off');
b31.Position = [.91 .95 .05 .04];
b31.UserData.popup = pu1;

pu2 = uicontrol('Units','normalized','Parent',f,'Style','popup','ToolTipString','timeframe','Value',1,'String','-','Tag','Popup2');
pu2.Position = [.05 .9 .73 .04];
pu2.UserData.Restriction = [];
b12 = uicontrol('Units','normalized','Parent',f,'Style','pushbutton','String','*','ToolTipString','Selected/Total','Tag','Button12','Value',0);
b12.Position = [.79 .9 .05 .04];
b12.UserData.all_options = all_timeframes;
b12.UserData.selected = true(size(all_timeframes));
b12.UserData.popup = pu2;
b12.String = sprintf('%d/%d',sum(b12.UserData.selected),length(b12.UserData.selected));
b22 = uicontrol('Units','normalized','Parent',f,'Style','pushbutton','String','Batch','ToolTipString','Show selected options in batch mode','Tag','Button22','Value',0);
b22.Position = [.85 .9 .05 .04];
b22.UserData.popup = pu2;
b32 = uicontrol('Units','normalized','Parent',f,'Style','pushbutton','String','All','ToolTipString','Show all options in batch mode','Tag','Button32','Value',0,'Enable','off');
b32.Position = [.91 .9 .05 .04];
b32.UserData.popup = pu2;

pu3 = uicontrol('Units','normalized','Parent',f,'Style','popup','ToolTipString','reference','Value',1,'String','-','Tag','Popup3');
pu3.Position = [.05 .85 .73 .04];
pu3.UserData.Restriction = [];
b13 = uicontrol('Units','normalized','Parent',f,'Style','pushbutton','String','*','ToolTipString','Selected/Total','Tag','Button13','Value',0);
b13.Position = [.79 .85 .05 .04];
b13.UserData.all_options = all_references;
b13.UserData.selected = true(size(all_references));
b13.UserData.popup = pu3;
b13.String = sprintf('%d/%d',sum(b13.UserData.selected),length(b13.UserData.selected));
b23 = uicontrol('Units','normalized','Parent',f,'Style','pushbutton','String','Batch','ToolTipString','Show selected options in batch mode','Tag','Button23','Value',0);
b23.Position = [.85 .85 .05 .04];
b23.UserData.popup = pu3;
b33 = uicontrol('Units','normalized','Parent',f,'Style','pushbutton','String','All','ToolTipString','Show all options in batch mode','Tag','Button33','Value',0,'Enable','off');
b33.Position = [.91 .85 .05 .04];
b33.UserData.popup = pu3;

b1 = uicontrol('Units','normalized','Parent',f,'Style','pushbutton','String','Browse','Tag','Button1');
b1.Position = [.05 .8 .1 .04];
e1 = uicontrol('Units','normalized','Parent',f,'Style','pushbutton','ToolTipString','Info Panel','String','','Tag','Edit1','BackgroundColor','w');
e1.Position = [.155 .8 .625 .04];
pu0 = uicontrol('Units','normalized','Parent',f,'Style','popupmenu','String','Rmax|Tmax|RT_pattern','Tag','Popup0');
pu0.Position = [.79 .8 .05 .04];
b2 = uicontrol('Units','normalized','Parent',f,'Style','pushbutton','String','Display','Tag','Button2','Enable','off');
b2.Position = [.85 .8 .05 .04];
b3 = uicontrol('Units','normalized','Parent',f,'Style','pushbutton','String','Save','Tag','Button3');
b3.Position = [.91 .8 .05 .04];

ax1 = subplot(131,'Parent',f,'Tag','Ax1','XTick',[],'XTickLabel',[],'YTick',[],'YTickLabel',[]);
ax2 = subplot(132,'Parent',f,'Tag','Ax2','XTick',[],'XTickLabel',[],'YTick',[],'YTickLabel',[]);
ax3 = subplot(133,'Parent',f,'Tag','Ax3','YTick',[],'YTickLabel',[]);
ax1.Position = [.025 .05 .3 .7];
ax2.Position = [.35 .05 .3 .7];
ax3.Position = [.775 .05 .2 .7];

cb1 = uicontrol('Units','normalized','Parent',f,'Style','checkbox','ToolTipString','Atlas on/off','Tag','Checkbox1','Value',0);
cb1.Position = [0 0 .02 .05];
cb2 = uicontrol('Units','normalized','Parent',f,'Style','checkbox','ToolTipString','AlphaMap on/off','Tag','Checkbox2','Value',0);
cb2.Position = [0 .05 .02 .05];

% Callback attribution
handles = guihandles(f);
pu1.Callback = {@pu1_Callback,handles};
pu2.Callback = {@pu2_Callback,handles};
pu3.Callback = {@pu3_Callback,handles};
pu3.KeyPressFcn = {@pu3_key_pressFcn,handles};

b1.Callback = {@b1_Callback,handles};
b2.Callback = {@display_Callback,handles};
b3.Callback = {@save_Callback,handles};
e1.Callback = {@e1_Callback};
cb1.Callback = {@cb1_Callback,[handles.Ax1;handles.Ax2]};
cb2.Callback = {@cb2_Callback,handles.Ax1};

b11.Callback = {@dialog_Callback,handles};
b12.Callback = {@dialog_Callback,handles};
b13.Callback = {@dialog_Callback,handles};

b21.Callback = {@batch_Callback,handles};
b22.Callback = {@batch_Callback,handles};
b23.Callback = {@batch_Callback,handles};

% b31.Callback = {@all_Callback,handles};
% b32.Callback = {@all_Callback,handles};
% b33.Callback = {@all_Callback,handles};

f.Units = 'normalized';
f.Position = [0.0380    0.3065    0.8662    0.4981];
pu1_Callback(pu1,[],handles);

end

function save_Callback(~,~,handles)
% Batch saving

pu1 = handles.Popup1;
b23 = handles.Button23;

h = waitbar(0,'Please wait');

for i = 1:length(pu1.String)
    pu1.Value = i;
    pu1_Callback(pu1,[],handles);
    for j=1:3
        handles.Popup0.Value =j;
        f2 = batch_Callback(b23,[],handles);
        b11 = findobj(f2,'Tag','Button11');
        b11_Callback(b11,[],handles);
    end

    prop = i/length(pu1.String);
    waitbar(prop,h,sprintf('Saving Synthesis fUS-Correlation %.1f %% completed',100*prop));
end

close(h);

end

function e1_Callback(hObj,~)
winopen(hObj.String);
end

function b1_Callback(~,~,handles)

f =  handles.MainFigure;
e1 = handles.Edit1;
pu1 = handles.Popup1;
pu2 = handles.Popup2;
pu3 = handles.Popup3;
b11 = handles.Button11;
b12 = handles.Button12;
b13 = handles.Button13;

data_dir = f.UserData.data_dir;
recording = f.UserData.recording;
timeframe = f.UserData.timeframe;
reference = f.UserData.reference;

[file,path] = uigetfile(fullfile(data_dir,recording,timeframe,reference));

if ~isequal(file,0) && contains(path,data_dir)
    temp = regexp(strrep(path,data_dir,''),filesep,'split');
    recording = char(temp(2));
    timeframe = char(temp(3));
    reference = char(temp(4));
    
    % update popup 1
    d = dir(fullfile(data_dir));
    d = d(arrayfun(@(x) ~strcmp(x.name(1),'.'),d));
    list_recording = {d(:).name}';
    pu1.String = list_recording;
    b11.Value = 0;
    pu1.Value = find(strcmp(pu1.String,recording)==1);
    
    % update popup 2
    dd = dir(fullfile(data_dir,recording));
    dd = dd(arrayfun(@(x) ~strcmp(x.name(1),'.'),dd));
    list_frames = {dd(:).name}';
    pu2.String = list_frames;
    b12.Value = 0;
    pu2.Value = find(strcmp(pu2.String,timeframe)==1);
    
    % update popup 3
    ddd = dir(fullfile(data_dir,recording,timeframe));
    ddd = ddd(arrayfun(@(x) ~strcmp(x.name(1),'.'),ddd));
    list_refs = {ddd(:).name}';
    pu3.String = list_refs;
    b13.Value = 0;
    pu3.Value = find(strcmp(pu3.String,reference)==1);
    
    dddd = dir(fullfile(data_dir,recording,timeframe,reference,'*.txt'));
    e1.String = fullfile(dddd.folder,dddd.name);
    display_Callback([],[],handles);
    
end

end

function dialog_Callback(hObj,~,handles)

W = 185;
H = 60;
ftsize = 10;

all_options = hObj.UserData.all_options;
selected = hObj.UserData.selected;

f2 = dialog('Units','characters',...
    'Position',[30 20 W H],...
    'HandleVisibility','callback',...
    'IntegerHandle','off',...
    'Renderer','painters',...
    'Toolbar','figure',...
    'NumberTitle','off',...
    'Tag','MainFigure',...
    'Name','Selection');

if strcmp(hObj.Tag,'Button13')
    status1='on';
    status2='on';
    list1 = {'broadband';'delta';'theta';'beta';'gammalow';'gammamid';'gammamidup';'gammahigh';'gammahighup';'ripple'};
    list2 = {'005';'006';'008';'009';'010';'011';'012';'013';'014';'015';'016';'017';'018';'019';'020';'022';'023';'024';'025';'03-extra';'04-extra';'05-extra';'06-extra';'07-extra';'08-extra'};
elseif strcmp(hObj.Tag,'Button12')
    status1='off';
    status2='off';
    list1 = '<0>';
    list2 = '<0>';
else
    status1='on';
    status2='off';
    list1 = {'SD025';'SD032';'SD041'};
    list2 = '<0>';
end
popup_band = uicontrol('Style','popupmenu',...
    'Units','characters',...
    'Position',[3*W/4 0 W/4 2],...
    'String',list1,...
    'Value',1,...
    'Visible',status1,...
    'Parent',f2);
popup_channel = uicontrol('Style','popupmenu',...
    'Units','characters',...
    'Position',[3*W/4 2 W/4 2],...
    'String',list2,...
    'Value',1,...
    'Visible',status2,...
    'Parent',f2);

okButton = uicontrol('Style','pushbutton',...
    'Units','characters',...
    'Position',[W/4 0 W/4 2],...
    'String','OK',...
    'Parent',f2);
cancelButton = uicontrol('Style','pushbutton',...
    'Units','characters',...
    'Position',[W/2 0 W/4 2],...
    'String','Cancel',...
    'Parent',f2);
selectButton = uicontrol('Style','pushbutton',...
    'Units','characters',...
    'Position',[W/4 2 W/4 2],...
    'String','Select All',...
    'Parent',f2);
deselectButton = uicontrol('Style','pushbutton',...
    'Units','characters',...
    'Position',[W/2 2 W/4 2],...
    'String','Deselect All',...
    'Parent',f2);

mainPanel = uipanel('FontSize',ftsize,...
    'Units','characters',...
    'Tag','MainPanel',...
    'Position',[0 4 W H-4],...
    'Parent',f2);
% pos = get(mainPanel,'Position');
mainPanel.Units = 'normalized';

n_lines = 50;
n_col = 5;
for i =1:length(all_options)
    y = floor((i-1)/n_lines);
    x = mod(i-1,n_lines);
    uicontrol('Style','checkbox',...
        'Units','normalized',...
        'Position',[y/n_col (1-1/n_lines)-(x/n_lines) 1/n_col 1/n_lines],...
        'String',char(all_options(i)),...
        'Value',selected(i),...
        'Parent',mainPanel);
end

handles2 = guihandles(f2);

okButton.Callback={@okButton_callback,handles,handles2,hObj};
cancelButton.Callback={@cancelButton_callback,handles2};
selectButton.Callback={@selectButton_callback,handles2};
deselectButton.Callback={@deselectButton_callback,handles2};
popup_band.Callback={@popup_select_callback,handles2};
popup_channel.Callback={@popup_select_callback,handles2};

end

function popup_select_callback(hObj,~,handles2)
pattern = strtrim(char(hObj.String(hObj.Value,:)));
all_cb = findobj(handles2.MainFigure,'Style','checkbox');
for j =1:length(all_cb)
    if contains(all_cb(j).String,pattern)
        all_cb(j).Value=1-all_cb(j).Value;
    end
end
end

function selectButton_callback(~,~,handles2)
all_cb = findobj(handles2.MainFigure,'Style','checkbox');
for j =1:length(all_cb)
    all_cb(j).Value=1;
end
end

function deselectButton_callback(~,~,handles2)
all_cb = findobj(handles2.MainFigure,'Style','checkbox');
for j =1:length(all_cb)
    all_cb(j).Value=0;
end
end

function okButton_callback(~,~,handles,handles2,hParent)
all_cb = flipud(findobj(handles2.MainFigure,'Style','checkbox'));
selected = true(size(all_cb));
for j =1:length(all_cb)
    selected(j)=all_cb(j).Value;
end
hParent.UserData.selected =selected;
hParent.String = sprintf('%d/%d',sum(hParent.UserData.selected),length(hParent.UserData.selected));
%Storing restriction
hParent.UserData.popup.UserData.Restriction = hParent.UserData.all_options(selected);

% Resetting popups
if strcmp(hParent.UserData.popup.Tag,'Popup1')
    hParent.UserData.popup.String = hParent.UserData.popup.UserData.Restriction;
    hParent.UserData.popup.Value = 1;
end
pu1_Callback(handles.Popup1,[],handles);

close(handles2.MainFigure);

end

function cancelButton_callback(~,~,handles2)
close(handles2.MainFigure);
end

function pu1_Callback(hObj,~,handles)

f = handles.MainFigure;
pu2 = handles.Popup2;
data_dir = f.UserData.data_dir;

% Searching files and removing hidden files
recording = strtrim(char(hObj.String(hObj.Value,:)));
f.UserData.recording = recording;

d = dir(fullfile(data_dir,recording));
d = d(arrayfun(@(x) ~strcmp(x.name(1),'.'),d));
list_frames = {d(:).name}';

% Checking Restriction
if isempty(pu2.UserData.Restriction)
    pu2.String=list_frames;
    pu2.Value=1;
else
    pu2.String=list_frames(contains(list_frames,pu2.UserData.Restriction));
    pu2.Value=1;
end
pu2_Callback(pu2,[],handles);

end

function pu2_Callback(hObj,~,handles)

f = handles.MainFigure;
pu3 = handles.Popup3;

dir_save = f.UserData.dir_save;
recording = f.UserData.recording;
data_dir = f.UserData.data_dir;

% Searching files and removing hidden files
timeframe = strtrim(char(hObj.String(hObj.Value,:)));
f.UserData.timeframe = timeframe;

d = dir(fullfile(data_dir,recording,timeframe));
d = d(arrayfun(@(x) ~strcmp(x.name(1),'.'),d));
list_refs = {d(:).name}';

% Sorting list_refs by channels
% all_patterns = {'016';'011';'020';'025';'023';'015';'019';'024'};
% all_patterns = {'006';'005';'016';'015';'012';'009';'019';'025'};
if exist(fullfile(dir_save,strcat(recording,'_nlab'),'NConfig.mat'),'file')
    data_config = load(fullfile(dir_save,strcat(recording,'_nlab'),'NConfig.mat'));
    all_patterns = data_config.channel_id(strcmp(data_config.channel_type,'LFP'));
    
    all_indexes = zeros(length(list_refs),length(all_patterns)+1);
    cumulative_indexes = zeros(length(list_refs),1);
    list_refs_sorted = [];
    for k=1:length(all_patterns)
        cur_pattern = char(all_patterns(k));
        cur_indexes = ~(cellfun('isempty',strfind(list_refs,cur_pattern)));
        all_indexes(:,k)=(cur_indexes-cumulative_indexes)>0;
        cumulative_indexes = sum(all_indexes,2)>0;
        list_refs_sorted = [list_refs_sorted;list_refs(all_indexes(:,k)==1)];
    end
    all_indexes(:,k+1)=1-cumulative_indexes;
    list_refs_sorted = [list_refs_sorted;list_refs(all_indexes(:,k+1)==1)];
end

list_refs = list_refs_sorted;

% Sorting list_refs by bands
all_patterns = {'-delta-';'-theta-';'-beta-';'-gammalow-';'-gammamid-';'-gammamidup-';'-gammahigh-';'-gammahighup-';'-ripple-'};
all_indexes = zeros(length(list_refs),length(all_patterns)+1);
cumulative_indexes = zeros(length(list_refs),1);
list_refs_sorted = [];
for k=1:length(all_patterns)
    cur_pattern = char(all_patterns(k));
    cur_indexes = ~(cellfun('isempty',strfind(list_refs,cur_pattern)));
    all_indexes(:,k)=(cur_indexes-cumulative_indexes)>0;
    cumulative_indexes = sum(all_indexes,2)>0;
    list_refs_sorted = [list_refs_sorted;list_refs(all_indexes(:,k)==1)]; 
end
all_indexes(:,k+1)=1-cumulative_indexes;
list_refs_sorted = [list_refs_sorted;list_refs(all_indexes(:,k+1)==1)];
list_refs = list_refs_sorted;


% Checking Restriction
if isempty(pu3.UserData.Restriction)
    pu3.String=list_refs;
    pu3.Value=1;
else
    pu3.String=list_refs(contains(list_refs,pu3.UserData.Restriction));
    pu3.Value=1;
end
pu3_Callback(pu3,[],handles);

end

function pu3_Callback(hObj,~,handles)

f = handles.MainFigure;
e1 = handles.Edit1;

data_dir = f.UserData.data_dir;
recording = f.UserData.recording;
timeframe = f.UserData.timeframe;

% Searching files and removing hidden files
reference = strtrim(char(hObj.String(hObj.Value,:)));
f.UserData.reference = reference;

d = dir(fullfile(data_dir,recording,timeframe,reference,'_info.txt'));
e1.String = fullfile(d.folder,d.name);
display_Callback([],[],handles);

end

function pu3_key_pressFcn(hObj,evnt,handles)

previous_state = strtrim(char(hObj.String(hObj.Value,:)));
last_state = strtrim(char(hObj.String(end,:)));
first_state = strtrim(char(hObj.String(1,:)));
pu1 = handles.Popup1;
pu3 = handles.Popup3;

% evnt.Key

switch evnt.Key

    case 'rightarrow'
%         disp(1)
        if strcmp(previous_state,last_state) && pu1.Value<size(pu1.String,1)
            disp('go next');
            pu1.Value = pu1.Value+1;
            pu1_Callback(pu1,[],handles);
        end
        
    case 'leftarrow'
%         disp(2)
        if strcmp(previous_state,first_state) && pu1.Value>1
            disp('go previous');
            pu1.Value = pu1.Value-1;
            pu1_Callback(pu1,[],handles);
            % display last
            pu3.Value = size(pu3.String,1);
            pu3_Callback(pu3,[],handles);
        end
end
end

function cb1_Callback(hObj,~,all_axes)

all_atlas = findobj(all_axes,'Tag','Atlas');
    
if hObj.Value
    status = 'on';
else
    status = 'off';
end
for i = 1:length(all_atlas)
    all_atlas(i).Visible = status;
end

end

function cb2_Callback(hObj,~,ax)

im1 = findobj(ax,'Type','Image');
    
if hObj.Value
    im1.AlphaData= abs(im1.CData)>.15;
%     im1.AlphaData(isnan(im1.CData))=0;
else
    im1.AlphaData= 1;
end

end

function cb3_Callback(~,~,hObj,all_axes)

edit_min = hObj.UserData.Edit1;
edit_max = hObj.UserData.Edit2;

for i = 1:length(all_axes)
    if hObj.Value
        all_axes(i).CLimMode = 'auto';
        edit_min.Enable='off';
        edit_max.Enable='off';
    else
        all_axes(i).CLimMode = 'manual';
        all_axes(i).CLim = [str2double(edit_min.String) str2double(edit_max.String)];
        edit_min.Enable='on';
        edit_max.Enable='on';
    end
end
end

function display_Callback(~,~,handles)

f =  handles.MainFigure;
ax1 = handles.Ax1;
ax2 = handles.Ax2;
ax3 = handles.Ax3;

str_save = f.UserData.str_save;
dir_save = fullfile(str_save,'NLab_DATA');

color_atlas = 'k';
linewidth_atlas = .5;

data_dir = f.UserData.data_dir;
recording = f.UserData.recording;
timeframe = f.UserData.timeframe;
reference = f.UserData.reference;

fprintf('Loading Correlation Pattern [%s] ... ',fullfile(recording,timeframe,reference));
data_corr = load(fullfile(data_dir,recording,timeframe,reference,'Correlation_pattern.mat'));
fprintf('done.\n');

cur_file = strcat(recording,'_nlab');
% Loading atlas
fprintf('Loading Atlas [File: %s] ... ',cur_file);
data_atlas = load(fullfile(dir_save,cur_file,'Atlas.mat'));
fprintf('done.\n');
% Loading alphamap
data_mask = [];
if exist(fullfile(dir_save,cur_file,'Sources_fUS','Whole-reg.mat'),'file')
    data_mask = load(fullfile(dir_save,cur_file,'Sources_fUS','Whole-reg.mat'));
    data_mask.mask(data_mask.mask==0)=NaN;
end

 
if handles.Checkbox1.Value
    status = 'on';
else
    status = 'off';
end

cla(ax1);
im1 = imagesc(data_corr.Rmax_map,'Parent',ax1);
hold(ax1,'on');
plot(data_atlas.line_x,data_atlas.line_z,'Linewidth',linewidth_atlas,'Color',color_atlas,'Parent',ax1,'Tag','Atlas','Visible',status);
ax1.Title.String = 'Rmax';
% ax1.CLim = [-.4,.8];
ax1.XTick = [];
ax1.XTickLabel = '';
ax1.YTick = [];
ax1.YTickLabel = '';
ax1.XLim  = [.5 size(im1.CData,2)+.5];
ax1.YLim  = [.5 size(im1.CData,1)+.5];
colorbar(ax1);

cla(ax2);
im2 = imagesc(data_corr.Tmax_map,'Parent',ax2);
hold(ax2,'on');
plot(data_atlas.line_x,data_atlas.line_z,'Linewidth',linewidth_atlas,'Color',color_atlas,'Parent',ax2,'Tag','Atlas','Visible',status);
ax2.Title.String = 'Tmax';
% ax2.CLim = [-.4,.8];
ax2.XTick = [];
ax2.XTickLabel = '';
ax2.YTick = [];
ax2.YTickLabel = '';
ax2.XLim  = [.5 size(im2.CData,2)+.5];
ax2.YLim  = [.5 size(im2.CData,1)+.5];
colorbar(ax2);

cla(ax3);
im3 = imagesc('XData',data_corr.x_,'YData',1:size(data_corr.RT_pattern,1),'CData',data_corr.RT_pattern,'Parent',ax3);
% hold(ax3,'on');
% plot(data_atlas.line_x,data_atlas.line_z,'Linewidth',linewidth_atlas,'Color',color_atlas,'Parent',ax3,'Tag','Atlas','Visible',status);
ax3.Title.String = 'RT Pattern';
% ax3.CLim = [-.4,.4];
% ax3.XTick = [];
% ax3.XTickLabel = '';
ax3.YTick = 1:size(data_corr.RT_pattern,1);
ax3.YTickLabel = data_corr.labels(2:end,:);
ax3.XLim = [data_corr.x_(1) data_corr.x_(end)];
ax3.YLim = [.5 size(data_corr.RT_pattern,1)+.5];
colorbar(ax3);

% if ~isempty(data_mask)
%     im1.CData = im1.CData .* data_mask.mask;
%     im2.CData = im2.CData .* data_mask.mask;
% %     im3.CData = im3.CData .* data_mask.mask;
% end

cb1_Callback(handles.Checkbox1,[],[handles.Ax1;handles.Ax2]);
cb2_Callback(handles.Checkbox2,[],handles.Ax1);
drawnow;

end

function f2 = batch_Callback(hObj,~,handles)

f =  handles.MainFigure;
ax1 = handles.Ax1;
ax2 = handles.Ax2;
ax3 = handles.Ax3;

% all_params={'Rmax';'Tmax';'RT_pattern'};
% [ind_param,v] = listdlg('Name','List Selection','PromptString','Select parameter to display',...
%     'SelectionMode','single','ListString',all_params,'InitialValue','','ListSize',[300 500]);
% if isempty(ind_param)||v==0
%     return;
% else
%     cur_param = char(all_params(ind_param));
% end
cur_param = strtrim(handles.Popup0.String(handles.Popup0.Value,:));
str_save = f.UserData.str_save;
dir_save = fullfile(str_save,'NLab_DATA');

color_atlas = 'k';
linewidth_atlas = .5;

data_dir = f.UserData.data_dir;
recording = f.UserData.recording;
timeframe = f.UserData.timeframe;
reference = f.UserData.reference;
all_options = hObj.UserData.popup.String;

switch hObj.Tag
    case 'Button21'
        flag_popup = 1;
        str_batch = fullfile('*',timeframe,reference);
        all_recordings = all_options;
        all_timeframes = {timeframe};
        all_references = {reference};
    case 'Button22'
        flag_popup = 2;
        str_batch = fullfile(recording,'*',reference);
        all_recordings = {recording};
        all_timeframes = all_options;
        all_references = {reference};

    case 'Button23'
        flag_popup = 3;
        str_batch = fullfile(recording,timeframe,'*');
        all_recordings = {recording};
        all_timeframes = {timeframe};
        all_references = all_options;
end

f2 = figure('Tag','Batch','Name',str_batch,'Units','normalized');
f2.UserData.cur_param = cur_param;
colormap(f2,'jet');
clrmenu(f2);
cb1_status = 'on';
cb1 = uicontrol('Units','normalized','Parent',f2,'Style','checkbox','String','Atlas on/off','Tag','Checkbox1','Value',0);
cb1.Position = [.01 0 .1 .05];
cb3 = uicontrol('Units','normalized','Parent',f2,'Style','checkbox','String','CLimMode auto','Tag','Checkbox3','Value',0);
cb3.Position = [.11 0 .1 .05];
e1 = uicontrol('Units','normalized','Parent',f2,'Style','edit','String',-.25,'TooltipString','CLim(1)','Tag','Edit1','Enable','off');
e1.Position = [.21 .01 .04 .03];
e2 = uicontrol('Units','normalized','Parent',f2,'Style','edit','String',.5,'TooltipString','CLim(2)','Tag','Edit2','Enable','off');
e2.Position = [.26 .01 .04 .03];
cb3.UserData.Edit1=e1;
cb3.UserData.Edit2=e2;
t1 = uicontrol('Units','normalized','Parent',f2,'FontWeight','bold','FontSize',12,'Style','text','Tag','Text1');%,'BackgroundColor','w'
t1.Position = [.4 .01 .4 .03];
b11 = uicontrol('Units','normalized','Parent',f2,'Style','pushbutton','String','Save','TooltipString','Save Image','Tag','Button11');
b11.Position = [.9 .01 .08 .03];

N = ceil(sqrt(length(all_options)));
counter = 0;
all_axes = [];
all_labels = [];
all_end_titles = [];

for i=1:length(all_recordings)
    cur_recording = char(all_recordings(i));
    cur_file = strcat(cur_recording,'_nlab');

    if exist(fullfile(dir_save,cur_file,'Atlas.mat'),'file')
        fprintf('Loading Atlas [File: %s] ... ',cur_file);
        data_atlas = load(fullfile(dir_save,cur_file,'Atlas.mat'));
        fprintf('done.\n');
    end
            
    for j=1:length(all_timeframes)
        cur_timeframe = char(all_timeframes(j));
            
        for k=1:length(all_references)
            cur_reference = char(all_references(k));
            if exist(fullfile(data_dir,cur_recording,cur_timeframe,cur_reference),'file') 
                fprintf('Loading Correlation Pattern [%d/%d] [%s] ... ',counter,length(all_options),fullfile(cur_recording,cur_timeframe,cur_reference));
                data_corr = load(fullfile(data_dir,cur_recording,cur_timeframe,cur_reference,'Correlation_pattern.mat'));
                fprintf('done.\n');
            else
                warning('Could not load [%d/%d] [%s].',counter,length(all_options),fullfile(cur_recording,cur_timeframe,cur_reference));
                continue;
            end

            counter = counter+1;
            cur_option = char(all_options(counter));
            
            ax = subplot(N,N,counter,'Parent',f2);
            switch cur_param
                case {'Rmax'}
                    imagesc(data_corr.Rmax_map,'Parent',ax);
                case {'Tmax'}
                    imagesc(data_corr.Tmax_map,'Parent',ax);
                    e1.String = -2;
                    e2.String = 6;
                case {'RT_pattern'}
                    imagesc(data_corr.RT_pattern,'Parent',ax,'XData',data_corr.x_);
            end
            hold(ax,'on');
            plot(data_atlas.line_x,data_atlas.line_z,'Linewidth',linewidth_atlas,'Color',color_atlas,'Parent',ax,'Tag','Atlas','Visible',cb1_status);
            if strcmp(cur_param,'RT_pattern')
                set(ax,'YTick',[],'YTickLabel',[]);
            else%if counter>1
                set(ax,'XTick',[],'XTickLabel',[],'YTick',[],'YTickLabel',[]);
            end
            
            switch data_atlas.AtlasName
                case 'Rat Coronal Paxinos'
                    ylabel = sprintf('AP=%.2fmm',data_atlas.AP_mm);
                case 'Rat Sagittal Paxinos'
                    ylabel = sprintf('ML=%.2fmm',data_atlas.ML_mm);
            end
            ax.YLabel.String = ylabel;
            all_labels = [all_labels;{ylabel}];
            
            ax.FontSize = 8;
            ax.Title.String = strrep(cur_option,'_','-');
            temp = strrep(cur_option,'-extra','');
            all_end_titles = [all_end_titles;{temp(end-2:end)}];
            all_axes = [all_axes;ax];
        end
    end
end

% Addding colorbar to last axis
cbar = colorbar(ax,'westoutside');

% Reorganizing axes 
if strcmp(hObj.Tag,'Button23')
    %indexing by column
    % n_col = length(unique(all_end_titles));
    % n_rows = ceil(N/n_rows);
    %indexing by line
    n_rows = length(unique(all_end_titles));
    n_col = ceil(counter/n_rows);
else
    n_rows = ceil(sqrt(counter));
    n_col = ceil(sqrt(counter));
end

eps1 =.01;
eps2 =.015;
for i=1:counter
    ax = all_axes(i);
%     %indexing by line
%     ax.Position = [mod(i-1,n_col)/n_col+eps1 1-(ceil(i/n_col)/n_rows)+eps2 1/n_col-2*eps1 1/n_rows-2*eps2];  
    % indexing by column
    ax.Position = [ (floor((i-1)/n_rows)/n_col)+eps1 1-((mod(i-1,n_rows)+1)/(1.05*n_rows))+eps2 1/n_col-2*eps1 1/(1.05*n_rows)-2*eps2];  
%     fprintf('%d - (%.2f,%.2f)- %s\n',i,ax.Position(1),ax.Position(2),ax.Title.String);
    ax.FontSize = 6;
end

cbar.Position = [ax.Position(1)-0.75*eps1 ax.Position(2) eps1/2 ax.Position(4)];

if length(unique(all_labels))==1
    f2.Name = sprintf('[%s]%s[%d recordings-%s]',char(unique(all_labels)),str_batch,counter,cur_param);
else
    f2.Name = sprintf('%s[%d recordings-%s]',str_batch,counter,cur_param);
end
f2.OuterPosition = [0 0 1 1];
t1.String = f2.Name;

b11.Callback = {@b11_Callback,handles};
cb1.Callback = {@cb1_Callback,all_axes};
cb3.Callback = {@cb3_Callback,cb3,all_axes};
e1.Callback = {@cb3_Callback,cb3,all_axes};
e2.Callback = {@cb3_Callback,cb3,all_axes};

cb1_Callback(cb1,[],all_axes);
cb3_Callback([],[],cb3,all_axes);

end

function b11_Callback(hObj,~,handles)

% Save pic
f_main =  handles.MainFigure;
f = hObj.Parent;
cur_param = f.UserData.cur_param;
data_dir = fullfile(f_main.UserData.fig_dir,'Synthesis',cur_param);

if ~exist(data_dir,'dir')
    mkdir(data_dir);
end
save_name = strcat(strrep(strrep(f.Name,filesep,'-'),'*','-'),'.jpg');
saveas(f,fullfile(data_dir,save_name),'jpeg');
data_dir2 = '/media/hobbes/DataMOBs171/Synthesis-fUS-Correlation';
saveas(f,fullfile(data_dir2,save_name),'jpeg');
fprintf('File Saved [%s].\n',fullfile(data_dir,save_name));
close(f);

end

% function f2 = all_Callback(hObj,~,handles)
% 
% f =  handles.MainFigure;
% str_save = f.UserData.str_save;
% dir_save = fullfile(str_save,'NLab_DATA');
% data_dir = f.UserData.data_dir;
% recording = f.UserData.recording;
% timeframe = f.UserData.timeframe;
% reference = f.UserData.reference;
% 
% color_atlas = 'k';
% linewidth_atlas = .5;
% 
% % all_params={'Rmax';'Tmax';'RT_pattern'};
% % [ind_param,v] = listdlg('Name','List Selection','PromptString','Select parameter to display',...
% %     'SelectionMode','single','ListString',all_params,'InitialValue','','ListSize',[300 500]);
% % if isempty(ind_param)||v==0
% %     return;
% % else
% %     cur_param = char(all_params(ind_param));
% % end
% cur_param = strtrim(handles.Popup0.String(handles.Popup0.Value,:));
% 
% % Listing all files
% d = dir(fullfile(data_dir,'*','*','*','Correlation_pattern.mat'));
% all_folders = {d(:).folder}';
% all_recordings = handles.Popup1.String;
% all_timeframes = handles.Popup2.String;
% all_references = handles.Popup3.String;
% % Restricting to selection
% ind_restrict = (contains(all_folders,all_recordings).* contains(all_folders,all_timeframes)).* contains(all_folders,all_references);
% d = d(ind_restrict==1);
% all_folders = {d.folder}';
% 
% list_options = hObj.UserData.popup.String;
% 
% switch hObj.Tag
%     case 'Button31'
%         str_batch = [];
%         for j = 1:length(all_timeframes)
%             for k = 1:length(all_references)
%                 str_batch = [str_batch; fullfile('*',all_timeframes(j),all_references(k))];
%             end
%         end
%         
%     case 'Button32'
%         str_batch = [];
%         for i = 1:length(all_recordings)
%             for k = 1:length(all_references)
%                 str_batch = [str_batch; fullfile(all_recordings(i),'*',all_references(k))];
%             end
%         end
%         
%     case 'Button33'
%         str_batch = [];
%         for i = 1:length(all_recordings)
%             for j = 1:length(all_timeframes)
%                 str_batch = [str_batch; fullfile(all_recordings(i),all_timeframes(j),'*')];
%             end
%         end
% end
% 
% f2 = figure('Units','normalized','Tag','All','Name',sprintf('Birds Eye View [%s]',data_dir));
% f2.UserData.cur_param = cur_param;
% clrmenu(f2);
% colormap(f2,'jet');
% cb1_status = 'on';
% cb1 = uicontrol('Units','normalized','Parent',f2,'Style','checkbox','String','Atlas on/off','Tag','Checkbox1','Value',0);
% cb1.Position = [.01 .01 .1 .02];
% cb3 = uicontrol('Units','normalized','Parent',f2,'Style','checkbox','String','CLimMode auto','Tag','Checkbox3','Value',0);
% cb3.Position = [.11 .01 .1 .02];
% e1 = uicontrol('Units','normalized','Parent',f2,'Style','edit','String',-.25,'TooltipString','CLim(1)','Tag','Edit1','Enable','off');
% e1.Position = [.21 .01 .04 .03];
% e2 = uicontrol('Units','normalized','Parent',f2,'Style','edit','String',.5,'TooltipString','CLim(2)','Tag','Edit2','Enable','off');
% e2.Position = [.26 .01 .04 .03];
% cb3.UserData.Edit1=e1;
% cb3.UserData.Edit2=e2;
% b21 = uicontrol('Units','normalized','Parent',f2,'Style','pushbutton','String','Save','TooltipString','Save Image','Tag','Button21');
% b21.Position = [.9 .01 .08 .03];
% 
% % Creating uitabgroup
% mP = uipanel('FontSize',8,'Units','normalized','Position',[0 .05 1 .95],'Parent',f2);
% tabgp = uitabgroup('Units','normalized','Position',[0 0 1 1],'Parent',mP,'Tag','TabGroup');
% all_axes_2 = [];
% 
% h = waitbar(0,'Please wait');
% counter = 0;
% for i=1:5%length(str_batch)
%     
%     all_labels = [];
%     all_end_titles = [];
%     cur_batch = char(str_batch(i));
%     cur_options = strrep(cur_batch,'*',list_options);
%         
%     tab = uitab('Parent',tabgp,'Title',sprintf('%02d',i),'Units','normalized','Tag',sprintf('Tab%d',i));
%     tab.TooltipString=cur_batch;
% %     tab.UserData.cur_batch = cur_batch;
%     all_axes = [];
%     
%     d_restricted = d(contains(all_folders,cur_options)==1);
%     N = length(d_restricted);
%     n = ceil(sqrt(N));
%         
%     prop = ((i-1)/length(str_batch));
%     waitbar(prop,h,sprintf('Loading [%s]\n %.1f %% completed',cur_batch,100*prop));
%     
%     for j=1:N
%         
%         counter = counter+1 ;
%         temp = regexp(d_restricted(j).folder,filesep,'split');
%         cur_recording = char(temp(end-2));
%         cur_timeframe = char(temp(end-1));
%         cur_reference = char(temp(end));
%         
%         switch hObj.Tag
%             case 'Button31'
%                 cur_option=cur_recording;
%                 tab_title=fullfile(cur_timeframe,cur_reference);
%             case 'Button32'
%                 cur_option=cur_timeframe;
%                 tab_title=fullfile(cur_recording,cur_reference);
%             case 'Button33'
%                 cur_option=cur_reference;
%                 tab_title=fullfile(cur_recording,cur_timeframe);
%         end
%     
%         fprintf('Loading Correlation Pattern [%d/%d] [%s] ... ',j,N,d_restricted(j).folder);
%         data_corr = load(fullfile(d_restricted(j).folder,d_restricted(j).name));
%         fprintf('done.\n');
%         
%         cur_file = strcat(cur_recording,'_nlab');
%         if exist(fullfile(dir_save,cur_file,'Atlas.mat'),'file')
%             fprintf('Loading Atlas [File: %s] ... ',cur_file);
%             data_atlas = load(fullfile(dir_save,cur_file,'Atlas.mat'));
%             fprintf('done.\n');
%         end
%         
%         ax = subplot(n,n,j,'Parent',tab);
%         
%         %imagesc(data_corr.Rmax_map,'Parent',ax);
%         switch cur_param
%             case {'Rmax'}
%                 imagesc(data_corr.Rmax_map,'Parent',ax);
%             case {'Tmax'}
%                 imagesc(data_corr.Tmax_map,'Parent',ax);
%                 e1.String = -2;
%                 e2.String = 6;
%             case {'RT_pattern'}
%                 imagesc(data_corr.RT_pattern,'Parent',ax,'XData',data_corr.x_);
%         end
%         
%         hold(ax,'on');
%         plot(data_atlas.line_x,data_atlas.line_z,'Linewidth',linewidth_atlas,'Color',color_atlas,'Parent',ax,'Tag','Atlas','Visible',cb1_status);
%         
%         switch data_atlas.AtlasName
%             case 'Rat Coronal Paxinos'
%                 ylabel = sprintf('AP=%.2fmm',data_atlas.AP_mm);
%             case 'Rat Sagittal Paxinos'
%                 ylabel = sprintf('ML=%.2fmm',data_atlas.ML_mm);
%         end
%         ax.YLabel.String = ylabel;
%         all_labels = [all_labels;{ylabel}];
%         
%         if strcmp(cur_param,'RT_pattern') %&& j==1
%             set(ax,'YTick',[],'YTickLabel',[]);
%         else%if counter>1
%             set(ax,'XTick',[],'XTickLabel',[],'YTick',[],'YTickLabel',[]);
%         end
%         
%         ax.FontSize = 6;
%         ax.Title.String = strrep(cur_option,'_','-');
%         all_axes = [all_axes;ax];
%         all_end_titles = [all_end_titles;{cur_option(end-2:end)}];
%     end
%     
%     % Addding colorbar to last axis
%     cbar = colorbar(ax,'westoutside');
%     
%     eps1 =.01;
%     eps2 =.015;
%     
%     if strcmp(hObj.Tag,'Button33')
% %         %indexing by column
% %         n_col = length(unique(all_end_titles));
% %         n_rows = ceil(N/n_rows);
%         %indexing by line
%         n_rows = length(unique(all_end_titles));
%         n_col = ceil(N/n_rows);
%     else
%         n_rows = ceil(sqrt(N));
%         n_col = ceil(sqrt(N));
%     end
% 
%     for k=1:N
%         ax=all_axes(k);
%         % ax.Position = [mod(j-1,n)/n+eps 1-ceil(j/n)/n+eps 1/n-2*eps 1/n-2*eps];
%         % indexing by line
%         % ax.Position = [mod(i-1,n_col)/n_col+eps1 1-(ceil(i/n_col)/n_rows)+eps2 1/n_col-2*eps1 1/n_rows-2*eps2];
%         % indexing by column
%         ax.Position = [ (floor((k-1)/n_rows)/n_col)+eps1 1-((mod(k-1,n_rows)+1)/n_rows)+eps2 1/n_col-2*eps1 1/n_rows-2*eps2];
%     end
%     cbar.Position = [ax.Position(1)-0.75*eps1 ax.Position(2) eps1/2 ax.Position(4)];
% 
%     if length(unique(all_labels))==1
%         tab.Title=strcat('[',char(unique(all_labels)),']',tab_title);
%     else
%         tab.Title=tab_title;
%     end
%     tab.UserData.all_axes = all_axes;
%     all_axes_2 = [all_axes_2;all_axes];
% 
% end
% 
% close(h);
% f2.Name = sprintf('Birds-Eye-View[%drecordings-%s]',counter,cur_param);
% f2.OuterPosition = [0 0 1 1];
% 
% b21.Callback = {@b21_Callback,handles};
% cb1.Callback = {@cb1_Callback,all_axes_2};
% cb3.Callback = {@cb3_Callback,cb3,all_axes_2};
% e1.Callback = {@cb3_Callback,cb3,all_axes_2};
% e2.Callback = {@cb3_Callback,cb3,all_axes_2};
% 
% cb1_Callback(cb1,[],all_axes_2);
% cb3_Callback([],[],cb3,all_axes_2);
% 
% end
% 
% function b21_Callback(hObj,~,handles)
% 
% % Save pic
% f_main =  handles.MainFigure;
% f = hObj.Parent;
% cur_param = f.UserData.cur_param;
% data_dir = fullfile(f_main.UserData.fig_dir,'Synthesis',cur_param);
% tabgp = findobj(f,'Tag','TabGroup');
% all_tabs = tabgp.Children;
% 
% if ~exist(data_dir,'dir')
%     mkdir(data_dir);
% end
% 
% for i =1:length(all_tabs)
%     cur_tab = all_tabs(i);
%     tabgp.SelectedTab = cur_tab;
%     save_name = strcat(strrep(cur_tab.Title,filesep,'-'),'.jpg');
%     saveas(f,fullfile(data_dir,save_name),'jpeg');
% %     save_name = strcat(strrep(cur_tab.Title,filesep,'-'),'.pdf');
% %     saveas(f,fullfile(data_dir,save_name),'pdf');
% 
%     fprintf('File Saved %d/%d [%s].\n',i,length(all_tabs),fullfile(data_dir,save_name));
% end
% 
% end
