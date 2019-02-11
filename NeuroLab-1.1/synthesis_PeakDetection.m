function synthesis_PeakDetection()

global DIR_SYNT DIR_STATS DIR_FIG;

d = dir(fullfile(DIR_SYNT,'Peak_Detection','*.txt'));
[ind_list,v] = listdlg('Name','Folder Selection','PromptString','Select Folder',...
    'SelectionMode','single','ListString',{d(:).name}','InitialValue','','ListSize',[300 500]);
if v==0 || isempty(ind_list)
    return
else
    folder_synt = fullfile(DIR_SYNT,'Peak_Detection');
    list_name_txt = char(d(ind_list).name);
    list_name = strrep(list_name_txt,'.txt','');
    folder = fullfile(DIR_SYNT,'Peak_Detection',list_name);
end

% Selection recording list via listdlg
% list_name = 'CORONAL_SORTED';
% list_name_txt = strcat(list_name,'.txt');

% Open file
filename = fullfile(folder_synt,list_name_txt);
fileID = fopen(filename);
rec_list = [];
while ~feof(fileID)
    hline = fgetl(fileID);
    rec_list = [rec_list;{hline}];
end
fclose(fileID);

%Extracting file channel and episode from rec_list
file_list = [];
channel_list = [];
episode_list = [];
for i =1:length(rec_list)
    pattern = strrep(char(rec_list(i)),'.mat','');
    temp = regexp(pattern,'_Peak_Detection_|_REM','split');
    file_list = [file_list;temp(1)];
    channel_list = [channel_list;temp(2)];
    episode_list = [episode_list;{strcat('REM',char(temp(3)))}];
end

%Clearing folder synthesis
folder_list = fullfile(folder_synt,list_name);
if exist(folder_list,'dir')
    fprintf('Clearing folder %s\n',folder_list);
    rmdir(folder_list,'s');
end
mkdir(folder_list);

%Moving stats 
for i =1:length(rec_list)
    fprintf('Moving file %s\n',filename);
    filename = char(rec_list(i));
    status = copyfile(fullfile(DIR_STATS,'Peak_Detection',char(file_list(i)),filename),fullfile(folder_list,filename));
    if ~status
        warning('Problem copying file %s',filename);
    end
end

%Moving figures
for i =1:length(rec_list) 
    channel = char(channel_list(i));
    episode = char(episode_list(i));
    tag = 'RasterY';
    %tag = '';
    d = dir(fullfile(DIR_FIG,'Peak_Detection',char(file_list(i)),'*.jpg'));
    all_files = {d(:).name}';
    ind_keep = contains(all_files,channel).*contains(all_files,episode).*contains(all_files,tag);
    files_keep = all_files(ind_keep==1);
    
    for ii =1:length(files_keep)
        filename = char(files_keep(ii));
        fprintf('Moving file %s\n',filename);
        status = copyfile(fullfile(DIR_FIG,'Peak_Detection',char(file_list(i)),filename),fullfile(folder_list,filename));
        if ~status
            warning('Problem copying file %s',filename);
        end
    end
end

%%
d = dir(fullfile(folder,'*.mat'));
all_files = {d(:).name}';

f2 = figure('Units','normalized',...
    'HandleVisibility','callback',...
    'IntegerHandle','off',...
    'Renderer','painters',...
    'Toolbar','figure',...
    'NumberTitle','off',...
    'Tag','MainFigure',...
    'PaperPositionMode','auto',...
    'Name','Synthesis Peak Detection');
f2.Position = [.1 .1 .8 .8];
f2.UserData.all_files = all_files;
f2.UserData.folder = folder;
% Colormaps
%colormap('jet');
f2.UserData.g_colors = get(groot,'DefaultAxesColorOrder');
clrmenu(f2);

D_files = [];
D_traces = [];
for i = 1:length(all_files)
    data_l =load(fullfile(folder,char(all_files(i))),'recording','tag','channel','label_channels');
    D_files = [D_files;{data_l.recording,data_l.tag,data_l.channel}];
    D_traces = [D_traces;data_l.label_channels];
end

D = D_traces;
D_u = unique(D,'stable');
occurences = NaN(size(D_u));
for i = 1:length(D_u)
    occurences(i) = sum(strcmp(D,D_u(i)));
end
D_traces = [D_u,num2cell(occurences)];

%Parameters
cb1_def = 1;
cb1_tip = 'Legend Visibility';
cb2_def = 1;
cb2_tip = 'Dot Visibility';
cb3_def = 0;
cb3_tip = 'Tick Visibility';

% Information Panel
iP = uipanel('FontSize',12,...
    'Units','normalized',...
    'Tag','InfoPanel',...
    'Position',[0 0 1 .1],...
    'Parent',f2);
t1 = uicontrol('Units','normalized','Style','text','HorizontalAlignment','left','Parent',iP,...
    'String',f2.Name,'Tag','Text1','FontSize',15);
e1 = uicontrol('Units','normalized','Style','edit','HorizontalAlignment','center','Parent',iP,...
    'String',1,'Tag','Edit1','Tooltipstring','Line Width');
e2 = uicontrol('Units','normalized','Style','edit','HorizontalAlignment','center','Parent',iP,...
    'String',5,'Tag','Edit2','Tooltipstring','Marker Size');
% pu1 = uicontrol('Units','normalized','Style','popupmenu','Parent',iP,...
%     'String','<0>','Tag','Popup1','Value',1);
% pu2 = uicontrol('Units','normalized','Style','popupmenu','Parent',iP,...
%     'String','<0>','Tag','Popup2','Value',1);
br = uicontrol('Units','normalized','Style','pushbutton','Parent',iP,...
    'String','Reset','Tag','ButtonReset');
bc = uicontrol('Units','normalized','Style','pushbutton','Parent',iP,...
    'String','Compute','Tag','ButtonCompute');
bi = uicontrol('Units','normalized','Style','pushbutton','Parent',iP,...
    'String','Save Image','Tag','ButtonSaveImage');
bs = uicontrol('Units','normalized','Style','pushbutton','Parent',iP,...
    'String','Save Stats','Tag','ButtonSaveStats');
cb1 = uicontrol('Units','normalized','Style','checkbox','Parent',iP,...
    'TooltipString',cb1_tip,'Tag','Checkbox1','Value',cb1_def);
cb2 = uicontrol('Units','normalized','Style','checkbox','Parent',iP,...
    'TooltipString',cb2_tip,'Tag','Checkbox2','Value',cb2_def);
cb3 = uicontrol('Units','normalized','Style','checkbox','Parent',iP,...
    'TooltipString',cb3_tip,'Tag','Checkbox3','Value',cb3_def);


ipos = [0 0 1 1];
t1.Position = [ipos(3)/50      ipos(4)/10    ipos(3)/4   3*ipos(4)/4];
%pu1.Position = [ipos(3)/4     ipos(4)/2    ipos(3)/4   ipos(4)/3];
%pu2.Position = [ipos(3)/4     ipos(4)/10             ipos(3)/4   ipos(4)/3];
e1.Position = [6*ipos(3)/10     ipos(4)/2    5*ipos(3)/100   4*ipos(4)/10];
e2.Position = [6*ipos(3)/10     ipos(4)/10             5*ipos(3)/100   4*ipos(4)/10];

br.Position = [7*ipos(3)/10     ipos(4)/2     1.5*ipos(3)/10-.01   ipos(4)/2.5];
bc.Position = [8.5*ipos(3)/10     ipos(4)/2      1.5*ipos(3)/10-.01   ipos(4)/2.5];
bi.Position = [7*ipos(3)/10     ipos(4)/10      1.5*ipos(3)/10-.01   ipos(4)/2.5];
bs.Position = [8.5*ipos(3)/10     ipos(4)/10      1.5*ipos(3)/10-.01   ipos(4)/2.5];

cb1.Position = [5*ipos(3)/10     .5*ipos(4)/10    ipos(3)/10   3*ipos(4)/10];
cb2.Position = [5*ipos(3)/10     3.5*ipos(4)/10    ipos(3)/10   3*ipos(4)/10];
cb3.Position = [5*ipos(3)/10     6.5*ipos(4)/10    ipos(3)/10   3*ipos(4)/10];

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
tab00 = uitab('Parent',tabgp,...
    'Title','Traces & Episodes',...
    'Tag','TraceTab');
filePanel = uipanel('Parent',tab00,...
    'Units','normalized',...
    'Position',[0 0 1/3 1],...
    'Title','Files',...
    'Tag','FilePanel');
tracePanel = uipanel('Parent',tab00,...
    'Units','normalized',...
    'Position',[1/3 0 1/3 1],...
    'Title','Traces',...
    'Tag','TracePanel');
lfpPanel = uipanel('Parent',tab00,...
    'Units','normalized',...
    'Position',[2/3 .67 1/3 .33],...
    'Title','LFP',...
    'Tag','lfpPanel');
cbvPanel = uipanel('Parent',tab00,...
    'Units','normalized',...
    'Position',[2/3 .335 1/3 .33],...
    'Title','CBV',...
    'Tag','cbvPanel');
dcbvPanel = uipanel('Parent',tab00,...
    'Units','normalized',...
    'Position',[2/3 0 1/3 .33],...
    'Title','dCBVdt',...
    'Tag','dcbvPanel');
% Table Data
ft = uitable('Units','normalized',...
    'ColumnName','',...
    'RowName',{},...
    'ColumnFormat',{'char','char','char'},...
    'ColumnEditable',[false,false,false],...
    'ColumnWidth',{200 100 100},...
    'Data',D_files,...
    'Position',[0 0 1 1],...
    'Tag','File_table',...
    'CellSelectionCallback',@template_uitable_select,...
    'RowStriping','on',...
    'Parent',filePanel);
ft.UserData.Selection = (1:size(ft.Data,1))';

tt = uitable('Units','normalized',...
    'ColumnName','',...
    'RowName',{},...
    'ColumnFormat',{'char','char'},...
    'ColumnEditable',[false,false],...
    'ColumnWidth',{200 200},...
    'Data',D_traces,...
    'Position',[0 0 1 1],...
    'Tag','Trace_table',...
    'CellSelectionCallback',@template_uitable_select,...
    'RowStriping','on',...
    'Parent',tracePanel);
tt.UserData.Selection = (1:size(tt.Data,1))';

D = {'gamma-low';'gamma-mid';'gamma-midup';'gamma-high';'gamma-highup';'ripple';'theta'};
lt = uitable('Units','normalized',...
    'ColumnName','',...
    'RowName',{},...
    'ColumnFormat',{'char'},...
    'ColumnEditable',false,...
    'ColumnWidth',{200},...
    'Data',D,...
    'Position',[0 0 1 1],...
    'Tag','LFP_table',...
    'CellSelectionCallback',@template_uitable_select,...
    'RowStriping','on',...
    'Parent',lfpPanel);
lt.UserData.Selection = [1;2;4;7];%(1:size(lt.Data,1))';

D = {'ycortex';'yhpc';'ythal';'ywhole'};
ct = uitable('Units','normalized',...
    'ColumnName','',...
    'RowName',{},...
    'ColumnFormat',{'char'},...
    'ColumnEditable',false,...
    'ColumnWidth',{200},...
    'Data',D,...
    'Position',[0 0 1 1],...
    'Tag','CBV_table',...
    'CellSelectionCallback',@template_uitable_select,...
    'RowStriping','on',...
    'Parent',cbvPanel);
ct.UserData.Selection = (1:size(ct.Data,1))';

D = {'dcortex';'dhpc';'dthal';'dwhole'};
dt = uitable('Units','normalized',...
    'ColumnName','',...
    'RowName',{},...
    'ColumnFormat',{'char'},...
    'ColumnEditable',false,...
    'ColumnWidth',{200},...
    'Data',D,...
    'Position',[0 0 1 1],...
    'Tag','dCBV_table',...
    'CellSelectionCallback',@template_uitable_select,...
    'RowStriping','on',...
    'Parent',dcbvPanel);
dt.UserData.Selection = (1:size(dt.Data,1))';

% All tabs
tab0 = uitab('Parent',tabgp,...
    'Title','Traces',...
    'Tag','MainTab');
uitab('Parent',tabgp,...
    'Title','Raster-y',...
    'Tag','FirstTab');
uitab('Parent',tabgp,...
    'Title','Timing-y',...
    'Tag','SecondTab');
uitab('Parent',tabgp,...
    'Title','Raster-dydt',...
    'Tag','ThirdTab');
uitab('Parent',tabgp,...
    'Title','Timing-dydt',...
    'Tag','FourthTab');
tab5 = uitab('Parent',tabgp,...
    'Title','Synthesis',...
    'Tag','FifthTab');
tab6 = uitab('Parent',tabgp,...
    'Title','Continuous',...
    'Tag','SixthTab');

%Traces
subplot(311,'Parent',tab0,'Tag','Ax1');
subplot(312,'Parent',tab0,'Tag','Ax2');
subplot(313,'Parent',tab0,'Tag','Ax3');

%Checkboxes
uicontrol('Units','normalized','Style','checkbox','Parent',tab0,...
    'TooltipString','Visibility','Position',[0 .68 .08 .04],...
    'Callback',{@boxVisible_Callback},...
    'Tag','BoxVisible','String','gamma-low','Value',1);
uicontrol('Units','normalized','Style','checkbox','Parent',tab0,...
    'TooltipString','Visibility','Position',[0 .72 .08 .04],...
    'Callback',{@boxVisible_Callback},...
    'Tag','BoxVisible','String','gamma-mid','Value',1);
uicontrol('Units','normalized','Style','checkbox','Parent',tab0,...
    'TooltipString','Visibility','Position',[0 .76 .08 .04],...
    'Callback',{@boxVisible_Callback},...
    'Tag','BoxVisible','String','gamma-midup','Value',1);
uicontrol('Units','normalized','Style','checkbox','Parent',tab0,...
    'TooltipString','Visibility','Position',[0 .8 .08 .04],...
    'Callback',{@boxVisible_Callback},...
    'Tag','BoxVisible','String','gamma-high','Value',1);
uicontrol('Units','normalized','Style','checkbox','Parent',tab0,...
    'TooltipString','Visibility','Position',[0 .84 .08 .04],...
    'Callback',{@boxVisible_Callback},...
    'Tag','BoxVisible','String','gamma-highup','Value',1);
uicontrol('Units','normalized','Style','checkbox','Parent',tab0,...
    'TooltipString','Visibility','Position',[0 .88 .08 .04],...
    'Callback',{@boxVisible_Callback},...
    'Tag','BoxVisible','String','ripple','Value',1);
uicontrol('Units','normalized','Style','checkbox','Parent',tab0,...
    'TooltipString','Visibility','Position',[0 .92 .08 .04],...
    'Callback',{@boxVisible_Callback},...
    'Tag','BoxVisible','String','theta','Value',1);

uicontrol('Units','normalized','Style','checkbox','Parent',tab0,...
    'TooltipString','Visibility','Position',[0 .41 .08 .04],...
    'Callback',{@boxVisible_Callback},...
    'Tag','BoxVisible','String','ycortex','Value',1);
uicontrol('Units','normalized','Style','checkbox','Parent',tab0,...
    'TooltipString','Visibility','Position',[0 .45 .08 .04],...
    'Callback',{@boxVisible_Callback},...
    'Tag','BoxVisible','String','yhpc','Value',1);
uicontrol('Units','normalized','Style','checkbox','Parent',tab0,...
    'TooltipString','Visibility','Position',[0 .49 .08 .04],...
    'Callback',{@boxVisible_Callback},...
    'Tag','BoxVisible','String','ythal','Value',1);
uicontrol('Units','normalized','Style','checkbox','Parent',tab0,...
    'TooltipString','Visibility','Position',[0 .53 .08 .04],...
    'Callback',{@boxVisible_Callback},...
    'Tag','BoxVisible','String','ywhole','Value',1);

uicontrol('Units','normalized','Style','checkbox','Parent',tab0,...
    'TooltipString','Visibility','Position',[0 .08 .08 .04],...
    'Callback',{@boxVisible_Callback},...
    'Tag','BoxVisible','String','dcortex','Value',1);
uicontrol('Units','normalized','Style','checkbox','Parent',tab0,...
    'TooltipString','Visibility','Position',[0 .12 .08 .04],...
    'Callback',{@boxVisible_Callback},...
    'Tag','BoxVisible','String','dhpc','Value',1);
uicontrol('Units','normalized','Style','checkbox','Parent',tab0,...
    'TooltipString','Visibility','Position',[0 .16 .08 .04],...
    'Callback',{@boxVisible_Callback},...
    'Tag','BoxVisible','String','dthal','Value',1);
uicontrol('Units','normalized','Style','checkbox','Parent',tab0,...
    'TooltipString','Visibility','Position',[0 .2 .08 .04],...
    'Callback',{@boxVisible_Callback},...
    'Tag','BoxVisible','String','dwhole','Value',1);


% Synthesis
subplot(221,'Parent',tab5,'Tag','Ax4');
subplot(222,'Parent',tab5,'Tag','Ax5');
subplot(223,'Parent',tab5,'Tag','Ax6');
subplot(224,'Parent',tab5,'Tag','Ax7');
axes('Parent',tab6,'Tag','Ax8','Position',[.1 .75 .8 .2]);
axes('Parent',tab6,'Tag','Ax9','Position',[.1 .5 .8 .2]);
axes('Parent',tab6,'Tag','Ax10','Position',[.1 .05 .35 .4]);
axes('Parent',tab6,'Tag','Ax11','Position',[.55 .05 .35 .4]);

% reset
handles2 = guihandles(f2);
reset_Callback([],[],handles2);
tabgp.SelectedTab = tab00;

end

function handles = reset_Callback(~,~,handles)

handles = guihandles(handles.MainFigure);
handles.CenterAxes = handles.Ax1;

% set(handles.Edit1,'Callback',{@edit_Callback,all_axes});
% set(handles.Edit2,'Callback',{@edit_Callback,all_axes});
set(handles.Checkbox1,'Callback',{@checkbox1_Callback,handles});
set(handles.Checkbox2,'Callback',{@checkbox2_Callback,handles});
set(handles.Checkbox3,'Callback',{@checkbox3_Callback,handles});

set(handles.ButtonReset,'Callback',{@reset_Callback,handles});
set(handles.ButtonCompute,'Callback',{@compute_Callback,handles});
% set(handles.ButtonSaveImage,'Callback',{@saveimage_Callback,handles});
% set(handles.ButtonSaveStats,'Callback',{@savestats_Callback,handles});

% Clear secondary panels
ax = findobj([handles.FirstTab;handles.SecondTab;handles.ThirdTab;handles.FourthTab;handles.FifthTab;handles.SixthTab],'Type','axes');
for i =1:length(ax)
    delete(ax(i).Children);
end

% Legend/ticks Dipslay
checkbox1_Callback(handles.Checkbox1,[],handles);
checkbox2_Callback(handles.Checkbox2,[],handles);
checkbox3_Callback(handles.Checkbox3,[],handles);

% Linking axes x
linkaxes([handles.Ax1;handles.Ax2;handles.Ax3],'x');

end

function checkbox1_Callback(hObj,~,handles)
% Display legend

l = findobj(handles.MainFigure,'Tag','Legend');
if hObj.Value
    for i =1:length(l)
        l(i).Visible ='on';
    end
else
    for i =1:length(l)
        l(i).Visible ='off';
    end
end

end

function checkbox2_Callback(hObj,~,handles)
% Display dots

l = findobj(handles.MainFigure,'Tag','Dot_peak');
if hObj.Value
    for i =1:length(l)
        l(i).Visible ='on';
    end
else
    for i =1:length(l)
        l(i).Visible ='off';
    end
end

end

function checkbox3_Callback(hObj,~,handles)
% Display ticks

l = findobj(handles.MainFigure,'Tag','Tick_peak');
if hObj.Value
    for i =1:length(l)
        l(i).Visible ='on';
    end
else
    for i =1:length(l)
        l(i).Visible ='off';
    end
end

end

function boxVisible_Callback(hObj,~)

l = findobj(hObj.Parent,'Tag',hObj.String);
%ylim = l(1).Parent.YLim;
if hObj.Value
    for i =1:length(l)
        l(i).Visible = 'on';
    end
else
    for i =1:length(l)
        l(i).Visible = 'off';
    end
end
%l(1).Parent.YLim = ylim;

end

function compute_Callback(~,~,handles)

% Parameters
cmap = handles.MainFigure.Colormap;
all_files = handles.MainFigure.UserData.all_files;
folder = handles.MainFigure.UserData.folder;
g_colors = handles.MainFigure.UserData.g_colors;
linewidth = str2double(handles.Edit1.String);
markersize = str2double(handles.Edit2.String);

ft = handles.File_table;
if isempty(ft.UserData.Selection)
    warning('Please Select Files');
    return;
else
    ft_sel = ft.UserData.Selection;
    fprintf('File Selection : \n');
    ft.Data(ft_sel)
    str_files = ft.Data(ft_sel,1);
    %fprintf('\n');
end

tt = handles.Trace_table;
if isempty(tt.UserData.Selection)
    warning('Please Select Traces');
    return;
else
    tt_sel = tt.UserData.Selection;
    fprintf('Trace Selection : \n');
    tt.Data(tt_sel)
    str_channels = tt.Data(tt_sel,1);
    %fprintf('\n');
end

lt = handles.LFP_table;
if ~isempty(lt.UserData.Selection)
    lt_sel = lt.UserData.Selection;
    str_lfp = lt.Data(lt_sel,1);
else
    str_lfp = [];
end
ct = handles.CBV_table;
if ~isempty(ct.UserData.Selection)
    ct_sel = ct.UserData.Selection;
    str_cbv = ct.Data(ct_sel,1);
else
    str_cbv = [];
end
dt = handles.dCBV_table;
if ~isempty(dt.UserData.Selection)
    dt_sel = dt.UserData.Selection;
    str_dcbvdt = dt.Data(dt_sel,1);
else
    str_dcbvdt = [];
end

% Pointer Watch
set(handles.MainFigure, 'pointer', 'watch');
drawnow;
handles.MainFigure.UserData.success = false;

%BoxVisible
boxes = findobj(handles.MainFigure,'Tag','BoxVisible');
str = [str_lfp;str_cbv;str_dcbvdt];
for i =1:length(boxes)
    if sum(strcmp(str,boxes(i).String))>0
        boxes(i).Value = 1;
    else
        boxes(i).Value = 0;
    end
end

% Loading data
% R_Y = NaN(length(str_cbv),length(str_lfp),length(str_files));
% R_dYdt = NaN(length(str_dcbvdt),length(str_lfp),length(str_files));
% R_ALL = NaN(length(str_channels),length(str_lfp),length(str_files));
% R_dALLdt = NaN(length(str_channels),length(str_lfp),length(str_files));
% Loading freqdom from first file assuming size is constant for every file
% data = load(fullfile(folder,char(all_files(1))),'freqdom');
% R_CONT = NaN(length(str_channels),length(data.freqdom),length(str_files));
% R_dCONTdt = NaN(length(str_channels),length(data.freqdom),length(str_files));

%Loading items from first file assuming size is constant for every file
data = load(fullfile(folder,char(all_files(1))),'freqdom','R_y','R_all','R_cont');
n_cbv = size(data.R_y,1);
n_lfp = size(data.R_y,2);
n_dom = length(data.freqdom);
R_Y = NaN(n_cbv,n_lfp,length(str_files));
R_dYdt = NaN(n_cbv,n_lfp,length(str_files));
R_ALL = NaN(length(str_channels),n_lfp,length(str_files));
R_dALLdt = NaN(length(str_channels),n_lfp,length(str_files));
R_CONT = NaN(length(str_channels),n_dom,length(str_files));
R_dCONTdt = NaN(length(str_channels),n_dom,length(str_files));
% Agregate LFP and CBV
S_LFP_CONT = [];
S_CBV = [];
DATA_Y = [];
DATA_dYdt = [];
% Agregate LFP fUS and dfUS
S_LFP = [];
S_FUS = [];
S_dFUSdt = [];
    
for i=1:length(ft_sel)
    ii = ft_sel(i);
    filename = fullfile(folder,char(all_files(ii)));
    data = load(filename,'R_y','R_dydt','R_all','R_dalldt','R_cont','R_dcont',...
        'S_fus','S_dfusdt','S_cbv','S_dcbvdt','S_lfp','S_lfp_cont',...
        'data_y','data_dydt','ratio_y','ratio_dydt','R_cont','R_dcont',...
        'label_channels','recording','tag','Tag_Selection',...
        'channel','freqdom','thresh_inf','thresh_sup');
    data.label_fus = {data.S_fus(:).name}';
    data.label_cbv = {data.S_cbv(:).name}';
    data.label_lfp = {data.S_lfp(:).name}';
    data.label_lfp_cont = {data.S_lfp_cont(:).name}';
    
    % Keeping relevant indexes
    indexes_in = [];
    indexes_out = [];
    for k =1:length(str_channels);
        pattern = char(str_channels(k));
        ind = find(strcmp(data.label_channels,pattern)==1);
        indexes_in = [indexes_in;ind];
        if length(ind)==1
            indexes_out = [indexes_out;k];
        end
    end
    
    % Agregate S_FUS
    if isempty(S_FUS)
        S_FUS = data.S_fus;
        % reformating
        for j=1:length(S_FUS)
            S_FUS(j).x = S_FUS(j).x(:);
            S_FUS(j).x_scaled = S_FUS(j).x_scaled(:);
            S_FUS(j).y = S_FUS(j).y(:);
            S_FUS(j).y_scaled = S_FUS(j).y_scaled(:);
        end
    else
        for j=1:length(data.S_fus)
            S_FUS(j).x = [S_FUS(j).x;data.S_fus(j).x(:)];
            S_FUS(j).x_scaled = [S_FUS(j).x_scaled;data.S_fus(j).x_scaled(:)];
            S_FUS(j).y = [S_FUS(j).y;data.S_fus(j).y(:)];
            S_FUS(j).y_scaled = [S_FUS(j).y_scaled;data.S_fus(j).y_scaled(:)];      
        end
    end
    % Agregate S_dFUSdt
    if isempty(S_dFUSdt)
        S_dFUSdt = data.S_dfusdt;
        % reformating
        for j=1:length(S_dFUSdt)
            S_dFUSdt(j).x = S_dFUSdt(j).x(:);
            S_dFUSdt(j).x_scaled = S_dFUSdt(j).x_scaled(:);
            S_dFUSdt(j).y = S_dFUSdt(j).y(:);
            S_dFUSdt(j).y_scaled = S_dFUSdt(j).y_scaled(:);
        end
    else
        for j=1:length(data.S_dfusdt)
            S_dFUSdt(j).x = [S_dFUSdt(j).x;data.S_dfusdt(j).x(:)];
            S_dFUSdt(j).x_scaled = [S_dFUSdt(j).x_scaled;data.S_dfusdt(j).x_scaled(:)];
            S_dFUSdt(j).y = [S_dFUSdt(j).y;data.S_dfusdt(j).y(:)];
            S_dFUSdt(j).y_scaled = [S_dFUSdt(j).y_scaled;data.S_dfusdt(j).y_scaled(:)];      
        end
    end
    
    % Agregate S_CBV
    if isempty(S_CBV)
        S_CBV = struct('x',[],'y',[],'name',[],'x_scaled',[],'y_scaled',[]);
        S_CBV(length(str_channels)).x = [];
        S_CBV(indexes_out) = data.S_cbv(indexes_in);
        % reformating
        for j=1:length(S_CBV)
            S_CBV(j).x = S_CBV(j).x(:);
            S_CBV(j).x_scaled = S_CBV(j).x_scaled(:);
            S_CBV(j).y = S_CBV(j).y(:);
        end
    else
        data.S_cbv = data.S_cbv(indexes_in);
        for j=1:length(data.S_cbv)
            S_CBV(indexes_out(j)).x = [S_CBV(indexes_out(j)).x;data.S_cbv(j).x(:)];
            S_CBV(indexes_out(j)).x_scaled = [S_CBV(indexes_out(j)).x_scaled;data.S_cbv(j).x_scaled(:)];
            S_CBV(indexes_out(j)).y = [S_CBV(indexes_out(j)).y;data.S_cbv(j).y(:)];
        end
    end
    
    % Agregate S_LFP
    if isempty(S_LFP)
        S_LFP = data.S_lfp;
        % reformating
        for j=1:length(S_LFP)
            S_LFP(j).x = S_LFP(j).x(:);
            S_LFP(j).x_scaled = S_LFP(j).x_scaled(:);
            S_LFP(j).y = S_LFP(j).y(:);
            S_LFP(j).y_scaled = S_LFP(j).y_scaled(:);
        end
    else
        for j=1:length(data.S_lfp)
            S_LFP(j).x = [S_LFP(j).x;data.S_lfp(j).x(:)];
            S_LFP(j).x_scaled = [S_LFP(j).x_scaled;data.S_lfp(j).x_scaled(:)];
            S_LFP(j).y = [S_LFP(j).y;data.S_lfp(j).y(:)];
            S_LFP(j).y_scaled = [S_LFP(j).y_scaled;data.S_lfp(j).y_scaled(:)];      
        end
    end
    % Agregate S_LFP_CONT
    if isempty(S_LFP_CONT)
        S_LFP_CONT = data.S_lfp_cont;
        % reformating
        for j=1:length(S_LFP_CONT)
            S_LFP_CONT(j).x = S_LFP_CONT(j).x(:);
            S_LFP_CONT(j).x_scaled = S_LFP_CONT(j).x_scaled(:);
            S_LFP_CONT(j).y = S_LFP_CONT(j).y(:);
        end
    else
        for j=1:length(data.S_lfp_cont)
            S_LFP_CONT(j).x = [S_LFP_CONT(j).x;data.S_lfp_cont(j).x(:)];
            S_LFP_CONT(j).x_scaled = [S_LFP_CONT(j).x_scaled;data.S_lfp_cont(j).x_scaled(:)];
            S_LFP_CONT(j).y = [S_LFP_CONT(j).y;data.S_lfp_cont(j).y(:)];
        end
    end
    
    % Aggregate DATA_Y
    if isempty(DATA_Y)
        DATA_Y  = data.data_y;
        for j=1:length(data.data_y)
            DATA_Y(j).str_recordings = repmat({data.recording},[size(data.data_y(j).delta_t,1),1]);
        end        
    else
        for j=1:length(data.data_y)
            DATA_Y(j).delta_t = [DATA_Y(j).delta_t;data.data_y(j).delta_t];
            DATA_Y(j).val_peak_scaled = [DATA_Y(j).val_peak_scaled;data.data_y(j).val_peak_scaled];
            DATA_Y(j).val_peak = [DATA_Y(j).val_peak;data.data_y(j).val_peak];
            DATA_Y(j).str_recordings = [DATA_Y(j).str_recordings;repmat({data.recording},[size(data.data_y(j).delta_t,1),1])];
        end
    end
    % Agregate DATA_dYdt
    if isempty(DATA_dYdt)
        DATA_dYdt  = data.data_dydt;
        for j=1:length(data.data_y)
            DATA_dYdt(j).str_recordings = repmat({data.recording},[size(data.data_dydt(j).delta_t,1),1]);
        end
    else
        for j=1:length(data.data_dydt)
            DATA_dYdt(j).delta_t = [DATA_dYdt(j).delta_t;data.data_dydt(j).delta_t];
            DATA_dYdt(j).val_peak_scaled = [DATA_dYdt(j).val_peak_scaled;data.data_dydt(j).val_peak_scaled];
            DATA_dYdt(j).val_peak = [DATA_dYdt(j).val_peak;data.data_dydt(j).val_peak];
            DATA_dYdt(j).str_recordings = [DATA_dYdt(j).str_recordings;repmat({data.recording},[size(data.data_dydt(j).delta_t,1),1])];
        end
    end
    
    % R_Y
    R_Y(:,:,i) = data.R_y;
    R_dYdt(:,:,i) = data.R_dydt;
    % R_ALL
    R_ALL(indexes_out,:,i) = data.R_all(indexes_in,:);
    R_dALLdt(indexes_out,:,i) = data.R_dalldt(indexes_in,:);
    % R_CONT
    R_CONT(indexes_out,:,i) = data.R_cont(indexes_in,:);
    R_dCONTdt(indexes_out,:,i) = data.R_dcont(indexes_in,:);
    
    fprintf('Data loaded %s \n',filename);
end


% Keeping only selected lfp and fus channels
R_Y = R_Y(ct_sel,lt_sel,:);
R_dYdt = R_dYdt(dt_sel,lt_sel,:);
R_ALL = R_ALL(:,lt_sel,:);
R_dALLdt = R_dALLdt(:,lt_sel,:);
% Keeping only selected lfp and fus channels
DATA_Y = DATA_Y(ct_sel);
for j=1:length(DATA_Y)
    DATA_Y(j).delta_t = [DATA_Y(j).delta_t(:,1),DATA_Y(j).delta_t(:,lt_sel+1)];
    DATA_Y(j).val_peak = [DATA_Y(j).val_peak(:,1),DATA_Y(j).val_peak(:,lt_sel+1)];
    DATA_Y(j).val_peak_scaled = [DATA_Y(j).val_peak_scaled(:,1),DATA_Y(j).val_peak_scaled(:,lt_sel+1)];
end
DATA_dYdt = DATA_dYdt(dt_sel);
for j=1:length(DATA_Y)
    DATA_dYdt(j).delta_t = [DATA_dYdt(j).delta_t(:,1),DATA_dYdt(j).delta_t(:,lt_sel+1)];
    DATA_dYdt(j).val_peak = [DATA_dYdt(j).val_peak(:,1),DATA_dYdt(j).val_peak(:,lt_sel+1)];
    DATA_dYdt(j).val_peak_scaled = [DATA_dYdt(j).val_peak_scaled(:,1),DATA_dYdt(j).val_peak_scaled(:,lt_sel+1)];
end
% Keeping only selected lfp and fus channels
%S_LFP = S_LFP(lt_sel);

% Clear secondary panels
all_tabs = [handles.FirstTab;handles.SecondTab;handles.ThirdTab;handles.FourthTab;handles.FifthTab;handles.SixthTab];
ax = findobj(all_tabs,'Type','axes');
for i =1:length(ax)
    delete(ax(i).Children);
end
l = findobj(all_tabs,'Tag','Legend','-or','Type','Colorbar');
for i =1:length(l)
    delete(l(i));
end

% Reinitialize panels
initialize_panels(handles,length(str_cbv),length(str_lfp));

% FirstTab
ax = handles.Ax1;
delete(ax.Children);
hold(ax,'on');
n_bins = 10;
test_histogram = false; % true if histogram

for i=1:length(S_LFP)
    if ~test_histogram
        plot(S_LFP(i).x_scaled,S_LFP(i).y,'Tag',char(S_LFP(i).name),...
            'Marker','o','LineStyle','none','Parent',ax,'Color',g_colors(i,:));
    else
        histogram(S_LFP(i).x_scaled,n_bins,'Tag',char(S_LFP(i).name),...
            'Parent',ax,'FaceColor',g_colors(i,:));
    end
end
ax.YLabel.String = 'LFP filtered';
legend(ax,{S_LFP(:).name}','Tag','Legend');
hold(ax,'off');
%Ax2
ax = handles.Ax2;
delete(ax.Children);
hold(ax,'on');

for i=1:length(S_FUS)
    if ~test_histogram
        plot(S_FUS(i).x_scaled,S_FUS(i).y,'Tag',strcat('y',char(S_FUS(i).name)),...
            'Marker','o','LineStyle','none','Parent',ax,'Color',g_colors(i,:));
    else
        histogram(S_FUS(i).x_scaled,n_bins,'Tag',strcat('y',char(S_FUS(i).name)),...
            'Parent',ax,'FaceColor',g_colors(i,:));
    end
end
ax.YLabel.String = 'fUS Peaks';
legend(ax,{S_FUS(:).name}','Tag','Legend');
hold(ax,'off');
%Ax3
ax = handles.Ax3;
delete(ax.Children);
hold(ax,'on');
for i=1:length(S_dFUSdt)
    if ~test_histogram
        plot(S_dFUSdt(i).x_scaled,S_dFUSdt(i).y,'Tag',strcat('d',char(S_dFUSdt(i).name)),...
            'Marker','o','LineStyle','none','Parent',ax,'Color',g_colors(i,:));
    else
        histogram(S_dFUSdt(i).x_scaled,n_bins,'Tag',strcat('d',char(S_dFUSdt(i).name)),...
            'Parent',ax,'FaceColor',g_colors(i,:));
    end
end
ax.YLabel.String = 'fUS Peaks'; 
legend(ax,{S_dFUSdt(:).name}','Tag','Legend');
hold(ax,'off');


boxes = findobj(handles.MainFigure,'Tag','BoxVisible');
for i =1:length(boxes)
    boxes(i).Callback(boxes(i),[]);
end

% Change if needed
% flag_scaled = 1 uses scaled CBV values for correlation
% flag_scaled = 0 uses raw CBV % values for correlation
flag_scaled = 1;
% flag_histogram = 1 displays timing histograms
% flag_histogram = 0 displays timing bar diagram
flag_histogram = 1;
% flag_sorted = 1 sorts timing in ascending order
% flag_sorted = 0 leaves timing in occurence order
flag_sorted = 0;

% DATA_Y
r_global_y = NaN(length(str_cbv),length(str_lfp));
r_global_dydt = NaN(length(str_cbv),length(str_lfp));
for j =1:length(str_cbv)
    for i=1:length(str_lfp)
        if flag_scaled ==1
            DATA = DATA_Y(j).val_peak_scaled(:,i+1);
        else
            DATA = DATA_Y(j).val_peak(:,i+1);
        end
        
        delays = DATA_Y(j).delta_t(:,i+1);
        if flag_sorted ==1
            [~, ind_sort] = sort(DATA,'ascend');
        else
            ind_sort = 1:length(DATA);
        end
        % test if more than two dots
        t = length(DATA);
        s = sum(isnan(DATA));
        if (t-s)<2
            continue;
        end
        
        ax = findobj(handles.FirstTab,'Tag',sprintf('Ax%d-%d',j,i));
        marker_size = 1; 
        if flag_scaled ==1
            plot(DATA,DATA_Y(j).val_peak_scaled(:,1),'o','Color',g_colors(i,:),'Parent',ax,'MarkerSize',marker_size);
            r = corr(DATA_Y(j).val_peak_scaled(:,1),DATA,'rows','complete');
        else
            plot(DATA,DATA_Y(j).val_peak(:,1),'o','Color',g_colors(i,:),'Parent',ax,'MarkerSize',marker_size);
            r = corr(DATA_Y(j).val_peak(:,1),DATA,'rows','complete');
        end
        r_global_y(j,i)=r;
        ax.Tag = sprintf('Ax%d-%d',j,i);
        ax.XLim = [min(DATA)-1e-4,max(DATA)+1e-4];
        ax.YLim = [min(DATA_Y(j).val_peak_scaled(:,1))-1e-4,max(DATA_Y(j).val_peak_scaled(:,1))+1e-4];
        
        ax.XLabel.String = char(str_lfp(i));
        ax.YLabel.String = char(str_cbv(j));
        ax.Title.String = sprintf('r = %.2f (%d/%d)',r,t-s,t);
        lsline(ax);
        
        ax = findobj(handles.SecondTab,'Tag',sprintf('Ax%d-%d',j,i));
        m = mean(delays,'omitnan');
        if flag_histogram ==0
            barh(delays(ind_sort),'EdgeColor','none','FaceColor',g_colors(i,:),'Parent',ax);
            ax.YLim = [.5 length(delays)+.5];
            ax.XLim = [data.thresh_inf data.thresh_sup];
        else
            h = histogram(delays(ind_sort),'BinEdges',data.thresh_inf:(data.thresh_sup-data.thresh_inf)/30:data.thresh_sup,...
                'FaceAlpha',.5,'FaceColor',g_colors(i,:),'Parent',ax);
            ax.XLim = [data.thresh_inf data.thresh_sup]; 
            ax.YLim = [0,max(h.BinCounts)+.5];
        end
        ax.Tag = sprintf('Ax%d-%d',j,i);
        
        ax.XLabel.String = char(str_lfp(i));
        ax.YLabel.String = char(str_cbv(j));
        ax.Title.String = sprintf('m = %.2f (%d/%d)',m,t-s,t);     
    end
end

% DATA_dYdt
for j =1:length(str_cbv)
    for i=1:length(str_lfp)
        if flag_scaled ==1
            DATA = DATA_dYdt(j).val_peak_scaled(:,i+1);
        else
            DATA = DATA_dYdt(j).val_peak(:,i+1);
        end
        delays = DATA_dYdt(j).delta_t(:,i+1);
        if flag_sorted ==1
            [~, ind_sort] = sort(DATA,'ascend');
        else
            ind_sort = 1:length(DATA);
        end
        % test if more than two dots
        t = length(DATA);
        s = sum(isnan(DATA));
        if (t-s)<2
            continue;
        end
        
        ax = findobj(handles.ThirdTab,'Tag',sprintf('Ax%d-%d',j,i));
        if flag_scaled ==1
            plot(DATA,DATA_dYdt(j).val_peak_scaled(:,1),'o','Color',g_colors(i,:),'Parent',ax);
            r = corr(DATA_dYdt(j).val_peak_scaled(:,1),DATA,'rows','complete');
        else
            plot(DATA,DATA_dYdt(j).val_peak(:,1),'o','Color',g_colors(i,:),'Parent',ax);
            r = corr(DATA_dYdt(j).val_peak(:,1),DATA,'rows','complete');
        end
        r_global_dydt(j,i)=r;
        ax.Tag = sprintf('Ax%d-%d',j,i);
        ax.XLim = [min(DATA)-1e-4,max(DATA)+1e-4];
        ax.YLim = [min(DATA_dYdt(j).val_peak_scaled(:,1))-1e-4,max(DATA_dYdt(j).val_peak_scaled(:,1))+1e-4];
        ax.XLabel.String = char(str_lfp(i));
        ax.YLabel.String = char(str_cbv(j));
        ax.Title.String = sprintf('r = %.2f (%d/%d)',r,t-s,t);
        lsline(ax);
        
        ax = findobj(handles.FourthTab,'Tag',sprintf('Ax%d-%d',j,i));
        m = mean(delays,'omitnan');
        if flag_histogram ==0
            barh(delays(ind_sort),'EdgeColor','none','FaceColor',g_colors(i,:),'Parent',ax);
            ax.YLim = [.5 length(delays)+.5];
            ax.XLim = [data.thresh_inf data.thresh_sup];
        else
            h = histogram(delays(ind_sort),'BinEdges',data.thresh_inf:(data.thresh_sup-data.thresh_inf)/40:data.thresh_sup,...
                'FaceAlpha',.5,'FaceColor',g_colors(i,:),'Parent',ax);
            ax.XLim = [data.thresh_inf data.thresh_sup]; 
            ax.YLim = [0,max(h.BinCounts)+.5];
        end
        ax.Tag = sprintf('Ax%d-%d',j,i);
        ax.XLabel.String = char(str_lfp(i));
        ax.YLabel.String = char(str_cbv(j));
        ax.Title.String = sprintf('m = %.2f (%d/%d)',m,t-s,t);     
    end
end

%R_all
R_y = mean(R_Y,3,'omitnan');
R_dydt = mean(R_dYdt,3,'omitnan');
R_all = mean(R_ALL,3,'omitnan');
R_dalldt = mean(R_dALLdt,3,'omitnan');
R_cont = mean(R_CONT,3,'omitnan');
R_dcontdt = mean(R_dCONTdt,3,'omitnan');

ax4 = handles.Ax4;
imagesc(R_y,'Parent',ax4);
ax4.YTick = 1:size(R_y,1);
ax4.YTickLabel = str_cbv;
ax4.XTick = 1:size(R_y,2);
ax4.XTickLabel = str_lfp;
ax4.XTickLabelRotation = 90;
ax4.Title.String = 'Synthesis CBV';
ax4.Tag = 'Ax4';
ax4.CLim = [0,1];
colorbar(ax4);

ax5 = handles.Ax5;
imagesc(R_dydt,'Parent',ax5);
ax5.YTick = 1:size(R_dydt,1);
ax5.YTickLabel = str_dcbvdt;
ax5.XTick = 1:size(R_dydt,2);
ax5.XTickLabel = str_lfp;
ax5.XTickLabelRotation = 90;
ax5.Title.String = 'Synthesis dCBV/dt';
ax5.Tag = 'Ax5';
ax5.CLim = [0,1];
colorbar(ax5);

ax6 = handles.Ax6;
imagesc(R_all,'Parent',ax6);
ax6.YTick = 1:size(R_all,1);
ax6.YTickLabel = str_channels;
ax6.XTick = 1:size(R_all,2);
ax6.XTickLabel = str_lfp;
ax6.XTickLabelRotation = 90;
ax6.Title.String = 'All CBV';
ax6.Tag = 'Ax6';
ax6.CLim = [0,1];
colorbar(ax6);

ax7 = handles.Ax7;
imagesc(R_dalldt,'Parent',ax7);
ax7.YTick = 1:size(R_dalldt,1);
ax7.YTickLabel = str_channels;
ax7.XTick = 1:size(R_dalldt,2);
ax7.XTickLabel = str_lfp;
ax7.XTickLabelRotation = 90;
ax7.Title.String = 'All dCBVdt';
ax7.Tag = 'Ax7';
ax7.CLim = [0,1];
colorbar(ax7);

% Displaying Spectrogram
ind_sub = 20; %Sub_sampling for f_cont 
ax = handles.Ax8;
ax.XLim = [0,1];
ax.YLim = [.5,length(data.freqdom)+.5];
ax.YDir = 'normal';
ax.YTick = 1:ind_sub:length(data.label_lfp_cont);
ax.YTickLabel = data.label_lfp_cont(1:ind_sub:end);%data.label_lfp_cont;
ax.Tag = 'Ax8';
hold(ax,'on');
for i =1:length(S_LFP_CONT)
    plot(S_LFP_CONT(i).x_scaled,i*ones(size(S_LFP_CONT(i).x_scaled)),...
        'Color','k','LineStyle','none','Marker','.','MarkerSize',markersize,'Parent',ax);
end
hold(ax,'off');

% Displaying CBV traces
ax = handles.Ax9;
ax.XLim = [0,1];
ax.YLim = [.5,length(str_channels)+.5];
ax.YDir = 'normal';
ax.YTick = 1:length(str_channels);
ax.YTickLabel = str_channels;
ax.Tag = 'Ax9';
hold(ax,'on');
for i =1:length(S_CBV)
    plot(S_CBV(i).x_scaled,i*ones(size(S_CBV(i).x_scaled)),...
        'Color','k','LineStyle','none','Marker','.','MarkerSize',markersize,'Parent',ax);
end
hold(ax,'off');

% Displaying Continuous
ax = handles.Ax10;
imagesc(R_cont,'Parent',ax);
ax.XTick = 1:ind_sub:length(data.label_lfp_cont);
ax.XTickLabel = data.label_lfp_cont(1:ind_sub:end);
ax.YTick = 1:size(R_cont,1);
ax.YTickLabel = str_channels;
ax.Title.String = 'Correlogram LFP - CBV';
ax.Tag = 'Ax10';
ax.CLim = [0,.8];
colorbar(ax);

ax = handles.Ax11;
imagesc(R_dcontdt,'Parent',ax);
ax.XTick = 1:ind_sub:length(data.label_lfp_cont);
ax.XTickLabel = data.label_lfp_cont(1:ind_sub:end);
ax.YTick = 1:size(R_dcontdt,1);
ax.YTickLabel = str_channels;
ax.Title.String = 'Correlogram LFP - dCBVdt';
ax.Tag = 'Ax11';
ax.CLim = [-1,1];
colorbar(ax);
%fprintf(' done\n');


% Writing data out
% Removing folder
folder = fullfile(handles.MainFigure.UserData.folder,'Data');
if ~exist(folder,'dir')
    mkdir(folder);
else
    rmdir(folder,'s');
    mkdir(folder);
end
% Statistics Separate files
for i = 1:length(DATA_Y)
    %T = table(var1,...,varN)
    temp = DATA_Y(i);
    filename_out = fullfile(folder,sprintf('DATA-Y_%s.txt',char(temp.name)));
    fid = fopen(filename_out,'w');
    fwrite(fid,sprintf('Recording \t Timing \t '));
    fwrite(fid,sprintf('%s \t ', str_lfp{:}));
    fwrite(fid,sprintf('\t Raster \t '));
    fwrite(fid,sprintf('%s \t ', str_lfp{:}));
    fwrite(fid,sprintf('\t Raster_scaled \t '));
    fwrite(fid,sprintf('%s \t ', str_lfp{:}));
    fwrite(fid,newline);
    for k = 1: size(temp.str_recordings,1)
        fwrite(fid,sprintf('%s \t ', char(temp.str_recordings(k,:))));
        fwrite(fid,sprintf('%.3f \t ', temp.delta_t(k,:)));
        fwrite(fid,sprintf('\t '));
        fwrite(fid,sprintf('%.3f \t ', temp.val_peak(k,:)));
        fwrite(fid,sprintf('\t '));
        fwrite(fid,sprintf('%.3f \t ', temp.val_peak_scaled(k,:)));
        fwrite(fid,newline);
    end  
    fclose(fid);
    fprintf('Data saved in file %s\n',filename_out);
end
for i = 1:length(DATA_dYdt)
    temp = DATA_dYdt(i);
    filename_out = fullfile(folder,sprintf('DATA-dYdt_%s.txt',char(temp.name)));
    fid = fopen(filename_out,'w');
    fwrite(fid,sprintf('Recording \t Timing \t '));
    fwrite(fid,sprintf('%s \t ', str_lfp{:}));
    fwrite(fid,sprintf('Raster \t '));
    fwrite(fid,sprintf('%s \t ', str_lfp{:}));
    fwrite(fid,sprintf('Raster_scaled \t '));
    fwrite(fid,sprintf('%s \t ', str_lfp{:}));
    fwrite(fid,newline);
    for k = 1: size(temp.str_recordings,1)
        fwrite(fid,sprintf('%s \t ', char(temp.str_recordings(k,:))));
        fwrite(fid,sprintf('%.3f \t ', temp.delta_t(k,:)));
        fwrite(fid,sprintf('%.3f \t ', temp.val_peak(k,:)));
        fwrite(fid,sprintf('%.3f \t ', temp.val_peak_scaled(k,:)));
        fwrite(fid,newline);
    end  
    fclose(fid);
    fprintf('Data saved in file %s\n',filename_out);
end
% Correlation Separate files
%R_Y
filename_out = fullfile(folder,'Correlation_R-Y.txt');
fid = fopen(filename_out,'w');
for l = 1: size(R_Y,1)
    fwrite(fid,sprintf('%s \t ', char(str_cbv(l,:))));
    fwrite(fid,sprintf('%s \t ',str_lfp{:}));
    fwrite(fid,newline);
    for k = 1:size(R_Y,3)
        fwrite(fid,sprintf('%s \t ', char(str_files(k,:))));
        fwrite(fid,sprintf('%.3f \t ', R_Y(l,:,k)));
        fwrite(fid,newline);
    end
    fwrite(fid,newline);
end
fclose(fid);
fprintf('Data saved in file %s\n',filename_out);
%R_dYdt
filename_out = fullfile(folder,'Correlation_R-dYdt.txt');
fid = fopen(filename_out,'w');
for l = 1: size(R_dYdt,1)
    fwrite(fid,sprintf('%s \t ', char(str_cbv(l,:))));
    fwrite(fid,sprintf('%s \t ',str_lfp{:}));
    fwrite(fid,newline);
    for k = 1:size(R_dYdt,3)
        fwrite(fid,sprintf('%s \t ', char(str_files(k,:))));
        fwrite(fid,sprintf('%.3f \t ', R_dYdt(l,:,k)));
        fwrite(fid,newline);
    end
    fwrite(fid,newline);
end
fclose(fid);
fprintf('Data saved in file %s\n',filename_out);
%R_ALL
filename_out = fullfile(folder,'Correlation_R-ALL.txt');
fid = fopen(filename_out,'w');
for l = 1: size(R_ALL,1)
    fwrite(fid,sprintf('%s \t ', char(str_channels(l,:))));
    fwrite(fid,sprintf('%s \t ',str_lfp{:}));
    fwrite(fid,newline);
    for k = 1:size(R_ALL,3)
        fwrite(fid,sprintf('%s \t ', char(str_files(k,:))));
        fwrite(fid,sprintf('%.3f \t ', R_ALL(l,:,k)));
        fwrite(fid,newline);
    end
    fwrite(fid,newline);
end
fclose(fid);
fprintf('Data saved in file %s\n',filename_out);
%R_dALLdt
filename_out = fullfile(folder,'Correlation_R-dALLdt.txt');
fid = fopen(filename_out,'w');
for l = 1: size(R_dALLdt,1)
    fwrite(fid,sprintf('%s \t ', char(str_channels(l,:))));
    fwrite(fid,sprintf('%s \t ',str_lfp{:}));
    fwrite(fid,newline);
    for k = 1:size(R_dALLdt,3)
        fwrite(fid,sprintf('%s \t ', char(str_files(k,:))));
        fwrite(fid,sprintf('%.3f \t ', R_dALLdt(l,:,k)));
        fwrite(fid,newline);
    end
    fwrite(fid,newline);
end
fclose(fid);
fprintf('Data saved in file %s\n',filename_out);
%R_CONT
filename_out = fullfile(folder,'Correlation_R-CONT.txt');
fid = fopen(filename_out,'w');
for l = 1: size(R_CONT,1)
    fwrite(fid,sprintf('%s \t ', char(str_channels(l,:))));
    fwrite(fid,sprintf('%3.1f \t ',data.freqdom));
    fwrite(fid,newline);
    for k = 1:size(R_CONT,3)
        fwrite(fid,sprintf('%s \t ', char(str_files(k,:))));
        fwrite(fid,sprintf('%.3f \t ', R_CONT(l,:,k)));
        fwrite(fid,newline);
    end
    fwrite(fid,newline);
end
fclose(fid);
fprintf('Data saved in file %s\n',filename_out);
%R_dCONTdt
filename_out = fullfile(folder,'Correlation_R-dCONTdt.txt');
fid = fopen(filename_out,'w');
for l = 1: size(R_dCONTdt,1)
    fwrite(fid,sprintf('%s \t ', char(str_channels(l,:))));
    fwrite(fid,sprintf('%3.1f \t ',data.freqdom));
    fwrite(fid,newline);
    for k = 1:size(R_dCONTdt,3)
        fwrite(fid,sprintf('%s \t ', char(str_files(k,:))));
        fwrite(fid,sprintf('%.3f \t ', R_dCONTdt(l,:,k)));
        fwrite(fid,newline);
    end
    fwrite(fid,newline);
end
fclose(fid);
fprintf('Data saved in file %s\n',filename_out);


% Synthesis Y
filename_synt = fullfile(folder,'Synthesis_y.txt');
fid2 = fopen(filename_synt,'w');
% Regression
fwrite(fid2,sprintf('REGRESSION \n'));
fwrite(fid2,sprintf('Region \t'));
fwrite(fid2,sprintf('%s \t ', str_lfp{:}));
fwrite(fid2,newline);
for i = 1:size(r_global_y,1)
    fwrite(fid2,sprintf('%s \t',char(str_cbv(i))));
    fwrite(fid2,sprintf('%.3f \t ',r_global_y(i,:)));
    fwrite(fid2,newline);
end
% Timing
fwrite(fid2,newline);
fwrite(fid2,sprintf('TIMING \n'));
fwrite(fid2,sprintf('Region \t'));
fwrite(fid2,sprintf('%s \t ', str_lfp{:}));
fwrite(fid2,sprintf('sem \t'));
fwrite(fid2,sprintf('%s \t ', str_lfp{:}));
fwrite(fid2,newline);
for i = 1:length(DATA_Y)
    temp = DATA_Y(i);
    fwrite(fid2,sprintf('%s \t',char(temp.name)));
    fwrite(fid2,sprintf('%.3f \t ',mean(temp.delta_t(:,2:end),'omitnan')));
    fwrite(fid2,sprintf('\t'));
    fwrite(fid2,sprintf('%.3f \t ',std(temp.delta_t(:,2:end),[],'omitnan')./sum(~isnan(temp.delta_t(:,2:end)))));
    fwrite(fid2,newline);
end
% Ratio
fwrite(fid2,newline);
fwrite(fid2,sprintf('RATIO \n'));
fwrite(fid2,sprintf('Region \t'));
fwrite(fid2,sprintf('%s \t ', str_lfp{:}));
fwrite(fid2,sprintf('Total \t'));
fwrite(fid2,newline);
for i = 1:length(DATA_Y)
    temp = DATA_Y(i);
    fwrite(fid2,sprintf('%s \t',char(temp.name)));
    fwrite(fid2,sprintf('%3d \t ',sum(~isnan(temp.delta_t(:,2:end)))));
    %fwrite(fid2,sprintf('\t '));
    fwrite(fid2,sprintf('%3d \t',size(temp.delta_t,1)));
    fwrite(fid2,newline);
end
% Correlation matrix
fwrite(fid2,newline);
fwrite(fid2,sprintf('CORRELATION\n'));
fwrite(fid2,sprintf('R-Y \t '));
fwrite(fid2,sprintf('%s \t ',str_lfp{:}));
fwrite(fid2,newline);
for i = 1:size(R_y,1)
    fwrite(fid2,sprintf('%s \t ', char(str_cbv(i,:))));
    fwrite(fid2,sprintf('%.3f \t ', R_y(i,:)));
    fwrite(fid2,newline);
end
fwrite(fid2,newline);
fwrite(fid2,sprintf('R-ALL \t '));
fwrite(fid2,sprintf('%s \t ',str_lfp{:}));
fwrite(fid2,newline);
for i = 1:size(R_all,1)
    fwrite(fid2,sprintf('%s \t ', char(str_channels(i,:))));
    fwrite(fid2,sprintf('%.3f \t ', R_all(i,:)));
    fwrite(fid2,newline);
end
fwrite(fid2,newline);
fwrite(fid2,sprintf('R-CONT\t'));
fwrite(fid,sprintf('%3.1f \t ',data.freqdom));
fwrite(fid2,newline);
for i = 1:size(R_cont,1)
    fwrite(fid2,sprintf('%s \t ', char(str_channels(i,:))));
    fwrite(fid2,sprintf('%.3f \t ', R_cont(i,:)));
    fwrite(fid2,newline);
end
fprintf('Data saved in file %s\n',filename_synt);    
fclose(fid2);

% Synthesis Y
filename_synt = fullfile(folder,'Synthesis_dydt.txt');
fid3 = fopen(filename_synt,'w');
% Regression
fwrite(fid3,sprintf('REGRESSION \n'));
fwrite(fid3,sprintf('Region \t'));
fwrite(fid3,sprintf('%s \t ', str_lfp{:}));
fwrite(fid3,newline);
for i = 1:size(r_global_dydt,1)
    fwrite(fid3,sprintf('%s \t',char(str_cbv(i))));
    fwrite(fid3,sprintf('%.3f \t ',r_global_dydt(i,:)));
    fwrite(fid3,newline);
end
% Timing
fwrite(fid3,newline);
fwrite(fid3,sprintf('TIMING \n'));
fwrite(fid3,sprintf('Region \t'));
fwrite(fid3,sprintf('%s \t ', str_lfp{:}));
fwrite(fid3,newline);
for i = 1:length(DATA_dYdt)
    temp = DATA_dYdt(i);
    fwrite(fid3,sprintf('%s \t',char(temp.name)));
    fwrite(fid3,sprintf('%.3f \t ',mean(temp.delta_t(:,2:end),'omitnan')));
    fwrite(fid3,newline);
end
% Ratio
fwrite(fid3,newline);
fwrite(fid3,sprintf('RATIO \n'));
fwrite(fid3,sprintf('Region \t'));
fwrite(fid3,sprintf('%s \t ', str_lfp{:}));
fwrite(fid3,sprintf('Total \t'));
fwrite(fid3,newline);
for i = 1:length(DATA_dYdt)
    temp = DATA_dYdt(i);
    fwrite(fid3,sprintf('%s \t',char(temp.name)));
    fwrite(fid3,sprintf('%3d \t ',sum(~isnan(temp.delta_t(:,2:end)))));
    %fwrite(fid3,sprintf('\t '));
    fwrite(fid3,sprintf('%3d \t',size(temp.delta_t,1)));
    fwrite(fid3,newline);
end
% Correlation matrix
fwrite(fid3,newline);
fwrite(fid3,sprintf('CORRELATION\n'));
fwrite(fid3,sprintf('R-dYdt \t '));
fwrite(fid3,sprintf('%s \t ',str_lfp{:}));
fwrite(fid3,newline);
for i = 1:size(R_dydt,1)
    fwrite(fid3,sprintf('%s \t ', char(str_cbv(i,:))));
    fwrite(fid3,sprintf('%.3f \t ', R_dydt(i,:)));
    fwrite(fid3,newline);
end
fwrite(fid3,newline);
fwrite(fid3,sprintf('R-dALLdt \t '));
fwrite(fid3,sprintf('%s \t ',str_lfp{:}));
fwrite(fid3,newline);
for i = 1:size(R_dalldt,1)
    fwrite(fid3,sprintf('%s \t ', char(str_channels(i,:))));
    fwrite(fid3,sprintf('%.3f \t ', R_dalldt(i,:)));
    fwrite(fid3,newline);
end
fwrite(fid3,newline);
fwrite(fid3,sprintf('R-dCONTdt\t'));
fwrite(fid,sprintf('%3.1f \t ',data.freqdom));
fwrite(fid3,newline);
for i = 1:size(R_dcontdt,1)
    fwrite(fid3,sprintf('%s \t ', char(str_channels(i,:))));
    fwrite(fid3,sprintf('%.3f \t ', R_dcontdt(i,:)));
    fwrite(fid3,newline);
end
fprintf('Data saved in file %s\n',filename_synt);    
fclose(fid3);


% Timings Separate files
ind_ref = contains({DATA_Y(:).name}','thal');
ref = DATA_Y(ind_ref);
str_recordings_all = [];
timing_all = [];
timing_diff_all = [];
delta_t_all = [];
        
for i = 1:size(ref.delta_t,1)
    recording = ref.str_recordings(i);
    timing = ref.delta_t(i,1);
    delta_t = ref.delta_t(i,2:end);
    
    %Finding timings;
    timing_diff = NaN(1,length(DATA_Y));
    for j =1:length(DATA_Y)
        ind_rec = contains(DATA_Y(j).str_recordings,recording);
        all_t = DATA_Y(j).delta_t(ind_rec,1);
        [~,index] = min(abs(all_t-timing));
        val = all_t(index)-timing;  
        if abs(val)<=2
            timing_diff(j) = val;
        end
    end
     
    if sum(isnan(timing_diff))==0
        str_recordings_all = [str_recordings_all; recording];
        timing_all = [timing_all; timing];
        timing_diff_all = [timing_diff_all; timing_diff];
        delta_t_all = [delta_t_all; -delta_t];
    end
end

% Reformating
offset = delta_t_all(:,4);
ind_keep = ~isnan(offset);
timing_diff_all = timing_diff_all-repmat(offset,[1,length(str_cbv)]);
delta_t_all = delta_t_all-repmat(offset,[1,length(str_lfp)]);
str_recordings_all = str_recordings_all(ind_keep);
timing_all = timing_all(ind_keep,:);
timing_diff_all = timing_diff_all(ind_keep,:);
delta_t_all = delta_t_all(ind_keep,:);

%writing to file
N = size(str_recordings_all,1);
filename_out = fullfile(folder,'Timing.txt');
fid4 = fopen(filename_out,'w');
fwrite(fid,sprintf('Recording \t Timing \t '));
fwrite(fid,sprintf('%s \t ', str_cbv{:}));
fwrite(fid,sprintf('%s \t ', str_lfp{:}));
fwrite(fid,newline);
for k = 1:N
    fwrite(fid,sprintf('%s \t ', char(str_recordings_all(k,:))));
    fwrite(fid,sprintf('%.3f \t ', timing_all(k,:)));
    %fwrite(fid,sprintf('\t '));
    fwrite(fid,sprintf('%.3f \t ', timing_diff_all(k,:)));
    %fwrite(fid,sprintf('\t '));
    fwrite(fid,sprintf('%.3f \t ', delta_t_all(k,:)));
    fwrite(fid,newline);
end
fwrite(fid,sprintf('%s \t ', 'Mean'));
fwrite(fid,sprintf('\t '));
fwrite(fid,sprintf('%.3f \t ', mean(timing_diff_all,'omitnan')));
fwrite(fid,sprintf('%.3f \t ', mean(delta_t_all,'omitnan')));
fwrite(fid,newline);
fwrite(fid,sprintf('%s \t ', 'St-dev'));
fwrite(fid,sprintf('\t '));
fwrite(fid,sprintf('%.3f \t ', std(timing_diff_all,[],'omitnan')));
fwrite(fid,sprintf('%.3f \t ', std(delta_t_all,[],'omitnan')));
fwrite(fid,newline);
fwrite(fid,sprintf('%s \t ', 'Z-score'));
fwrite(fid,sprintf('\t '));
fwrite(fid,sprintf('%.3f \t ', mean(timing_diff_all,'omitnan')./sqrt(std(timing_diff_all,[],'omitnan').^2/N)));
fwrite(fid,sprintf('%.3f \t ', mean(delta_t_all,'omitnan')./sqrt(std(delta_t_all,[],'omitnan').^2/N)));
fclose(fid4);
fprintf('Data saved in file %s\n',filename_out);


handles.MainFigure.Pointer = 'arrow';
handles.MainFigure.UserData.success = true;
toc;

end

function initialize_panels(handles,x,y)

tab1 = handles.FirstTab;
tab2 = handles.SecondTab;
tab3 = handles.ThirdTab;
tab4 = handles.FourthTab;
all_tabs = [tab1;tab2;tab3;tab4];
for i =1:length(all_tabs)
    delete(all_tabs(i).Children);
end

%Raster
ax_1 = gobjects(y,x);
for ind = 1:x*y
    i = mod(ind-1,x)+1;
    j = ceil(ind/x);
    ax_1(j,i) = subplot(y,x,ind,'Parent',tab1,'Tag',sprintf('Ax%d-%d',i,j));
    ax_1(j,i).Title.String = sprintf('Ax%d-%d',i,j);
end

%Timing
ax_2 = gobjects(y,x);
for ind = 1:x*y
    i = ceil(ind/x);
    j = mod(ind-1,x)+1;
    ax_2(i,j) = subplot(y,x,ind,'Parent',tab2,'Tag',sprintf('Ax%d-%d',j,i));
    ax_2(i,j).Title.String = sprintf('Ax%d-%d',j,i);
end

%Raster
ax_1 = gobjects(x,y);
for ind = 1:x*y
    i = ceil(ind/y);
    j = mod(ind-1,y)+1;
    ax_1(i,j) = subplot(x,y,ind,'Parent',tab3,'Tag',sprintf('Ax%d-%d',i,j));
    ax_1(i,j).Title.String = sprintf('Ax%d-%d',i,j);
end

%Timing
ax_2 = gobjects(x,y);
for ind = 1:x*y
    i = ceil(ind/y);
    j = mod(ind-1,y)+1;
    ax_2(i,j) = subplot(x,y,ind,'Parent',tab4,'Tag',sprintf('Ax%d-%d',i,j));
    ax_2(i,j).Title.String = sprintf('Ax%d-%d',i,j);
end

end