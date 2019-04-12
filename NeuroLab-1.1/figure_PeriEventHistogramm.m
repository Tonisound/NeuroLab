function f2 = figure_PeriEventHistogramm(handles,val,str_group)
% Time Tag Selection Callback

global DIR_SAVE FILES CUR_FILE;

f2 = figure('Units','characters',...
    'HandleVisibility','callback',...
    'IntegerHandle','off',...
    'Renderer','painters',...
    'Toolbar','figure',...
    'NumberTitle','off',...
    'Tag','MainFigure',...
    'PaperPositionMode','auto',...
    'Name','Peri Event Histogramm');
clrmenu(f2);
colormap(f2,'jet');

iP = uipanel('FontSize',12,...
    'Units','normalized',...
    'Tag','InfoPanel',...
    'Parent',f2);

% Texts and Edits
uicontrol('Units','characters','Style','text','HorizontalAlignment','left','Parent',iP,...
    'String',sprintf('File : %s',FILES(CUR_FILE).nlab),'Tag','Text1');
uicontrol('Units','characters','Style','text','HorizontalAlignment','left','Parent',iP,...
    'String',sprintf(handles.CenterPanelPopup.String(handles.CenterPanelPopup.Value,:)),...
    'Tag','Text2');

uicontrol('Units','characters','Style','edit','HorizontalAlignment','center','Parent',iP,...
    'String',6,'Tag','Edit1','Tooltipstring','# fUS Traces');
uicontrol('Units','characters','Style','edit','HorizontalAlignment','center','Parent',iP,...
    'String',2,'Tag','Edit2','Tooltipstring','# Cereplex Traces');
uicontrol('Units','characters','Style','edit','HorizontalAlignment','center','Parent',iP,...
    'String',0,'Tag','Edit3','Tooltipstring','# CFC Channels');
uicontrol('Units','characters','Style','edit','HorizontalAlignment','center','Parent',iP,...
    'String',4,'Tag','Edit4','Tooltipstring','Polar Display');
uicontrol('Units','characters','Style','edit','HorizontalAlignment','center','Parent',iP,...
    'String',.5,'Tag','Edit5','Tooltipstring','Gaussian Smoothing (s)');

uicontrol('Units','characters','Style','edit','HorizontalAlignment','center','Parent',iP,...
    'String',5,'Tag','Edit_Start','Tooltipstring','Time Before Stimulus');
uicontrol('Units','characters','Style','edit','HorizontalAlignment','center','Parent',iP,...
    'String',5,'Tag','Edit_End','Tooltipstring','Time After Stimulus');

% Popup Lists
uicontrol('Units','characters','Style','popupmenu','Parent',iP,...
    'String','<0>','Tag','Popup1','Value',1,'Enable','off');
uicontrol('Units','characters','Style','popupmenu','Parent',iP,...
    'String','<0>','Tag','Popup2','Value',1,'Enable','off');
uicontrol('Units','characters','Style','popupmenu','Parent',iP,...
    'String','<0>','Tag','Popup3','Value',1,'Enable','off');
uicontrol('Units','characters','Style','popupmenu','Parent',iP,...
    'String','Mean + All Trials|Mean +/- SD|Median + All Trials|Median +/- SD',...
    'Tag','PopupTrials','Value',1,'Enable','off');
uicontrol('Units','characters','Style','popupmenu','Parent',iP,...
    'String','<0>','Tag','PopupEpisodeList','Value',1);
uicontrol('Units','characters','Style','popupmenu','Parent',iP,...
    'String','<0>','Tag','PopupStart','Value',1);
uicontrol('Units','characters','Style','popupmenu','Parent',iP,...
    'String','<0>','Tag','PopupEnd','Value',1);

% Checkboxes
uicontrol('Units','characters','Style','checkbox','Parent',iP,...
    'Tag','Checkbox1','Value',1,'Tooltipstring','Align Before Stimulus');
uicontrol('Units','characters','Style','checkbox','Parent',iP,...
    'Tag','Checkbox2','Value',1,'Tooltipstring','Align After Stimulus');
uicontrol('Units','characters','Style','checkbox','Parent',iP,...
    'Tag','Checkbox3','Value',1,'Tooltipstring','Link/Unlink Axes');
uicontrol('Units','characters','Style','checkbox','Parent',iP,...
    'Tag','Checkbox4','Value',1,'Tooltipstring','Remove NaN trials');
uicontrol('Units','characters','Style','checkbox','Parent',iP,...
    'Tag','Checkbox5','Value',1,'Tooltipstring','Gather left/right regions');

% Buttons 
uicontrol('Units','characters','Style','pushbutton','Parent',iP,...
    'String','Reset','Tag','ButtonReset');
bc = uicontrol('Units','characters','Style','pushbutton','Parent',iP,...
    'String','Compute','Tag','ButtonCompute');
uicontrol('Units','characters','Style','pushbutton','Parent',iP,...
    'String','Save Image','Tag','ButtonSaveImage');
uicontrol('Units','characters','Style','pushbutton','Parent',iP,...
    'String','Save Stats','Tag','ButtonSaveStats');
bb = uicontrol('Units','characters','Style','pushbutton','Parent',iP,...
    'String','Batch Save','Tag','ButtonBatch');
bb.UserData.fUSData = [];
bb.UserData.LFPData = [];
bb.UserData.CFCData = [];

bs = uicontrol('Units','characters','Style','pushbutton','Parent',iP,...
    'String','Sort','Tag','Button_Sort','TooltipString','Sorting Episodes','Enable','off');
bs.UserData.Selected = '';
bs.UserData.str_sort = {''};
bs.UserData.permutation = '';

% Creating uitabgroup
mP = uipanel('FontSize',12,...
    'Units','normalized',...
    'Position',[0 .1 1 .9],...
    'Parent',f2);
tabgp = uitabgroup('Units','normalized',...
    'Position',[0 0 1 1],...
    'Parent',mP,...
    'Tag','TabGroup');

% Selection Tab
tab0 = uitab('Parent',tabgp,...
    'Title','Traces & Episodes',...
    'Tag','SelectionTab');
eventPanel = uipanel('Parent',tab0,...
    'Units','normalized',...
    'Position',[0 0 .2 1],...
    'Title','Episodes',...
    'Tag','EventPanel');
tracePanel = uipanel('Parent',tab0,...
    'Units','normalized',...
    'Position',[.2 0 .2 1],...
    'Title','fUS Traces',...
    'Tag','fUSPanel');
lfpPanel = uipanel('Parent',tab0,...
    'Units','normalized',...
    'Position',[.4 0 .2 1],...
    'Title','Cereplex Traces',...
    'Tag','LFPPanel');
cfcPanel = uipanel('Parent',tab0,...
    'Units','normalized',...
    'Position',[.6 0 .2 1],...
    'Title','CFC Channels',...
    'Tag','CFCPanel');
tgPanel = uipanel('Parent',tab0,...
    'Units','normalized',...
    'Position',[.8 0 .2 1],...
    'Title','Time Groups',...
    'Tag','TimeGroupsPanel');
tabgp.SelectedTab = tab0;

% FirstTab
tab1 = uitab('Parent',tabgp,...
    'Title','Event Display',...
    'Tag','FirstTab');
uipanel('FontSize',12,...
    'Units','normalized',...
    'Tag','MainPanel',...
    'Parent',tab1);
uipanel('FontSize',12,...
    'Units','normalized',...
    'Tag','SecondPanel',...
    'Parent',tab1);
uipanel('FontSize',12,...
    'Units','normalized',...
    'Tag','ThirdPanel',...
    'Parent',tab1);

% Second Tab
uitab('Parent',tabgp,...
    'Title','Average Response',...
    'Tag','SecondTab');

% ThirdTab
tab3 = uitab('Parent',tabgp,...
    'Title','Correlation',...
    'Tag','ThirdTab');
subplot(1,2,1,...
    'Parent',tab3,...
    'Tag','AxCorr');
uicontrol('style','popup',...
    'String','Pearson|Spearman',...
    'Units','normalized',...
    'Position',[.15 .93 .2 .05],...
    'Value',2,...
    'Tag','PopupCorr',...
    'Parent',tab3);
subplot(1,2,2,...
    'Tag','AxHR',...
    'Parent',tab3);
uicontrol('style','popup',...
    'String','Mean|Mean+/-SD|Mean+/-SEM|Median|Median+/-SD|Median+/-SEM|Normalized',...
    'Units','normalized',...
    'Position',[.65 .93 .2 .05],...
    'Tag','PopupHR',...
    'Value',3,...
    'Parent',tab3);

% FourthTab
load('Preferences.mat','GDisp');
GDisp.dotstyle(14)={'none'};
GDisp.linestyle(5)={'none'};
tab4 = uitab('Parent',tabgp,...
    'Title','Adaptation',...
    'Tag','FourthTab');
subplot(2,1,1,...
    'Parent',tab4,...
    'Tag','AxfUS');
uicontrol('style','popup',...
    'String','Mean|Median|Mean Norm|Median Norm',...
    'Units','normalized',...
    'Position',[.01 .95 .1 .05],...
    'Value',3,...
    'Tag','PopupfUS',...
    'Parent',tab4);
uicontrol('style','checkbox',...
    'Value',0,...
    'Units','normalized',...
    'Position',[.01 .51 .03 .03],...
    'Tag','Checkbox_style1',...
    'TooltipString','Regression Lines',...
    'Parent',tab4);
uicontrol('style','popup',...
    'Value',1,...
    'String',GDisp.dotstyle(1:14,:),...
    'Units','normalized',...
    'Position',[.005 .55 .1 .03],...
    'TooltipString','Dot Style',...
    'Tag','Popup_dotstyle1',...
    'Parent',tab4);
uicontrol('style','popup',...
    'String',GDisp.linestyle(1:5,:),...
    'Units','normalized',...
    'Position',[.005 .6 .1 .03],...
    'Value',1,...
    'Tag','Popup_linestyle1',...
    'TooltipString','Line Style',...
    'Parent',tab4);
uicontrol('style','edit',...
    'String',1,...
    'Units','normalized',...
    'Position',[.01 .65 .04 .04],...
    'Tag','MarkerSize_1',...
    'TooltipString','Marker Size',...
    'Parent',tab4);
uicontrol('style','edit',...
    'String',1,...
    'Units','normalized',...
    'Position',[.01 .7 .04 .04],...
    'Value',1,...
    'Tag','LineWidth_1',...
    'TooltipString','Line Width',...
    'Parent',tab4);
subplot(2,1,2,...
    'Tag','AxTrace',...
    'Parent',tab4);
uicontrol('style','popup',...
    'String','Mean|Median|Mean Norm|Median Norm',...
    'Units','normalized',...
    'Position',[.01 .45 .25 .05],...
    'Tag','PopupTrace',...
    'Value',3,...
    'Parent',tab4);
uicontrol('style','checkbox',...
    'Value',0,...
    'Units','normalized',...
    'Position',[.01 0 .03 .03],...
    'Tag','Checkbox_style2',...
    'TooltipString','Regression Lines',...
    'Parent',tab4);
uicontrol('style','popup',...
    'Value',2,...
    'String',GDisp.dotstyle(1:14,:),...
    'Units','normalized',...
    'Position',[.005 .05 .1 .03],...
    'TooltipString','Dot Style',...
    'Tag','Popup_dotstyle2',...
    'Parent',tab4);
uicontrol('style','popup',...
    'String',GDisp.linestyle(1:5,:),...
    'Units','normalized',...
    'Position',[.005 .1 .1 .03],...
    'Value',5,...
    'Tag','Popup_linestyle2',...
    'TooltipString','Line Style',...
    'Parent',tab4);
uicontrol('style','edit',...
    'String',1,...
    'Units','normalized',...
    'Position',[.01 .15 .04 .04],...
    'Tag','MarkerSize_2',...
    'TooltipString','Marker Size',...
    'Parent',tab4);
uicontrol('style','edit',...
    'String',1,...
    'Units','normalized',...
    'Position',[.01 .2 .04 .04],...
    'Value',1,...
    'Tag','LineWidth_2',...
    'TooltipString','Line Width',...
    'Parent',tab4);

%Fifth Tab
uitab('Parent',tabgp,...
    'Title','Regression',...
    'Tag','FifthTab');

% Lines Array
ax_lines = axes('Parent',f2,'Visible','off');
m = findobj(handles.RightAxes,'Tag','Trace_Mean');
l = flipud(findobj(handles.RightAxes,'Type','line','-not','Tag','Cursor','-not','Tag','Trace_Cerep','-not','Tag','Trace_Mean'));
t = flipud(findobj(handles.RightAxes,'Tag','Trace_Cerep'));
l = copyobj(l,ax_lines);
t = copyobj(t,ax_lines);
m = copyobj(m,ax_lines);
lines_channels = [m;l];
% l_0 = copyobj(l,ax_lines);
% t_0 = copyobj(t,ax_lines);
% m_0 = copyobj(m,ax_lines);
% lines_channels_0 = [m_0;l_0];
% bc.UserData.lines_channels_0 = lines_channels_0;
% bc.UserData.lines_electrodes_0 = t_0 ;

% Loading Traces
load(fullfile(DIR_SAVE,FILES(CUR_FILE).nlab,'Time_Reference.mat'),'time_ref');
xlim1 = time_ref.Y(1);
xlim2 = time_ref.Y(end);
traces_name=[];
traces = struct('X',[],'Y',[],'f_samp',[]);
for i =1:length(t)
    traces_name = [traces_name;{t(i).UserData.Name}];
    X=t(i).UserData.X;
    Y=t(i).UserData.Y;
    f_samp = 1/(X(2)-X(1));
%    X = X(floor(xlim1*f_samp):ceil(xlim2*f_samp));
%    Y = Y(floor(xlim1*f_samp):ceil(xlim2*f_samp));
    X = X(floor(xlim1*f_samp):min(end,ceil(xlim2*f_samp)));
    Y = Y(floor(xlim1*f_samp):min(end,ceil(xlim2*f_samp)));
    traces(i).X = X;
    traces(i).Y = Y;
    traces(i).f_samp = f_samp;
    traces(i).fullname = t(i).UserData.Name;
end
%Feeding Data
cfcPanel.UserData.traces = traces;
cfcPanel.UserData.traces_name = traces_name;

% Feeding Data
bc.UserData.lines_channels = lines_channels;
bc.UserData.lines_electrodes = t;

% UiTable EventTable
uitable('ColumnName',{'',''},...
    'ColumnFormat',{'char','char'},...
    'ColumnEditable',[false,false],...
    'ColumnWidth',{120 120},...
    'Data','',...
    'Tag','EventTable',...
    'Units','normalized',...
    'Position',[0 0 1 1],...
    'CellSelectionCallback',@uitable_select,...
    'RowStriping','on',...
    'Parent',eventPanel);

% Table Data
D={'Whole','Trace_Mean'};
for i =1:length(l)
    D=[D;{l(i).UserData.Name, l(i).Tag}];
    %D=[D;{l(i).UserData.Name}];
