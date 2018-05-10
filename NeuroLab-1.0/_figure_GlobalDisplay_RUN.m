function f2 = figure_GlobalDisplay_RUN(handles,val,str_group)
% Global Display REM

global DIR_SAVE FILES CUR_FILE START_IM END_IM;

try
    load(fullfile(DIR_SAVE,FILES(CUR_FILE).gfus,'Time_Tags.mat'),'TimeTags_cell');
    load(fullfile(DIR_SAVE,FILES(CUR_FILE).gfus,'Time_Reference.mat'),'time_ref','n_burst','length_burst');
catch
    errordlg(sprintf('Missing File Time_Tags.mat or Time_Reference.mat %s',fullfile(DIR_SAVE,FILES(CUR_FILE).gfus)));
    return;
end

f2 = figure('Units','characters',...
    'HandleVisibility','callback',...
    'IntegerHandle','off',...
    'Renderer','painters',...
    'Toolbar','figure',...
    'NumberTitle','off',...
    'Tag','MainFigure',...
    'PaperPositionMode','auto',...
    'Name','Global Episode Display (RUN)');
colormap(f2,'jet');
clrmenu(f2);

% Information Panel
iP = uipanel('FontSize',12,...
    'Units','normalized',...
    'Tag','InfoPanel',...
    'Position',[0 .1 1 .9],...
    'Parent',f2);

uicontrol('Units','characters','Style','text','HorizontalAlignment','left','Parent',iP,...
    'String',sprintf('File : %s',FILES(CUR_FILE).gfus),'Tag','Text1');
uicontrol('Units','characters','Style','text','HorizontalAlignment','left','Parent',iP,...
    'String',sprintf('Source : %s',handles.CenterPanelPopup.String(handles.CenterPanelPopup.Value,:)),'Tag','Text2');
uicontrol('Units','characters','Style','edit','HorizontalAlignment','center',...
    'Tooltipstring','Margin (%)','Parent',iP,'String',.02,'Tag','Edit3');
uicontrol('Units','characters','Style','edit','HorizontalAlignment','center',...
    'Tooltipstring','Button Size (%)','Parent',iP,'String',.04,'Tag','Edit4');

e1 = uicontrol('Units','characters',...
    'Style','edit',...
    'HorizontalAlignment','center',...
    'Tooltipstring','Start Time',...
    'String',datestr(0/(24*3600),'HH:MM:SS.FFF'),...
    'Parent',iP,...
    'Tag','Edit1');
e2 = uicontrol('Units','characters',...
    'Style','edit',...
    'HorizontalAlignment','center',...
    'Tooltipstring','End Time',...
    'String',datestr(0,'HH:MM:SS.FFF'),...
    'Parent',iP,...
    'Tag','Edit2');
e1.String = handles.TimeDisplay.UserData(START_IM,:);
e2.String = handles.TimeDisplay.UserData(END_IM,:);
e1.Enable = 'off';
e2.Enable = 'off';

%Copying Buttons from Main Panel
copyobj(handles.PlusButton,iP);
copyobj(handles.MinusButton,iP);
copyobj(handles.SkipButton,iP);
copyobj(handles.BackButton,iP);
nt = copyobj(handles.nextTagButton,iP);
nt.Enable = 'off';
pt = copyobj(handles.prevTagButton,iP);
pt.Enable = 'off';
cp = copyobj(handles.RescaleButton,iP);
cp.UserData.str1 = handles.TimeDisplay.UserData(1,:);
cp.UserData.str2 = handles.TimeDisplay.UserData(end,:);
copyobj(handles.TagButton,iP);
% if length(tb.UserData.Selected)>1
%     tb.UserData=[];
% end

uicontrol('Units','characters','Style','pushbutton','Parent',iP,...
    'String','Reset','Tag','ButtonReset');
bc = uicontrol('Units','characters','Style','pushbutton','Parent',iP,...
    'String','Compute','Tag','ButtonCompute');
uicontrol('Units','characters','Style','pushbutton','Parent',iP,...
    'String','Autoscale','Tag','ButtonAutoScale');
uicontrol('Units','characters','Style','pushbutton','Parent',iP,...
    'String','Save Stats','Tag','ButtonSaveStats');
uicontrol('Units','characters','Style','pushbutton','Parent',iP,...
    'String','Save Image','Tag','ButtonSaveImages');
bb = uicontrol('Units','characters','Style','pushbutton','Parent',iP,...
    'String','Batch Save','Tag','ButtonBatchSave');

uicontrol('Units','characters',...
    'Style','checkbox',...
    'Parent',iP,...
    'TooltipString','Normalized Data',...
    'Tag','BoxNorm',...
    'Value',1);
uicontrol('Units','characters',...
    'Style','checkbox',...
    'Parent',iP,...
    'TooltipString','Bar Separation',...
    'Tag','BoxBars',...
    'Value',0);
uicontrol('Units','characters',...
    'Style','checkbox',...
    'Parent',iP,...
    'TooltipString','Auto/Manual Scaling',...
    'Tag','BoxAuto',...
    'Value',1);

