function f2 = figure_fUS_EpisodeStatistics(handles,val,str_group)
% (Figure) Displays epsiode statistics based on time groups

global DIR_SAVE FILES CUR_FILE;

if ~exist(fullfile(DIR_SAVE,FILES(CUR_FILE).nlab,'Time_Tags.mat'),'file')||~exist(fullfile(DIR_SAVE,FILES(CUR_FILE).nlab,'Time_Reference.mat'),'file')
    warning('Missing File Time_Tags.mat or Time_Reference.mat %s',fullfile(DIR_SAVE,FILES(CUR_FILE).nlab));
    return;
end
load(fullfile(DIR_SAVE,FILES(CUR_FILE).nlab,'Time_Tags.mat'),'TimeTags_cell','TimeTags_images','TimeTags_strings');
load(fullfile(DIR_SAVE,FILES(CUR_FILE).nlab,'Time_Reference.mat'),'time_ref','n_burst','length_burst');

if exist(fullfile(DIR_SAVE,FILES(CUR_FILE).nlab,'Time_Groups.mat'),'file')
    load(fullfile(DIR_SAVE,FILES(CUR_FILE).nlab,'Time_Groups.mat'),'TimeGroups_name','TimeGroups_S');
else
    TimeGroups_name=[];
    TimeGroups_S = [];
end

f2 = figure('Units','characters',...
    'HandleVisibility','callback',...
    'IntegerHandle','off',...
    'Renderer','painters',...
    'Toolbar','figure',...
    'NumberTitle','off',...
    'Tag','MainFigure',...
    'PaperPositionMode','auto',...
    'Name','fUS Region Statistics');
% Storing Time Data
f2.UserData.old_handles = handles;
f2.UserData.TimeTags_cell = TimeTags_cell;
f2.UserData.TimeTags_images = TimeTags_images;
f2.UserData.TimeTags_strings = TimeTags_strings;
f2.UserData.time_ref = time_ref;
f2.UserData.n_burst = n_burst;
f2.UserData.length_burst = length_burst;
% Colormaps
colormap(f2,'jet');
clrmenu(f2);

% Information Panel
iP = uipanel('FontSize',12,...
    'Units','normalized',...
    'Tag','InfoPanel',...
    'Position',[0 .1 1 .9],...
    'Parent',f2);

str = handles.CenterPanelPopup.String(handles.CenterPanelPopup.Value,:);
uicontrol('Units','characters','Style','text','HorizontalAlignment','left','Parent',iP,...
    'String',sprintf(' File : %s\n Source : %s',FILES(CUR_FILE).nlab,str),'Tag','Text1');
e1 = uicontrol('Units','characters','Style','edit','HorizontalAlignment','center',...
    'Tooltipstring','# Episodes','Parent',iP,'String',0,'Tag','Edit1');

uicontrol('Units','characters','Style','edit','HorizontalAlignment','center','Parent',iP,...
    'String',4,'Tag','Edit2','Tooltipstring','# Channels');
pu1 = uicontrol('Units','characters','Style','popupmenu','Parent',iP,...
    'String','<0>','Tag','Popup1','Value',1);
pu2 = uicontrol('Units','characters','Style','popupmenu','Parent',iP,...
    'String','<0>','Tag','Popup2','Value',1);

switch n_burst
    case 1
        pu2.String = 'Mean|Median|BoxPlot';
    otherwise
        str = 'Mean|Median|Mean Per Burst|Median Per Burst|Min Per Burst|Max Per Burst';
        str = strcat(str,'|Peak Time Per Burst (Ref:Speed)|Peak Time Per Burst (Ref:Accel)|Peak Time Per Burst (Ref:Theta)');
        pu2.String = str;
end

uicontrol('Units','characters','Style','pushbutton','Parent',iP,...
    'String','Reset','Tag','ButtonReset');
bc = uicontrol('Units','characters','Style','pushbutton','Parent',iP,...
    'String','Compute','Tag','ButtonCompute');
uicontrol('Units','characters','Style','pushbutton','Parent',iP,...
    'String','Legend','Tag','ButtonLegend');
uicontrol('Units','characters','Style','pushbutton','Parent',iP,...
    'String','Save Image','Tag','ButtonSaveImage');
uicontrol('Units','characters','Style','pushbutton','Parent',iP,...
    'String','Save Stats','Tag','ButtonSaveStats');
uicontrol('Units','characters','Style','pushbutton','Parent',iP,...
    'String','Batch Save','Tag','ButtonBatchSave');
uicontrol('Units','characters','Style','checkbox','Parent',iP,...
    'TooltipString','Group by','Tag','BoxInvert','Value',0,'String','Groups');
uicontrol('Units','characters','Style','checkbox','Parent',iP,...
    'TooltipString','BarLink','Tag','BoxBarLink','Value',0,'String','unlinked');

bg = uibuttongroup('Visible','on','Tag','Buttongroup',...
    'Units','characters','Parent',iP);       
% Create three radio buttons in the button group.
uicontrol(bg,'Style','radiobutton','String','Groups',...
    'Tag','Radio1','Units','characters','Position',[10 150 100 30]);        
uicontrol(bg,'Style','radiobutton','String','Channels',...
    'Tag','Radio2','Units','characters','Position',[10 50 100 30]);

% Creating uitabgroup
mP = uipanel('FontSize',12,...
    'Units','normalized',...
    'Position',[0 .1 1 .9],...
    'Parent',f2);
tabgp = uitabgroup('Units','normalized',...
    'Position',[0 0 1 1],...
    'Parent',mP,...
    'Tag','TabGroup');

%Trace Tab
tab0 = uitab('Parent',tabgp,...
    'Title','Traces & Episodes',...
    'Tag','TraceTab');
episodes = str2double(e1.String);
tracePanel = uipanel('Parent',tab0,...
    'Units','normalized',...
    'Position',[0 0 1/(1+episodes) 1],...
    'Title','Traces',...
    'Tag','TracePanel');
groupPanel = uipanel('Parent',tab0,...
    'Units','normalized',...
    'Position',[1/(1+episodes) 0 1/(1+episodes) 1],...
    'Title','Time Groups',...
    'Tag','GroupPanel');

% Lines Array
m = findobj(handles.RightAxes,'Tag','Trace_Mean');
l = flipud(findobj(handles.RightAxes,'Type','line','-not','Tag','Cursor','-not','Tag','Trace_Cerep','-not','Tag','Trace_Mean'));
t = flipud(findobj(handles.RightAxes,'Tag','Trace_Cerep'));
lines = [m;l;t];
bc.UserData.lines = lines;
pu1.UserData.lines = lines;

% Table Data
D = [];
for i =1:length(lines)
    D=[D;{lines(i).UserData.Name, lines(i).Tag}];
end

tt = uitable('Units','normalized',...
    'ColumnName','',...
    'RowName',{},...
    'ColumnFormat',{'char','char'},...
    'ColumnEditable',[false,false],...
    'ColumnWidth',{120 120},...
    'Data',D,...
    'Position',[0 0 1 1],...
    'Tag','Trace_table',...
    'CellSelectionCallback',@template_uitable_select,...
    'RowStriping','on',...
    'Parent',tracePanel);
tt.UserData.Selection = find(strcmp(tt.Data(:,2),'Trace_Region')==1);
gt = uitable('Units','normalized',...
    'ColumnName','',...
    'RowName',{},...
    'ColumnFormat',{'char'},...
    'ColumnEditable',false,...
    'ColumnWidth',{120},...
    'Data',TimeGroups_name,...
    'Position',[0 0 1 1],...
    'Tag','Group_table',...
    'CellSelectionCallback',@template_uitable_select,...
    'RowStriping','on',...
    'Parent',groupPanel);
gt.UserData.Selection=[];
gt.UserData.TimeGroups_name = TimeGroups_name;
gt.UserData.TimeGroups_S = TimeGroups_S;

% First tab
tab1 = uitab('Parent',tabgp,...
    'Title','Bar graphs',...
    'Units','normalized',...
    'Tag','MainTab');
uipanel('FontSize',12,...
    'Units','normalized',...
    'Tag','MainPanel',...
    'Parent',tab1);

% Second tab
tab2 = uitab('Parent',tabgp,...
    'Title','Mean',...
    'Units','normalized',...
    'Tag','SecondTab');
sp = uipanel('FontSize',12,...
    'Units','normalized',...
    'Position',[0 0 1 1],...
    'Tag','SecondPanel',...
    'Parent',tab2);
uicontrol('Units','normalized',...
    'Style','checkbox',...
    'Callback',{@boxLegend_Callback},...
    'Parent',sp,...
    'TooltipString','Legend Visibility',...
    'Position',[0 0 .04 .04],...
    'Tag','BoxLegend',...
    'Value',1);
uicontrol('Units','normalized',...
    'Style','checkbox',...
    'Callback',{@boxErrorBar_Callback},...
    'Position',[0 .04 .04 .04],...
    'Parent',sp,...
    'TooltipString','ErrorBar Visibility',...
    'Tag','BoxBar',...
    'Value',0);
axes('Parent',sp,'Position',[.05 .05 .8 .9],...
    'Tag','SecondAxes',...
    'TickLength',[0 0.1]);