end
% UiTable fUSTable
uitable('ColumnName',{'Name'},...
    'ColumnFormat',{'char'},...
    'ColumnEditable',false,...
    'ColumnWidth',{240},...
    'Data',D,...
    'Tag','fUSTable',...
    'Units','normalized',...
    'Position',[0 0 1 1],...
    'CellSelectionCallback',@uitable_select,...
    'RowStriping','on',...
    'Parent',tracePanel);

% UiTable LFPTable
D = {};
for i =1:length(t)
    D=[D;{t(i).UserData.Name, t(i).Tag}];
    %D=[D;{t(i).UserData.Name}];
end
uitable('ColumnName',{'Name'},...
    'ColumnFormat',{'char'},...
    'ColumnEditable',false,...
    'ColumnWidth',{240},...
    'Data',D,...
    'Tag','LFPTable',...
    'Units','normalized',...
    'Position',[0 0 1 1],...
    'CellSelectionCallback',@uitable_select,...
    'RowStriping','on',...
    'Parent',lfpPanel);

% UiTable CFCTable
uitable('ColumnName',{'Channel','Electrode'},...
    'ColumnFormat',{'char','char'},...
    'ColumnEditable',[false,false],...
    'ColumnWidth',{120 120},...
    'Data','',...
    'Tag','CFCTable',...
    'Units','normalized',...
    'Position',[0 0 1 1],...
    'CellSelectionCallback',@uitable_select,...
    'RowStriping','on',...
    'Parent',cfcPanel);

% UiTable TimeGroupsTable
uitable('ColumnName',{'Name','Duration'},...
    'ColumnFormat',{'char','char'},...
    'ColumnEditable',[false,false],...
    'ColumnWidth',{120 120},...
    'Data','',...
    'Tag','TimeGroupsTable',...
    'Units','normalized',...
    'Position',[0 0 1 1],...
    'CellSelectionCallback',@uitable_select,...
    'RowStriping','on',...
    'Parent',tgPanel);

resetbutton_Callback([],[],guihandles(f2));
initialize_eventPanel(guihandles(f2));
initialize_cfcPanel(guihandles(f2));
initialize_tgPanel(guihandles(f2))
set(f2,'Position',[30 30 200 50]);

% If nargin > 3 batch processing
% val indicates callback provenance (0 : batch mode - 1 : user mode)
% str_group contains group names 
if val==0
    batch_Callback([],[],guihandles(f2),str_group,1);
end

end

function resize_Figure(~,~,handles)
% Main Figure resize function

fpos = get(handles.MainFigure,'Position');
set(handles.InfoPanel,'Position',[0 0 fpos(3) fpos(4)/10]);

end

function resize_InfoPanel(hObj,~,handles)

ipos = get(hObj,'Position');
handles.Text1.Position = [1     2*ipos(4)/3-.25    ipos(3)/5   ipos(4)/3.5];
handles.Text2.Position = [1     ipos(4)/3+.25             ipos(3)/5   ipos(4)/3.5];
handles.PopupEpisodeList.Position =[0     .5             ipos(3)/5   ipos(4)/3.5];

handles.Popup1.Position = [ipos(3)/5     -.5    ipos(3)/8   ipos(4)/2];
handles.Popup2.Position = [ipos(3)/5+ipos(3)/8     -.5    ipos(3)/8   ipos(4)/2];
handles.Popup3.Position = [ipos(3)/5+ipos(3)/4     -.5    ipos(3)/8   ipos(4)/2];
handles.PopupTrials.Position = [ipos(3)/5+3*ipos(3)/8   -.5  ipos(3)/8   ipos(4)/2];

handles.Edit_Start.Position = [ipos(3)/5     ipos(4)/2+0.2      ipos(3)/30   ipos(4)/2.5];
handles.Checkbox1.Position = [ipos(3)/5+ipos(3)/30     ipos(4)/2      ipos(3)/50   ipos(4)/2];
handles.PopupStart.Position = [ipos(3)/5+ipos(3)/30+ipos(3)/50     ipos(4)/2+.5     ipos(3)/8   ipos(4)/3.5];
handles.PopupEnd.Position = [38*ipos(3)/100     ipos(4)/2+.5      ipos(3)/8   ipos(4)/3.5];
handles.Checkbox2.Position = [50.5*ipos(3)/100     ipos(4)/2      ipos(3)/55   ipos(4)/2];
handles.Edit_End.Position = [52.5*ipos(3)/100     ipos(4)/2+0.2      ipos(3)/30   ipos(4)/2.5];

%handles.Edit1.Position = [9*ipos(3)/10+3     ipos(4)/2      ipos(3)/30-1.5   ipos(4)/2-.25];
%handles.Edit2.Position = [9.375*ipos(3)/10+1     ipos(4)/2      ipos(3)/30-1.5   ipos(4)/2-.25];
%handles.Edit3.Position = [9.66*ipos(3)/10+1     ipos(4)/2      ipos(3)/30-1.5   ipos(4)/2-.25];
handles.Edit1.Position = [9.5*ipos(3)/10+1     2*ipos(4)/3      ipos(3)/20-1.5   ipos(4)/3-.25];
handles.Edit2.Position = [9.5*ipos(3)/10+1     ipos(4)/3      ipos(3)/20-1.5   ipos(4)/3-.25];
handles.Edit3.Position = [9.5*ipos(3)/10+1     0      ipos(3)/20-1.5   ipos(4)/3-.25];

handles.Edit4.Position = [58*ipos(3)/100     ipos(4)/2+0.2      ipos(3)/25   ipos(4)/2.5];
handles.Edit5.Position = [62*ipos(3)/100     ipos(4)/2+0.2      ipos(3)/25   ipos(4)/2.5];
handles.Checkbox3.Position = [66.5*ipos(3)/100    ipos(4)/2      ipos(3)/80   ipos(4)/4];
handles.Checkbox4.Position = [68*ipos(3)/100      ipos(4)/2      ipos(3)/80   ipos(4)/4];
handles.Checkbox5.Position = [69.5*ipos(3)/100    ipos(4)/2      ipos(3)/80   ipos(4)/4];

handles.ButtonCompute.Position = [8.5*ipos(3)/12+4     ipos(4)/2      ipos(3)/12-2   ipos(4)/2];
handles.ButtonReset.Position = [9.5*ipos(3)/12+2     ipos(4)/2      ipos(3)/12-2   ipos(4)/2];
handles.Button_Sort.Position = [10.5*ipos(3)/12     ipos(4)/2      ipos(3)/12-2   ipos(4)/2];
handles.ButtonSaveStats.Position = [8.5*ipos(3)/12+4     0      ipos(3)/12-2   ipos(4)/2];
handles.ButtonSaveImage.Position = [9.5*ipos(3)/12+2     0      ipos(3)/12-2   ipos(4)/2];
handles.ButtonBatch.Position = [10.5*ipos(3)/12     0      ipos(3)/12-2   ipos(4)/2];

end

function uitable_select(hObj,evnt)

if ~isempty(evnt.Indices)
    hObj.UserData.Selection = unique(evnt.Indices(:,1));
end

% Exclude NaN from selection
A = strfind((hObj.Data(hObj.UserData.Selection,:)),'NaN');
ind = cellfun('isempty',A);
hObj.UserData.Selection(sum(ind,2)<size(ind,2))=[];

switch hObj.Tag
    case 'EventTable'
        t = findobj(hObj.Parent.Parent,'Tag','TimeGroupsTable');
        t.UserData = [];
    case 'TimeGroupsTable'
        t = findobj(hObj.Parent.Parent,'Tag','EventTable');
        t.UserData = [];
end

end

function initialize_eventPanel(handles)

global SEED DIR_SAVE FILES CUR_FILE;

if ~exist(fullfile(DIR_SAVE,FILES(CUR_FILE).nlab,'Spikoscope_Episodes.mat'),'file')
    import_episodes(fullfile(SEED,FILES(CUR_FILE).parent,FILES(CUR_FILE).spiko),fullfile(DIR_SAVE,FILES(CUR_FILE).nlab));
end
load(fullfile(DIR_SAVE,FILES(CUR_FILE).nlab,'Spikoscope_Episodes.mat'),'episodes');

handles.EventPanel.UserData = episodes;
handles.PopupEpisodeList.String = unique({episodes(:).parent});
handles.PopupEpisodeList.Value = 1;
update_episode_list(handles.PopupEpisodeList,[],handles);

end

function initialize_cfcPanel(handles,traces)

traces = handles.CFCPanel.UserData.traces;
temp = handles.CFCPanel.UserData.traces_name;

%temp = {traces.fullname};
ind_1 = ~(cellfun('isempty',strfind(temp,'Power-gammalow')));
ind_2 = ~(cellfun('isempty',strfind(temp,'Power-gammamid')));
ind_3 = ~(cellfun('isempty',strfind(temp,'Power-gammamidup')));
ind_4 = ~(cellfun('isempty',strfind(temp,'Power-gammahigh')));
ind_5 = ~(cellfun('isempty',strfind(temp,'Power-gammamidup')));
ind_keep = find(ind_1|ind_2|ind_3|ind_4|ind_5==1);

traces = traces(ind_keep);
traces_name = temp(ind_keep);

channel = [];
electrode = [];
for i = 1:length(traces_name)
    temp = regexp(char(traces_name(i)),'/','split');
    channel = [channel ;temp(1)];
    electrode = [electrode ;temp(2)];
end
handles.CFCTable.Data = [channel,electrode];

% temp = {traces.fullname};
% temp = regexprep(temp,'LFP_0_Gamma_mid_power','Gamma_mid_power');
% temp = regexprep(temp,'LFP_0_Gamma_high_power','Gamma_high_power');
% temp = regexprep(temp,'LFP_0_Gamma_low_power','Gamma_low_power');
% temp = regexprep(temp,'LFP_0_Gamma_high_background_po','Gamma_high_background');
% temp = regexprep(temp,'LFP_0_Gamma_mid_background_pow','Gamma_mid_background');
% temp = regexprep(temp,'\d|-|/','');
% handles.CFCTable.Data = cat(1,temp,{traces.fullname})';

end

function initialize_tgPanel(handles)

global DIR_SAVE FILES CUR_FILE;

if exist(fullfile(DIR_SAVE,FILES(CUR_FILE).nlab,'Time_Groups.mat'),'file')
    data_tg = load(fullfile(DIR_SAVE,FILES(CUR_FILE).nlab,'Time_Groups.mat'));
end

handles.TimeGroupsTable.Data= [data_tg.TimeGroups_name,data_tg.TimeGroups_duration];
handles.TimeGroupsPanel.UserData.TimeGroups_name = data_tg.TimeGroups_name;
handles.TimeGroupsPanel.UserData.TimeGroups_duration = data_tg.TimeGroups_duration;
handles.TimeGroupsPanel.UserData.TimeGroups_frames = data_tg.TimeGroups_frames;
handles.TimeGroupsPanel.UserData.TimeGroups_S = data_tg.TimeGroups_S;

end

function initialize_mainTab(handles)

global SEED DIR_SAVE FILES CUR_FILE;

if ~exist(fullfile(DIR_SAVE,FILES(CUR_FILE).nlab,'Time_Reference.mat'),'file')
     errordlg('Missing File [%s]',fullfile(DIR_SAVE,FILES(CUR_FILE).nlab,'Time_Reference.mat'));
     return;
end
load(fullfile(DIR_SAVE,FILES(CUR_FILE).nlab,'Time_Reference.mat'),'time_ref');
handles.ButtonCompute.UserData.time_ref = time_ref;

channels = str2double(handles.Edit1.String);
electrodes = str2double(handles.Edit2.String);
crossfreq = str2double(handles.Edit3.String);
N = channels+electrodes+crossfreq;
%delete(handles.FirstTab.Children);

handles.MainPanel.Position = [0 0 channels/N 1];
delete(handles.MainPanel.Children);
handles.SecondPanel.Position = [channels/N 0 electrodes/N 1];
delete(handles.SecondPanel.Children);
handles.ThirdPanel.Position = [(channels+electrodes)/N 0 crossfreq/N 1];
delete(handles.ThirdPanel.Children);

w_b_all = .025;
for i=1:channels
    ax1 = subplot(2,channels,i,...
        'Parent',handles.MainPanel,...
        'Tag',sprintf('Ax%d',i));
    title(ax1,sprintf('Event Histogram %d',i));
    
    ax2 = subplot(2,channels,i+channels,...
        'Parent',handles.MainPanel,...
        'Tag',sprintf('Ax%d',i+channels));
    title(ax2,sprintf('Average%d',i));
    linkaxes([ax1,ax2],'x');
    
    w_b= w_b_all *N/channels;
    uicontrol('Units','normalized',...
        'Style','edit',...
        'HorizontalAlignment','center',...
        'Parent',handles.MainPanel,...
        'Position',[(i-1)/channels .96  w_b .04],...
        'String',0,...
        'Tag',sprintf('cmin_%d',i),...
        'Callback', {@update_caxis,ax1,ax2,1},...
        'Tooltipstring',sprintf('Colormin %d',i));
    uicontrol('Units','normalized',...
        'Style','edit',...
        'HorizontalAlignment','center',...
        'Parent',handles.MainPanel,...
        'Position',[(i-1)/channels .92  w_b .04],...
        'String',1,...
        'Tag',sprintf('cmax_%d',i),...
        'Callback', {@update_caxis,ax1,ax2,2},...
        'Tooltipstring',sprintf('Colormax %d',i));
    uicontrol('Units','normalized',...
        'Style','edit',...
        'HorizontalAlignment','center',...
        'Parent',handles.MainPanel,...
        'Position',[(i-1)/channels .2  w_b .04],...
        'String',0,...
        'Tag',sprintf('xmin_%d',i),...
        'Callback', {@update_xaxis,ax2,1},...
        'Tooltipstring',sprintf('Xmin %d',i));
    uicontrol('Units','normalized',...
        'Style','edit',...
        'HorizontalAlignment','center',...
        'Position',[(i-1)/channels 0  w_b .04],...
        'Parent',handles.MainPanel,...
        'String',1,...
        'Tag',sprintf('xmax_%d',i),...
        'Callback', {@update_xaxis,ax2,2},...
        'Tooltipstring',sprintf('Xmax %d',i));
end