% Creating uitabgroup
mP = uipanel('FontSize',12,'Units','normalized','Position',[0 .1 1 .9],'Parent',f2);
tabgp = uitabgroup('Units','normalized','Position',[0 0 1 1],'Parent',mP,'Tag','TabGroup');

% First tab
tab1 = uitab('Parent',tabgp,'Title','General','Units','normalized','Tag','MainTab');
uipanel('FontSize',12,'Units','normalized','Tag','MainPanel','Parent',tab1);
%Second Tab
tab2 = uitab('Parent',tabgp,'Title','Traces & Episodes','Tag','SecondTab');

% Lines Array
m = findobj(handles.RightAxes,'Tag','Trace_Mean');
l = flipud(findobj(handles.RightAxes,'Tag','Trace_Region'));
u = flipud(findobj(handles.RightAxes,'Tag','Trace_Pixel'));
v = flipud(findobj(handles.RightAxes,'Tag','Trace_Box'));
t = flipud(findobj(handles.RightAxes,'Tag','Trace_Spiko'));

% Sorting Trace_Spiko
t1 = [];
t2 = [];
for i =1:length(t)
    if strcmp(t(i).UserData.Name(1:min(4,end)),'fUS/')
        t2 = [t2;t(i)];
    else
        t1 = [t1;t(i)];
    end
end

lines_1 = [m;l];
lines_2 = [u;v];
lines_3 = t1;
if length(t2)>1
    lines_4 = [t2(end);t2(1:end-1)];
else
    lines_4 = t2;
end
bc.UserData.lines_1 = lines_1;
bc.UserData.lines_2 = lines_2;
bc.UserData.lines_3 = lines_3;
bc.UserData.lines_4 = lines_4;

%Regions Panel
rPanel = uipanel('Parent',tab2,'Units','normalized',...
    'Position',[0 0 .25 1],'Title','Regions','Tag','RegionPanel');
% Table Data
D={'Whole', m.Tag};
for i =2:length(lines_1)
    D=[D;{lines_1(i).UserData.Name,lines_1(i).Tag}];
end
rt = uitable('Units','normalized',...
    'ColumnName','',...
    'RowName',{},...
    'ColumnFormat',{'char','char'},...
    'ColumnEditable',[false,false],...
    'ColumnWidth',{120 120},...
    'Data',D,...
    'Position',[0 0 1 1],...
    'Tag','Region_table',...
    'CellSelectionCallback',@template_uitable_select,...
    'RowStriping','on',...
    'Parent',rPanel);
rt.UserData.Selection = 1:length(D);

%Pixel Panel
pPanel = uipanel('FontSize',10,'Units','normalized','Position',[.25 0 .25 1],...
    'Title','Pixels and Boxes','Tag','Pixel_Panel','Parent',tab2);
% Table Data
D={};
for i =1:length(lines_2)
    D=[D;{lines_2(i).UserData.Name, lines_2(i).Tag}];
end
% UiTable
pt = uitable('Units','normalized',...
    'ColumnName','',...
    'RowName',{},...
    'ColumnFormat',{'char','char'},...
    'ColumnEditable',[false,false],...
    'ColumnWidth',{70 70},...
    'Position',[0 0 1 1],...
    'Data',D,...
    'Tag','Pixel_table',...
    'CellSelectionCallback',@template_uitable_select,...
    'RowStriping','on',...
    'Parent',pPanel);
pt.UserData.Selection = [];

%Trace Panel
tPanel = uipanel('Parent',tab2,'Units','normalized','Position',[.5 0 .25 1],...
    'Title','Traces','Tag','TracePanel');
% Table Data
D={};
for i =1:length(lines_3)
    D=[D;{lines_3(i).UserData.Name, lines_3(i).Tag}];
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
    'Parent',tPanel);
tt.UserData.Selection = [];

%fUS Panel
fPanel = uipanel('FontSize',10,'Units','normalized','Position',[.75 0 .25 1],...
    'Title','fUS (Spiko)','Tag','fUS_Panel','Parent',tab2);
% Table Data
D={};
for i =1:length(lines_4)
    D=[D;{lines_4(i).UserData.Name, lines_4(i).Tag}];
end
% UiTable
ft = uitable('Units','normalized',...
    'ColumnName','',...
    'RowName',{},...
    'ColumnFormat',{'char','char','char'},...
    'ColumnEditable',[false,false,false],...
    'ColumnWidth',{70 70 70},...
    'Position',[0 0 1 1],...
    'Data',D,...
    'Tag','fUS_table',...
    'CellSelectionCallback',@template_uitable_select,...
    'RowStriping','on',...
    'Parent',fPanel);
ft.UserData.Selection = [];

set(f2,'Position',[30 30 200 40]);
resetbutton_Callback([],[],guihandles(f2),handles);
tabgp.SelectedTab = tab2;