axes('Parent',sp,'Position',[.05 .05 .8 .9],...
    'Tag','DummyAxes',...
    'Visible','off',...
    'TickLength',[0 0.1]);

% Third tab
tab3 = uitab('Parent',tabgp,...
    'Title','Median',...
    'Units','normalized',...
    'Tag','ThirdTab');
tp = uipanel('FontSize',12,...
    'Units','normalized',...
    'Position',[0 0 1 1],...
    'Tag','ThirdPanel',...
    'Parent',tab3);
uicontrol('Units','normalized',...
    'Style','checkbox',...
    'Callback',{@boxLegend_Callback},...
    'Parent',tp,...
    'TooltipString','Legend Visibility',...
    'Position',[0 0 .04 .04],...
    'Tag','BoxLegend',...
    'Value',1);
uicontrol('Units','normalized',...
    'Style','checkbox',...
    'Callback',{@boxErrorBar_Callback},...
    'Parent',tp,...
    'TooltipString','ErrorBar Visibility',...
    'Position',[0 .04 .04 .04],...
    'Tag','BoxBar',...
    'Value',0);
axes('Parent',tp,'Position',[.05 .05 .8 .9],...
    'Tag','ThirdAxes',...
    'TickLength',[0 0.1]);
axes('Parent',tp,'Position',[.05 .05 .8 .9],...
    'Tag','DummyAxes',...
    'Visible','off',...
    'TickLength',[0 0.1]);

% Fourth tab
tab4 = uitab('Parent',tabgp,...
    'Title','BoxPlot',...
    'Units','normalized',...
    'Tag','FourthTab');
fp = uipanel('FontSize',12,...
    'Units','normalized',...
    'Position',[0 0 1 1],...
    'Tag','FourthPanel',...
    'Parent',tab4);
uicontrol('Units','normalized',...
    'Style','checkbox',...
    'Callback',{@boxLegend_Callback},...
    'Parent',fp,...
    'TooltipString','Legend Visibility',...
    'Tag','BoxLegend',...
    'Position',[0 0 .04 .04],...
    'Value',1);
axes('Parent',fp,'Position',[.05 .05 .8 .9],...
    'Tag','FourthAxes',...
    'TickLength',[0 0.1]);
axes('Parent',fp,'Position',[.05 .05 .8 .9],...
    'Tag','DummyAxes',...
    'Visible','off',...
    'TickLength',[0 0.1]);

% Fifth tab
tab5 = uitab('Parent',tabgp,...
    'Title','Histograms',...
    'Units','normalized',...
    'Tag','FifthTab');
fip = uipanel('FontSize',12,...
    'Units','normalized',...
    'Position',[0 0 1 1],...
    'Tag','FifthPanel',...
    'Parent',tab5);
uicontrol('Units','normalized',...
    'Style','checkbox',...
    'Callback',{@boxLegend_Callback},...
    'Parent',fip,...
    'TooltipString','Legend Visibility',...
    'Tag','BoxLegend',...
    'Position',[0 0 .04 .04],...
    'Value',1);
axes('Parent',fip,'Position',[.05 .05 .8 .9],...
    'Tag','FifthAxes',...
    'TickLength',[0 0.1]);
axes('Parent',fip,'Position',[.05 .05 .8 .9],...
    'Tag','DummyAxes',...
    'Visible','off',...
    'TickLength',[0 0.1]);

% Sixth tab
tab6 = uitab('Parent',tabgp,...
    'Title','Amplification',...
    'Units','normalized',...
    'Tag','SixthTab');
sip = uipanel('FontSize',12,...
    'Units','normalized',...
    'Position',[0 0 1 1],...
    'Tag','SixthPanel',...
    'Parent',tab6);
uicontrol('Units','normalized',...
    'Style','checkbox',...
    'Callback',{@boxLegend_Callback},...
    'Parent',sip,...
    'TooltipString','Legend Visibility',...
    'Tag','BoxLegend',...
    'Position',[0 0 .04 .04],...
    'Value',1);
ax1 = axes('Parent',sip,'Position',[.05 .05 .8 .9],...
    'Tag','SixthAxes',...
    'TickLength',[0 0.1]);
axes('Parent',sip,'Position',[.05 .05 .8 .9],...
    'Tag','DummyAxes',...
    'Visible','off',...
    'TickLength',[0 0.1]);
uicontrol('Units','normalized',...
    'Style','edit',...
    'HorizontalAlignment','center',...
    'Parent',sip,...
    'String',0,...
    'Tag','xmin',...
    'Position',[0 .9 .04 .04],...
    'Callback', {@update_yaxis,ax1,1},...
    'Tooltipstring','Xmin');
uicontrol('Units','normalized',...
    'Style','edit',...
    'HorizontalAlignment','center',...
    'Parent',sip,...
    'String',1,...
    'Tag','xmax',...
    'Position',[0 .95 .04 .04],...
    'Callback', {@update_yaxis,ax1,2},...
    'Tooltipstring','Xmax');

% Seventh tab
tab7 = uitab('Parent',tabgp,...
    'Title','Connectivity',...
    'Units','normalized',...
    'Tag','SeventhTab');
sup = uipanel('FontSize',12,...
    'Units','normalized',...
    'Position',[0 0 1 1],...
    'Tag','SeventhPanel',...
    'Parent',tab7);
uicontrol('Units','normalized',...
    'Style','checkbox',...
    'Callback',{@boxLabel_Callback},...
    'Parent',sup,...
    'TooltipString','Label Visibility',...
    'Tag','BoxLabel',...
    'Position',[0 .04 .04 .04],...
    'Value',1);
uicontrol('Units','normalized',...
    'Style','checkbox',...
    'Parent',sup,...
    'TooltipString','Auto/Manual CLimMode',...
    'Tag','BoxCLim',...
    'Position',[0 0 .04 .04],...
    'Value',1);
uicontrol('Units','normalized',...
    'Style','edit',...
    'HorizontalAlignment','center',...
    'Parent',sup,...
    'String',-1,...
    'Tag','cmin',...
    'Position',[0 .9 .04 .04],...
    'Tooltipstring','Cmin');
uicontrol('Units','normalized',...
    'Style','edit',...
    'HorizontalAlignment','center',...
    'Parent',sup,...
    'String',1,...
    'Tag','cmax',...
    'Position',[0 .95 .04 .04],...
    'Tooltipstring','Cmax');

handles2 = guihandles(f2);
resetbutton_Callback([],[],handles2);
set(f2,'Position',[30 30 200 40]);
tabgp.SelectedTab = tab0;

% If nargin > 3 batch processing
% val indicates callback provenance (0 : batch mode - 1 : user mode)
% str_group contains group names
if val==0
    batchsave_Callback([],[],handles2,str_group);
end

end

function resize_Figure(~,~,handles)
% Main Figure resize function

fpos = get(handles.MainFigure,'Position');

handles.InfoPanel.Position = [0 0 fpos(3) fpos(4)/10];
handles.MainPanel.Position = [0 0 1 1];

end

function resize_InfoPanel(hObj,~,handles)

ipos = get(hObj,'Position');
handles.Text1.Position = [0      ipos(4)/10    ipos(3)/4   3*ipos(4)/4];
handles.Popup1.Position = [ipos(3)/4     ipos(4)/2-.75    ipos(3)/4   ipos(4)/2];
handles.Popup2.Position = [ipos(3)/4     -.25             ipos(3)/4   ipos(4)/2];
handles.Edit1.Position = [2*ipos(3)/3     5*ipos(4)/10    4*ipos(3)/100   4*ipos(4)/10];
handles.Edit2.Position = [2*ipos(3)/3     .5*ipos(4)/10             4*ipos(3)/100   4*ipos(4)/10];

handles.BoxInvert.Position = [5.5*ipos(3)/10     ipos(4)/10    ipos(3)/10   3*ipos(4)/10];
handles.BoxBarLink.Position = [5.5*ipos(3)/10     5*ipos(4)/10    ipos(3)/10   3*ipos(4)/10];
handles.Buttongroup.Position = [5*ipos(3)/10     ipos(4)/20    ipos(3)/20   8*ipos(4)/10];
%handles.Radio1.Position = [5*ipos(3)/10     .5*ipos(4)/10    ipos(3)/10   4*ipos(4)/10];
%handles.Radio2.Position = [5*ipos(3)/10     5.5*ipos(4)/10    ipos(3)/10   4*ipos(4)/10];

handles.ButtonReset.Position = [7*ipos(3)/10+2.5     ipos(4)/2-.25     ipos(3)/10-1   ipos(4)/2];
handles.ButtonCompute.Position = [8*ipos(3)/10+1.5     ipos(4)/2-.25      ipos(3)/10-1   ipos(4)/2];
handles.ButtonBatchSave.Position = [9*ipos(3)/10+.5     0      ipos(3)/10-1   ipos(4)/2];
handles.ButtonSaveImage.Position = [7*ipos(3)/10+2.5     0      ipos(3)/10-1   ipos(4)/2];
handles.ButtonSaveStats.Position = [8*ipos(3)/10+1.5     0      ipos(3)/10-1   ipos(4)/2];
handles.ButtonLegend.Position = [9*ipos(3)/10+.5     ipos(4)/2-.25      ipos(3)/10-1   ipos(4)/2];

end

function resize_MainPanel(hObj,~,handles)