for i=1:electrodes
    ax1 = subplot(2,electrodes,i,...
        'Parent',handles.SecondPanel,...
        'Tag',sprintf('Ax%d',i));
    title(ax1,sprintf('Event Histogram %d',i));
    
    ax2 = subplot(2,electrodes,i+electrodes,...
        'Parent',handles.SecondPanel,...
        'Tag',sprintf('Ax%d',i+electrodes));
    title(ax2,sprintf('Average%d',i));
    linkaxes([ax1,ax2],'x');
    
    %w_b=.04;
    w_b= w_b_all *N/electrodes;
    uicontrol('Units','normalized',...
        'Style','edit',...
        'HorizontalAlignment','center',...
        'Parent',handles.SecondPanel,...
        'Position',[(i-1)/electrodes .96  w_b .04],...
        'String',0,...
        'Tag',sprintf('cmin_%d',i),...
        'Callback', {@update_caxis,ax1,ax2,1},...
        'Tooltipstring',sprintf('Colormin %d',i));
    uicontrol('Units','normalized',...
        'Style','edit',...
        'HorizontalAlignment','center',...
        'Parent',handles.SecondPanel,...
        'Position',[(i-1)/electrodes .92  w_b .04],...
        'String',1,...
        'Tag',sprintf('cmax_%d',i),...
        'Callback', {@update_caxis,ax1,ax2,2},...
        'Tooltipstring',sprintf('Colormax %d',i));
    uicontrol('Units','normalized',...
        'Style','edit',...
        'HorizontalAlignment','center',...
        'Parent',handles.SecondPanel,...
        'Position',[(i-1)/electrodes .2  w_b .04],...
        'String',0,...
        'Tag',sprintf('xmin_%d',i),...
        'Callback', {@update_xaxis,ax2,1},...
        'Tooltipstring',sprintf('Xmin %d',i));
    uicontrol('Units','normalized',...
        'Style','edit',...
        'HorizontalAlignment','center',...
        'Position',[(i-1)/electrodes 0  w_b .04],...
        'Parent',handles.SecondPanel,...
        'String',1,...
        'Tag',sprintf('xmax_%d',i),...
        'Callback', {@update_xaxis,ax2,2},...
        'Tooltipstring',sprintf('Xmax %d',i));
end

for i=1:crossfreq
    ax1 = subplot(2,crossfreq,i,...
        'Parent',handles.ThirdPanel,...
        'Tag',sprintf('Ax%d',i));
    title(ax1,sprintf('CFC Coupling %d',i));
    
    ax2 = subplot(2,crossfreq,i+crossfreq,...
        'Parent',handles.ThirdPanel,...
        'Tag',sprintf('Ax%d',i+crossfreq));
    title(ax2,sprintf('Average%d',i));
    linkaxes([ax1,ax2],'x');
    
    w_b= w_b_all *N/crossfreq;
    uicontrol('Units','normalized',...
        'Style','edit',...
        'HorizontalAlignment','center',...
        'Parent',handles.ThirdPanel,...
        'Position',[(i-1)/crossfreq .96  w_b .04],...
        'String',0,...
        'Tag',sprintf('cmin_%d',i),...
        'Callback', {@update_caxis,ax1,ax2,1},...
        'Tooltipstring',sprintf('Colormin %d',i));
    uicontrol('Units','normalized',...
        'Style','edit',...
        'HorizontalAlignment','center',...
        'Parent',handles.ThirdPanel,...
        'Position',[(i-1)/crossfreq .92  w_b .04],...
        'String',1,...
        'Tag',sprintf('cmax_%d',i),...
        'Callback', {@update_caxis,ax1,ax2,2},...
        'Tooltipstring',sprintf('Colormax %d',i));
    uicontrol('Units','normalized',...
        'Style','edit',...
        'HorizontalAlignment','center',...
        'Parent',handles.ThirdPanel,...
        'Position',[(i-1)/crossfreq .2  w_b .04],...
        'String',0,...
        'Tag',sprintf('xmin_%d',i),...
        'Callback', {@update_xaxis,ax2,1},...
        'Tooltipstring',sprintf('Xmin %d',i));
    uicontrol('Units','normalized',...
        'Style','edit',...
        'HorizontalAlignment','center',...
        'Position',[(i-1)/crossfreq 0  w_b .04],...
        'Parent',handles.ThirdPanel,...
        'String',1,...
        'Tag',sprintf('xmax_%d',i),...
        'Callback', {@update_xaxis,ax2,2},...
        'Tooltipstring',sprintf('Xmax %d',i));
end

end

function resetbutton_Callback(~,~,handles)

initialize_mainTab(handles);
ax = handles.AxCorr;
handles = guihandles(handles.MainFigure);
handles.AxCorr = ax;

% Resize Function Attribution
set(handles.MainFigure,'ResizeFcn',{@resize_Figure,handles});
set(handles.InfoPanel,'ResizeFcn',{@resize_InfoPanel,handles});

% Linking axes
channels = str2double(handles.Edit1.String);
axes = [];
for i = 1:channels
    ax = findobj(handles.MainPanel,'Tag',sprintf('Ax%d',i));
    axes = [axes;ax];
end
set(handles.Checkbox3,'Callback',{@checkbox3_Callback,axes});
if channels>0
    checkbox3_Callback(handles.Checkbox3,[],axes);
end

% Callback function Attribution
set(handles.ButtonReset,'Callback',{@resetbutton_Callback,handles});
set(handles.ButtonCompute,'Callback',{@compute_Callback,handles});
set(handles.ButtonSaveImage,'Callback',{@saveImage_Callback,handles});
set(handles.ButtonSaveStats,'Callback',{@saveStats_Callback,handles});
set(handles.ButtonBatch,'Callback',{@batch_Callback,handles});
handles.ButtonBatch.UserData.flag=0;
set(handles.Button_Sort,'Callback',{@buttonsort_Callback,handles});

set(handles.Popup1,'Callback',{@update_popup1_Callback,handles});
set(handles.Popup2,'Callback',{@update_popup2_Callback,handles});
set(handles.Popup3,'Callback',{@update_popup3_Callback,handles});
set(handles.PopupTrials,'Callback',{@update_popup_trials_Callback,handles});
set(handles.PopupEpisodeList,'Callback',{@update_episode_list,handles});
set(handles.PopupStart,'Callback',{@update_episode,handles});
set(handles.PopupEnd,'Callback',{@update_episode,handles});

% Resetting Button_Sort
handles.Button_Sort.Enable = 'off';
handles.ButtonSaveImage.Enable = 'off';
handles.ButtonSaveStats.Enable = 'off';
handles.ButtonBatch.Enable = 'off';
handles.PopupTrials.Enable = 'off';    
handles.Button_Sort.UserData.Selected = '';
handles.Button_Sort.UserData.str_sort = {''};
handles.Button_Sort.UserData.permutation = '';

% Figure Resizing
resize_Figure(0,0,handles);

% Resetting axes Position
channels = str2double(handles.Edit1.String);
electrodes = str2double(handles.Edit2.String);
crossfreq = str2double(handles.Edit3.String);
N = channels+electrodes+crossfreq;
margin_all = .008;
margin_vert = .01;
margin_a = margin_all*N/channels;
margin_b = margin_all*N/electrodes;
margin_c = margin_all*N/crossfreq;

for i=1:channels
    ax1 = findobj(handles.MainPanel,'Tag',sprintf('Ax%d',i));
    ax2 = findobj(handles.MainPanel,'Tag',sprintf('Ax%d',i+channels));     
    ax1.Position = [(i-1)/channels+4*margin_a 1/4+2.5*margin_vert  (1/channels)-(5*margin_a) 3/4-8*margin_vert];
    ax2.Position = [(i-1)/channels+4*margin_a 2.5*margin_vert  (1/channels)-(5*margin_a) .25-5*margin_vert];
end

for i=1:electrodes
    ax1 = findobj(handles.SecondPanel,'Tag',sprintf('Ax%d',i));
    ax2 = findobj(handles.SecondPanel,'Tag',sprintf('Ax%d',i+electrodes));     
    ax1.Position = [(i-1)/electrodes+4*margin_b 1/4+2.5*margin_vert  (1/electrodes)-(5*margin_b) 3/4-8*margin_vert];
    ax2.Position = [(i-1)/electrodes+4*margin_b 2.5*margin_vert  (1/electrodes)-(5*margin_b) .25-5*margin_vert];
end

for i=1:crossfreq
    ax1 = findobj(handles.ThirdPanel,'Tag',sprintf('Ax%d',i));
    ax2 = findobj(handles.ThirdPanel,'Tag',sprintf('Ax%d',i+crossfreq));     
    ax1.Position = [(i-1)/crossfreq+4*margin_c 1/4+2.5*margin_vert  (1/crossfreq)-(5*margin_c) 3/4-8*margin_vert];
    ax2.Position = [(i-1)/crossfreq+4*margin_c 2.5*margin_vert  (1/crossfreq)-(5*margin_c) .25-5*margin_vert];
end

end

function checkbox3_Callback(hObj,~,axes)
    switch hObj.Value
        case 0
            linkaxes(axes,'off');
        case 1
            linkaxes(axes,'x');
    end
end

function buttonsort_Callback(hObj,~,handles)

handles.MainFigure.Pointer = 'watch';
drawnow;

Selected = hObj.UserData.Selected;
st1 = hObj.UserData.str_sort_channels;
st2 = hObj.UserData.str_sort_electrodes;
st3 = hObj.UserData.str_sort_crossfreq;
str_sort =[st1;st2;st3];
integ_data_channels = hObj.UserData.integ_data_channels;
integ_data_electrodes = hObj.UserData.integ_data_electrodes;
integ_data_crossfreq = hObj.UserData.integ_data_crossfreq;
integ_data = cat(3,integ_data_channels,integ_data_electrodes,integ_data_crossfreq);

[ind_tag,v] = listdlg('Name','Reference Selection','PromptString','Select Trace',...
    'SelectionMode','multiple','ListString',str_sort,...
    'InitialValue',Selected,'ListSize',[300 500]);
if v==0 || isempty(ind_tag) || isempty(char(str_sort(ind_tag)))
    hObj.UserData.Selected='';
    hObj.UserData.permutation='';
else
    hObj.UserData.Selected = ind_tag(1);
    integ = integ_data(:,:,ind_tag(1));
    [~,I] = sort(integ);
    hObj.UserData.permutation = I;
end

if str2double(handles.Edit1.String)>0
    update_popup1_Callback([],[],handles);
end
if str2double(handles.Edit2.String)>0
    update_popup2_Callback([],[],handles);
end
if str2double(handles.Edit3.String)>0
    update_popup3_Callback([],[],handles);
end
handles.MainFigure.Pointer = 'arrow';

end

function update_caxis(hObj,~,ax1,ax2,value)
switch value
    case 1
        ax1.CLim(1) = str2double(hObj.String);
        ax2.YLim(1) = str2double(hObj.String);
    case 2
        ax1.CLim(2) = str2double(hObj.String);
        ax2.YLim(2) = str2double(hObj.String);
end
all_ticks = findobj(ax2,'Tag','Ticks');
for i =1:length(all_ticks)
    %all_ticks(i).YData = [.85*ax2.YLim(2),.95*ax2.YLim(2)];
    all_ticks(i).YData = [ax2.YLim(1)+.85*(ax2.YLim(2)-ax2.YLim(1)),ax2.YLim(1)+.95*(ax2.YLim(2)-ax2.YLim(1))];
end
end

function update_xaxis(hObj,~,ax,value)
for i=1:length(ax)
    switch value
        case 1
            ax(i).XLim(1) = str2double(hObj.String);
        case 2
            ax(i).XLim(2) = str2double(hObj.String);
    end
end
end

function update_episode_list(hObj,~,handles)

val = hObj.Value;
parent = hObj.String(val,:);
episodes = handles.EventPanel.UserData;
episodes = episodes(ismember({episodes(:).parent},parent));
hObj.UserData = episodes;
handles.EventTable.Data = cell(length(episodes(1).Y),2);

handles.PopupStart.String = {episodes(:).shortname};
handles.PopupStart.Value = 4;
handles.PopupEnd.String = {episodes(:).shortname};
handles.PopupEnd.Value = 5;

update_episode(handles.PopupStart,[],handles);
update_episode(handles.PopupEnd,[],handles);

end

function update_episode(hObj,~,handles)
% Same Callback Function for PopupStart and PopupEnd

val = hObj.Value;
switch hObj.Tag
    case 'PopupStart'
        index =1;
    case 'PopupEnd'
        index =2;
end

episodes = handles.PopupEpisodeList.UserData;
handles.EventTable.ColumnName(index) = {episodes(val).shortname};
temp = cell(length(episodes(val).Y),1);
for i=1:length(episodes(val).Y)
    if ~isnan(episodes(val).Y(i))
        temp(i,:) = {datestr(episodes(val).Y(i)/(24*3600),'HH:MM:SS.FFF')};
    else
        temp(i,:) = {'NaN'};
    end
end
handles.EventTable.Data(:,index) = temp;

end

function compute_Callback(hObj,~,handles)

% Return if empty selection
if isempty(handles.fUSTable.UserData)&&isempty(handles.LFPTable.UserData)&&isempty(handles.CFCTable.UserData)
    errordlg('Please Select Traces.');
    return;
end

% Event Selection
if isempty(handles.EventTable.UserData)  
    if isempty(handles.TimeGroupsTable.UserData)
        errordlg('Please Select Events or Time Groups.');
        return;
    else
        % Select Episodes corresponding to Time Groups
        tg_selection = handles.TimeGroupsTable.UserData.Selection(1);
        TimeGroups_S = handles.TimeGroupsPanel.UserData.TimeGroups_S(tg_selection);
        temp = datenum(TimeGroups_S.TimeTags_strings(:,1));
        t_start = (temp - floor(temp))*24*3600;
        temp = datenum(TimeGroups_S.TimeTags_strings(:,2));
        t_end = (temp - floor(temp))*24*3600;
        
        % Episodes
        t_margin = 1; % Margin at start to include episodes not fully included in Time Groups
        episodes = handles.EventTable.Data;
        temp = datenum(episodes(:,1));
        t_e1 = (temp - floor(temp))*24*3600;
        temp = datenum(episodes(:,2));
        t_e2 = (temp - floor(temp))*24*3600;
        ind_keep = [];
        for i =1:size(episodes,1)
            ind_start = (t_start - t_e1(i))<0+t_margin;
            ind_end = (t_end - t_e2(i))>0;
            if sum(ind_start.*ind_end)>0
                ind_keep = [ind_keep;i];
            end
        end
        handles.EventTable.UserData.Selection = ind_keep;
        hObj.UserData.TimeGroup = handles.TimeGroupsTable.Data(tg_selection,1);
    end
else
     hObj.UserData.TimeGroup = {'CURRENT'};
end

% Resetting if empty selection in fUSTable, LFPTable or CFCTable
flag_reset = false;
if isempty(handles.fUSTable.UserData)
    handles.Edit1.String=0;
    flag_reset = true;
end
if isempty(handles.LFPTable.UserData)
    handles.Edit2.String=0;
    flag_reset = true;
end
if isempty(handles.CFCTable.UserData)
    handles.Edit3.String=0;
    flag_reset = true;
end
if flag_reset
    resetbutton_Callback([],[],handles);
end

% Pointer Watch
set(handles.MainFigure, 'pointer', 'watch');
drawnow;

% Getting Data from uiconntrols
f_int = 100;        % Default interpolation frequency
bins = 0:10:720;    % Bins for CFC

channels = str2double(handles.Edit1.String);
electrodes = str2double(handles.Edit2.String);
crossfreq = str2double(handles.Edit3.String);
time_before = str2double(handles.Edit_Start.String);
time_after = str2double(handles.Edit_End.String);
%time_ref = hObj.UserData.time_ref;

