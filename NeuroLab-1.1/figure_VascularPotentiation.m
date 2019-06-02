function f = figure_VascularPotentiation(handles,val,str_group)
% (Figure) Displays vascular potentiation based on linear regression

global DIR_SAVE FILES CUR_FILE START_IM END_IM IM;
start_im = START_IM;
end_im = END_IM;
margin_w = .02;
margin_h = .05;

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

f = figure('Units','normalized',...
    'HandleVisibility','callback',...
    'IntegerHandle','off',...
    'Renderer','painters',...
    'Toolbar','figure',...
    'NumberTitle','off',...
    'Tag','MainFigure',...
    'PaperPositionMode','auto',...
    'Name','Peri Event Histogramm');

% Storing Time Data
f.UserData.IM = IM;
f.UserData.old_handles = handles;
f.UserData.TimeTags_cell = TimeTags_cell;
f.UserData.TimeTags_images = TimeTags_images;
f.UserData.TimeTags_strings = TimeTags_strings;
f.UserData.time_ref = time_ref;
f.UserData.n_burst = n_burst;
f.UserData.length_burst = length_burst;
% Colormaps
colormap(f,'hot');
clrmenu(f);

% Information Panel
iP = uipanel('FontSize',12,...
    'Units','normalized',...
    'Tag','InfoPanel',...
    'Position',[0 0 1 .15],...
    'Parent',f);

% Texts and Edits
t1 = uicontrol('Units','normalized','Style','text','HorizontalAlignment','left','Parent',iP,...
    'String',sprintf('File : %s',FILES(CUR_FILE).nlab),'Tag','Text1');
t2 = uicontrol('Units','normalized','Style','text','HorizontalAlignment','left','Parent',iP,...
    'String',sprintf(handles.CenterPanelPopup.String(handles.CenterPanelPopup.Value,:)),...
    'Tag','Text2');
e1 = uicontrol('Units','normalized','Style','edit','HorizontalAlignment','center','Parent',iP,...
    'String',start_im,'Tag','Edit1','Tooltipstring','Start Image');
e2 = uicontrol('Units','normalized','Style','edit','HorizontalAlignment','center','Parent',iP,...
    'String',end_im,'Tag','Edit2','Tooltipstring','End Image');
e3 = uicontrol('Units','normalized','Style','edit','HorizontalAlignment','center','Parent',iP,...
    'String',margin_w,'Tag','Edit3','Tooltipstring','margin_w');
e4 = uicontrol('Units','normalized','Style','edit','HorizontalAlignment','center','Parent',iP,...
    'String',margin_h,'Tag','Edit4','Tooltipstring','margin_h');

% Buttons 
br = uicontrol('Units','normalized','Style','pushbutton','Parent',iP,...
    'String','Reset','Tag','ButtonReset');
bc = uicontrol('Units','normalized','Style','pushbutton','Parent',iP,...
    'String','Compute','Tag','ButtonCompute');
bsi = uicontrol('Units','normalized','Style','pushbutton','Parent',iP,...
    'String','Save Image','Tag','ButtonSaveImage');
bss = uicontrol('Units','normalized','Style','pushbutton','Parent',iP,...
    'String','Save Stats','Tag','ButtonSaveStats');
bb = uicontrol('Units','normalized','Style','pushbutton','Parent',iP,...
    'String','Batch','Tag','ButtonBatch');
bb.UserData.fUSData = [];
bb.UserData.LFPData = [];
bb.UserData.CFCData = [];

% position
t1.Position = [0     .4    .25   .5];
t2.Position = [0     -.1    .25   .5];
e1.Position = [.25     .5    .05   .5];
e2.Position = [.25     0    .05   .5];
e3.Position = [.35     .5    .05   .5];
e4.Position = [.35     0    .05   .5];
bc.Position = [7/10     .5      .1   .5];
br.Position = [7/10     0      .1   .5];
bss.Position = [8/10     .5      .1   .5];
bsi.Position = [8/10     0      .1   .5];
bb.Position = [9/10     .5      .1   .5];

% Creating uitabgroup
mP = uipanel('FontSize',12,...
    'Units','normalized',...
    'Position',[0 iP.Position(4) 1 1-iP.Position(4)],...
    'Parent',f);
tabgp = uitabgroup('Units','normalized',...
    'Position',[0 0 1 1],...
    'Parent',mP,...
    'Tag','TabGroup');
%Trace Tab
tab0 = uitab('Parent',tabgp,...
    'Title','Traces & Episodes',...
    'Tag','TraceTab');