% If nargin > 3 batch processing
% val indicates callback provenance (0 : batch mode - 1 : user mode)
% str_group contains group names 
if val==0
    batchsave_Callback(bb,[],guihandles(f2),handles,str_group,1);
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
handles.Text1.Position = [.5     ipos(4)/2-.25    ipos(3)/3-.5   ipos(4)/3];
handles.Text2.Position = [.5    0+.25             ipos(3)/3-.5   ipos(4)/3];

handles.Edit1.Position = [ipos(3)/3     2.75*ipos(4)/5   ipos(3)/8   ipos(4)/3];
handles.Edit2.Position = [ipos(3)/3     ipos(4)/10           ipos(3)/8   ipos(4)/3];
handles.Edit3.Position = [7*ipos(3)/10     2.75*ipos(4)/5   4*ipos(3)/100   ipos(4)/3];
handles.Edit4.Position = [7*ipos(3)/10     ipos(4)/10       4*ipos(3)/100   ipos(4)/3];

handles.PlusButton.Position = [4.75*ipos(3)/10     ipos(4)/2-.25   ipos(3)/20   ipos(4)/2];
handles.MinusButton.Position = [4.75*ipos(3)/10     0   ipos(3)/20   ipos(4)/2];
handles.SkipButton.Position = [5.25*ipos(3)/10     ipos(4)/2-.25   ipos(3)/20   ipos(4)/2];
handles.BackButton.Position = [5.25*ipos(3)/10     0   ipos(3)/20   ipos(4)/2];
handles.nextTagButton.Position = [5.75*ipos(3)/10     ipos(4)/2-.25   ipos(3)/20   ipos(4)/2];
handles.prevTagButton.Position = [5.75*ipos(3)/10     0   ipos(3)/20   ipos(4)/2];
handles.RescaleButton.Position = [6.25*ipos(3)/10     ipos(4)/2-.25   ipos(3)/20   ipos(4)/2];
handles.TagButton.Position = [6.25*ipos(3)/10     0   ipos(3)/20   ipos(4)/2];

handles.ButtonReset.Position = [7.45*ipos(3)/10     ipos(4)/2-.25      ipos(3)/12   ipos(4)/2];
handles.ButtonCompute.Position = [7.45*ipos(3)/10+ipos(3)/12     ipos(4)/2-.25      ipos(3)/12   ipos(4)/2];
handles.ButtonAutoScale.Position = [7.45*ipos(3)/10+ipos(3)/6     ipos(4)/2-.25      ipos(3)/12   ipos(4)/2];

handles.ButtonSaveStats.Position = [7.45*ipos(3)/10     0      ipos(3)/12   ipos(4)/2];
handles.ButtonSaveImages.Position = [7.45*ipos(3)/10+ipos(3)/12     0      ipos(3)/12   ipos(4)/2];
handles.ButtonBatchSave.Position = [7.45*ipos(3)/10+ipos(3)/6     0      ipos(3)/12   ipos(4)/2];

handles.BoxNorm.Position = [6.78*ipos(3)/10     .25      ipos(3)/50   ipos(4)/4];
handles.BoxBars.Position = [6.78*ipos(3)/10     1.5      ipos(3)/50   ipos(4)/4];
handles.BoxAuto.Position = [6.78*ipos(3)/10     2.75      ipos(3)/50   ipos(4)/4];

end

function resize_MainPanel(~,~,handles)

margin = str2double(handles.Edit3.String);
w_button = str2double(handles.Edit4.String);

R = length(handles.Region_table.UserData.Selection);
P = length(handles.Pixel_table.UserData.Selection);
T = length(handles.Trace_table.UserData.Selection);
F = length(handles.fUS_table.UserData.Selection);
N = (R+P+T+F)*(1+7*margin);

if N==0
    R=1;
    P=1;
    T=1;
    F=1;
    N=4;
end

handles.Ax1.Position = [.075 (F+T+P)/N+4*margin  .86 R/N];
handles.Ax2.Position = [.075 (F+T)/N+3*margin  .86 P/N];
handles.Ax3.Position = [.075 F/N+2*margin  .86 T/N];
handles.Ax4.Position = [.075 margin  .86 F/N];

handles.Colorbar1.Position = [.94 (F+T+P)/N+4*margin  .015  R/N];
handles.Colorbar2.Position = [.94 (F+T)/N+3*margin  .015  P/N];
handles.Colorbar3.Position = [.94 F/N+2*margin  .015  T/N];
handles.Colorbar4.Position = [.94 margin  .015  F/N];

handles.xmin1.Position = [.97 (F+T+P)/N+4*margin  .03 w_button];
handles.xmax1.Position = [.97 (F+T+P+R)/N+4*margin-w_button .03  w_button];
handles.xmin2.Position = [.97 (F+T)/N+3*margin  .03 w_button];
handles.xmax2.Position = [.97 (F+T+P)/N+3*margin-w_button .03  w_button];
handles.xmin3.Position = [.97 F/N+2*margin  .03 w_button];
handles.xmax3.Position = [.97 (F+T)/N+2*margin-w_button .03  w_button];
handles.xmin4.Position = [.97 margin  .03 w_button];
handles.xmax4.Position = [.97 F/N+margin-w_button .03  w_button];