% Extracting Event times
ind_events = handles.EventTable.UserData.Selection;
ind_keep = ones(size(ind_events));        
Time_indices = NaN(length(ind_events),4);
Event_Selection = handles.EventTable.Data(ind_events,:);
for i =1:length(ind_events)
    a = datenum(char(Event_Selection(i,1)));
    b = datenum(char(Event_Selection(i,2)));
    Time_indices(i,:) = [((a-floor(a))*24*3600)-time_before,(a-floor(a))*24*3600,(b-floor(b))*24*3600,((b-floor(b))*24*3600)+time_after];
end

% Channels
if channels>0
    % Compute Aligned Trials
    ind_channels = handles.fUSTable.UserData.Selection;
    fUS_Selection = handles.fUSTable.Data(ind_channels,:);
    lines_channels = hObj.UserData.lines_channels;
    lines_channels = lines_channels(ind_channels);
    [Xdata,Ydata,ind_start,ind_end,ref_time,f_samp] = compute_channels(handles,Time_indices,ind_events,f_int);
    
    % Clean Up if Box4 checked
    if handles.Checkbox4.Value
        for k=1:size(ind_start,3)
            for j=1:size(Ydata,1)
                i_start = ind_start(j);
                i_end = ind_end(j);
                y = Ydata(j,i_start:i_end,k);
                if sum(~isnan(y))<(4*length(y)/5)
                    ind_keep(j) = 0;
                end
            end
        end
        ind_events = ind_events(ind_keep==1);
        Time_indices = Time_indices(ind_keep==1,:);
        Ydata = Ydata(ind_keep==1,:,:);
        Xdata = Xdata(ind_keep==1,:,:);
        ind_start = ind_start(ind_keep==1);
        ind_end = ind_end(ind_keep==1);
    end
    
    % Setting Popup Strings
    handles.Popup1.Enable = 'on';
    handles.Popup1.String = handles.fUSTable.Data(ind_channels(1:channels:length(ind_channels)));
    handles.Popup1.Value = 1;
    
    % Feeding data to Popup
    handles.Popup1.UserData.ind_events = ind_events;
    handles.Popup1.UserData.fUS_Selection = fUS_Selection;
    handles.Popup1.UserData.lines_channels = lines_channels;
    handles.Popup1.UserData.Time_indices = Time_indices;
    handles.Popup1.UserData.Xdata_raw = Xdata;
    handles.Popup1.UserData.Ydata_raw = Ydata;
    handles.Popup1.UserData.ind_start_raw = ind_start;
    handles.Popup1.UserData.ind_end_raw = ind_end;
    handles.Popup1.UserData.ref_time_raw = ref_time;
    handles.Popup1.UserData.f_samp = f_samp;
    % Feeding integ_data to Sort Button
    handles.Button_Sort.UserData.integ_data_channels = mean(Ydata,2,'omitnan');
    handles.Button_Sort.UserData.str_sort_channels = fUS_Selection(:,1);
    
    % Display results
    update_popup1_Callback(handles.Popup1,[],handles);
else
    handles.Button_Sort.UserData.integ_data_channels = [];
    handles.Button_Sort.UserData.str_sort_channels = '';
    handles.Popup1.Enable = 'off';
    handles.Popup1.String = '<0>';
    handles.Popup1.Value = 1;
end

% Electrodes
if electrodes>0
    % Compute Aligned Electrodes
    ind_electrodes = handles.LFPTable.UserData.Selection;
    LFP_Selection = handles.LFPTable.Data(ind_electrodes,:);
    lines_electrodes = hObj.UserData.lines_electrodes;
    lines_electrodes = lines_electrodes(ind_electrodes);
    [Xdata,Ydata,ind_start,ind_end,ref_time,f_samp]= compute_electrodes(handles,Time_indices,ind_events,f_int);
    
    % Setting Popup Strings
    handles.Popup2.Enable = 'on';
    handles.Popup2.String = handles.LFPTable.Data(ind_electrodes(1:electrodes:length(ind_electrodes)));
    handles.Popup2.Value = 1;
    
    % Feeding data to Popup
    handles.Popup2.UserData.ind_events = ind_events;
    handles.Popup2.UserData.LFP_Selection = LFP_Selection;
    handles.Popup2.UserData.lines_electrodes = lines_electrodes;
    handles.Popup2.UserData.Time_indices = Time_indices;
    handles.Popup2.UserData.Xdata_raw = Xdata;
    handles.Popup2.UserData.Ydata_raw = Ydata;
    handles.Popup2.UserData.ind_start_raw = ind_start;
    handles.Popup2.UserData.ind_end_raw = ind_end;
    handles.Popup2.UserData.ref_time_raw = ref_time;
    handles.Popup2.UserData.f_samp = f_samp;
    % Feeding integ_data to Sort Button
    handles.Button_Sort.UserData.integ_data_electrodes = mean(Ydata,2,'omitnan');
    handles.Button_Sort.UserData.str_sort_electrodes = LFP_Selection(:,1);
    
    % Display results
    update_popup2_Callback([],[],handles);
else
    handles.Button_Sort.UserData.integ_data_electrodes = [];
    handles.Button_Sort.UserData.str_sort_electrodes = '';
    handles.Popup2.Enable = 'off';
    handles.Popup2.String = '<0>';
    handles.Popup2.Value = 1;

end

% Cross-freq
if crossfreq>0
    % Compute CFC for all trials
    ind_crossfreq = handles.CFCTable.UserData.Selection;
    CFC_Selection = handles.CFCTable.Data(ind_crossfreq,:);
    [Zdata,Zdata_norm] = compute_crossfreq(handles,Time_indices,bins,ind_events);
   
    % Setting Popup Strings
    temp = strcat(handles.CFCTable.Data(:,1),'/',handles.CFCTable.Data(:,2));
    handles.Popup3.Enable = 'on';
    handles.Popup3.String = temp(ind_crossfreq(1:crossfreq:length(ind_crossfreq)),:);
    handles.Popup3.Value = 1;
    
    % Feeding data to Popup
    handles.Popup3.UserData.ind_events = ind_events;
    handles.Popup3.UserData.ind_lfp = ind_crossfreq;
    handles.Popup3.UserData.CFC_Selection = CFC_Selection;
    handles.Popup3.UserData.Time_indices = Time_indices;
    handles.Popup3.UserData.bins = bins;
    handles.Popup3.UserData.Zdata = Zdata;
    handles.Popup3.UserData.Zdata_norm = Zdata_norm;
    % Feeding integ_data to Sort Button
    handles.Button_Sort.UserData.integ_data_crossfreq = -sum(Zdata_norm.*log(Zdata_norm),2,'omitnan');
    handles.Button_Sort.UserData.str_sort_crossfreq = strcat(CFC_Selection(:,1),'(CFC_Channel)/',CFC_Selection(:,2));
    
    % Display results
    update_popup3_Callback([],[],handles);
else
    handles.Button_Sort.UserData.integ_data_crossfreq = [];
    handles.Button_Sort.UserData.str_sort_crossfreq = '';
    handles.Popup3.Enable = 'off';
    handles.Popup3.String = '<0>';
    handles.Popup3.Value = 1;
end

% Feeding Data to control buttons
handles.PopupTrials.Enable = 'on';    
handles.ButtonSaveImage.Enable = 'on';
handles.ButtonSaveStats.Enable = 'on';
handles.ButtonBatch.Enable = 'on';
handles.Button_Sort.Enable = 'on';
handles.Button_Sort.UserData.Selected = '';
handles.Button_Sort.UserData.permutation = '';

% Display results
set(handles.MainFigure, 'pointer', 'arrow');
handles.TabGroup.SelectedTab = handles.FirstTab;

% Update Correlation Panel
correlation_Callback(handles);

% Update Adaptation Panel
adaptation_Callback(handles);

% Update Polar Plot Panel
%display_regression([],[],handles);

% Store Data
% handles.ButtonBatch.UserData.Zdata = Zdata;
% handles.ButtonBatch.UserData.ref_time= ref_time;
% handles.ButtonBatch.UserData.ind_start= ind_start;
% handles.ButtonBatch.UserData.ind_end= ind_end;
% handles.ButtonBatch.UserData.labels= labels;

end

function display_regression(~,~,handles)

%Cor = handles.AxCorr.Children.CData;
%labels = handles.AxCorr.YTickLabel;
%fUS = handles.fUSTable.Data(handles.fUSTable.UserData.Selection);
pu = findobj(handles.FifthTab,'Tag','PopupfUS_5');
if ~isempty(pu)
    val = pu.Value;
else
    val=1;
end
f = handles.FifthTab;
delete(f.Children);
load('Preferences.mat','GDisp');
GDisp.dotstyle(14)={'none'};
GDisp.linestyle(5)={'none'};
uicontrol('Units','normalized',...
        'Style','pushbutton',...
        'Parent',f,...
        'Position',[.01 .01 .05 .03],...
        'String','Display',...
        'Callback',{@display_regression,handles});
uicontrol('style','popup',...
    'String','Mean|Median',...
    'Units','normalized',...
    'Position',[.1 .01 .2 .03],...
    'Value',val,...
    'Tag','PopupfUS_5',...
    'Parent',f);
uicontrol('style','checkbox',...
    'Value',1,...
    'Units','normalized',...
    'Position',[.97 .01 .03 .03],...
    'Tag','Checkbox_style_5',...
    'TooltipString','Regression Lines',...
    'Parent',f);
uicontrol('style','popup',...
    'Value',1,...
    'String',GDisp.dotstyle(1:14,:),...
    'Units','normalized',...
    'Position',[.4 .01 .2 .03],...
    'TooltipString','Dot Style',...
    'Tag','Popup_dotstyle_5',...
    'Parent',f);
uicontrol('style','popup',...
    'String',GDisp.linestyle(1:5,:),...
    'Units','normalized',...
    'Position',[.6 .01 .2 .03],...
    'Value',5,...
    'Tag','Popup_linestyle_5',...
    'TooltipString','Line Style',...
    'Parent',f);
uicontrol('style','edit',...
    'String',10,...
    'Units','normalized',...
    'Position',[.81 .01 .04 .03],...
    'Tag','MarkerSize_5',...
    'TooltipString','Marker Size',...
    'Parent',f);
uicontrol('style','edit',...
    'String',1,...
    'Units','normalized',...
    'Position',[.86 .01 .04 .03],...
    'Value',1,...
    'Tag','LineWidth_5',...
    'TooltipString','Line Width',...
    'Parent',f);

LFP = handles.LFPTable.Data(handles.LFPTable.UserData.Selection);
nb_subplots = str2double(handles.Edit4.String);
margin = .02;
N = min(length(LFP),nb_subplots);

l_all = [];
for i = 1:N
    popup = uicontrol('Units','normalized',...
        'Style','popup',...
        'Parent',f,...
        'Position',[margin+(i-1)/N .95 1/N-2*margin .03],...
        'String',LFP,...
        'UserData',i,...
        'Value',i);
    ax1 = axes('Parent',f,...
        'Position',[margin+(i-1)/N .55 1/N-2*margin .35]);
    ax2 = axes('Parent',f,...
        'Position',[margin+(i-1)/N .1 1/N-2*margin .35]);
    popup.Callback ={@regression_popupCallback,handles,ax1,ax2};
    l = regression_popupCallback(popup,[],handles,ax1,ax2);
    l_all = [l_all;l];
end
cs = findobj(handles.FifthTab,'Tag','Checkbox_style_5');
cs.Callback = {@cs_Callback,l_all};
cs_Callback(cs,[],l_all);
%thick_lines = findobj(ax,'type','line');
%leg = legend(thick_lines,flip(labels),'Location','eastoutside');
    function cs_Callback(hObj,~,l)
        l = l(:);
        if hObj.Value
            for k=1:length(l)
                l(k).Visible = 'on';
            end
        else
            for k=1:length(l)
                l(k).Visible = 'off';
            end
        end
    end

end

function l = regression_popupCallback(hObj,~,handles,ax1,ax2)

g_colors = get(groot,'defaultAxesColorOrder');
i = hObj.Value;
pu = findobj(handles.FifthTab,'Tag','PopupfUS_5');
cs = findobj(handles.FifthTab,'Tag','Checkbox_style_5');
pd = findobj(handles.FifthTab,'Tag','Popup_dotstyle_5');
pl = findobj(handles.FifthTab,'Tag','Popup_linestyle_5');
ms = findobj(handles.FifthTab,'Tag','MarkerSize_5');
ls = findobj(handles.FifthTab,'Tag','LineWidth_5');
marker = char(pd.String(pd.Value,:));
linestyle = char(pl.String(pl.Value,:));
marker_size = str2double(ms.String);
line_width = str2double(ls.String);

LFP = handles.LFPTable.Data(handles.LFPTable.UserData.Selection);
fUS = handles.fUSTable.Data(handles.fUSTable.UserData.Selection);
labels = handles.AxCorr.YTickLabel;
Cor = handles.AxCorr.Children.CData;
pattern = LFP(i,:);
ind_1 = ismember(labels,pattern);
Ydata1 = handles.Popup1.UserData.Ydata;
Ydata2 = handles.Popup2.UserData.Ydata;
lines = handles.Popup1.UserData.lines_channels;
ref = Ydata2(:,:,i);

cla(ax1);
%b = bar(Cor(ind_1,1:length(fUS)),'Parent',ax1);
switch strtrim(pu.String(pu.Value,:))
    case 'Mean',
        bdata = corr(mean(ref,2,'omitnan'),permute(mean(Ydata1,2,'omitnan'),[1,3,2]));
    case 'Median',
        bdata = corr(median(ref,2,'omitnan'),permute(median(Ydata1,2,'omitnan'),[1,3,2]));
end
b = bar(bdata,'Parent',ax1);
b.FaceColor = g_colors(mod(hObj.UserData-1,length(g_colors))+1,:);
ax1.XLim = [.5 length(fUS)+.5];
ax1.YLim = [-1,1];
ax1.XTickLabel=fUS;
ax1.XTick=1:length(fUS);
ax1.XTickLabelRotation=45;


cla(ax2);
%pu.Callback = {@pu_Callback,hObj,[],handles,ax1,ax2};
switch strtrim(pu.String(pu.Value,:))
    case 'Mean',
        for ii=1:size(Ydata1,3)
            line('XData',mean(ref,2,'omitnan'),...
                'YData',mean(Ydata1(:,:,ii),2,'omitnan'),...
                'Color',lines(ii).Color,...
                'Marker',marker,...
                'LineStyle',linestyle,...
                'MarkerSize',marker_size,...
                'LineWidth',line_width,...
                'Parent',ax2);
        end
    case 'Median',
        for ii=1:size(Ydata1,3)
            line('XData',median(ref,2,'omitnan'),...
                'YData',median(Ydata1(:,:,ii),2,'omitnan'),...
                'Color',lines(ii).Color,...
                'Marker',marker,...
                'LineStyle',linestyle,...
                'MarkerSize',marker_size,...
                'LineWidth',line_width,...
                'Parent',ax2);
        end
end

ax2.XLabel.String='LFP';
ax2.YLabel.String='fUS';
l = lsline(ax2);

end

function adaptation_Callback(handles)

channels = str2double(handles.Edit1.String);
electrodes = str2double(handles.Edit2.String);
crossfreq = str2double(handles.Edit3.String);

Ydata1=[];
lines1=[];
Ydata2=[];
lines2=[];
ind_events=[];
labels1={};
labels2={};