tracePanel = uipanel('Parent',tab0,...
    'Units','normalized',...
    'Position',[0 0 .5 1],...
    'Title','Traces',...
    'Tag','TracePanel');
groupPanel = uipanel('Parent',tab0,...
    'Units','normalized',...
    'Position',[.5 0 .5 1],...
    'Title','Time Groups',...
    'Tag','GroupPanel');

% Lines Array
ax_dummy = axes('Parent',tab0,'Visible','off');
m = findobj(handles.RightAxes,'Tag','Trace_Mean');
l = flipud(findobj(handles.RightAxes,'Type','line','-not','Tag','Cursor','-not','Tag','Trace_Cerep','-not','Tag','Trace_Mean'));
t = flipud(findobj(handles.RightAxes,'Tag','Trace_Cerep'));
lines = copyobj([m;l;t],ax_dummy);
%bc.UserData.lines = lines;

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

% Potentiation Tab
uitab('Parent',tabgp,...
    'Title','Potentiation',...
    'Tag','PotentiationTab');

handles2 = guihandles(f);
reset_Callback([],[],handles2);
f.Position = [0.12    0.2    0.75    0.5];
tabgp.SelectedTab = tab0;

% If nargin > 3 batch processing
% val indicates callback provenance (0 : batch mode - 1 : user mode)
% str_group contains group names
if val==0
    batchsave_Callback([],[],handles2,str_group);
end

end

function reset_Callback(~,~,handles2)

handles = guihandles(handles2.MainFigure);
handles.ButtonReset.Callback = {@reset_Callback,handles};
handles.ButtonCompute.Callback = {@compute_Callback,handles};
handles.ButtonSaveImage.Callback = {@saveimage_Callback,handles};
handles.ButtonSaveStats.Callback = {@savestats_Callback,handles};
handles.ButtonBatch.Callback = {@batchsave_Callback,handles};

end

function compute_Callback(~,~,handles)

tab0 = handles.PotentiationTab;
f = handles.MainFigure;
margin_w = str2double(handles.Edit3.String);
margin_h = str2double(handles.Edit4.String);
IM = f.UserData.IM;

% Pointer Watch
set(handles.MainFigure, 'pointer', 'watch');
drawnow;
handles.MainFigure.UserData.success = false;

delete(tab0.Children);

% Select Time indices
selection = handles.Group_table.UserData.Selection;
if isempty(selection)
    start_im = str2double(handles.Edit1.String);
    end_im = str2double(handles.Edit2.String);
    Time_indices = (handles.MainFigure.UserData.time_ref.X>=start_im).*(handles.MainFigure.UserData.time_ref.X<=end_im);
    str_title = sprintf('CURRENT[%d-%d]',start_im,end_im);
else
    selection = selection(1);
    TimeTags_images = handles.Group_table.UserData.TimeGroups_S(selection).TimeTags_images;
    Time_indices = zeros(size(handles.MainFigure.UserData.time_ref.X));
    for i =1:size(TimeTags_images,1)
        im1 = TimeTags_images(i,1);
        im2 = TimeTags_images(i,2);
        ind_keep = (handles.MainFigure.UserData.time_ref.X>=im1).*(handles.MainFigure.UserData.time_ref.X<=im2);
        Time_indices(ind_keep==1)=1;
    end
    str_title = sprintf('TimeGroup-%s',char(handles.Group_table.UserData.TimeGroups_name(selection)));
end

%X = (1:end_im-start_im+1)';
X = (1:length(find(Time_indices==1)))';
n = 1;
P1 = NaN(size(IM(:,:,1)));
P2 = NaN(size(IM(:,:,1)));
h = waitbar(0,'Please wait');

for i =1:size(IM,1)
    for j =1:size(IM,2)
        Y = squeeze(IM(i,j,Time_indices==1));
        P = polyfit(X,Y,n);
        P1(i,j) = P(1);
        P2(i,j) = P(2);
    end
    x=i/size(IM,1);
    waitbar(x,h,sprintf('%.1f %% completed',100*x));

end
close(h);

ax1 = axes('Parent',tab0);
imagesc(P2,'parent',ax1);
%title(sprintf('offset (%d-%d)',start_im,end_im))
title(sprintf('Offset (%s)',str_title))
colorbar(ax1);


Mmax = max(max(P1(:),0));
Mmin = min(min(P1(:),0));
ax2 = axes('Parent',tab0);
im = imagesc(P1,'parent',ax2);
im.AlphaData = P1>0;
%title(sprintf('slope + (%d-%d)',start_im,end_im))
title(sprintf('Slope + (%s)',str_title));
colorbar(ax2);
ax2.CLim = [0 Mmax];