end

function initialize_centerPanel(handles)

delete(handles.MainPanel.Children);

ax1 = subplot(4,1,1,'Parent',handles.MainPanel,'Tag','Ax1');
ax1.XLim = [0,10000];
title(ax1,'Regions');
c1 = colorbar(ax1,'Tag','Colorbar1');
set(ax1,'ButtonDownFcn',{@template_axes_clickFcn,1,[],[handles.Edit1,handles.Edit2]});
%caxis(ax1,'auto');

ax2 = subplot(4,1,2,'Parent',handles.MainPanel,'Tag','Ax2');
ax2.XLim = [0,10000];
title(ax2,'Pixels and Regions');
c2 = colorbar(ax2,'Tag','Colorbar2');
set(ax2,'ButtonDownFcn',{@template_axes_clickFcn,1,[],[handles.Edit1,handles.Edit2]});
%caxis(ax2,'auto');

ax3 = subplot(4,1,3,'Parent',handles.MainPanel,'Tag','Ax3');
ax3.XLim = [0,10000];
title(ax3,'Traces');
c3 = colorbar(ax3,'Tag','Colorbar3');
set(ax3,'ButtonDownFcn',{@template_axes_clickFcn,1,[],[handles.Edit1,handles.Edit2]});
%caxis(ax3,'auto');

ax4 = subplot(4,1,4,'Parent',handles.MainPanel,'Tag','Ax4');
ax4.XLim = [0,10000];
title(ax4,'fUS Traces');
c4 = colorbar(ax4,'Tag','Colorbar4');
set(ax4,'ButtonDownFcn',{@template_axes_clickFcn,1,[],[handles.Edit1,handles.Edit2]});
%caxis(ax4,'auto');

uicontrol('Units','normalized','Style','edit','HorizontalAlignment','center','Parent',handles.MainPanel,...
    'String',0,'Tag','xmin1','Callback', {@update_caxis,ax1,c1,1},'Tooltipstring','xmin1');
uicontrol('Units','normalized','Style','edit','HorizontalAlignment','center','Parent',handles.MainPanel,...
    'String',1,'Tag','xmax1','Callback', {@update_caxis,ax1,c1,2},'Tooltipstring','xmax1');
uicontrol('Units','normalized','Style','edit','HorizontalAlignment','center','Parent',handles.MainPanel,...
    'String',0,'Tag','xmin2','Callback', {@update_caxis,ax2,c2,1},'Tooltipstring','xmin2');
uicontrol('Units','normalized','Style','edit','HorizontalAlignment','center','Parent',handles.MainPanel,...
    'String',1,'Tag','xmax2','Callback', {@update_caxis,ax2,c2,2},'Tooltipstring','xmax2');
uicontrol('Units','normalized','Style','edit','HorizontalAlignment','center','Parent',handles.MainPanel,...
    'String',0,'Tag','xmin3','Callback', {@update_caxis,ax3,c3,1},'Tooltipstring','xmin3');
uicontrol('Units','normalized','Style','edit','HorizontalAlignment','center','Parent',handles.MainPanel,...
    'String',1,'Tag','xmax3','Callback', {@update_caxis,ax3,c3,2},'Tooltipstring','xmax3');
uicontrol('Units','normalized','Style','edit','HorizontalAlignment','center','Parent',handles.MainPanel,...
    'String',0,'Tag','xmin4','Callback', {@update_caxis,ax4,c4,1},'Tooltipstring','xmin4');
uicontrol('Units','normalized','Style','edit','HorizontalAlignment','center','Parent',handles.MainPanel,...
    'String',1,'Tag','xmax4','Callback', {@update_caxis,ax4,c4,2},'Tooltipstring','xmax4');

end

function resetbutton_Callback(~,~,handles,old_handles)

global START_IM END_IM;
initialize_centerPanel(handles);
handles = guihandles(handles.MainFigure);

% Resize Function Attribution
set(handles.MainFigure,'ResizeFcn',{@resize_Figure,handles});
set(handles.MainPanel,'ResizeFcn',{@resize_MainPanel,handles});
set(handles.InfoPanel,'ResizeFcn',{@resize_InfoPanel,handles});

% Callback function Attribution
set(handles.ButtonReset,'Callback',{@resetbutton_Callback,handles,old_handles});
set(handles.ButtonCompute,'Callback',{@compute_Callback,handles});
set(handles.ButtonAutoScale,'Callback',{@buttonAutoScale_Callback,handles});
set(handles.ButtonSaveImages,'Callback',{@saveimage_Callback,handles});
set(handles.ButtonSaveStats,'Callback',{@savestats_Callback,handles});
set(handles.ButtonBatchSave,'Callback',{@batchsave_Callback,handles,old_handles});
set(handles.BoxBars,'Callback',{@boxbar_Callback,handles});

%Interactive Control
all_axes = findobj(handles.MainPanel,'Type','axes');
for i=1:length(all_axes)
    all_axes(i).XLim = [START_IM END_IM];