if channels>0
    Ydata1 = handles.Popup1.UserData.Ydata;
    lines1 = handles.Popup1.UserData.lines_channels;
    labels1 = handles.Popup1.UserData.fUS_Selection(:,1);
    ind_events = handles.Popup1.UserData.ind_events;
end
if electrodes>0
    Ydata2 = handles.Popup2.UserData.Ydata;
    lines2 = handles.Popup2.UserData.lines_electrodes;
    labels2 = handles.Popup2.UserData.LFP_Selection(:,1);
    ind_events = handles.Popup2.UserData.ind_events;
end
% if crossfreq>0
%     Zdata_norm = handles.Popup3.UserData.Zdata_norm;
%     temp = -sum(Zdata_norm.*log(Zdata_norm),2,'omitnan');
%     data = [data,permute(temp,[1,3,2])];
%     temp = strcat(handles.Popup3.UserData.CFC_Selection(:,1),'-(cross-freq)/',handles.Popup3.UserData.CFC_Selection(:,2));
%     labels = [labels;regexprep(temp,'_','-')];
% end

% Labels
% labs1 = cell(size(labels1));
% for j=1:length(labels1)
%     temp = char(labels1(j,1));
%     labs1(j) = {strcat(temp(1:min(end,3)),temp(end-1:end))};
% end

label_events = cell(length(ind_events),1);
for k=1:length(ind_events)
    label_events(k) = {sprintf('#%d',ind_events(k))};
end

%Popup Choice
pu1 = handles.PopupfUS;
ax1 = handles.AxfUS;
pu2 = handles.PopupTrace;
ax2 = handles.AxTrace;
pu1.Callback={@popup_response_adapt,ax1,lines1,Ydata1,labels1,label_events};
pu2.Callback={@popup_response_adapt,ax2,lines2,Ydata2,labels2,label_events};
if channels>0
    popup_response_adapt(pu1,[],ax1,lines1,Ydata1,labels1,label_events);
end
if electrodes>0
    popup_response_adapt(pu2,[],ax2,lines2,Ydata2,labels2,label_events);
end

    function popup_response_adapt(hObj,~,ax,lines,Ydata,labels,label_events)
        cla(ax);
        switch ax.Tag
            case 'AxfUS'
                cs = findobj(handles.FourthTab,'Tag','Checkbox_style1');
                pd = findobj(handles.FourthTab,'Tag','Popup_dotstyle1');
                pl = findobj(handles.FourthTab,'Tag','Popup_linestyle1');
                ms = findobj(handles.FourthTab,'Tag','MarkerSize_1');
                ls = findobj(handles.FourthTab,'Tag','LineWidth_1');
                
            case 'AxTrace'
                cs = findobj(handles.FourthTab,'Tag','Checkbox_style2');
                pd = findobj(handles.FourthTab,'Tag','Popup_dotstyle2');
                pl = findobj(handles.FourthTab,'Tag','Popup_linestyle2');
                ms = findobj(handles.FourthTab,'Tag','MarkerSize_2');
                ls = findobj(handles.FourthTab,'Tag','LineWidth_2');
        end
        marker = char(pd.String(pd.Value,:));
        linestyle = char(pl.String(pl.Value,:));
        marker_size = str2double(ms.String);
        line_width = str2double(ls.String);
        
        switch strtrim(hObj.String(hObj.Value,:))
            case 'Mean'
                for i=1:length(lines)
                    line('XData',1:size(Ydata,1),...
                        'YData',mean(Ydata(:,:,i),2,'omitnan'),...
                        'Color',lines(i).Color,...
                        'Marker',marker,...
                        'LineStyle',linestyle,...
                        'MarkerSize',marker_size,...
                        'LineWidth',line_width,...
                        'Parent',ax);
                end
            case 'Median'
                for i=1:length(lines)
                    line('XData',1:size(Ydata,1),...
                        'YData',median(Ydata(:,:,i),2,'omitnan'),...
                        'Color',lines(i).Color,...
                        'Marker',marker,...
                        'LineStyle',linestyle,...
                        'MarkerSize',marker_size,...
                        'LineWidth',line_width,...
                        'Parent',ax);
                end
            case 'Mean Norm'
                for i=1:length(lines)
                    line('XData',1:size(Ydata,1),...
                        'YData',(mean(Ydata(:,:,i),2,'omitnan')-mean(mean(Ydata(:,:,i),2,'omitnan'),1,'omitnan'))/std(mean(Ydata(:,:,i),2,'omitnan'),[],1,'omitnan'),...
                        'Marker',marker,...
                        'LineStyle',linestyle,...
                        'MarkerSize',marker_size,...
                        'LineWidth',line_width,...
                        'Color',lines(i).Color,...
                        'Parent',ax);
                end
            case 'Median Norm'
                for i=1:length(lines)
                    line('XData',1:size(Ydata,1),...
                        'YData',median(Ydata(:,:,i),2,'omitnan')/mean(median(Ydata(:,:,i),2,'omitnan'),1,'omitnan')/std(median(Ydata(:,:,i),2,'omitnan'),[],1,'omitnan'),...
                        'Marker',marker,...
                        'LineStyle',linestyle,...
                        'MarkerSize',marker_size,...
                        'LineWidth',line_width,...
                        'Color',lines(i).Color,...
                        'Parent',ax);
                end
        end
        ax.XLim = [.5,length(label_events)+.5];
        ax.XTick = 1:length(label_events);
        ax.XTickLabel = label_events;
        ax.XTickLabelRotation = 90;
        thick_lines = findobj(ax,'type','line');
        legend(thick_lines,flip(labels),'Location','eastoutside');
        if cs.Value
            lsline(ax);
        end
    end

end

function correlation_Callback(handles)

global DIR_SAVE FILES CUR_FILE;
load('Preferences.mat','GTraces');
load(fullfile(DIR_SAVE,FILES(CUR_FILE).nlab,'Time_Reference.mat'),'time_ref');

channels = str2double(handles.Edit1.String);
electrodes = str2double(handles.Edit2.String);
crossfreq = str2double(handles.Edit3.String);

data=[];
Ydata=[];
lines=[];
ind_start=[];
ind_end = [];
ref_time = [];
labels={};

if channels>0
    Ydata = handles.Popup1.UserData.Ydata;
    lines = handles.Popup1.UserData.lines_channels;
    ref_time = handles.Popup1.UserData.ref_time;
    ind_start = handles.Popup1.UserData.ind_start;
    ind_end = handles.Popup1.UserData.ind_end;
    %Selection = handles.Popup1.UserData.fUS_Selection;
    data = [data,permute((mean(Ydata,2,'omitnan')),[1,3,2])];
    labels = [labels;handles.Popup1.UserData.fUS_Selection(:,1)];
end
if electrodes>0
    ref_time = handles.Popup2.UserData.ref_time;
    lmin =  min(length(ref_time),length(handles.Popup2.UserData.ref_time));
    if ~isempty(Ydata)
        Ydata = cat(3,Ydata(:,1:lmin,:),handles.Popup2.UserData.Ydata(:,1:lmin,:));
        data = permute((mean(Ydata,2,'omitnan')),[1,3,2]);
    else
        Ydata = handles.Popup2.UserData.Ydata(:,1:lmin,:);
        data = [data,permute((mean(Ydata,2,'omitnan')),[1,3,2])];
    end
    ref_time = handles.Popup2.UserData.ref_time(1:lmin);
    lines = [lines;handles.Popup2.UserData.lines_electrodes];
    ind_start = [ind_start;handles.Popup2.UserData.ind_start];
    ind_end = [ind_end;handles.Popup2.UserData.ind_end];
    %Selection = [Selection;handles.Popup2.UserData.LFP_Selection];
    labels = [labels;handles.Popup2.UserData.LFP_Selection(:,1)];
end
if crossfreq>0
    Zdata_norm = handles.Popup3.UserData.Zdata_norm;
    temp = -sum(Zdata_norm.*log(Zdata_norm),2,'omitnan');
    data = [data,permute(temp,[1,3,2])];
    temp = strcat(handles.Popup3.UserData.CFC_Selection(:,1),'-(cross-freq)/',handles.Popup3.UserData.CFC_Selection(:,2));
    labels = [labels;regexprep(temp,'_','-')];
end

% Correlation Maps
% Labels
labs = cell(size(labels));
for j=1:length(labels)
    temp = char(labels(j,1));
    labs(j) = {strcat(temp(1:min(end,3)),temp(end-1:end))};
end

% Pearson
cmap_pearson = corr(data,'type','pearson','rows','pairwise');
cmap_spearman = corr(data,'type','spearman','rows','pairwise');

%Popup Choice 
pu = handles.PopupCorr;
ax1 = handles.AxCorr;
pu.Callback={@popup_response,ax1,cmap_pearson,cmap_spearman,labels,labs};
popup_response(pu,[],ax1,cmap_pearson,cmap_spearman,labels,labs);  

pu2 = handles.PopupHR;
ax2 = handles.AxHR;
pu2.Callback={@popup_response2,ax2,labels,Ydata,ref_time,lines,ind_start,ind_end};
if channels+electrodes>0
    popup_response2(pu2,[],ax2,labels,Ydata,ref_time,lines,ind_start,ind_end);
end


handles.ButtonBatch.UserData.labels = labels;
handles.ButtonBatch.UserData.data= data;

    function popup_response2(hObj,~,ax2,labels,Ydata,ref_time,lines,ind_start,ind_end)
        if isempty(lines)
            return;
        else
            labels=labels(1:length(lines));
        end
        
        cla(ax2);
        switch strtrim(hObj.String(hObj.Value,:))
            case {'Mean','Mean+/-SD'}
                m = mean(Ydata(:,:,:),1,'omitnan');
                s = std(Ydata(:,:,:),1,'omitnan');
            case 'Mean+/-SEM'
                m = mean(Ydata(:,:,:),1,'omitnan');
                s = std(Ydata(:,:,:),1,'omitnan');
                A = sum(~isnan(Ydata),1);
                s = s./sqrt(A);
            case {'Median','Median+/-SD'}
                m = mean(Ydata(:,:,:),1,'omitnan');
                s = std(Ydata(:,:,:),1,'omitnan');
            case 'Median+/-SEM'
                m = mean(Ydata(:,:,:),1,'omitnan');
                s = std(Ydata(:,:,:),1,'omitnan');
                A = sum(~isnan(Ydata),1);
                s = s./sqrt(A);
            case 'Normalized'
                m = mean(Ydata(:,:,:),1,'omitnan');
                s = std(Ydata(:,:,:),1,'omitnan');
                a = mean(m,2,'omitnan');
                b = mean(s,2,'omitnan');
                for kk=1:size(m,3)
                    m(:,:,kk) = (m(:,:,kk)-a(:,:,kk))/b(:,:,kk);
                end
        end
        
        % Removing missing values in average response
        thresh_prop = .25;
        ind_set_nan = mean(isnan(Ydata(:,:,1)),1)>thresh_prop;
        modifier = ones(size(m));
        modifier(:,ind_set_nan,:) = NaN;
        m = m.*modifier;
        s = s.*modifier;
%         % gaussian smoothing
%         t_gauss = GTraces.GaussianSmoothing;
%         delta =  time_ref.Y(2)-time_ref.Y(1);
%         w = gausswin(round(2*t_gauss/delta));
%         w = w/sum(w);
%         for i=1:size(m,3)
%             m(:,:,i) = nanconv(m(:,:,i),w,'same');
%             s(:,:,i) = nanconv(s(:,:,i),w,'same');
%         end
        
        for i=1:length(lines)
            line('XData',ref_time,...
                'YData',m(:,:,i),...
                'Color',lines(i).Color,...
                'LineWidth',2,...
                'Parent',ax2)
        end
        
        if hObj.Value==2 || hObj.Value==3 || hObj.Value==5 || hObj.Value==6
            for i=1:length(lines)
%                 line('XData',ref_time,...
%                     'YData',m(:,:,i)+s(:,:,i),...
%                     'Color',lines(i).Color,...
%                     'LineWidth',.5,...
%                     'Parent',ax2)
%                 line('XData',ref_time,...
%                     'YData',m(:,:,i)-s(:,:,i),...
%                     'Color',lines(i).Color,...
%                     'LineWidth',.5,...
%                     'Parent',ax2)
                %Patch
                p_xdat = [ref_time,fliplr(ref_time)];
                p_ydat = [m(:,:,i)-s(:,:,i),fliplr(m(:,:,i)+s(:,:,i))];
                patch('XData',p_xdat(~isnan(p_ydat)),'YData',p_ydat(~isnan(p_ydat)),...
                    'FaceColor',lines(i).Color,'FaceAlpha',.25,'EdgeColor','none',...
                    'LineWidth',.25,'Parent',ax2);
            end
        end
        %ax2.Title.String = 'Normalized Responses';
        %ax2.XLim = [ref_time(1),ref_time(end)];
        ax2.XLim = [0,ref_time(end)];
        thick_lines = findobj(ax2,'LineWidth',2);
        legend(thick_lines,flip(labels),'Location','eastoutside');
        
        % ticks on graph
        val1=.9;
        val2=1;
        for k=1:size(Ydata,1)
            line('XData',[ref_time(ind_start(k)),ref_time(ind_start(k))],...
                'YData',[val1*ax2.YLim(2) val2*ax2.YLim(2)],...
                'LineWidth',.5,'Tag','Ticks','Color','k','Parent',ax2);
            line('XData',[ref_time(ind_end(k)),ref_time(ind_end(k))],...
                'YData',[val1*ax2.YLim(2) val2*ax2.YLim(2)],...
                'LineWidth',.5,'Tag','Ticks','Color','k','Parent',ax2);
            
        end
        grid(ax2,'on');
        ax2.XAxisLocation = 'origin';
        ax2.YAxisLocation = 'origin';
        
        % Sixth tab
        tab = handles.SecondTab;
        delete(tab.Children);        
        all_axes = [];
        margin_w=.02;
        margin_h=.02;
        n_columns = 4;
        n_rows = ceil(length(lines)/n_columns);
        % Creating axes
        for ii = 1:n_rows
            for jj = 1:n_columns
                index = (ii-1)*n_columns+jj;
                if index>length(lines)
                    continue;
                end
                x = mod(index-1,n_columns)/n_columns;
                y = (n_rows-1-(floor((index-1)/n_columns)))/n_rows;
                ax = axes('Parent',tab);
                ax.Position= [x+margin_w y+margin_h (1/n_columns)-2*margin_w (1/n_rows)-3*margin_h];
                ax.XAxisLocation ='origin';
                ax.Title.String = sprintf('Ax-%02d',index);
                ax.Title.Visible = 'on';
                all_axes = [all_axes;ax];
            end
        end
        
        gather_regions = handles.Checkbox5.Value;
        if gather_regions
            labels_gathered = strrep(labels,'-L','');
            labels_gathered = strrep(labels_gathered,'-R','');
            [C, ~, ic] = unique(labels_gathered,'stable');
            % Reposition axes
            delete(all_axes(length(C)+1:end));
            n_rows = ceil(length(C)/n_columns);
            for ii = 1:n_rows
                for jj = 1:n_columns
                    index = (ii-1)*n_columns+jj;
                    if index>length(C)
                        continue;
                    end
                    x = mod(index-1,n_columns)/n_columns;
                    y = (n_rows-1-(floor((index-1)/n_columns)))/n_rows;
                    ax = all_axes(index);
                    ax.Position= [x+margin_w y+margin_h (1/n_columns)-2*margin_w (1/n_rows)-3*margin_h];
                    
                end
            end
            all_axes = all_axes(ic);
        else
            labels_gathered=labels;
        end
        
        % Plotting
        for index = 1:length(lines)
            ax = all_axes(index);
            if contains(labels(index),'-L')
                marker = 'none';
                linestyle = '--';
            elseif contains(labels(index),'-R')
                marker = 'none';
                linestyle = '-.';
            else
                marker = 'none';
                linestyle = '-';
            end
            % Main line 
            line('XData',ref_time,'YData',m(:,:,index),...
                'Color',lines(index).Color,'LineWidth',1,'Linestyle',linestyle,...
                'Marker',marker','MarkerSize',1,'MarkerFaceColor','none',...
                'MarkerEdgeColor',lines(index).Color,'Parent',ax)
            title(ax,labels_gathered(index))
            grid(ax,'on');
            
            % axes limits
            %ax.XLim = [ref_time(1) ref_time(end)];
            ax.YLim = [min(m(:,:,index)-s(:,:,index),[],'omitnan') max(m(:,:,index)+s(:,:,index),[],'omitnan')];
            xlim = ref_time(~isnan(m(:,:,index)));
            ax.XLim = [min(xlim(1),-.1), xlim(end)];
            ax.YLim = [-5;20];