ax3 = axes('Parent',tab0);
im = imagesc(P1,'parent',ax3);
im.AlphaData = P1<0;
%title(sprintf('slope - (%d-%d)',start_im,end_im))
title(sprintf('Slope - (%s)',str_title))
colorbar(ax3);
ax3.CLim = [Mmin 0];

ax1.Position = [margin_w margin_h 1/3-4*margin_w 1-2*margin_h];
ax1.Visible = 'off';
ax1.Title.Visible = 'on';
ax2.Position = [1/3+margin_w margin_h 1/3-4*margin_w 1-2*margin_h];
ax2.Visible = 'off';
ax2.Title.Visible = 'on';
ax3.Position = [2/3+margin_w margin_h 1/3-4*margin_w 1-2*margin_h];
ax2.Visible = 'off';
ax2.Title.Visible = 'on';

% Storing Data
handles.MainFigure.UserData.P1 = P1;
handles.MainFigure.UserData.P2 = P2;
handles.MainFigure.UserData.str_title = str_title;

handles.TabGroup.SelectedTab = handles.PotentiationTab;
set(handles.MainFigure, 'pointer', 'arrow');
handles.MainFigure.UserData.success = true;

end

function saveimage_Callback(~,~,handles)

global FILES CUR_FILE DIR_FIG;
load('Preferences.mat','GTraces');

%Loading data
str_title = char(handles.MainFigure.UserData.str_title);
% Creating Save Directory
save_dir = fullfile(DIR_FIG,'Vascular_Potentiation',FILES(CUR_FILE).recording);
if ~isdir(save_dir)
    mkdir(save_dir);
end

% Saving Image
cur_tab = handles.TabGroup.SelectedTab;
handles.TabGroup.SelectedTab = handles.PotentiationTab;
pic_name = sprintf('%s_Vascular_Potentiation_%s%s',FILES(CUR_FILE).recording,str_title,GTraces.ImageSaveExtension);
saveas(handles.MainFigure,fullfile(save_dir,pic_name),GTraces.ImageSaveFormat);
fprintf('Image saved at %s.\n',fullfile(save_dir,pic_name));

handles.TabGroup.SelectedTab = cur_tab;

end

function savestats_Callback(~,~,handles)

global FILES CUR_FILE DIR_STATS;
load('Preferences.mat','GTraces');

%Loading data
str_title = char(handles.MainFigure.UserData.str_title);
recording = FILES(CUR_FILE).recording;
% % Storing parameters
% Tag_Selection = handles.MainFigure.UserData.Tag_Selection;
% thresh_inf = handles.MainFigure.UserData.thresh_inf;
% thresh_sup = handles.MainFigure.UserData.thresh_sup;
% t_gauss_lfp = handles.MainFigure.UserData.t_gauss_lfp;
% t_gauss_cbv = handles.MainFigure.UserData.t_gauss_cbv;
% freqdom = handles.MainFigure.UserData.freqdom;
% Storing data
P1 = handles.MainFigure.UserData.P1;
P2 = handles.MainFigure.UserData.P2;

% Creating Stats Directory
data_dir = fullfile(DIR_STATS,'Vascular_Potentiation',FILES(CUR_FILE).recording);
if ~isdir(data_dir)
    mkdir(data_dir);
end

% Saving data
filename = sprintf('%s_Vascular_Potentiation_%s.mat',FILES(CUR_FILE).recording,str_title);
save(fullfile(data_dir,filename),'recording','str_title','P1','P2',...
    '-v7.3');
fprintf('Data saved at %s.\n',fullfile(data_dir,filename));

end

function batchsave_Callback(~,~,handles,str_group)

if nargin > 3
    % If batch mode, keep only elements in str_group
    ind_group = [];
    for i=1:length(handles.Group_table.Data)
        ind_keep = strcmp(char(handles.Group_table.Data(i)),str_group);
        if sum(ind_keep)>0
            ind_group = [ind_group;i];
        end
    end
    handles.Group_table.UserData.Selection = ind_group;
else
    ind_group = handles.Group_table.UserData.Selection;
end


% Compute for handles.Popup2.Value =1:2
for j=1:length(ind_group)
    handles.Group_table.UserData.Selection = ind_group(j);
    compute_Callback(handles.ButtonCompute,[],handles);
    savestats_Callback([],[],handles);
    saveimage_Callback([],[],handles);
end
handles.Group_table.UserData.Selection = ind_group;

end