%episodes = str2double(handles.Edit1.String);
channels = str2double(handles.Edit2.String);
margin = .03;
box_size = .03;
button_size =.05;

for i = 1:channels
    ax1 = findobj(hObj,'Tag',sprintf('Ax%d',i));
    ax2 = findobj(hObj,'Tag',sprintf('Ax%d',i+channels));
    ax1.Position = [(i-1)/channels+(1.5*margin) .5+margin  (1/channels)-(1.75*margin) .5-2*margin];
    ax2.Position = [(i-1)/channels+(1.5*margin) margin  (1/channels)-(1.75*margin) .5-3*margin];
    button3 = findobj(hObj,'Tag',sprintf('xmin_%d',i));
    button4 = findobj(hObj,'Tag',sprintf('xmax_%d',i));
    button3.Position = [(i-1)/channels 1-button_size button_size/2  button_size];
    button4.Position = [(i-1)/channels 1-2*button_size  button_size/2 button_size];
end

handles.BoxScale.Position = [0 .5 box_size box_size];
handles.BoxLink.Position = [0 .55 box_size box_size];

w_margin = 10;
% Adjust Columns
tt = handles.Trace_table;
tt.Units = 'pixels';
tt.ColumnWidth ={.5*(tt.Position(3)-2*w_margin) .5*(tt.Position(3)-2*w_margin)};
tt.Units = 'normalized';
% Adjust Columns
gt = handles.Group_table;
gt.Units = 'pixels';
gt.ColumnWidth ={gt.Position(3)-w_margin};
gt.Units = 'normalized';

all_table = findobj(handles.MainFigure,'Tag','Tag_table');
for i = 1:length(all_table)
    tt = all_table(i);
    tt.Units = 'pixels';
    tt.ColumnWidth ={.33*(tt.Position(3)-2*w_margin) .33*(tt.Position(3)-2*w_margin) .33*(tt.Position(3)-2*w_margin)};
    tt.Units = 'normalized';
end

end

function initialize_timePanel(handles)

%Time Data
TimeTags_cell = handles.MainFigure.UserData.TimeTags_cell;
TimeTags_images = handles.MainFigure.UserData.TimeTags_images;
TimeTags_strings = handles.MainFigure.UserData.TimeTags_strings;

episodes = str2double(handles.Edit1.String);
all_panels = findobj(handles.TraceTab,'Type','uipanel');
l = length(all_panels)-2;

if l>episodes
    %delete
    for i=episodes+1:l
        delete(findobj(handles.MainFigure,'Tag',sprintf('TimePanel%d',i)));
    end
elseif l<episodes
    %create
    for i=l+1:episodes
        panel = uipanel('FontSize',10,...
            'Units','normalized',...
            'Title',sprintf('Episode_%d',i),...
            'Tag',sprintf('TimePanel%d',i),...
            'Parent',handles.TraceTab);
        
        % UiTable
        table = uitable('Units','normalized',...
            'ColumnName','',...
            'RowName',{},...
            'ColumnFormat',{'char','char','char','char','char','char'},...
            'ColumnEditable',[false,false,false,false,false,false],...
            'ColumnWidth',{70 70 70 70 70 70},...
            'Position',[0 0 1 1],...
            'Data',TimeTags_cell(2:end,2:4),...
            'Tag','Tag_table',...
            'CellSelectionCallback',@template_uitable_select,...
            'RowStriping','on',...
            'Parent',panel);
        table.UserData.Selection = [];
        table.UserData.TimeTags_images = TimeTags_images;
        table.UserData.TimeTags_strings = TimeTags_strings;
    end
end

handles.TracePanel.Position = [0 0 1/(2+episodes) 1];
handles.GroupPanel.Position = [1/(2+episodes) 0 1/(2+episodes) 1];

for i = 1:episodes
    p = findobj(handles.MainFigure,'Tag',sprintf('TimePanel%d',i));
    p.Position = [(i+1)/(2+episodes) 0 1/(2+episodes) 1];
end

end

function initialize_centerPanel(handles)

channels = str2double(handles.Edit2.String);
episodes = str2double(handles.Edit1.String);
delete(handles.MainPanel.Children);

for i=1:channels
    ax1 = subplot(2,channels,i,'Parent',handles.MainPanel,'Tag',sprintf('Ax%d',i));
    title(ax1,sprintf('Bar %d',i));
    ax2 = subplot(2,channels,i+channels,'Parent',handles.MainPanel,'Tag',sprintf('Ax%d',i+channels));
    title(ax2,sprintf('Histogram %d',i));
    uicontrol('Units','normalized',...
        'Style','edit',...
        'HorizontalAlignment','center',...
        'Parent',handles.MainPanel,...
        'String',0,...
        'Tag',sprintf('xmin_%d',i),...
        'Callback', {@update_yaxis,ax1,1},...
        'Tooltipstring',sprintf('Xmin %d',i));
    uicontrol('Units','normalized',...
        'Style','edit',...
        'HorizontalAlignment','center',...
        'Parent',handles.MainPanel,...
        'String',1,...
        'Tag',sprintf('xmax_%d',i),...
        'Callback', {@update_yaxis,ax1,2},...
        'Tooltipstring',sprintf('Xmax %d',i));
end

uicontrol('Units','normalized',...
    'Style','checkbox',...
    'Callback',{@rescalebox_Callback,handles},...
    'Parent',handles.MainPanel,...
    'TooltipString','Vertical Scaling',...
    'Tag','BoxScale',...
    'Value',0);
uicontrol('Units','normalized',...
    'Style','checkbox',...
    'Callback',{@linkbox_Callback,handles},...
    'Parent',handles.MainPanel,...
    'TooltipString','Link/unlink Axes',...
    'Tag','BoxLink',...
    'Value',0);
end

function resetbutton_Callback(~,~,handles)

% Initialize
initialize_timePanel(handles);
initialize_centerPanel(handles);
handles = guihandles(handles.MainFigure);

%Clear axes
if ~isempty(findobj(handles.SecondPanel,'Tag','SecondAxes'))
    delete(handles.SecondAxes.Children);
end
if ~isempty(findobj(handles.ThirdPanel,'Tag','ThirdAxes'))
    delete(handles.ThirdAxes.Children);
end
if ~isempty(findobj(handles.FourthPanel,'Tag','FourthAxes'))
    delete(handles.FourthAxes.Children);
end
if ~isempty(findobj(handles.FifthPanel,'Tag','FifthAxes'))
    delete(handles.FifthAxes.Children);
end
if ~isempty(findobj(handles.SixthPanel,'Tag','SixthAxes'))
    delete(handles.SixthAxes.Children);
end

%Clear dummy axes
d_axes = findobj(handles.MainFigure,'Tag','DummyAxes');
for i =1:length(d_axes)
    delete(d_axes(i).Children);
end
% Delete PatchAxes & legends
delete(findobj(handles.MainFigure,'Tag','PatchAxes'));
delete(findobj(handles.MainFigure,'type','legend'));

% Resize Function Attribution
set(handles.MainFigure,'ResizeFcn',{@resize_Figure,handles});
set(handles.MainPanel,'ResizeFcn',{@resize_MainPanel,handles});
set(handles.InfoPanel,'ResizeFcn',{@resize_InfoPanel,handles});

% Callback function Attribution
set(handles.ButtonReset,'Callback',{@resetbutton_Callback,handles});
set(handles.ButtonCompute,'Callback',{@compute_Callback,handles});
set(handles.ButtonSaveImage,'Callback',{@saveimage_Callback,handles});
set(handles.ButtonSaveStats,'Callback',{@savestats_Callback,handles});
set(handles.ButtonBatchSave,'Callback',{@batchsave_Callback,handles});

set(handles.ButtonLegend,'Callback',{@legend_Callback,handles});
set(handles.Popup1,'Callback',{@update_popup_Callback,handles});
%set(handles.Popup2,'Callback',{@update_popup_Callback,handles});
set(handles.BoxScale,'Callback',{@rescalebox_Callback,handles});
set(handles.BoxLink,'Callback',{@linkbox_Callback,handles});
set(handles.BoxInvert,'Callback',{@boxInvert_Callback});
set(handles.BoxBarLink,'Callback',{@boxBarLink_Callback,handles});

% Figure Resizing
resize_Figure(0,0,handles);
% Fixing non automatic Main Panel resize
resize_MainPanel(handles.MainPanel,[],handles);

end

function compute_Callback(hObj,~,handles)

global LAST_IM;
%Time Data
tt_cell = handles.MainFigure.UserData.TimeTags_cell(2:end,:);
tt_images = handles.MainFigure.UserData.TimeTags_images;
tt_strings = handles.MainFigure.UserData.TimeTags_strings;
time_ref = handles.MainFigure.UserData.time_ref;
n_burst = handles.MainFigure.UserData.n_burst;
length_burst = handles.MainFigure.UserData.length_burst;
% Colormap
cmap = handles.MainFigure.Colormap;

if isempty(handles.Trace_table.UserData)
    warning('Please Select Traces');
    return;
elseif str2double(handles.Edit1.String)>0
    for k=1:length(handles.Tag_table)
        panel = findobj(handles.MainFigure,'Tag',sprintf('TimePanel%d',k));
        table = findobj(panel,'Tag','Tag_table');
        if isempty(table.UserData.Selection)
            warning('Please Select Time Tags (Panel %d)',k);
            return;
        end
    end