%             %Lines
%             if hObj.Value==2 || hObj.Value==3 || hObj.Value==5 || hObj.Value==6
%                 line('XData',ref_time,...
%                     'YData',m(:,:,index)+s(:,:,index),...
%                     'Color',lines(index).Color,...
%                     'LineWidth',.25,...
%                     'Parent',ax)
%                 line('XData',ref_time,...
%                     'YData',m(:,:,index)-s(:,:,index),...
%                     'Color',lines(index).Color,...
%                     'LineWidth',.25,...
%                     'Parent',ax)
%             end
            %Patch
            if hObj.Value==2 || hObj.Value==3 || hObj.Value==5 || hObj.Value==6
                p_xdat = [ref_time,fliplr(ref_time)];
                p_ydat = [m(:,:,index)-s(:,:,index),fliplr(m(:,:,index)+s(:,:,index))];
                patch('XData',p_xdat(~isnan(p_ydat)),'YData',p_ydat(~isnan(p_ydat)),...
                    'FaceColor',lines(index).Color,'FaceAlpha',.25,'EdgeColor',lines(index).Color,...
                    'LineWidth',.25,'Parent',ax);
            end
            
            % ticks on graph
            for l=1:size(Ydata,1)
                val1 = .9;
                val2 = 1;
                line('XData',[ref_time(ind_start(l)),ref_time(ind_start(l))],...
                    'YData',[val1*ax.YLim(2) val2*ax.YLim(2)],...
                    'LineWidth',.2,'Tag','Ticks','Color',[.5 .5 .5],'Parent',ax);
                line('XData',[ref_time(ind_end(l)),ref_time(ind_end(l))],...
                    'YData',[val1*ax.YLim(2) val2*ax.YLim(2)],...
                    'LineWidth',.2,'Tag','Ticks','Color',[.5 .5 .5],'Parent',ax);
            end
        end
    end

    function popup_response(hObj,~,ax1,cmap_pearson,cmap_spearman,labels,labs)
        switch hObj.Value
            case 1
                imagesc(cmap_pearson,'Parent',ax1);
            case 2
                imagesc(cmap_spearman,'Parent',ax1);
        end
        colorbar(ax1);
        colormap(jet);
        ax1.XTick = 1:length(labs);
        ax1.XTickLabel = labs;
        ax1.XTickLabelRotation = 90;
        ax1.YTick = 1:length(labs);
        ax1.YTickLabel = labels;
        %ax1.CLim = [-1,1];
        %ax1.Title.String = 'Pearson';
    end

end

function update_popup1_Callback(~,~,handles)

lines_channels = handles.Popup1.UserData.lines_channels;
Xdata_raw = handles.Popup1.UserData.Xdata_raw;
Ydata_raw = handles.Popup1.UserData.Ydata_raw;
Time_indices = handles.Popup1.UserData.Time_indices;
ind_events = handles.Popup1.UserData.ind_events;
fUS_Selection = handles.Popup1.UserData.fUS_Selection;
ind_start_raw = handles.Popup1.UserData.ind_start_raw;
ind_end_raw = handles.Popup1.UserData.ind_end_raw;
ref_time_raw = handles.Popup1.UserData.ref_time_raw;

channels = str2double(handles.Edit1.String);
n_channels = length(handles.fUSTable.UserData.Selection);
[~,ind_longest] = max(Time_indices(:,4)-Time_indices(:,1));
val = handles.Popup1.Value;
align1 = handles.Checkbox1.Value;
align2 = handles.Checkbox2.Value;

% Clear Axes
h_all = findobj(handles.MainPanel,'Type','Axes');
for i=1:length(h_all)
    cla(h_all(i));
    delete(h_all(i).Title);
end

% Event Labels
label_events = cell(length(ind_events),1);
for k=1:length(ind_events)
    label_events(k) = {sprintf('#%d',ind_events(k))};
end

Ydata = NaN(size(Ydata_raw));
ind_start = NaN(size(ind_start_raw));
ind_end = NaN(size(ind_end_raw));

% Realigning Depending on Box Values
if align2==0
    if align1==0
        ref_time = ref_time_raw;
    else
        index_ref_start = ind_start_raw(ind_longest); 
        ref_time = ref_time_raw-ref_time_raw(index_ref_start);
    end
    ind_start = ind_start_raw; 
    ind_end = ind_end_raw;
    Ydata = Ydata_raw;
else
    if align1==0
        index_ref_end = ind_end_raw(ind_longest); 
        ref_time = ref_time_raw-ref_time_raw(index_ref_end);
        delta = index_ref_end-ind_end_raw;
        ind_start = ind_start_raw+delta;
        ind_end = ind_end_raw+delta;
        for k=1:size(Ydata,3)
            for i=1:size(Ydata_raw,1)
                Ydata(i,1+delta(i):end,k) = Ydata_raw(i,1:(end-delta(i)),k);
            end
        end
    else
        index_ref_start = ind_start_raw(ind_longest);
        index_ref_end = ind_end_raw(ind_longest);
        delta = index_ref_end-index_ref_start;
        ref_time = (1-index_ref_start)/delta:1/delta:10;
        ref_time = ref_time(1:length(ref_time_raw));
        if index_ref_start==index_ref_end
            errordlg('Scaling Error : Start_time = End_time');
            return;
        end
        %Xdata
        for i=1:size(Xdata_raw,1)
            a = ind_start_raw(i);
            b = ind_end_raw(i);
            x = resample(Xdata_raw(i,:)-Time_indices(i,1),delta,b-a);
            [~,ind_start(i)] = min((x-ref_time_raw(a)).^2);
            [~,ind_end(i)] = min((x-ref_time_raw(b)).^2);
        end
        %Ydata
        for k=1:size(Ydata_raw,3)
            for i=1:size(Ydata_raw,1)
                a = ind_start_raw(i);
                b = ind_end_raw(i);
                y = resample(Ydata_raw(i,:,k),delta,b-a);
                Ydata(i,:,k)= y(ind_start(i)-index_ref_start+1:ind_start(i)-index_ref_start+length(ref_time));
            end
        end
        delta2 = ind_start-ind_start_raw;
        ind_start = ind_start-delta2;
        ind_end = ind_end-delta2;
    end
end

% Feeding Data to Popup1
handles.Popup1.UserData.ref_time = ref_time;
handles.Popup1.UserData.ind_start = ind_start;
handles.Popup1.UserData.ind_end = ind_end;
handles.Popup1.UserData.Ydata = Ydata;

% Sort Ydata if permutation is specified
if ~isempty(handles.Button_Sort.UserData.permutation)
    I = handles.Button_Sort.UserData.permutation;
    Ydata = Ydata(I,:,:);
    label_events = label_events(I);
end

% Update Axes
for i=1:channels
    ind = (val-1)*channels+i;
    if  ind <= n_channels  
        % Axis Title
        c_reg = lines_channels(ind).Color;
        t = char(fUS_Selection(ind,1));
        t = t(1:min(length(t),20));
        str_t1 = strcat('{\color[rgb]',sprintf('{%.2f %.2f %.2f}',c_reg(1),c_reg(2),c_reg(3)),'[}');
        str_t2 = strcat('{\color[rgb]',sprintf('{%.2f %.2f %.2f}',c_reg(1),c_reg(2),c_reg(3)),']}');
         
        % Image all Events
        ax1 = findobj(handles.MainPanel,'Tag',sprintf('Ax%d',i));
        imagesc('XData',ref_time,...
            'CData',Ydata(:,:,ind),...
            'Parent',ax1,...
            'Tag','EventImage');
        
        % Ticks on Image Data
        for j=1:length(ind_events)
            line('XData',[ref_time(ind_start(j)),ref_time(ind_start(j))],...
                'YData',[j-.5 j+.5],...
                'LineWidth',2,...
                'Color','w',...
                'Parent',ax1);
            line('XData',[ref_time(ind_end(j)),ref_time(ind_end(j))],...
                'YData',[j-.5 j+.5],...
                'LineWidth',2,...
                'Color','w',...
                'Parent',ax1);
        end
        
        %Title and axes limits
        title(ax1,strcat(str_t1,t,str_t2));
        ax1.Tag = sprintf('Ax%d',i);
        set(ax1,'Ydir','reverse');
        ax1.XLim = [ref_time(1), ref_time(end)];
        ax1.YLim = [.5, size(Ydata,1)+.5];
        ax1.YTick = 1:size(Ydata,1);
        ax1.YTickLabel = label_events;
        
        % Integral Curve on Image Data
        integ = mean(Ydata(:,:,ind),2,'omitnan');
        m = min(integ);
        M = max(integ);
        integ = integ*((ax1.XLim(2)-ax1.XLim(1))/(M-m));
        m = min(integ);
        integ = integ-(m-ax1.XLim(1));
        line(integ,1:size(Ydata,1),...
            'Tag',sprintf('Integ_Curve%d',i),...
            'Parent',ax1,...
            'Color',[0 0 0]);
        
        % Update Controls
        caxis(ax1,'auto');
        button1 = findobj(handles.MainPanel,'Tag',sprintf('cmin_%d',i));
        button1.String = sprintf('%.1f',ax1.CLim(1));
        button2 = findobj(handles.MainPanel,'Tag',sprintf('cmax_%d',i));
        button2.String = sprintf('%.1f',ax1.CLim(2));
    end
end

% Update_channels
update_channels(handles,handles.PopupTrials);

S.Ydata = handles.Popup1.UserData.Ydata;
S.ind_start = handles.Popup1.UserData.ind_start;
S.ind_end = handles.Popup1.UserData.ind_end;
S.ref_time = handles.Popup1.UserData.ref_time;
S.label_events = label_events;
S.fUS_Selection = fUS_Selection;
S.align1 = align1;
S.align2 = align2;
handles.ButtonBatch.UserData.fUSData = S;

end

function update_popup2_Callback(~,~,handles)

lines_electrodes = handles.Popup2.UserData.lines_electrodes;
Xdata_raw = handles.Popup2.UserData.Xdata_raw;
Ydata_raw = handles.Popup2.UserData.Ydata_raw;
Time_indices = handles.Popup2.UserData.Time_indices;
ind_events = handles.Popup2.UserData.ind_events;
LFP_Selection = handles.Popup2.UserData.LFP_Selection;
ind_start_raw = handles.Popup2.UserData.ind_start_raw;
ind_end_raw = handles.Popup2.UserData.ind_end_raw;
ref_time_raw = handles.Popup2.UserData.ref_time_raw;

electrodes = str2double(handles.Edit2.String);
n_electrodes = length(handles.LFPTable.UserData.Selection);
[~,ind_longest] = max(Time_indices(:,4)-Time_indices(:,1));
val = handles.Popup2.Value;
align1 = handles.Checkbox1.Value;
align2 = handles.Checkbox2.Value;

% Clear Axes
h_all = findobj(handles.SecondPanel,'Type','Axes');
for i=1:length(h_all)
    cla(h_all(i));
    delete(h_all(i).Title);
end

% Event Labels
label_events = cell(length(ind_events),1);
for k=1:length(ind_events)
    label_events(k) = {sprintf('#%d',ind_events(k))};
end

Ydata = NaN(size(Ydata_raw));
ind_start = NaN(size(ind_start_raw));
ind_end = NaN(size(ind_end_raw));

% Realigning Depending on Box Values
if align2==0
    if align1==0
        ref_time = ref_time_raw;
    else
        index_ref_start = ind_start_raw(ind_longest); 
        ref_time = ref_time_raw-ref_time_raw(index_ref_start);
    end
    ind_start = ind_start_raw; 
    ind_end = ind_end_raw;
    Ydata = Ydata_raw;
else
    if align1==0
        index_ref_end = ind_end_raw(ind_longest); 
        ref_time = ref_time_raw-ref_time_raw(index_ref_end);
        delta = index_ref_end-ind_end_raw;
        ind_start = ind_start_raw+delta;
        ind_end = ind_end_raw+delta;
        for k=1:size(Ydata,3)
            for i=1:size(Ydata_raw,1)
                Ydata(i,1+delta(i):end,k) = Ydata_raw(i,1:(end-delta(i)),k);
            end
        end
    else
        index_ref_start = ind_start_raw(ind_longest);
        index_ref_end = ind_end_raw(ind_longest);
        delta = index_ref_end-index_ref_start;
        ref_time = (1-index_ref_start)/delta:1/delta:10;
        ref_time = ref_time(1:length(ref_time_raw));
        if index_ref_start==index_ref_end
            errordlg('Scaling Error : Start_time = End_time');
            return;
        end
        %Xdata
        for i=1:size(Xdata_raw,1)
            a = ind_start_raw(i);
            b = ind_end_raw(i);
            x = resample(Xdata_raw(i,:)-Time_indices(i,1),delta,b-a);
            [~,ind_start(i)] = min((x-ref_time_raw(a)).^2);
            [~,ind_end(i)] = min((x-ref_time_raw(b)).^2);
        end
        %Ydata
        for k=1:size(Ydata_raw,3)
            for i=1:size(Ydata_raw,1)
                a = ind_start_raw(i);
                b = ind_end_raw(i);
                y = resample(Ydata_raw(i,:,k),delta,b-a);
                Ydata(i,:,k)= y(ind_start(i)-index_ref_start+1:ind_start(i)-index_ref_start+length(ref_time));
            end
        end
        delta2 = ind_start-ind_start_raw;
        ind_start = ind_start-delta2;
        ind_end = ind_end-delta2;
    end