end

%Interactive Control
edits = [handles.Edit1;handles.Edit2];
% set(handles.MainFigure,'KeyPressFcn',{@cfc_keypressFcn,handles});
set(handles.PlusButton,'Callback',{@template_buttonPlus_Callback,all_axes,edits});
set(handles.MinusButton,'Callback',{@template_buttonMinus_Callback,all_axes,edits});
set(handles.SkipButton,'Callback',{@template_buttonSkip_Callback,all_axes,edits});
set(handles.BackButton,'Callback',{@template_buttonBack_Callback,all_axes,edits});
set(handles.RescaleButton,'Callback',{@buttonRescale_Callback,all_axes,edits,old_handles});
set(handles.TagButton,'Callback',{@button_TagSelection_Callback,all_axes,edits,old_handles});
% set(handles.prevTagButton,'Callback',{@template_prevTag_Callback,handles.TagButton,all_axes,edits});
% set(handles.nextTagButton,'Callback',{@template_nextTag_Callback,handles.TagButton,all_axes,edits});

% Figure Resizing
resize_Figure(0,0,handles);
% Fixing non automatic Main Panel resize
resize_MainPanel([],[],handles);

end

function update_caxis(hObj,~,ax,c,value)
switch value
    case 1,
        ax.CLim(1) = str2double(hObj.String);
    case 2,
        ax.CLim(2) = str2double(hObj.String);
end
c.Limits = ax.CLim;
end

function boxbar_Callback(hObj,~,handles)

bars = findobj(handles.MainPanel,'Tag','SepBar');
if hObj.Value
    for k=1:length(bars)
        bars(k).Visible = 'on';
    end
else
    for k=1:length(bars)
        bars(k).Visible = 'off';
    end
end

end

function buttonAutoScale_Callback(~,~,handles)

for j=1:4
    ax = findobj(handles.MainPanel,'Tag',sprintf('Ax%d',j));
    c = findobj(handles.MainPanel,'Tag',sprintf('Colorbar%d',j));
    if strcmp(ax.Visible,'off')
        continue;
    end
    im = findobj(ax,'Tag','Image');
    
    % Searching local max and min for all images in axes
    % Storing in X (timing) and Y (values)
    X=[];
    Y=[];
    for k=1:length(im)
        x_ind = max(ax.XLim(1),im(k).XData(1));
        y_ind = min(ax.XLim(2),im(k).XData(end));
        if y_ind>x_ind
            X = [X;x_ind y_ind];
            indexes = (im(k).XData>=x_ind).*(im(k).XData<=y_ind);
            temp = im(k).CData(:,indexes==1);
            val_min = min(min(temp,[],'omitnan'),[],'omitnan');
            val_max = .5*max(max(temp,[],'omitnan'),[],'omitnan');
            %val_max = 5* mean(mean(temp,1,'omitnan'),2,'omitnan');
            Y = [Y;val_min val_max];
        end
    end
    m = min(Y(:,1),[],'omitnan');
    M = max(Y(:,2),[],'omitnan');
    button3 = findobj(handles.MainPanel,'Tag',sprintf('xmin%d',j));
    button4 = findobj(handles.MainPanel,'Tag',sprintf('xmax%d',j));
    button3.String = sprintf('%.1f',m);
    button4.String = sprintf('%.1f',M);
    button3.Visible = 'on';
    button4.Visible = 'on';
    c.Limits = [m,M];
    ax.CLim = [m,M];
end

end

function buttonRescale_Callback(~,~,ax,edits,handles)

global LAST_IM;

str1 = handles.TimeDisplay.UserData(1,:);
str2 = handles.TimeDisplay.UserData(end,:);
for i=1:length(ax)
    ax(i).XLim =[1,LAST_IM];
end
if nargin>3
    edits(1).String = str1;
    edits(2).String = str2;
end

end

function button_TagSelection_Callback(hObj,~,ax,edits,handles,ind_tag,v)
% Time Tag Selection Callback (Global Display)
% If nargin == 6 : opens list dialog to manually select Time Tags

global DIR_SAVE FILES CUR_FILE;

try
    load(fullfile(DIR_SAVE,FILES(CUR_FILE).gfus,'Time_Tags.mat'),'TimeTags_cell','TimeTags_strings','TimeTags_images');
    %fprintf('Successful Time Tags Importation (File %s).\n',fullfile(DIR_SAVE,FILES(CUR_FILE).gfus,'Time_Tags.mat'));
catch
    errordlg(sprintf('Missing File Time_Tags.mat %s',fullfile(DIR_SAVE,FILES(CUR_FILE).gfus)));
    return;
end

if isempty(hObj.UserData)
    Selected = 1;
else
    Selected = hObj.UserData.Selected;
end

if nargin <6
    str_tag = arrayfun(@(i) strjoin(TimeTags_cell(i,2:4),' - '), 2:size(TimeTags_cell,1), 'unif', 0)';
    [ind_tag,v] = listdlg('Name','Tag Selection','PromptString','Select Time Tags',...
        'SelectionMode','mutiple','ListString',str_tag,...
        'InitialValue',Selected,'ListSize',[300 500]);