end

% Pointer Watch
set(handles.MainFigure, 'pointer', 'watch');
drawnow;
handles.MainFigure.UserData.success = false;

% Getting variables
episodes = str2double(handles.Edit1.String);
channels = str2double(handles.Edit2.String);
lines = hObj.UserData.lines;
ind_channels = handles.Trace_table.UserData.Selection;
n_channels = length(ind_channels);
label_channels = handles.Trace_table.Data(ind_channels,1);
ind_groups =  handles.Group_table.UserData.Selection;
n_groups = length(ind_groups);

% Setting Popup String
if n_channels <= channels
    str = sprintf('Trace 1 - %d',n_channels);
else
    str = sprintf('Trace 1 - %d',channels);
    for k=2:floor((n_channels-1)/channels)
        str = strcat(str,sprintf('|Trace %d - %d',(k-1)*channels+1,k*channels));
    end
    str = strcat(str,sprintf('|Trace %d - %d',floor((n_channels-1)/channels)*channels+1,n_channels));
end
handles.Popup1.String = str;
handles.Popup1.Value = 1;

% Selectin episode names
% Selecting Time indices
Tag_Selection = zeros(size(tt_cell,1),episodes+n_groups);
Tag_Name = struct('tags',[],'group',[],'strings',[],'images',[]);
label_episodes = cell(episodes+n_groups,1);
Time_indices = NaN(LAST_IM,size(Tag_Selection,2));
indices = (1:LAST_IM)';

% Pre-recorded groups 
for i=1:n_groups
    ii = ind_groups(i);
    label_episodes(i) = handles.Group_table.UserData.TimeGroups_name(ii);
    indexes = handles.Group_table.UserData.TimeGroups_S(ii).Selected;
    Tag_Selection(indexes,i)=1;
    Tag_Name(i).group = handles.Group_table.UserData.TimeGroups_name(ii);
    Tag_Name(i).tags = tt_cell(indexes,2);
    Tag_Name(i).images = tt_images(indexes,:);
    Tag_Name(i).strings = tt_strings(indexes,:);
    
    TimeTags_images = handles.Group_table.UserData.TimeGroups_S(ii).TimeTags_images;
    selected = zeros(size(indices));
    for k=1:size(TimeTags_images,1)
        selected = selected+(indices>=TimeTags_images(k,1)).*(indices<=TimeTags_images(k,2));
    end
    Time_indices(selected>0,i)=1;
end
% Manually set groups
for i=1:episodes
    panel = findobj(handles.MainFigure,'Tag',sprintf('TimePanel%d',i));
    table = findobj(panel,'Tag','Tag_table');
    Tag_Selection(table.UserData.Selection,n_groups+i) = 1;
    Tag_Name(n_groups+i).group = {panel.Title};
    Tag_Name(n_groups+i).tags = tt_cell(table.UserData.Selection,2);
    Tag_Name(n_groups+i).images = tt_images(table.UserData.Selection,:);
    Tag_Name(n_groups+i).strings = tt_strings(table.UserData.Selection,:);
    
    label_episodes(n_groups+i)={panel.Title};
    TimeTags_images=table.UserData.TimeTags_images(table.UserData.Selection,:);
    selected = zeros(size(indices));
    for k=1:size(TimeTags_images,1)
        selected = selected+(indices>=TimeTags_images(k,1)).*(indices<=TimeTags_images(k,2));
    end
    Time_indices(selected>0,n_groups+i)=1;
end
% Adding NaN between bursts
temp = [reshape(Time_indices,[length_burst,n_burst*size(Time_indices,2)]);NaN(1,n_burst*size(Time_indices,2))];
Time_indices = reshape(temp,[size(Time_indices,1)+n_burst , size(Time_indices,2)]);