end

% Feeding Data to Popup2
handles.Popup2.UserData.ref_time = ref_time;
handles.Popup2.UserData.ind_start = ind_start;
handles.Popup2.UserData.ind_end = ind_end;
handles.Popup2.UserData.Ydata = Ydata;

% Sort Ydata if permutation is specified
if ~isempty(handles.Button_Sort.UserData.permutation)
    I = handles.Button_Sort.UserData.permutation;
    Ydata = Ydata(I,:,:);
    label_events = label_events(I);
end

% Update Axes
for i=1:electrodes
    ind = (val-1)*electrodes+i;
    if  ind <= n_electrodes  
        % Axis Title
        c_reg = lines_electrodes(ind).Color;
        t = char(LFP_Selection(ind,1));
        t = t(1:min(length(t),20));
        str_t1 = strcat('{\color[rgb]',sprintf('{%.2f %.2f %.2f}',c_reg(1),c_reg(2),c_reg(3)),'[}');
        str_t2 = strcat('{\color[rgb]',sprintf('{%.2f %.2f %.2f}',c_reg(1),c_reg(2),c_reg(3)),']}');
         
        % Image all Events
        ax1 = findobj(handles.SecondPanel,'Tag',sprintf('Ax%d',i));
        imagesc('XData',ref_time,...
            'CData',Ydata(:,:,ind),...
            'Parent',ax1,...
            'Tag','EventImage');
        
        % Ticks on Image Data
        for j=1:length(ind_events)
            line('XData',[ref_time(ind_start(j)),ref_time(ind_start(j))],...
                'YData',[j-.5 j+.5],...
                'LineWidth',2,...
                'Color','w',...
                'Parent',ax1);
            line('XData',[ref_time(ind_end(j)),ref_time(ind_end(j))],...
                'YData',[j-.5 j+.5],...
                'LineWidth',2,...
                'Color','w',...
                'Parent',ax1);
        end
        
        %Title and axes limits
        title(ax1,strcat(str_t1,t,str_t2));
        ax1.Tag = sprintf('Ax%d',i);
        set(ax1,'Ydir','reverse');
        ax1.XLim = [ref_time(1), ref_time(end)];
        ax1.YLim = [.5, size(Ydata,1)+.5];
        ax1.YTick = 1:size(Ydata,1);
        ax1.YTickLabel = label_events;
        
        % Integral Curve on Image Data
        integ = mean(Ydata(:,:,ind),2,'omitnan');
        m = min(integ);
        M = max(integ);
        integ = integ*((ax1.XLim(2)-ax1.XLim(1))/(M-m));
        m = min(integ);
        integ = integ-(m-ax1.XLim(1));
        line(integ,1:size(Ydata,1),...
            'Tag',sprintf('Integ_Curve%d',i),...
            'Parent',ax1,...
            'Color',[0 0 0]);
        
        % Update Controls
        caxis(ax1,'auto');
        button1 = findobj(handles.SecondPanel,'Tag',sprintf('cmin_%d',i));
        button1.String = sprintf('%.1f',ax1.CLim(1));
        button2 = findobj(handles.SecondPanel,'Tag',sprintf('cmax_%d',i));
        button2.String = sprintf('%.1f',ax1.CLim(2));
    end
end

% Update_electrodes
update_electrodes(handles,handles.PopupTrials);

S.Ydata = handles.Popup2.UserData.Ydata;
S.ind_start = handles.Popup2.UserData.ind_start;
S.ind_end = handles.Popup2.UserData.ind_end;
S.ref_time = handles.Popup2.UserData.ref_time;
S.label_events = label_events;
S.LFP_Selection = LFP_Selection;
S.align1 = align1;
S.align2 = align2;
handles.ButtonBatch.UserData.LFPData = S;

end

function update_popup3_Callback(~,~,handles)

%ind_lfp = handles.Popup3.UserData.ind_lfp;
CFC_Selection = handles.Popup3.UserData.CFC_Selection;
bins = handles.Popup3.UserData.bins;
Zdata = handles.Popup3.UserData.Zdata;
Zdata_norm = handles.Popup3.UserData.Zdata_norm;
ind_events = handles.Popup3.UserData.ind_events;

crossfreq = str2double(handles.Edit3.String);
n_crossfreq = length(handles.CFCTable.UserData.Selection);
val = handles.Popup3.Value;

% Clear Axes
h_all = findobj(handles.ThirdPanel,'Type','Axes');
for i=1:length(h_all)
    cla(h_all(i));
    delete(h_all(i).Title);
end

% Event Labels
label_events = cell(length(ind_events),1);
for k=1:length(ind_events)
    label_events(k) = {sprintf('#%d',ind_events(k))};
end

% Sort Zdata if permutation is specified
if ~isempty(handles.Button_Sort.UserData.permutation)
    I = handles.Button_Sort.UserData.permutation;
    Zdata = Zdata(I,:,:);
    label_events = label_events(I);
end

% Update Axes
titles = strcat(CFC_Selection(:,1),'/',CFC_Selection(:,2));
titles = regexprep(titles,'_','-');
for i=1:crossfreq
    ind = (val-1)*crossfreq+i;
    if  ind <= n_crossfreq  
        % Axis Title
        t = titles(ind,:);
        t = t(1:min(length(t),20));
         
        % Image all Events
        ax1 = findobj(handles.ThirdPanel,'Tag',sprintf('Ax%d',i));
        imagesc('XData',bins,...
            'CData',Zdata(:,:,ind),...
            'Parent',ax1,...
            'Tag','EventImage');
        
        %Title and axes limits
        title(ax1,t);
        ax1.Tag = sprintf('Ax%d',i);
        set(ax1,'Ydir','reverse');
        ax1.XLim = [bins(1), bins(end)];
        ax1.YLim = [.5, size(Zdata,1)+.5];
        ax1.YTick = 1:size(Zdata,1);
        ax1.YTickLabel = label_events;
        
        % Integral Curve on Image Data
        temp = Zdata_norm(:,:,ind).*log(Zdata_norm(:,:,ind));
        integ = -sum(temp,2,'omitnan');
        integ = (log(length(integ))-integ)/log(length(integ));
        m = min(integ);
        M = max(integ);
        integ = integ*((ax1.XLim(2)-ax1.XLim(1))/(M-m));
        m = min(integ);
        integ = integ-(m-ax1.XLim(1));
        line(integ,1:size(Zdata_norm,1),...
            'Tag',sprintf('Integ_Curve%d',i),...
            'Parent',ax1,...
            'Color',[0 0 0]);
        
        % Update Controls
        caxis(ax1,'auto');
        button1 = findobj(handles.ThirdPanel,'Tag',sprintf('cmin_%d',i));
        button1.String = sprintf('%.1f',ax1.CLim(1));
        button2 = findobj(handles.ThirdPanel,'Tag',sprintf('cmax_%d',i));
        button2.String = sprintf('%.1f',ax1.CLim(2));
    end
end

% PopupTrials Callback
% Feeding Data to Popup3
handles.Popup3.UserData.bins = bins;
handles.Popup3.UserData.Zdata = Zdata;
update_crossfreq(handles,handles.PopupTrials);

S.Ydata = handles.Popup3.UserData.Ydata;
S.ind_start = handles.Popup3.UserData.ind_start;
S.ind_end = handles.Popup3.UserData.ind_end;
S.ref_time = handles.Popup3.UserData.ref_time;
S.label_events = label_events;
S.CFC_Selection = CFC_Selection;
S.align1 = align1;
S.align2 = align2;
handles.ButtonBatch.UserData.CFCData = S;

end

function update_channels(handles,popup)

Ydata = handles.Popup1.UserData.Ydata;
ind_start = handles.Popup1.UserData.ind_start;
ind_end = handles.Popup1.UserData.ind_end;
ref_time = handles.Popup1.UserData.ref_time;
val_popup1 = handles.Popup1.Value;
channels = str2double(handles.Edit1.String);
n_channels = length(handles.fUSTable.UserData.Selection);

val = popup.Value;
str = popup.String;

% Update Axes
for i=1:channels
    ind = (val_popup1-1)*channels+i;
    if  ind <= n_channels
        % Clear Axes
        button1 = findobj(handles.MainPanel,'Tag',sprintf('cmin_%d',i));
        button2 = findobj(handles.MainPanel,'Tag',sprintf('cmax_%d',i));
        ax1 = findobj(handles.MainPanel,'Tag',sprintf('Ax%d',i));
        ax2 = findobj(handles.MainPanel,'Tag',sprintf('Ax%d',i+channels));
        cla(ax2);
        delete(ax2.Title);
        
        switch strtrim(str(val,:))
            case 'Mean + All Trials'
                m = mean(Ydata(:,:,ind),1,'omitnan');
                s = std(Ydata(:,:,ind),[],1,'omitnan');
                % all trials
                for ii=1:size(Ydata,1)
                    line('XData',ref_time,'YData',Ydata(ii,:,ind),...
                        'LineWidth',.5,'Color',[.5 .5 .5],'Parent',ax2);
                end
                % mean
                line('XData',ref_time,'YData',m,...
                    'LineWidth',1,'Color','k','Parent',ax2);

            case 'Mean +/- SD'
                m = mean(Ydata(:,:,ind),1,'omitnan');
                s = std(Ydata(:,:,ind),[],1,'omitnan');
                % mean
                line('XData',ref_time,'YData',m,...
                    'LineWidth',1,'Color','k','Parent',ax2);
                % standard deviation
                line('XData',ref_time,'YData',m+s,...
                    'LineWidth',1,'Color',[.5 .5 .5],'Parent',ax2);
                line('XData',ref_time,'YData',m-s,...
                    'LineWidth',1,'Color',[.5 .5 .5],'Parent',ax2);
                
            case 'Median + All Trials'
                m = median(Ydata(:,:,ind),1,'omitnan');
                s = std(Ydata(:,:,ind),[],1,'omitnan');
                % all trials
                for ii=1:size(Ydata,1)
                    line('XData',ref_time,'YData',Ydata(ii,:,ind),...
                        'LineWidth',.5,'Color',[.5 .5 .5],'Parent',ax2);
                end
                % median
                line('XData',ref_time,'YData',m,...
                    'LineWidth',1,'Color','k','Parent',ax2);
                
            case 'Median +/- SD'
                m = median(Ydata(:,:,ind),1,'omitnan');
                s = std(Ydata(:,:,ind),[],1,'omitnan');
                % mean
                line('XData',ref_time,'YData',m,...
                    'LineWidth',1,'Color','k','Parent',ax2);
                % standard deviation
                line('XData',ref_time,'YData',m+s,...
                    'LineWidth',1,'Color',[.5 .5 .5],'Parent',ax2);
                line('XData',ref_time,'YData',m-s,...
                    'LineWidth',1,'Color',[.5 .5 .5],'Parent',ax2);
        end
        
        % ticks on graph
        val1 = .9;
        val2 = 1;
        for k=1:size(Ydata,1)
            line('XData',[ref_time(ind_start(k)),ref_time(ind_start(k))],...
                'YData',[val1*ax2.YLim(2) val2*ax2.YLim(2)],...
                'LineWidth',.5,'Tag','Ticks','Color','k','Parent',ax2);
            line('XData',[ref_time(ind_end(k)),ref_time(ind_end(k))],...
                'YData',[val1*ax2.YLim(2) val2*ax2.YLim(2)],...
                'LineWidth',.5,'Tag','Ticks','Color','k','Parent',ax2);
        end
        % update controls
        m_min = min(m);
        m_max = max(m);
        s_min = mean(s,'omitnan');
        s_max = s_min;
        
        button1.String = sprintf('%.1f',m_min-s_min);
        button2.String = sprintf('%.1f',m_max+s_max);
        ax1.CLim = [m_min-s_min,m_max+s_max];
        %axis(ax2,'auto y');
        ax2.YLim = [m_min-s_min,m_max+s_max];
        button3 = findobj(handles.MainPanel,'Tag',sprintf('xmin_%d',i));
        button3.String = sprintf('%.1f',ax2.XLim(1));
        button4 = findobj(handles.MainPanel,'Tag',sprintf('xmax_%d',i));
        button4.String = sprintf('%.1f',ax2.XLim(2));
        %title(ax2,strcat(str_t1,t,str_t2));
        
        %for ticks
        all_ticks = findobj(ax2,'Tag','Ticks');
        for ii =1:length(all_ticks)
            all_ticks(ii).YData = [ax2.YLim(1)+val1*(ax2.YLim(2)-ax2.YLim(1)),ax2.YLim(1)+val2*(ax2.YLim(2)-ax2.YLim(1))];
        end
    end
end

% Pointer off
handles.MainFigure.Pointer = 'arrow';

end

function update_electrodes(handles,popup)

Ydata = handles.Popup2.UserData.Ydata;
ind_start = handles.Popup2.UserData.ind_start;
ind_end = handles.Popup2.UserData.ind_end;
ref_time = handles.Popup2.UserData.ref_time;
val_popup2 = handles.Popup2.Value;
electrodes = str2double(handles.Edit2.String);
n_electrodes = length(handles.LFPTable.UserData.Selection);

val = popup.Value;
str = popup.String;