end

if v==0
    return;
elseif isempty(ind_tag)
    hObj.UserData='';
else
    hObj.UserData.Selected = ind_tag;
    hObj.UserData.Name = TimeTags_cell(ind_tag+1,2);
    hObj.UserData.TimeTags_strings = TimeTags_strings(ind_tag,:);
    hObj.UserData.TimeTags_images = TimeTags_images(ind_tag,:);
    
    % Adding TimeGroup Name
    name_Tag = '';
    if exist(fullfile(DIR_SAVE,FILES(CUR_FILE).gfus,'Time_Groups.mat'),'file')
        load(fullfile(DIR_SAVE,FILES(CUR_FILE).gfus,'Time_Groups.mat'),'TimeGroups_name','TimeGroups_S');
        % Test if ind_tags matches TimeGroups_S(i).Selected
        for i =1:length(TimeGroups_name)
            if length(TimeGroups_S(i).Selected)== length(ind_tag) && sum(TimeGroups_S(i).Selected-ind_tag(:))==0
                name_Tag = char(TimeGroups_name(i));
            end
        end
    end
    hObj.UserData.GroupName = name_Tag;
    
    % Setting limits on RightAxes
    im1 = min(TimeTags_images(ind_tag,1));
    im2 = max(TimeTags_images(ind_tag,2));
    for i=1:length(ax)
        ax(i).XLim = [im1,im2];
    end
    edits(1).String = handles.TimeDisplay.UserData(im1,:);
    edits(2).String = handles.TimeDisplay.UserData(im2,:);
end

end

function compute_Callback(hObj,~,handles)

global DIR_SAVE FILES CUR_FILE LAST_IM;
load(fullfile(DIR_SAVE,FILES(CUR_FILE).gfus,'Time_Reference.mat'),'time_ref','n_burst','length_burst');
x_burst = [ones(length_burst,n_burst);zeros(1,n_burst)];
x_burst = x_burst(:);

% Pointer Watch
set(handles.MainFigure, 'pointer', 'watch');
drawnow;
handles.MainFigure.UserData.success = false;

% Interpolation Frequency
f_int = 1/(time_ref.Y(2)-time_ref.Y(1));
bar_color = [.5 .5 .5];
lines_1 = hObj.UserData.lines_1;
lines_3 = hObj.UserData.lines_3;
lines_2 = hObj.UserData.lines_2;
lines_4 = hObj.UserData.lines_4;

% Time Selection
a = datenum(handles.Edit1.String);
b = datenum(handles.Edit2.String);
Time_indices = [(a-floor(a))*24*3600,(b-floor(b))*24*3600];
% Tag Selection
str = datestr((Time_indices(2)-Time_indices(1))/(24*3600),'HH:MM:SS.FFF');
Tag_Selection = {'CURRENT',handles.Edit1.String,str};

% Test if axis limits matches Whole
if round(Time_indices(1)-time_ref.Y(1))==0 && round(Time_indices(2)-time_ref.Y(end))==0
    tag = 'WHOLE';
    Tag_Selection ={tag,handles.Edit1.String,str};
% Test if axis limits matches tag
elseif ~isempty(handles.TagButton.UserData)
    if ~isempty(handles.TagButton.UserData.GroupName)
        tag = char(handles.TagButton.UserData.GroupName);
        Tag_Selection ={tag,handles.Edit1.String,str};
    else
        tts1 = char(handles.TagButton.UserData.TimeTags_strings(1));
        tts2 = char(handles.TagButton.UserData.TimeTags_strings(2));
        if strcmp(handles.Edit1.String(1:9),tts1(1:9)) && strcmp(handles.Edit2.String(1:9),tts2(1:9))
            tag = char(handles.TagButton.UserData.Name);
            Tag_Selection ={tag,handles.Edit1.String,str};
        end
    end
end

% Compute Table data
all_table = [handles.Region_table;handles.Pixel_table;handles.Trace_table;handles.fUS_table];
all_lines = {lines_1;lines_2;lines_3;lines_4};
all_ax = [handles.Ax1;handles.Ax2;handles.Ax3;handles.Ax4];