% Extracting Region data
TimeTag_Data = NaN(size(Time_indices,1),size(Time_indices,2),n_channels);
for k=1:n_channels
    l = lines(ind_channels(k));
    data = repmat(l.YData',1,size(Time_indices,2));
    % TimeTag_Data(:,:,k) = data.*Time_indices;
    % modifying this line account for uneven Ydata between Trace_cerep and
    % Trace_Region
    TimeTag_Data(1:size(data,1),:,k) = data.*Time_indices(1:size(data,1),:);
end

% Initialize boxes
all_boxes = findobj(handles.MainPanel,'Style','checkbox','-not','Tag','BoxScale','-not','Tag','BoxLink');
delete(all_boxes);
box_size = .03;
for i=1:episodes+n_groups
    uicontrol('Units','normalized',...
        'Style','checkbox',...
        'Callback',{@histbox_Callback,handles,i},...
        'Parent',handles.MainPanel,...
        'TooltipString',char(label_episodes(i)),...
        'Position',[0 .05*(i-1) box_size box_size],...
        'Tag',sprintf('Box%d',i),...
        'Value',1);
end

handles.Popup1.UserData.Tag_Selection = Tag_Selection;
handles.Popup1.UserData.Tag_Name = Tag_Name;
handles.Popup1.UserData.TimeTag_Data = TimeTag_Data;
handles.Popup1.UserData.label_episodes = label_episodes;
ref = datestr(time_ref.Y/(24*3600),'HH:MM:SS.FFF');
datenum_ref = datenum(ref);
handles.Popup1.UserData.datenum_ref = datenum_ref;
update_popup_Callback(handles.Popup1,[],handles);

% Second Panel
% Mean
panel = handles.SecondPanel;
ax = handles.SecondAxes;
bar_data = permute(mean(TimeTag_Data,1,'omitnan'),[3,2,1]);
ebar_data = permute(std(TimeTag_Data,1,'omitnan'),[3,2,1]);
bar_type = 'mean';
% sem
N = permute(sum(~isnan(TimeTag_Data)),[3 2 1]);
ebar_data = ebar_data./sqrt(N);

%Clearing Axes
delete(findobj(panel,'Type','legend'));
delete(ax.Children);
ax_dummy = findobj(panel,'Tag','DummyAxes');
delete(ax_dummy.Children);

% Getting box status
box = findobj(panel,'Tag','BoxLegend');
if box.Value
    status_l = 'on';
else
    status_l = 'off';
end
box = findobj(panel,'Tag','BoxBar');
if box.Value
    status_e = 'on';
else
    status_e = 'off';
end

%Getting data
if handles.BoxInvert.Value
    bdata = bar_data;
    edata = ebar_data;
    xtick_labs = label_channels;
    leg_labs = label_episodes;
else
    bdata = bar_data';
    edata = ebar_data';
    xtick_labs = label_episodes;
    leg_labs = label_channels;
end

%Drawing bar
b= bar(bdata,'Parent',ax);
% Removing bar edges
for i =1:length(b)
    b(i).EdgeColor='k';
    b(i).LineWidth= .1;
end
n_groups = size(bdata,1);
n_bars = size(bdata,2);

% Error bars
hold(ax,'on');
gpwidth = min(.8,n_bars/(n_bars+1.5));
for i = 1:n_bars
    %bar color
    ind_color = round(i*length(cmap)/n_bars-1)+1;
    b(i).FaceColor = cmap(ind_color,:);
    % Calculate center of each bar
    factor = gpwidth/2 - (2*(i)-1) *(gpwidth/(2*n_bars));
    x = (1:n_groups) - factor;
    e = errorbar(x,bdata(:,i),edata(:,i),'k',...
        'linewidth',1,'linestyle','none',...
        'Parent',ax,'Visible',status_e,'Tag','ErrorBar');
end
leg = legend(ax,leg_labs,'Visible',status_l);

% Axis limits
ax.XLim = [.5 n_groups+.5];
ax.XTick = 1:n_groups;
ax.XTickLabel = xtick_labs;
ax.Title.String = bar_type;
grid(ax,'on');

% Legend Position
panel = leg.Parent;
panel.Units = 'characters';
leg.Units = 'characters';
pos = panel.Position;
leg.Position = [.875*pos(3) .05*pos(4) .1*pos(3) .7*pos(4)];
panel.Units = 'normalized';
leg.Units = 'normalized';

% Plotting masks
if ~isempty(findobj(panel,'Tag','PatchAxes'))
    delete(findobj(panel,'Tag','PatchAxes'));
end
selected_lines  = lines(ind_channels);
ax_e = axes('Parent',panel,'Position',[.8775 .77 .1 .18],...
    'XTick',[],'YTick',[]);
im = handles.MainFigure.UserData.old_handles.MainImage;
copyobj(im,ax_e);
ax_e.YLim = [.5 size(im.CData,1)+.5];
ax_e.XLim = [.5 size(im.CData,2)+.5];
ax_e.YDir = 'reverse';
for i=1:length(selected_lines)
    if strcmp(selected_lines(i).Tag,'Trace_Region') || strcmp(selected_lines(i).Tag,'Trace_Pixel') || strcmp(selected_lines(i).Tag,'Trace_Box')
        p = selected_lines(i).UserData.Graphic;
        p = copyobj(p,ax_e);
        p.Visible ='on';
    end
end
ax_e.Tag = 'PatchAxes';

% Tag reasignement
ax.Tag = 'SecondAxes';
ax_dummy.Tag = 'DummyAxes';

% Third Panel
% Median
panel = handles.ThirdPanel;
ax = handles.ThirdAxes;
bar_data = permute(median(TimeTag_Data,1,'omitnan'),[3,2,1]);
ebar_data = permute(std(TimeTag_Data,1,'omitnan'),[3,2,1]);
bar_type = 'median';
% sem
N = permute(sum(~isnan(TimeTag_Data)),[3 2 1]);
ebar_data = ebar_data./sqrt(N);

%Clearing Axes
delete(findobj(panel,'Type','legend'));
delete(ax.Children);
ax_dummy = findobj(panel,'Tag','DummyAxes');
delete(ax_dummy.Children);

% Getting box status
box = findobj(panel,'Tag','BoxLegend');
if box.Value
    status_l = 'on';
else
    status_l = 'off';
end
box = findobj(panel,'Tag','BoxBar');
if box.Value
    status_e = 'on';
else
    status_e = 'off';
end

%Getting data
if handles.BoxInvert.Value
    bdata = bar_data;
    edata = ebar_data;
    xtick_labs = label_channels;
    leg_labs = label_episodes;
else
    bdata = bar_data';
    edata = ebar_data';
    xtick_labs = label_episodes;
    leg_labs = label_channels;
end

%Drawing bar
b= bar(bdata,'Parent',ax);
% Removing bar edges
for i =1:length(b)
    b(i).EdgeColor='k';
    b(i).LineWidth= .1;
end
n_groups = size(bdata,1);
n_bars = size(bdata,2);

% Error bars
hold(ax,'on');
gpwidth = min(.8,n_bars/(n_bars+1.5));
for i = 1:n_bars
    %bar color
    ind_color = round(i*length(cmap)/n_bars-1)+1;
    b(i).FaceColor = cmap(ind_color,:);
    % Calculate center of each bar
    factor = gpwidth/2 - (2*(i)-1) *(gpwidth/(2*n_bars));
    x = (1:n_groups) - factor;
    e = errorbar(x,bdata(:,i),edata(:,i),'k',...
        'linewidth',1,'linestyle','none',...
        'Parent',ax,'Visible',status_e,'Tag','ErrorBar');
end
leg = legend(ax,leg_labs,'Visible',status_l);

% Axis limits
ax.XLim = [.5 n_groups+.5];
ax.XTick = 1:n_groups;
ax.XTickLabel = xtick_labs;
ax.Title.String = bar_type;
grid(ax,'on');

% Legend Position
panel = leg.Parent;
panel.Units = 'characters';
leg.Units = 'characters';
pos = panel.Position;
leg.Position = [.875*pos(3) .05*pos(4) .1*pos(3) .7*pos(4)];
panel.Units = 'normalized';
leg.Units = 'normalized';


% Plotting masks
if ~isempty(findobj(panel,'Tag','PatchAxes'))
    delete(findobj(panel,'Tag','PatchAxes'));
end
ax_ref = findobj(handles.SecondPanel,'Tag','PatchAxes');
ax_e = copyobj(ax_ref,panel);
ax_e.Position = [.8775 .77 .1 .18];
ax_e.Tag = 'PatchAxes';

% Tag reasignement
ax.Tag = 'ThirdAxes';
ax_dummy.Tag = 'DummyAxes';

% Fourth Panel
% Box Plot
panel = handles.FourthPanel;
ax = handles.FourthAxes;
bar_data = TimeTag_Data;
bar_type = 'boxplot';

%Clearing Axes
delete(findobj(panel,'Type','legend'));
delete(ax.Children);
ax_dummy = findobj(panel,'Tag','DummyAxes');
delete(ax_dummy.Children);

% Getting box status
box = findobj(panel,'Tag','BoxLegend');
if box.Value
    status_l = 'on';
else
    status_l = 'off';
end

%Getting data
if handles.BoxInvert.Value
    tt_data = bar_data;
    dummy_data = ebar_data;
    xtick_labs = label_channels;
    leg_labs = label_episodes;
else
    tt_data = permute(bar_data,[1,3,2]);
    dummy_data = ebar_data';
    xtick_labs = label_episodes;
    leg_labs = label_channels;
end

% Box Plot
n_groups = size(tt_data,3);
n_bars = size(tt_data,2);
hold(ax,'on');
%gpwidth = min(.8,n_groups/(n_groups+1.5));
gpwidth = .85;
for i=1:n_groups
    positions = i-gpwidth/2:gpwidth/(n_bars-1):i+gpwidth/2;
    ind_colors = 1:63/(n_bars-1):64;
    colors = cmap(round(ind_colors),:);
    boxplot(tt_data(:,:,i),...
        'MedianStyle','target',...
        'positions',positions,...
        'colors',colors,...
        'OutlierSize',1,...
        'Widths',gpwidth/(n_bars+1),...
        'Parent',ax);

end
hold(ax,'off');
ax.Position = [.05 .05 .8 .9];

% Dummy axes for legend
b= bar(dummy_data,'Parent',ax_dummy);
for i=1:length(b)
    %bar color
    ind_color = round(i*length(cmap)/n_bars-1)+1;
    b(i).FaceColor = cmap(ind_color,:);
    b(i).EdgeColor = 'k';
    b(i).LineWidth = .1;
end
leg = legend(ax_dummy,leg_labs,'Visible',status_l);
ax_dummy.Position = [2 1 1 1];

% Axis limits
ax.YLim = [min(TimeTag_Data(:)) max(TimeTag_Data(:))];
ax.XLim = [.5 n_groups+.5];
ax.XTick = 1:n_groups;
ax.XTickLabel = xtick_labs;
ax.Title.String = bar_type;
grid(ax,'on');

% Legend Position
panel = leg.Parent;
panel.Units = 'characters';
leg.Units = 'characters';
pos = panel.Position;
leg.Position = [.875*pos(3) .05*pos(4) .1*pos(3) .7*pos(4)];
panel.Units = 'normalized';
leg.Units = 'normalized';

% Plotting masks
if ~isempty(findobj(panel,'Tag','PatchAxes'))
    delete(findobj(panel,'Tag','PatchAxes'));
end
ax_ref = findobj(handles.SecondPanel,'Tag','PatchAxes');
ax_e = copyobj(ax_ref,panel);
ax_e.Position = [.8775 .77 .1 .18];
ax_e.Tag = 'PatchAxes';

% Tag reasignement
ax.Tag = 'FourthAxes';
ax_dummy.Tag = 'DummyAxes';

% Fifth Panel
% Hist Plot
panel = handles.FifthPanel;
ax = handles.FifthAxes;
bar_data = TimeTag_Data;
bar_type = 'histplot';

%Clearing Axes
delete(findobj(panel,'Type','legend'));
delete(ax.Children);
ax_dummy = findobj(panel,'Tag','DummyAxes');
delete(ax_dummy.Children);

% Getting box status
box = findobj(panel,'Tag','BoxLegend');
if box.Value
    status_l = 'on';
else
    status_l = 'off';
end

%Getting data
if handles.BoxInvert.Value
    tt_data = bar_data;
    dummy_data = ebar_data;
    xtick_labs = label_channels;
    leg_labs = label_episodes;
else
    tt_data = permute(bar_data,[1,3,2]);
    dummy_data = ebar_data';
    xtick_labs = label_episodes;
    leg_labs = label_channels;
end

% Hist Plot
n_groups = size(tt_data,3);
n_bars = size(tt_data,2);
hold(ax,'on');
%gpwidth = min(.8,n_groups/(n_groups+1.5));
gpwidth = .85;
val_min = min(tt_data(:),[],'omitnan');
val_max = max(tt_data(:),[],'omitnan');
edges = val_min:(val_max-val_min)/100:val_max;
centers = edges(1:end-1)+.5*(edges(2)-edges(1));

for i=1:n_groups
    positions = i-gpwidth/2:gpwidth/(n_bars-1):i+gpwidth/2;
    ind_colors = 1:63/(n_bars-1):64;
    colors = cmap(round(ind_colors),:);
    delta_p = gpwidth/n_bars;
        
    for j=1:n_bars
        X = tt_data(:,j,i);
        X = X(~isnan(X));
        h_data = histcounts(X,edges);
        h_data = h_data/max(h_data);
        xdata = positions(j)+delta_p*h_data;
%         line('XData',ones(size(centers))*positions(j),'YData',centers,...
%             'Color',colors(j,:),'LineWidth',0.5,...
%             'Tag','HistBotLine','Parent',ax);
%         line('XData',xdata,'YData',centers,...
%             'Color',colors(j,:),'LineWidth',0.5,...
%             'Tag','HistLine','Parent',ax);
        patch(xdata,centers,colors(j,:),'FaceAlpha',1,...
            'EdgeColor','none','LineWidth',1,...
            'Tag','Region','Parent',ax);
%         patch(xdata,centers,colors(j,:),'FaceAlpha',0,...
%             'EdgeColor',colors(j,:),'LineWidth',1,...
%             'Tag','Region','Parent',ax);
    end
end
hold(ax,'off');

ax.Position = [.05 .05 .8 .9];

% Dummy axes for legend
b= bar(dummy_data,'Parent',ax_dummy);
for i=1:length(b)
    %bar color
    ind_color = round(i*length(cmap)/n_bars-1)+1;
    b(i).FaceColor = cmap(ind_color,:);
    b(i).EdgeColor = 'k';
    b(i).LineWidth = .1;
end
leg = legend(ax_dummy,leg_labs,'Visible',status_l);
ax_dummy.Position = [2 1 1 1];

% Axis limits
ax.XLim = [.5 n_groups+.5];
ax.XTick = 1:n_groups;
ax.XTickLabel = xtick_labs;
ax.Title.String = bar_type;
grid(ax,'on');

% Legend Position
panel = leg.Parent;
panel.Units = 'characters';
leg.Units = 'characters';
pos = panel.Position;
leg.Position = [.875*pos(3) .05*pos(4) .1*pos(3) .7*pos(4)];
panel.Units = 'normalized';
leg.Units = 'normalized';

% Plotting masks
if ~isempty(findobj(panel,'Tag','PatchAxes'))
    delete(findobj(panel,'Tag','PatchAxes'));
end
ax_ref = findobj(handles.SecondPanel,'Tag','PatchAxes');
ax_e = copyobj(ax_ref,panel);
ax_e.Position = [.8775 .77 .1 .18];
ax_e.Tag = 'PatchAxes';

% Tag reasignement
ax.Tag = 'FifthAxes';
ax_dummy.Tag = 'DummyAxes';

% Sixth Panel
% Bar Plot
panel = handles.SixthPanel;
ax = handles.SixthAxes;
mean_data = permute(mean(TimeTag_Data,1,'omitnan'),[2,3,1]);
%median_data = permute(median(TimeTag_Data,1,'omitnan'),[2,3,1]);
%ebar_data = permute(std(TimeTag_Data,1,'omitnan'),[2,3,1]);
bar_type = 'amplification';

%Clearing Axes
delete(findobj(panel,'Type','legend'));
delete(ax.Children);
ax_dummy = findobj(panel,'Tag','DummyAxes');
delete(ax_dummy.Children);

% Getting box status
box = findobj(panel,'Tag','BoxLegend');
if box.Value
    status_l = 'on';
else
    status_l = 'off';
end

% Amplification Plot
%n_groups = size(mean_data,1);
n_bars = size(mean_data,2);
label_ampli = {'QW';'NREM';'AW';'REM';'REM-TONIC';'REM-PHASIC'};
all_bars = NaN(size(label_ampli,1),n_bars);
for i =1:size(label_ampli,1)
    ind_ampli = strcmp(label_episodes,char(label_ampli(i)));
    if sum(ind_ampli)>0
        all_bars(i,:) = mean_data(ind_ampli==1,:);
    end
end
%Drawing bar
b = bar(all_bars,'grouped','Parent',ax);
leg = legend(ax,label_channels,'Visible',status_l);
ind_colors = 1:63/(n_bars-1):64;
colors = cmap(round(ind_colors),:);
for i =1:length(b)
    b(i).FaceColor = colors(i,:);
    b(i).EdgeColor = 'k';
    b(i).LineWidth = .5;
end

% Axis limits
ax.XLim = [.5 size(all_bars,1)+.5];
ax.XTick = 1:size(all_bars,1);
ax.XTickLabel = label_ampli;
ax.Title.String = bar_type;
%ax.YLim(1) = 0;
grid(ax,'on');
b1 = findobj(panel,'Tag','xmin');
b1.String = sprintf('%.1f',ax.YLim(1));
b2 = findobj(panel,'Tag','xmax');
b2.String =  sprintf('%.1f',ax.YLim(2));

% Legend Position
panel = leg.Parent;
panel.Units = 'characters';
leg.Units = 'characters';
pos = panel.Position;
leg.Position = [.875*pos(3) .05*pos(4) .1*pos(3) .7*pos(4)];
panel.Units = 'normalized';
leg.Units = 'normalized';

% Plotting masks
if ~isempty(findobj(panel,'Tag','PatchAxes'))
    delete(findobj(panel,'Tag','PatchAxes'));
end
ax_ref = findobj(handles.SecondPanel,'Tag','PatchAxes');
ax_e = copyobj(ax_ref,panel);
ax_e.Position = [.8775 .77 .1 .18];
ax_e.Tag = 'PatchAxes';

% Tag reasignement
ax.Tag = 'SixthAxes';
ax_dummy.Tag = 'DummyAxes';


% Seventh Panel
panel = handles.SeventhPanel;
all_sevenax = findobj(panel,'Type','axes');
for i =1:length(all_sevenax)
    delete(all_sevenax(i));
end

%Clearing Axes
%delete(findobj(panel,'Type','label'));
% Getting boxes
box1 = findobj(panel,'Tag','BoxLabel');
box2 = findobj(panel,'Tag','BoxCLim');

% Connectivity Plot
n_episodes = size(TimeTag_Data,2);
n_channels = size(TimeTag_Data,3);
all_axes = [];
all_cbars = [];
all_rhos = NaN(n_channels,n_channels,n_episodes);
for i=1:n_episodes
    data = permute(TimeTag_Data(:,i,:),[1,3,2]);
    rho = corr(data,'rows','pairwise');
    ax = subplot(2,ceil(n_episodes/2),i,'Parent',panel);
    imagesc(rho,'Parent',ax);
    ax.Tag = sprintf('Ax%d',i);
    
    ax.Title.String = char(label_episodes(i));
    ax.YTick = 1:n_channels;
    ax.YTickLabel = label_channels;
    ax.XTick = [];
    ax.XTickLabel = '';
    cbar = colorbar(ax);
    box1.UserData.label_channels = label_channels;
    all_axes = [all_axes;ax];
    all_cbars = [all_cbars;cbar];
    all_rhos(:,:,i) = rho;
end

b1 = findobj(panel,'Tag','cmin');
b1.Callback = {@update_caxis,all_axes,all_cbars,1};
b2 = findobj(panel,'Tag','cmax');
b2.Callback = {@update_caxis,all_axes,all_cbars,2};
if box2.Value
    %auto
    update_caxis([b1,b2],[],all_axes,all_cbars);
end


% Transmitting data to save button
save_data.label_episodes = label_episodes;
save_data.label_channels = label_channels;
save_data.label_ampli = label_ampli;
save_data.TimeTag_Data = TimeTag_Data;
save_data.all_rhos = all_rhos;
save_data.all_bars = all_bars;
handles.ButtonCompute.UserData.save_data=save_data;

if strcmp(handles.TabGroup.SelectedTab.Title,handles.TraceTab.Title)
    handles.TabGroup.SelectedTab = handles.FourthTab;
end
set(handles.MainFigure, 'pointer', 'arrow');
handles.MainFigure.UserData.success = true;

end

function legend_Callback(~,~,handles)

% Episode Name Selection
episodes = str2double(handles.Edit1.String);
name = 'Select Time Group Names';
prompt={};
defaultans={};
for i=1:episodes
    prompt = [prompt;{sprintf('Tag group %d',i)}];
    panel = findobj(handles.MainFigure,'Tag',sprintf('TimePanel%d',i));
    defaultans = [defaultans;{sprintf('%s',panel.Title)}];
end

% Testing if Selection is not empty
answer = inputdlg(prompt,name,[1 40],defaultans);
handles.Popup1.UserData.label_episodes = answer;
if ~isempty(answer)
    for i=1:episodes
        panel = findobj(handles.MainFigure,'Tag',sprintf('TimePanel%d',i));
        panel.Title = char(answer(i));
    end
end

end

function update_caxis(hObj,~,ax,c,value)

if length(hObj)>1
    clim1 = str2double(hObj(1).String);
    clim2 = str2double(hObj(2).String);
    for i=1:length(ax)
        ax(i).CLim = [clim1,clim2];
        c(i).Limits = [clim1,clim2];
    end
else
    for i=1:length(ax)
        switch value
            case 1,
                ax(i).CLim(1) = str2double(hObj.String);
            case 2,
                ax(i).CLim(2) = str2double(hObj.String);
        end
        c(i).Limits = ax(i).CLim;
    end
end

end

function update_popup_Callback(~,~,handles)

n_burst = handles.MainFigure.UserData.n_burst;
length_burst = handles.MainFigure.UserData.length_burst;
TimeTag_Data = handles.Popup1.UserData.TimeTag_Data;
label_episodes = handles.Popup1.UserData.label_episodes;
datenum_ref = handles.Popup1.UserData.datenum_ref;
lines = handles.Popup1.UserData.lines;

ind_channels = handles.Trace_table.UserData.Selection;
n_channels = length(ind_channels);
episodes = size(TimeTag_Data,2);
val = handles.Popup1.Value;
channels = str2double(handles.Edit2.String);
g_colors = get(groot,'DefaultAxesColorOrder');

% Clear Axes
h_all = findobj(handles.MainPanel,'Type','Axes');
for i=1:length(h_all)
    cla(h_all(i));
    delete(h_all(i).Title);
end
% Update Axes
for i=1:channels
    ind = (val-1)*channels+i;
    if  ind <= n_channels
        
        data = TimeTag_Data(:,:,ind);
        data_per_burst = reshape(data,[length_burst+1,n_burst*size(data,2)]);
        datenum_per_burst = repmat(datenum_ref,1,episodes);
        datenum_per_burst = [reshape(datenum_per_burst,[length_burst,n_burst*episodes]);NaN(1,n_burst*episodes)];
        
        val_max = max(data(:),[],'omitnan');
        val_min = min(data(:),[],'omitnan');
        c_reg = lines(ind_channels(ind)).Color;
        t = char(handles.Trace_table.Data(ind_channels(ind),1));
        t = t(1:min(length(t),10));
        str_t1 = strcat('{\color[rgb]',sprintf('{%.2f %.2f %.2f}',c_reg(1),c_reg(2),c_reg(3)),'[}');
        str_t2 = strcat('{\color[rgb]',sprintf('{%.2f %.2f %.2f}',c_reg(1),c_reg(2),c_reg(3)),']}');
        
        str_popup2 = handles.Popup2.String;
        val_popup2 = handles.Popup2.Value;
        switch strtrim(str_popup2(val_popup2,:))
            case {'Mean','BoxPlot'}
                m = mean(data,1,'omitnan');
                s = std(data,1,'omitnan');
            case 'Median'
                m = median(data,1,'omitnan');
                s = std(data,1,'omitnan');
            case 'Mean Per Burst'
                m_per_burst = mean(data_per_burst,1,'omitnan');
                m_per_burst = reshape(m_per_burst,[n_burst,size(data,2)]);
                m = mean(m_per_burst,1,'omitnan');
                s = std(m_per_burst,1,'omitnan');
            case 'Median Per Burst'
                m_per_burst = median(data_per_burst,1,'omitnan');
                m_per_burst = reshape(m_per_burst,[n_burst,size(data,2)]);
                m = mean(m_per_burst,1,'omitnan');
                s = std(m_per_burst,1,'omitnan');
            case 'Min Per Burst'
                m_per_burst = min(data_per_burst,[],'omitnan');
                m_per_burst = reshape(m_per_burst,[n_burst,size(data,2)]);
                m = mean(m_per_burst,1,'omitnan');
                s = std(m_per_burst,1,'omitnan');
            case 'Max Per Burst'
                m_per_burst = max(data_per_burst,[],'omitnan');
                m_per_burst = reshape(m_per_burst,[n_burst,size(data,2)]);
                m = mean(m_per_burst,1,'omitnan');
                s = std(m_per_burst,1,'omitnan');
            case {'Peak Time Per Burst (Ref:Speed)','Peak Time Per Burst (Ref:Accel)','Peak Time Per Burst (Ref:Theta)'}
                
                % Choosing Reference Data
                l = findobj(lines,'Tag','Trace_Cerep');
                switch strtrim(str_popup2(val_popup2,end-5:end-1))
                    case 'Speed',
                        for j=1:length(l)
                            if strcmpi(l(j).UserData.Name(1:8),'behavior')||strcmpi(l(j).UserData.Name(1:5),'speed')
                                ref_data = l(j).YData;
                            end
                        end
                    case 'Accel',
                        for j=1:length(l)
                            if strcmpi(l(j).UserData.Name(1:8),'accelero')||strcmpi(l(j).UserData.Name(1:5),'accel')
                                ref_data = l(j).YData;
                            end
                        end
                    case 'Theta',
                        for j=1:length(l)
                            if strcmpi(l(j).UserData.Name(1:5),'theta')
                                ref_data = l(j).YData;
                            end
                        end
                    otherwise,
                        errordlg('Unrecognized Reference.');
                        return;
                        
                end
                refdata_per_burst = reshape(ref_data,[length_burst+1,n_burst]);
                [m_ref,i_ref] = max(refdata_per_burst,[],'omitnan');
                t_ref = NaN(size(i_ref));
                for k=1:length(i_ref)
                    if ~isnan(m_ref(k))
                        t_ref(k) = datenum_per_burst(i_ref(k),k);
                        %datestr(t_ref(k),'HH:MM:SS.FFF')
                    end
                end
                t_ref = repmat(t_ref,1,episodes);
                
                % Computing Peak time
                [m_per_burst,i_per_burst] = max(data_per_burst,[],'omitnan');
                t_max = NaN(size(i_per_burst));
                for k=1:length(i_per_burst)
                    if ~isnan(m_per_burst(k))
                        t_max(k) = datenum_per_burst(i_per_burst(k),k);
                        %datestr(t_max(k),'HH:MM:SS.FFF')
                    end
                end
                t_diff = 24*3600*(t_max-t_ref);
                m_per_burst = reshape(t_diff,[n_burst,episodes]);
                m = mean(m_per_burst,1,'omitnan');
                s = std(m_per_burst,1,'omitnan');
                
            otherwise
                errordlg('Unrecognized Display.');
                return;
        end
        
        % Standard error mean
        s_sem = s./sqrt(sum(~isnan(data)));
        
        % Bar Graph
        ax1 = findobj(handles.MainPanel,'Tag',sprintf('Ax%d',i));
        hold(ax1,'on');
        b = bar(1:episodes,diag(m),'stacked','Parent',ax1);
        for k=1:episodes
            %b(k).FaceColor = char(GDisp.colors(k));
            b(k).FaceColor = g_colors(mod(k-1,7)+1,:);
        end
        e = errorbar(diag(m),diag(s_sem),'Color','k',...
            'Parent',ax1,'LineStyle','none',...
            'LineWidth',1.5);
        for k=1:length(e)
            if e(k).YData(k)>0
                e(k).LData(k)=0;
            else
                e(k).UData(k)=0;
            end
        end
        
        hold(ax1,'off');
        ax1.Tag = sprintf('Ax%d',i);
        ax1.XTick = 1:episodes;
        ax1.XTickLabel = label_episodes;
        %ax1.XTickLabelRotation = 90;
        ax1.XLim = [.5 episodes+.5];
        title(ax1,strcat(str_t1,t,str_t2));
        axis(ax1,'auto y');
        button3 = findobj(handles.MainPanel,'Tag',sprintf('xmin_%d',i));
        button3.String = ax1.YLim(1);
        button4 = findobj(handles.MainPanel,'Tag',sprintf('xmax_%d',i));
        button4.String = ax1.YLim(2);
        
        % Histogram
        ax2 = findobj(handles.MainPanel,'Tag',sprintf('Ax%d',i+channels));
        hold(ax2,'on');
        for k=1:episodes
            x = TimeTag_Data(~isnan(TimeTag_Data(:,k,ind)),k,ind);
            h = histogram(x,'BinEdges',floor(val_min):(val_max-val_min)/50:ceil(val_max),...
                'FaceAlpha',.5,'FaceColor',g_colors(mod(k-1,7)+1,:),...
                'Normalization','pdf','Parent',ax2);
            box = findobj(handles.MainPanel,'Tag',sprintf('Box%d',k));
            if ~box.Value
                h.Visible = 'off';
            end
        end
        ax2.XLim = [val_min val_max];
        title(ax2,strcat(str_t1,t,str_t2));
        hold(ax2,'off');
        
        % Adding Gaussian Interpolation
        x = val_min:0.01:val_max;
        for k=1:episodes
            mu = m(k);
            sigma = s(k);
            y = exp(-(x-mu).^2./(2*sigma^2))./(sigma*sqrt(2*pi));
            l = line(x,y,'Parent',ax2,'Color',g_colors(mod(k-1,7)+1,:),'LineWidth',1.5);
            box = findobj(handles.MainPanel,'Tag',sprintf('Box%d',k));
            if ~box.Value
                l.Visible = 'off';
            end
        end
    end
end

end

function boxErrorBar_Callback(hObj,~)

ebar = findobj(hObj.Parent,'Tag','ErrorBar');
if hObj.Value
    for i=1:length(ebar)
        ebar(i).Visible='on';
    end
else
    for i=1:length(ebar)
        ebar(i).Visible='off';
    end
end

end

function boxLegend_Callback(hObj,~)

l = findobj(hObj.Parent,'Type','legend');
if hObj.Value
    for i =1:length(l)
        l(i).Visible = 'on';
    end
else
    for i =1:length(l)
        l(i).Visible = 'off';
    end
end

end

function boxLabel_Callback(hObj,~)

label_channels = hObj.UserData.label_channels;
ax = findobj(hObj.Parent,'Type','axes');
if hObj.Value
    for i =1:length(ax)
        ax(i).YTick = 1:length(label_channels);
        ax(i).YTickLabel = label_channels;
    end
else
    for i =1:length(ax)
        ax(i).YTick = [];
        ax(i).YTickLabel = '';
    end
end

end

function boxInvert_Callback(hObj,~)

if hObj.Value
    hObj.String = 'Channels';
else
    hObj.String = 'Groups';
end

end

function boxBarLink_Callback(hObj,~,handles)

all_axes = [handles.SecondAxes;handles.ThirdAxes;handles.FourthAxes];

if hObj.Value
    hObj.String = 'linked';
    linkaxes(all_axes,'y');
else
    hObj.String = 'unlinked';
    linkaxes(all_axes,'off');
end

end

function update_yaxis(hObj,~,ax,value)
switch value
    case 1,
        ax.YLim(1) = str2double(hObj.String);
    case 2,
        ax.YLim(2) = str2double(hObj.String);
end
end

function histbox_Callback(hObj,~,handles,index)

panel = hObj.Parent;
channels = str2double(handles.Edit2.String);
for i=1:channels
    ax = findobj(panel,'Tag',sprintf('Ax%d',i+channels));
    h = flipud(findobj(ax,'Type','histogram'));
    l = flipud(findobj(ax,'Type','line'));
    if ~isempty(h)
        if hObj.Value
            h(index).Visible = 'on';
            l(index).Visible = 'on';
        else
            h(index).Visible = 'off';
            l(index).Visible = 'off';
        end
    end
end


end

function rescalebox_Callback(hObj,~,handles)

val = hObj.Value;
panel = hObj.Parent;
channels = str2double(handles.Edit2.String);

switch val
    case 0,
        for i=1:channels
            ax = findobj(panel,'Tag',sprintf('Ax%d',i));
            axis(ax,'auto y');
        end;
    case 1,
        m = handles.Ax1.YLim(1);
        M = handles.Ax1.YLim(2);
        for i=2:channels
            ax = findobj(panel,'Tag',sprintf('Ax%d',i));
            if ~isempty(ax.Title.String)
                m = min(m,ax.YLim(1));
                M = max(M,ax.YLim(2));
            end
        end
        for i=1:channels
            ax = findobj(panel,'Tag',sprintf('Ax%d',i));
            ax.YLim = [m M];
            button3 = findobj(panel,'Tag',sprintf('xmin_%d',i));
            button3.String = m;
            button4 = findobj(panel,'Tag',sprintf('xmax_%d',i));
            button4.String = M;
        end
end


end

function linkbox_Callback(hObj,~,handles)

panel = hObj.Parent;
channels = str2double(handles.Edit2.String);
all_axes= [];
for i=1:channels
    ax = findobj(panel,'Tag',sprintf('Ax%d',i));
    all_axes= [all_axes;ax];
end
switch hObj.Value
    case 0,
        linkaxes(all_axes,'off')
    case 1,
        linkaxes(all_axes,'y');
end

end

function saveimage_Callback(~,~,handles)

global FILES CUR_FILE DIR_FIG;
load('Preferences.mat','GTraces');

% Creating Save Directory
save_dir = fullfile(DIR_FIG,'fUS_Statistics',FILES(CUR_FILE).nlab);
if ~isdir(save_dir)
    mkdir(save_dir);
end

% Saving Image
cur_tab = handles.TabGroup.SelectedTab;
%str_p2 = strtrim(handles.Popup2.String(handles.Popup2.Value,:));
grouping = handles.BoxInvert.String;

handles.TabGroup.SelectedTab = handles.SecondTab;
title = handles.TabGroup.SelectedTab.Title;
pic_name = sprintf('%s_fUS_Statistics_%s_%s%s',FILES(CUR_FILE).nlab,grouping,title,GTraces.ImageSaveExtension);
saveas(handles.MainFigure,fullfile(save_dir,pic_name),GTraces.ImageSaveFormat);
fprintf('Image saved at %s.\n',fullfile(save_dir,pic_name));

handles.TabGroup.SelectedTab = handles.ThirdTab;
title = handles.TabGroup.SelectedTab.Title;
pic_name = sprintf('%s_fUS_Statistics_%s_%s%s',FILES(CUR_FILE).nlab,grouping,title,GTraces.ImageSaveExtension);
saveas(handles.MainFigure,fullfile(save_dir,pic_name),GTraces.ImageSaveFormat);
fprintf('Image saved at %s.\n',fullfile(save_dir,pic_name));

handles.TabGroup.SelectedTab = handles.FourthTab;
title = handles.TabGroup.SelectedTab.Title;
pic_name = sprintf('%s_fUS_Statistics_%s_%s%s',FILES(CUR_FILE).nlab,grouping,title,GTraces.ImageSaveExtension);
saveas(handles.MainFigure,fullfile(save_dir,pic_name),GTraces.ImageSaveFormat);
fprintf('Image saved at %s.\n',fullfile(save_dir,pic_name));

handles.TabGroup.SelectedTab = handles.FifthTab;
title = handles.TabGroup.SelectedTab.Title;
pic_name = sprintf('%s_fUS_Statistics_%s_%s%s',FILES(CUR_FILE).nlab,grouping,title,GTraces.ImageSaveExtension);
saveas(handles.MainFigure,fullfile(save_dir,pic_name),GTraces.ImageSaveFormat);
fprintf('Image saved at %s.\n',fullfile(save_dir,pic_name));

handles.TabGroup.SelectedTab = handles.SixthTab;
title = handles.TabGroup.SelectedTab.Title;
pic_name = sprintf('%s_fUS_Statistics_%s_%s%s',FILES(CUR_FILE).nlab,grouping,title,GTraces.ImageSaveExtension);
saveas(handles.MainFigure,fullfile(save_dir,pic_name),GTraces.ImageSaveFormat);
fprintf('Image saved at %s.\n',fullfile(save_dir,pic_name));

handles.TabGroup.SelectedTab = handles.SeventhTab;
title = handles.TabGroup.SelectedTab.Title;
pic_name = sprintf('%s_fUS_Statistics_%s_%s%s',FILES(CUR_FILE).nlab,grouping,title,GTraces.ImageSaveExtension);
saveas(handles.MainFigure,fullfile(save_dir,pic_name),GTraces.ImageSaveFormat);
fprintf('Image saved at %s.\n',fullfile(save_dir,pic_name));

handles.TabGroup.SelectedTab=cur_tab;
end

function savestats_Callback(~,~,handles)

global FILES CUR_FILE DIR_STATS LAST_IM;
load('Preferences.mat','GTraces');

TimeTag_Data = handles.Popup1.UserData.TimeTag_Data;
Tag_Selection = handles.Popup1.UserData.Tag_Selection;
Tag_Name = handles.Popup1.UserData.Tag_Name;
time_ref = handles.MainFigure.UserData.time_ref;

%Loading data
data = handles.ButtonCompute.UserData.save_data;
label_episodes = data.label_episodes;
label_channels = data.label_channels;
label_ampli = data.label_ampli;
all_rhos = data.all_rhos;
all_bars = data.all_bars;

% Creating Stats Directory
data_dir = fullfile(DIR_STATS,'fUS_Statistics',FILES(CUR_FILE).nlab);
if ~isdir(data_dir)
    mkdir(data_dir);
end

% Reformating TimeTag_Data
TimeTag_Data = permute(TimeTag_Data,[1,3,2]);
n_episodes = length(label_episodes);
n_channels = length(label_channels);
for i =1:n_episodes
    group = char(Tag_Name(i).group);
    tags = Tag_Name(i).tags;
    strings = Tag_Name(i).strings;
    images = Tag_Name(i).images;
    tt_data = TimeTag_Data(:,:,i);
    x_data = (1:size(tt_data,1))';
    x_data = x_data(~isnan(tt_data(:,1)));
    y_data = tt_data(x_data,:);
    t_data = time_ref.Y(x_data);
    
    % Saving Stats Groups
    % Saving Stats Per Time Group
    filename = sprintf('%s_fUS_Statistics_%s.mat',FILES(CUR_FILE).nlab,group);
    save(fullfile(data_dir,filename),'group','tags','strings','images',...
        't_data','x_data','y_data','label_channels','-v7.3');
    fprintf('Data saved at %s.\n',fullfile(data_dir,filename));
end

% Building S struct
S = struct('channel',[],'group',[],'t_data',[],'x_data',[],'y_data',[]);
S(n_episodes,n_channels).channel = '';
for i =1:n_episodes
    for j=1:n_channels
        tt_data = TimeTag_Data(:,:,i);
        x_data = (1:size(tt_data,1))';
        x_data = x_data(~isnan(tt_data(:,1)));
        y_data = tt_data(x_data,j);
        t_data = time_ref.Y(x_data);
        
        S(i,j).channel = char(label_channels(j));
        S(i,j).group = char(label_episodes(i));
        S(i,j).t_data = t_data;
        S(i,j).x_data = x_data;
        S(i,j).y_data = y_data(:);
    end
end
% Saving Stats Whole
filename = sprintf('%s_fUS_Statistics_WHOLE.mat',FILES(CUR_FILE).nlab);
recording = FILES(CUR_FILE).nlab;
r_length = LAST_IM;
save(fullfile(data_dir,filename),'S','recording','r_length','Tag_Selection','Tag_Name',...
    'label_episodes','label_channels','label_ampli','all_rhos','all_bars','-v7.3');
fprintf('Data saved at %s.\n',fullfile(data_dir,filename));

end

function batchsave_Callback(~,~,handles,str_group)

if nargin > 3
    % If batch mode, keep only elements in str_group
    ind_group=[];
    for i=1:length(handles.Group_table.Data)
        ind_keep = strcmp(char(handles.Group_table.Data(i)),str_group);
        if sum(ind_keep)>0
            ind_group=[ind_group,i];
        end
    end
    handles.Group_table.UserData.Selection = ind_group;
end

%if isempty(handles.Group_table.UserData)
%    errordlg('Missing group selection');
%    [ind_group,v] = listdlg('Name','Time Group Selection','PromptString','Select Time Groups',...
%        'SelectionMode','single','ListString',TimeGroups_name,'InitialValue',1,'ListSize',[300 500]);
%end

% Compute for handles.Popup2.Value =1:2
% for j=1:size(handles.Popup2.String,1)
%     handles.Popup2.Value =j;
    compute_Callback(handles.ButtonCompute,[],handles);
    savestats_Callback([],[],handles);
    saveimage_Callback([],[],handles);
%end

end