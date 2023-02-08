function f = script_browse_correlation(str_save)

global STR_SAVE;
if nargin < 1
    if exist(STR_SAVE)
        str_save = STR_SAVE;
    else
        errordlg('Please provide path to NEUROLAB folder. \n[/media/hobbes/DataMOBs171/Antoine-fUSDataset/NEUROLAB].');
        return;
    end
end

f = figure('Tag','MainFigure');
data_dir = fullfile(str_save,'NLab_Statistics','fUS_Correlation');

% Storing data
f.UserData.data_dir = data_dir;
f.UserData.str_save = str_save;
data_dir = f.UserData.data_dir;
f.UserData.recording = '';
f.UserData.timeframe = '';
f.UserData.reference = '';
clrmenu(f);
colormap(f,'jet')

% Searching files and removing hidden files
d = dir(data_dir);
d = d(arrayfun(@(x) ~strcmp(x.name(1),'.'),d));
list_files = {d(:).name}';
list_ref = '-';

% Searching all
all_files = list_files;
d = dir(fullfile(data_dir,'*','*'));
d = d(arrayfun(@(x) ~strcmp(x.name(1),'.'),d));
all_timeframes = unique({d(:).name}');
d = dir(fullfile(data_dir,'*','*','*'));
d = d(arrayfun(@(x) ~strcmp(x.name(1),'.'),d));
all_references = unique({d(:).name}');

pu1 = uicontrol('Units','normalized','Parent',f,'Style','popup','ToolTipString','recording','String',list_files,'Tag','Popup1');
pu1.Position = [.05 .95 .85 .04];
pu1.UserData.Restriction = [];
b11 = uicontrol('Units','normalized','Parent',f,'Style','pushbutton','String','*','ToolTipString','Selected/Total','Tag','Button11','Value',0);
b11.Position = [.91 .95 .05 .04];
b11.UserData.all_options = all_files;
b11.UserData.selected = true(size(all_files));
b11.UserData.popup = pu1;
b11.String = sprintf('%d/%d',sum(b11.UserData.selected),length(b11.UserData.selected));

pu2 = uicontrol('Units','normalized','Parent',f,'Style','popup','ToolTipString','timeframe','Value',1,'String',list_ref,'Tag','Popup2');
pu2.Position = [.05 .9 .85 .04];
pu2.UserData.Restriction = [];
b12 = uicontrol('Units','normalized','Parent',f,'Style','pushbutton','String','*','ToolTipString','Selected/Total','Tag','Button12','Value',0);
b12.Position = [.91 .9 .05 .04];
b12.UserData.all_options = all_timeframes;
b12.UserData.selected = true(size(all_timeframes));
b12.UserData.popup = pu2;
b12.String = sprintf('%d/%d',sum(b12.UserData.selected),length(b12.UserData.selected));

pu3 = uicontrol('Units','normalized','Parent',f,'Style','popup','ToolTipString','reference','Value',1,'String',list_ref,'Tag','Popup3');
pu3.Position = [.05 .85 .85 .04];
pu3.UserData.Restriction = [];
b13 = uicontrol('Units','normalized','Parent',f,'Style','pushbutton','String','*','ToolTipString','Selected/Total','Tag','Button13','Value',0);
b13.Position = [.91 .85 .05 .04];
b13.UserData.all_options = all_references;
b13.UserData.selected = true(size(all_references));
b13.UserData.popup = pu3;
b13.String = sprintf('%d/%d',sum(b13.UserData.selected),length(b13.UserData.selected));

b1 = uicontrol('Units','normalized','Parent',f,'Style','pushbutton','String','Browse','Tag','Button1');
b1.Position = [.05 .8 .1 .04];
e1 = uicontrol('Units','normalized','Parent',f,'Style','pushbutton','ToolTipString','Info Panel','String','','Tag','Edit1','BackgroundColor','w');
e1.Position = [.155 .8 .7 .04];
b2 = uicontrol('Units','normalized','Parent',f,'Style','pushbutton','String','Display','Tag','Button2');
b2.Position = [.86 .8 .1 .04];

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
e1.Callback = {@e1_Callback};
cb1.Callback = {@cb1_Callback,handles};
cb2.Callback = {@cb2_Callback,handles};

b11.Callback = {@dialog_Callback,handles};
b12.Callback = {@dialog_Callback,handles};
b13.Callback = {@dialog_Callback,handles};

f.Units = 'normalized';
f.Position = [0.0380    0.3065    0.8662    0.4981];
pu1_Callback(pu1,[],handles);

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
H = 65;
ftsize = 10;

all_options = hObj.UserData.all_options;
selected = hObj.UserData.selected;

f2 = dialog('Units','characters',...
    'Position',[30 10 W H],...
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

data_dir = f.UserData.data_dir;
recording = f.UserData.recording;

% Searching files and removing hidden files
timeframe = strtrim(char(hObj.String(hObj.Value,:)));
f.UserData.timeframe = timeframe;

d = dir(fullfile(data_dir,recording,timeframe));
d = d(arrayfun(@(x) ~strcmp(x.name(1),'.'),d));
list_refs = {d(:).name}';

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

d = dir(fullfile(data_dir,recording,timeframe,reference,'*.txt'));
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

function cb1_Callback(hObj,~,handles)

all_axes = [handles.Ax1; handles.Ax2];
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

function cb2_Callback(hObj,~,handles)

im1 = findobj(handles.Ax1,'Type','Image');
    
if hObj.Value
    im1.AlphaData= abs(im1.CData)>.15;
%     im1.AlphaData(isnan(im1.CData))=0;
else
    im1.AlphaData= 1;
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

cb1_Callback(handles.Checkbox1,[],handles);
cb2_Callback(handles.Checkbox2,[],handles);
drawnow;

end