for i=1:4
    table = all_table(i);
    lines = all_lines{i};
    ax = all_ax(i);
    data = [];
    
    % if Selection not empty fill data
    if ~isempty(table.UserData.Selection)
        % Extracting Regions
        ind = table.UserData.Selection;
        Selection = table.Data(ind,:);
        lines = lines(ind);
        % Building RData
        ref_time = max(1,round(ax.XLim(1))):min(LAST_IM,ceil(ax.XLim(2)));
        Ydata = NaN(length(ind),length(ref_time));
        for k=1:length(ind)
            %data = lines(k).YData(~isnan(lines(k).YData));
            data = lines(k).YData(x_burst==1);
            Y = (data)';
            Ydata(k,:)=Y(ref_time);
        end
        % Normalization
        M = repmat(mean(Ydata,2,'omitnan'),[1,length(ref_time)]);
        s = repmat(std(Ydata,[],2,'omitnan'),[1,length(ref_time)]);
        Ydata_norm = (Ydata-M)./s;
        % Saving data
        data = struct('ref_time',[],'Ydata',[],'Ydata_norm',[],'labels',[],'Title',[]);
        data.Title = char(Tag_Selection(1,1));
        data.labels = Selection(:,1);
        data.ref_time = ref_time;
        data.Ydata = Ydata;
        data.Ydata_norm = Ydata_norm;
    end
        
    % Storing data
    switch i
        case 1,
            Rdata = data;
            hObj.UserData.Rdata = Rdata;
        case 2,
            Pdata = data;
            hObj.UserData.Pdata = Pdata;
        case 3,
            Tdata = data;
            hObj.UserData.Tdata = Tdata;
        case 4,
            Fdata = data;
            hObj.UserData.Fdata = Fdata;
    end
end

% Clear Axes
% h_all = findobj(handles.MainPanel,'Type','Axes');
% for i=1:length(h_all)
%     cla(h_all(i));
%     delete(h_all(i).Title);
% end

% Update Axes
all_Data = {Rdata;Pdata;Tdata;Fdata};
all_ax = [handles.Ax1;handles.Ax2;handles.Ax3;handles.Ax4];
all_cbar = [handles.Colorbar1;handles.Colorbar2;handles.Colorbar3;handles.Colorbar4];
all_xmin = [handles.xmin1;handles.xmin2;handles.xmin3;handles.xmin4];
all_xmax = [handles.xmax1;handles.xmax2;handles.xmax3;handles.xmax4];
all_tag = ['Ax1';'Ax2';'Ax3';'Ax4'];

for i=1:4
    Data = all_Data{i};
    ax = all_ax(i);
    cbar = all_cbar(i);
    xmin = all_xmin(i);
    xmax = all_xmax(i);
    tag = all_tag(i,:);
    
    if ~isempty(Data)
        ax.Visible = 'on';
        cbar.Visible = 'on';
        str = datestr((Data.ref_time(end)-Data.ref_time(1))/(24*3600),'HH:MM:SS.FFF');
        ax.Title.String = sprintf('%s (Duration %s)',Data.Title,str);
        if handles.BoxNorm.Value
            imagesc('CData',Data.Ydata_norm,...
                'Xdata',Data.ref_time,...
                'HitTest','off',...
                'Tag','Image',...
                'Parent',ax);
        else
            imagesc('CData',Data.Ydata,...
                'Xdata',Data.ref_time,...
                'HitTest','off',...
                'Tag','Image',...
                'Parent',ax);
        end
        %ax.XLim = [Data.ref_time(1),Data.ref_time(end)];
        ax.YLim = [.5,size(Data.Ydata,1)+.5];
        ax.YTickLabel = Data.labels;
        ax.YTick = 1:length(Data.labels);
        ax.YDir  = 'reverse';
        ax.Tag = tag;
        
        %ax.CLim = [min(min(ax.CData,1,'omitnan'),2,'omitnan'),max(max(ax.CData,1,'omitnan'),2,'omitnan')];
        if handles.BoxAuto.Value
            % Auto Scaling
            xmin.String = sprintf('%.1f',ax.CLim(1));
            xmax.String = sprintf('%.1f',ax.CLim(2));
            xmin.Visible = 'on';
            xmax.Visible = 'on';
            cbar.Limits = ax.CLim;
        else
            % Manual Scaling
            c_min = str2double(xmin.String);
            c_max = str2double(xmax.String);
            caxis(ax,[c_min c_max]);
            cbar.Limits = [c_min,c_max];
        end
        
        % Plotting bars between burst
        x_bars = length_burst*(1:n_burst)+.5;
        for jj=1:length(x_bars)
            line('XData',[x_bars(jj),x_bars(jj)],'YData',...
                ax.YLim,'Parent',ax,'Color',bar_color,...
                'LineWidth',2,'Tag','SepBar');
        end
        boxbar_Callback(handles.BoxBars,[],handles);
    else
        ax.Visible = 'off';
        cbar.Visible = 'off';
        xmin.Visible = 'off';
        xmax.Visible = 'off';
    end
end

% Titles and Axes
ax_visible = flipud(findobj(handles.MainTab,'Type','axes','-and','Visible','on'));
for i=2:length(ax_visible)
    ax_visible(i-1).XTick = x_bars;
    ax_visible(i-1).XTickLabel = '|';
    ax_visible(i).Title.String = '';
end

% Fixing non automatic Main Panel resize
resize_MainPanel([],[],handles);

% Saving Data
save_data = savecompact_data(all_Data);
save_data.f_int = f_int;
hObj.UserData.save_data = save_data;

% Pointer Watch
handles.TabGroup.SelectedTab = handles.MainTab;
set(handles.MainFigure, 'pointer', 'arrow');
handles.MainFigure.UserData.success = true;