% Update Axes
for i=1:electrodes
    ind = (val_popup2-1)*electrodes+i;
    if  ind <= n_electrodes
        % Clear Axes
        button1 = findobj(handles.SecondPanel,'Tag',sprintf('cmin_%d',i));
        button2 = findobj(handles.SecondPanel,'Tag',sprintf('cmax_%d',i));
        ax1 = findobj(handles.SecondPanel,'Tag',sprintf('Ax%d',i));
        ax2 = findobj(handles.SecondPanel,'Tag',sprintf('Ax%d',i+electrodes));
        cla(ax2);
        delete(ax2.Title);
        
        switch strtrim(str(val,:))
            case 'Mean + All Trials'
                m = mean(Ydata(:,:,ind),1,'omitnan');
                s = std(Ydata(:,:,ind),[],1,'omitnan');
                % all trials
                for ii=1:size(Ydata,1)
                    line('XData',ref_time,'YData',Ydata(ii,:,ind),...
                        'LineWidth',.5,'Color',[.5 .5 .5],'Parent',ax2);
                end
                % mean
                line('XData',ref_time,'YData',m,...
                    'LineWidth',1,'Color','k','Parent',ax2);

            case 'Mean +/- SD'
                m = mean(Ydata(:,:,ind),1,'omitnan');
                s = std(Ydata(:,:,ind),[],1,'omitnan');
                % mean
                line('XData',ref_time,'YData',m,...
                    'LineWidth',1,'Color','k','Parent',ax2);
                % standard deviation
                line('XData',ref_time,'YData',m+s,...
                    'LineWidth',1,'Color',[.5 .5 .5],'Parent',ax2);
                line('XData',ref_time,'YData',m-s,...
                    'LineWidth',1,'Color',[.5 .5 .5],'Parent',ax2);
                
            case 'Median + All Trials'
                m = median(Ydata(:,:,ind),1,'omitnan');
                s = std(Ydata(:,:,ind),[],1,'omitnan');
                % all trials
                for ii=1:size(Ydata,1)
                    line('XData',ref_time,'YData',Ydata(ii,:,ind),...
                        'LineWidth',.5,'Color',[.5 .5 .5],'Parent',ax2);
                end
                % median
                line('XData',ref_time,'YData',m,...
                    'LineWidth',1,'Color','k','Parent',ax2);
                
            case 'Median +/- SD'
                m = median(Ydata(:,:,ind),1,'omitnan');
                s = std(Ydata(:,:,ind),[],1,'omitnan');
                % mean
                line('XData',ref_time,'YData',m,...
                    'LineWidth',1,'Color','k','Parent',ax2);
                % standard deviation
                line('XData',ref_time,'YData',m+s,...
                    'LineWidth',1,'Color',[.5 .5 .5],'Parent',ax2);
                line('XData',ref_time,'YData',m-s,...
                    'LineWidth',1,'Color',[.5 .5 .5],'Parent',ax2);
        end
        
        % ticks on graph
        val1 = .9;
        val2 = 1;
        for k=1:size(Ydata,1)
            line('XData',[ref_time(ind_start(k)),ref_time(ind_start(k))],...
                'YData',[val1*ax2.YLim(2) val2*ax2.YLim(2)],...
                'LineWidth',.5,'Tag','Ticks','Color','k','Parent',ax2);
            line('XData',[ref_time(ind_end(k)),ref_time(ind_end(k))],...
                'YData',[val1*ax2.YLim(2) val2*ax2.YLim(2)],...
                'LineWidth',.5,'Tag','Ticks','Color','k','Parent',ax2);
        end
        % update controls
        m_min = min(m);
        m_max = max(m);
        s_min = mean(s,'omitnan');
        s_max = s_min;
        
        button1.String = sprintf('%.1f',m_min-s_min);
        button2.String = sprintf('%.1f',m_max+s_max);
        ax1.CLim = [m_min-s_min,m_max+s_max];
        %axis(ax2,'auto y');
        ax2.YLim = [m_min-s_min,m_max+s_max];
        button3 = findobj(handles.SecondPanel,'Tag',sprintf('xmin_%d',i));
        button3.String = sprintf('%.1f',ax2.XLim(1));
        button4 = findobj(handles.SecondPanel,'Tag',sprintf('xmax_%d',i));
        button4.String = sprintf('%.1f',ax2.XLim(2));
        %title(ax2,strcat(str_t1,t,str_t2));
        
        %for ticks
        all_ticks = findobj(ax2,'Tag','Ticks');
        for ii =1:length(all_ticks)
            all_ticks(ii).YData = [ax2.YLim(1)+val1*(ax2.YLim(2)-ax2.YLim(1)),ax2.YLim(1)+val2*(ax2.YLim(2)-ax2.YLim(1))];
        end
    end
end

end

function update_crossfreq(handles,popup)

Zdata = handles.Popup3.UserData.Zdata;
bins = handles.Popup3.UserData.bins;
val_popup2 = handles.Popup3.Value;
crossfreq = str2double(handles.Edit3.String);
n_crossfreq = length(handles.CFCTable.UserData.Selection);

val = popup.Value;
str = popup.String;

% Update Axes
for i=1:crossfreq
    ind = (val_popup2-1)*crossfreq+i;
    if  ind <= n_crossfreq
        % Clear Axes
        button1 = findobj(handles.ThirdPanel,'Tag',sprintf('cmin_%d',i));
        button2 = findobj(handles.ThirdPanel,'Tag',sprintf('cmax_%d',i));
        ax1 = findobj(handles.ThirdPanel,'Tag',sprintf('Ax%d',i));
        ax2 = findobj(handles.ThirdPanel,'Tag',sprintf('Ax%d',i+crossfreq));
        cla(ax2);
        delete(ax2.Title);
        
        switch strtrim(str(val,:))
            case 'Mean + All Trials'
                m = mean(Zdata(:,:,ind),1,'omitnan');
                s = std(Zdata(:,:,ind),[],1,'omitnan');
                % all trials
                for ii=1:size(Zdata,1)
                    line('XData',bins,'YData',Zdata(ii,:,ind),...
                        'LineWidth',.5,'Color',[.5 .5 .5],'Parent',ax2);
                end
                % mean
                line('XData',bins,'YData',m,...
                    'LineWidth',1,'Color','k','Parent',ax2);  
                
            case 'Mean +/- SD'
                m = mean(Zdata(:,:,ind),1,'omitnan');
                s = std(Zdata(:,:,ind),[],1,'omitnan');
                % mean
                line('XData',bins,'YData',m,...
                    'LineWidth',1,'Color','k','Parent',ax2);
                % standard deviation
                line('XData',bins,'YData',m+s,...
                    'LineWidth',1,'Color',[.5 .5 .5],'Parent',ax2);
                line('XData',bins,'YData',m-s,...
                    'LineWidth',1,'Color',[.5 .5 .5],'Parent',ax2);
                
            case 'Median + All Trials'
                m = median(Zdata(:,:,ind),1,'omitnan');
                s = std(Zdata(:,:,ind),[],1,'omitnan');
                % all trials
                for ii=1:size(Zdata,1)
                    line('XData',bins,'YData',Zdata(ii,:,ind),...
                        'LineWidth',.5,'Color',[.5 .5 .5],'Parent',ax2);
                end
                % median
                line('XData',bins,'YData',m,...
                    'LineWidth',1,'Color','k','Parent',ax2);
                
            case 'Median +/- SD'
                m = median(Zdata(:,:,ind),1,'omitnan');
                s = std(Zdata(:,:,ind),[],1,'omitnan');
                % mean
                line('XData',bins,'YData',m,...
                    'LineWidth',1,'Color','k','Parent',ax2);
                % standard deviation
                line('XData',bins,'YData',m+s,...
                    'LineWidth',1,'Color',[.5 .5 .5],'Parent',ax2);
                line('XData',bins,'YData',m-s,...
                    'LineWidth',1,'Color',[.5 .5 .5],'Parent',ax2);
        end
        
        % update controls
        m_min = min(m);
        m_max = max(m);
        s_min = mean(s,'omitnan');
        s_max = s_min;
        
        button1.String = sprintf('%.1f',m_min-s_min);
        button2.String = sprintf('%.1f',m_max+s_max);
        ax1.CLim = [m_min-s_min,m_max+s_max];
        %axis(ax2,'auto y');
        ax2.YLim = [m_min-s_min,m_max+s_max];
        button3 = findobj(handles.ThirdPanel,'Tag',sprintf('xmin_%d',i));
        button3.String = sprintf('%.1f',ax2.XLim(1));
        button4 = findobj(handles.ThirdPanel,'Tag',sprintf('xmax_%d',i));
        button4.String = sprintf('%.1f',ax2.XLim(2));
        %title(ax2,strcat(str_t1,t,str_t2));
    end
end

end

function update_popup_trials_Callback(hObj,~,handles)

channels = str2double(handles.Edit1.String);
electrodes = str2double(handles.Edit2.String);
crossfreq = str2double(handles.Edit3.String);
if channels>0
    update_channels(handles,hObj)
end
if electrodes>0
    update_electrodes(handles,hObj)
end
if crossfreq>0
    update_crossfreq(handles,hObj)
end
end

function saveImage_Callback(~,~,handles)

% Pointer Watch
set(handles.MainFigure, 'pointer', 'watch');
drawnow;

global FILES CUR_FILE DIR_FIG;
load('Preferences.mat','GTraces');

channels = str2double(handles.Edit1.String);
electrodes = str2double(handles.Edit2.String);
crossfreq = str2double(handles.Edit3.String);
time_group = handles.ButtonCompute.UserData.TimeGroup;

% Creating Save Directory
folder_save = fullfile(DIR_FIG,'fUS_PeriEventHistogram',FILES(CUR_FILE).recording,char(time_group));
if isdir(folder_save)
    rmdir(folder_save,'s');
end
mkdir(folder_save);

% Saving frames for video
handles.TabGroup.SelectedTab = handles.FirstTab;
if channels>0
    save_dir = fullfile(folder_save,strcat(handles.Text2.String,'_fUS'));
    if ~isdir(save_dir) 
        mkdir(save_dir);
    end
    % Saving all channels
    t=0;
    for i = 1:size(handles.Popup1.String,1)
        t=t+1;
        handles.Popup1.Value = i;
        update_popup1_Callback(handles.Popup1,[],handles);
        pic_name = sprintf('%s_fUSPeriEventHistogram_%03d%s',FILES(CUR_FILE).recording,t,GTraces.ImageSaveExtension);
        saveas(handles.MainFigure,fullfile(save_dir,pic_name),GTraces.ImageSaveFormat);
        fprintf('Image saved at %s.\n',fullfile(save_dir,pic_name));
    end
elseif electrodes>0 && size(handles.Popup2.String,1)>1
    save_dir = fullfile(folder_save,strcat(handles.Text2.String,'_LFP'));
    if ~isdir(save_dir) 
        mkdir(save_dir);
    end
    % Saving all electrodes
    t=0;
    for i = 1:size(handles.Popup2.String,1)
        t=t+1;
        handles.Popup2.Value = i;
        update_popup2_Callback(handles.Popup2,[],handles);
        pic_name = sprintf('%s_fUSPeriEventHistogram_%03d%s',FILES(CUR_FILE).recording,t,GTraces.ImageSaveExtension);
        saveas(handles.MainFigure,fullfile(save_dir,pic_name),GTraces.ImageSaveFormat);
        fprintf('Image saved at %s.\n',fullfile(save_dir,pic_name));
    end
elseif crossfreq>0 && size(handles.Popup3.String,1)>1
    save_dir = fullfile(folder_save,strcat(handles.Text2.String,'_CFC'));
    if ~isdir(save_dir) 
        mkdir(save_dir);
    end
    % Saving all cfc channels
    t=0;
    for i = 1:size(handles.Popup3.String,1)
        t=t+1;
        handles.Popup3.Value = i;
        update_popup3_Callback(handles.Popup3,[],handles);
        pic_name = sprintf('%s_fUSPeriEventHistogram_%03d%s',FILES(CUR_FILE).recording,t,GTraces.ImageSaveExtension);
        saveas(handles.MainFigure,fullfile(save_dir,pic_name),GTraces.ImageSaveFormat);
        fprintf('Image saved at %s.\n',fullfile(save_dir,pic_name));
    end
end

% Saving video
work_dir = save_dir;
video_dir = folder_save;
video_name = strcat(FILES(CUR_FILE).recording,'-',handles.Text2.String,save_dir(end-3:end));
save_video(work_dir,video_dir,video_name);
set(handles.MainFigure, 'pointer', 'arrow');

% Saving all tabs
all_tabs = [handles.SecondTab;handles.ThirdTab;handles.FourthTab;handles.FifthTab];
for i =1:length(all_tabs)
    handles.TabGroup.SelectedTab = all_tabs(i);
    s = sprintf('%s',handles.TabGroup.SelectedTab.Title);
    pic_name = sprintf('%s_fUSPeriEventHistogram_%s_%03d%s',FILES(CUR_FILE).recording,s,GTraces.ImageSaveExtension);
    saveas(handles.MainFigure,fullfile(folder_save,pic_name),GTraces.ImageSaveFormat);
    fprintf('Image saved at %s.\n',fullfile(folder_save,pic_name));
end

handles.TabGroup.SelectedTab = handles.FirstTab;

end

function saveStats_Callback(~,~,handles)

% Pointer Watch
set(handles.MainFigure, 'pointer', 'watch');
drawnow;

global FILES CUR_FILE DIR_STATS;
load('Preferences.mat','GTraces');

% Creating Save Directory
time_group = handles.ButtonCompute.UserData.TimeGroup;
folder_save = fullfile(DIR_STATS,'fUS_PeriEventHistogram',FILES(CUR_FILE).recording,char(time_group));
if isdir(folder_save)
    rmdir(folder_save,'s');
end
mkdir(folder_save);

% General
align1 = handles.Checkbox1.Value;
align2 = handles.Checkbox2.Value;
data = handles.ButtonBatch.UserData.data;
labels = handles.ButtonBatch.UserData.labels;
channels = str2double(handles.Edit1.String);
electrodes = str2double(handles.Edit2.String);
crossfreq = str2double(handles.Edit3.String);
time_group = handles.ButtonCompute.UserData.TimeGroup;
if strcmp(handles.PopupStart.String(handles.PopupStart.Value,:),handles.PopupEnd.String(handles.PopupEnd.Value,:))
    str_ref = strcat(strtrim(char(handles.PopupEnd.String(handles.PopupEnd.Value,:))));
else
    str_ref = strcat(strtrim(char(handles.PopupStart.String(handles.PopupStart.Value,:))),'|',strtrim(char(handles.PopupEnd.String(handles.PopupEnd.Value,:))));
end
Doppler_ref = handles.Text2.String;
% Save
save(fullfile(folder_save,'EventDisplay.mat'),'data','labels','time_group','str_ref','Doppler_ref',...
    'channels','electrodes','crossfreq','align1','align2','-v7.3');
fprintf('Data saved at [%s].\n',fullfile(folder_save,'EventDisplay.mat'));

% fUS_Data
S = handles.ButtonBatch.UserData.fUSData;
if ~isempty(S)
    Ydata = S.Ydata;
    ind_start = S.ind_start;
    ind_end = S.ind_end;
    ref_time = S.ref_time;
    label_events = S.label_events;
    fUS_Selection = S.fUS_Selection;
    align1 = S.align1;
    align2 = S.align2;
    % Save
    save(fullfile(folder_save,'fUS_Data.mat'),'Ydata','ind_start','ind_end','ref_time','time_group',...
        'label_events','fUS_Selection','align1','align2','-v7.3');
    fprintf('Data saved at [%s].\n',fullfile(folder_save,'fUS_Data.mat'));
end

% LFP_Data
S = handles.ButtonBatch.UserData.LFPData;
if ~isempty(S)
    Ydata = S.Ydata;
    ind_start = S.ind_start;
    ind_end = S.ind_end;
    ref_time = S.ref_time;
    label_events = S.label_events;
    LFP_Selection = S.fUS_Selection;
    align1 = S.align1;
    align2 = S.align2;
    % Save
    save(fullfile(folder_save,'LFP_Data.mat'),'Ydata','ind_start','ind_end','ref_time','time_group',...
        'label_events','LFP_Selection','align1','align2','-v7.3');
    fprintf('Data saved at [%s].\n',fullfile(folder_save,'fUS_Data.mat'));
end

% CFC_Data
S = handles.ButtonBatch.UserData.CFCData;
if ~isempty(S)
    Ydata = S.Ydata;
    ind_start = S.ind_start;
    ind_end = S.ind_end;
    ref_time = S.ref_time;
    label_events = S.label_events;
    CFC_Selection = S.CFC_Selection;
    align1 = S.align1;
    align2 = S.align2;
    % Save
    save(fullfile(folder_save,'CFC_Data.mat'),'Ydata','ind_start','ind_end','ref_time','time_group',...
        'label_events','CFC_Selection','align1','align2','-v7.3');
    fprintf('Data saved at [%s].\n',fullfile(folder_save,'fUS_Data.mat'));
end

end