end

function save_data = savecompact_data(all_Data)
labels = [];
Ydata = [];
Ydata_norm = [];
t = [];
%f_samp = [];
ref_time = [];
for i=1:4
    Data = all_Data{i};
    if ~isempty(Data)
        labels = [labels;Data.labels];
        Ydata = [Ydata;Data.Ydata];
        Ydata_norm = [Ydata_norm;Data.Ydata_norm];
        t = Data.Title;
        %f_samp = Data.f_samp;
        ref_time = Data.ref_time;
    end
end
%save_data = struct('Title',[],'labels',[],'ref_time',[],'f_samp',[],'Ydata',[],'Ydata_norm',[]);
save_data = struct('Title',[],'labels',[],'ref_time',[],'Ydata',[],'Ydata_norm',[]);
save_data.Title = t;
save_data.labels = labels;
save_data.ref_time = ref_time;
%save_data.f_samp = f_samp;
save_data.Ydata = Ydata;
save_data.Ydata_norm = Ydata_norm;
end

function saveimage_Callback(~,~,handles)

global FILES CUR_FILE DIR_FIG;
load('Preferences.mat','GTraces');

% Creating Save Directory
save_dir = fullfile(DIR_FIG,'Global_Display',FILES(CUR_FILE).eeg);
if ~isdir(save_dir)
    mkdir(save_dir);
end
tag = handles.ButtonCompute.UserData.save_data.Title;

% Saving Image
pic_name = sprintf('%s_Global_Display_%s%s',FILES(CUR_FILE).eeg,tag,GTraces.ImageSaveExtension);
saveas(handles.MainFigure,fullfile(save_dir,pic_name),GTraces.ImageSaveFormat);
fprintf('Image saved at %s.\n',fullfile(save_dir,pic_name));

end

function savestats_Callback(~,~,handles)

global FILES CUR_FILE DIR_STATS;
load('Preferences.mat','GTraces');

% Creating Stats Directory
data_dir = fullfile(DIR_STATS,'Global_Display',FILES(CUR_FILE).eeg);
if ~isdir(data_dir)
    mkdir(data_dir);
end

% Test if axis limits matches tag
data = handles.ButtonCompute.UserData.save_data;
Title = data.Title;
labels = data.labels;
ref_time = data.ref_time;
x_start = ref_time(1);
x_end = ref_time(end);
%f_samp = data.f_samp;
f_int = data.f_int;
Ydata = data.Ydata;
Ydata_norm =  data.Ydata_norm;

% Saving Stats
filename = sprintf('%s_Global_Display_%s.mat',FILES(CUR_FILE).eeg,Title);
%save(fullfile(data_dir,filename),'Title','labels','ref_time','f_samp','f_int','Ydata','Ydata_norm','-v7.3');
save(fullfile(data_dir,filename),'Title','labels','x_start','x_end','ref_time','f_int','Ydata','Ydata_norm','-v7.3');
fprintf('Data saved at %s.\n',fullfile(data_dir,filename));

end

function batchsave_Callback(~,~,handles,old_handles,str_group,v)

global DIR_SAVE FILES CUR_FILE;

if exist(fullfile(DIR_SAVE,FILES(CUR_FILE).gfus,'Time_Groups.mat'),'file')
    load(fullfile(DIR_SAVE,FILES(CUR_FILE).gfus,'Time_Groups.mat'),'TimeGroups_name','TimeGroups_S');        
end

if nargin == 4
    % If Manual Callback open inputdlg
    [ind_group,v] = listdlg('Name','Group Selection','PromptString','Select Time Groups',...
        'SelectionMode','multiple','ListString',TimeGroups_name,...
        'InitialValue','','ListSize',[300 500]);
else
    % If batch mode, keep only elements in str_group
    ind_group = [];
    temp = TimeGroups_name;
    for i=1:length(temp)
        ind_keep = ~(cellfun('isempty',strfind(str_group,temp(i))));
        if sum(ind_keep)>0
            ind_group=[ind_group,i];
        end
    end  
end

if isempty(ind_group)||v==0
    return
end

% Compute for whole recording
edits = [handles.Edit1,handles.Edit2];
all_axes = findobj(handles.MainPanel,'type','axes');
buttonRescale_Callback(handles.RescaleButton,[],all_axes,edits,old_handles);
compute_Callback(handles.ButtonCompute,[],handles);
buttonAutoScale_Callback([],[],handles);
savestats_Callback([],[],handles);
saveimage_Callback([],[],handles);

% Compute for designated time tags
for i = 1:length(ind_group)%size(TimeGroups_strings,1)
    ind_tag = TimeGroups_S(ind_group(i)).Selected;
    button_TagSelection_Callback(handles.TagButton,[],all_axes,edits,old_handles,ind_tag,v)
    %resetbutton_Callback([],[],handles);
    compute_Callback(handles.ButtonCompute,[],handles);
    buttonAutoScale_Callback([],[],handles);
    savestats_Callback([],[],handles);
    saveimage_Callback([],[],handles);
end

end