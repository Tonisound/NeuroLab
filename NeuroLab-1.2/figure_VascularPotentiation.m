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
load(fullfile(DIR_SAVE,FILES(CUR_FILE).nlab,'Time_Tags.mat'),'TimeTags','TimeTags_cell','TimeTags_images','TimeTags_strings');
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
e5 = uicontrol('Units','normalized','Style','edit','HorizontalAlignment','center','Parent',iP,...
    'String',.005,'Tag','Edit5','Tooltipstring','Slope+ min threshold');
e6 = uicontrol('Units','normalized','Style','edit','HorizontalAlignment','center','Parent',iP,...
    'String',-.005,'Tag','Edit6','Tooltipstring','Slope- min threshold');
e7 = uicontrol('Units','normalized','Style','edit','HorizontalAlignment','center','Parent',iP,...
    'String',.1,'Tag','Edit7','Tooltipstring','Slope+ max threshold');
e8 = uicontrol('Units','normalized','Style','edit','HorizontalAlignment','center','Parent',iP,...
    'String',-.1,'Tag','Edit8','Tooltipstring','Slope- max threshold');

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
e1.Position = [.25     .5    .04   .5];
e2.Position = [.25     0    .04   .5];
e3.Position = [.3     .5    .04   .5];
e4.Position = [.3     0    .04   .5];
e5.Position = [.35     .5    .04   .5];
e6.Position = [.35     0    .04   .5];
e7.Position = [.4     .5    .04   .5];
e8.Position = [.4     0    .04   .5];
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
    'Position',[0 0 .33 1],...
    'Title','Traces',...
    'Tag','TracePanel');
tagPanel = uipanel('Parent',tab0,...
    'Units','normalized',...
    'Position',[.335 0 .33 1],...
    'Title','Time Tags',...
    'Tag','TagPanel');
groupPanel = uipanel('Parent',tab0,...
    'Units','normalized',...
    'Position',[.67 0 .33 1],...
    'Title','Time Groups',...
    'Tag','GroupPanel');

% Lines Array
ax_dummy = axes('Parent',tab0,'Visible','off');
m = findobj(handles.RightAxes,'Tag','Trace_Mean');
l = flipud(findobj(handles.RightAxes,'Type','line','-not','Tag','Cursor','-not','Tag','Trace_Cerep','-not','Tag','Trace_Mean'));
t = flipud(findobj(handles.RightAxes,'Tag','Trace_Cerep'));
lines = copyobj([m;l;t],ax_dummy);
f.UserData.lines = lines;

% Table Data
D = [];
for i =1:length(lines)
    D=[D;{lines(i).UserData.Name, lines(i).Tag}];
end

rt = uitable('Units','normalized',...
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
%rt.UserData.Selection = find(strcmp(rt.Data(:,2),'Trace_Region')==1);
rt.UserData.Selection = [];
f.UserData.lines_name = rt.Data(:,1);

tt = uitable('Units','normalized',...
    'ColumnName','',...
    'RowName',{},...
    'ColumnFormat',{'char'},...
    'ColumnEditable',false,...
    'ColumnWidth',{120},...
    'Data',{TimeTags(:).Tag}',...
    'Position',[0 0 1 1],...
    'Tag','Tag_table',...
    'CellSelectionCallback',@template_uitable_select,...
    'RowStriping','on',...
    'Parent',tagPanel);
tt.UserData.Selection = [];
tt.UserData.TimeTags = TimeTags;
tt.UserData.TimeTags_cell = TimeTags_cell;
tt.UserData.TimeTags_images = TimeTags_images;
tt.UserData.TimeTags_strings = TimeTags_strings;

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
gt.UserData.Selection = [];
gt.UserData.TimeGroups_name = TimeGroups_name;
gt.UserData.TimeGroups_S = TimeGroups_S;

% Pixel Tab
uitab('Parent',tabgp,...
    'Title','Pixels',...
    'Tag','PixelTab');

% Regions Tab
uitab('Parent',tabgp,...
    'Title','Regions (lines)',...
    'Tag','RegionTab');

% Potentiation Tab
uitab('Parent',tabgp,...
    'Title','Regions (mask)',...
    'Tag','BarTab');

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

tab0 = handles.PixelTab;
tab1 = handles.RegionTab;
tab2 = handles.BarTab;
f = handles.MainFigure;
margin_w = str2double(handles.Edit3.String);
margin_h = str2double(handles.Edit4.String);
IM = f.UserData.IM;
lines = f.UserData.lines;
lines_name = f.UserData.lines_name;

% Pointer Watch
set(handles.MainFigure, 'pointer', 'watch');
drawnow;
handles.MainFigure.UserData.success = false;

% Select Time indices
sel2 = handles.Tag_table.UserData.Selection;
sel3 = handles.Group_table.UserData.Selection;
if ~isempty(sel2)
    % Time Tag Selection
    TimeTags_images = handles.Tag_table.UserData.TimeTags_images(sel2,:);
    Time_indices = zeros(size(handles.MainFigure.UserData.time_ref.X));
    for i =1:size(TimeTags_images,1)
        im1 = TimeTags_images(i,1);
        im2 = TimeTags_images(i,2);
        ind_keep = (handles.MainFigure.UserData.time_ref.X>=im1).*(handles.MainFigure.UserData.time_ref.X<=im2);
        Time_indices(ind_keep==1)=1;
    end
    str_title = strcat(handles.Tag_table.UserData.TimeTags(sel2(1)).Tag,...
        '---',handles.Tag_table.UserData.TimeTags(sel2(end)).Tag);
elseif ~isempty(sel3)
    % Time Group Selection
    % keeping first
    sel3 = sel3(1);
    TimeTags_images = handles.Group_table.UserData.TimeGroups_S(sel3).TimeTags_images;
    Time_indices = zeros(size(handles.MainFigure.UserData.time_ref.X));
    for i =1:size(TimeTags_images,1)
        im1 = TimeTags_images(i,1);
        im2 = TimeTags_images(i,2);
        ind_keep = (handles.MainFigure.UserData.time_ref.X>=im1).*(handles.MainFigure.UserData.time_ref.X<=im2);
        Time_indices(ind_keep==1)=1;
    end
    str_title = sprintf('TimeGroup-%s',char(handles.Group_table.UserData.TimeGroups_name(sel3)));
else 
    start_im = str2double(handles.Edit1.String);
    end_im = str2double(handles.Edit2.String);
    Time_indices = (handles.MainFigure.UserData.time_ref.X>=start_im).*(handles.MainFigure.UserData.time_ref.X<=end_im);
    str_title = sprintf('CURRENT[%d-%d]',start_im,end_im);
end

% Select Regions
sel1 = handles.Trace_table.UserData.Selection;
if isempty(sel1)
    ind_regions = find(strcmp(handles.Trace_table.Data(:,2),'Trace_Region')==1);
    handles.Trace_table.UserData.Selection = ind_regions;
else
    ind_regions = sel1;
end
%str_regions = handles.Trace_table.Data(ind_regions,1);

% Compute Pixel Potentiation
%X = (1:end_im-start_im+1)';
X = (1:length(find(Time_indices==1)))';
n = 1;
Slope_Map = NaN(size(IM(:,:,1)));
Offset_Map = NaN(size(IM(:,:,1)));
h = waitbar(0,'Please wait');
for i =1:size(IM,1)
    for j =1:size(IM,2)
        Y = squeeze(IM(i,j,Time_indices==1));
        P = polyfit(X,Y,n);
        Slope_Map(i,j) = P(1);
        Offset_Map(i,j) = P(2);
    end
    x=i/size(IM,1);
    waitbar(x,h,sprintf('%.1f %% completed',100*x));
end
close(h);

% Compute Pixel Potentiation per Mask
lines_reg = findobj(lines,'Tag','Trace_Region');
S = struct('name',[],'offset_map',[],'slope_map',[],'offset',[],'slope',[],'color',[]);
S(length(lines_reg)).name = '';
for i =1:length(lines_reg)
    l = lines_reg(i);
    S(i).name = l.UserData.Name;
    mask = l.UserData.Mask;
    mask(mask==0)=NaN;
    S(i).offset_map = mask.*Offset_Map;
    S(i).slope_map = mask.*Slope_Map;
    S(i).offset = mean(mean(S(i).offset_map,1,'omitnan'),2,'omitnan');
    S(i).slope = mean(mean(S(i).slope_map,1,'omitnan'),2,'omitnan');
    S(i).color = l.Color;
end

% Compute Region Potentiation
Slope_Reg = NaN(size(ind_regions));
Offset_Reg = NaN(size(ind_regions));
str_regions = [];
r_colors = [];
for i =1:length(ind_regions)
    %region_name = char(handles.Trace_table.Data(ind_regions(i),1));
    l = lines(ind_regions(i));
    str_regions = [str_regions ; {l.UserData.Name}];
    r_colors = [r_colors ;l.Color];
    Y = (squeeze(l.YData(Time_indices==1)))';
    P = polyfit(X,Y,n);
    Slope_Reg(i) = P(1);
    Offset_Reg(i) = P(2);
end

% PixelTab
delete(tab0.Children);
ax1 = axes('Parent',tab0);
imagesc(Offset_Map,'parent',ax1);
%title(sprintf('offset (%d-%d)',start_im,end_im))
title(sprintf('Offset (%s)',str_title))
colorbar(ax1);

thresh_sup_min = str2double(handles.Edit5.String);
thresh_inf_min = str2double(handles.Edit6.String);
thresh_sup_max = str2double(handles.Edit7.String);
thresh_inf_max= str2double(handles.Edit8.String);

Mmax = max(max(Slope_Map(:),0));
Mmin = min(min(Slope_Map(:),0));
ax2 = axes('Parent',tab0);
im1 = imagesc(Slope_Map,'parent',ax2);
im1.AlphaData = Slope_Map>thresh_sup_min;
im1.UserData.Slope_Map = Slope_Map;
im1.UserData.index = 1;
%title(sprintf('slope + (%d-%d)',start_im,end_im))
title(sprintf('Slope + (%s)',str_title));
c2 = colorbar(ax2);
%ax2.CLim = [thresh_sup_min Mmax];
ax2.CLim = [thresh_sup_min thresh_sup_max];

ax3 = axes('Parent',tab0);
%im = imagesc(Slope_Map,'parent',ax3);
im2 = imagesc(abs(Slope_Map),'parent',ax3);
im2.AlphaData = Slope_Map<thresh_inf_min;
im2.UserData.Slope_Map = Slope_Map;
im2.UserData.index = 2;
%title(sprintf('slope - (%d-%d)',start_im,end_im))
title(sprintf('Slope - (%s)',str_title))
c3 = colorbar(ax3);
%ax3.CLim = [Mmin 0];
%ax3.CLim = [abs(thresh_inf_min) abs(Mmin)];
ax3.CLim = [abs(thresh_inf_min) abs(thresh_inf_max)];

handles.Edit5.Callback = {@update_caxis,ax2,c2,im1,1};
handles.Edit6.Callback  = {@update_caxis,ax3,c3,im2,1};
handles.Edit7.Callback = {@update_caxis,ax2,c2,im1,2};
handles.Edit8.Callback  = {@update_caxis,ax3,c3,im2,2};

ax1.Position = [margin_w margin_h 1/3-4*margin_w 1-2*margin_h];
ax1.Visible = 'off';
ax1.Title.Visible = 'on';
ax2.Position = [1/3+margin_w margin_h 1/3-4*margin_w 1-2*margin_h];
ax2.Visible = 'off';
ax2.Title.Visible = 'on';
ax3.Position = [2/3+margin_w margin_h 1/3-4*margin_w 1-2*margin_h];
ax2.Visible = 'off';
ax2.Title.Visible = 'on';

% RegionTab
delete(tab1.Children);
ax1 = axes('Parent',tab1);
for i =1:length(Slope_Reg)
    line('XData',Slope_Reg(i),'YData',Offset_Reg(i),'Linestyle','none','Parent',ax1,...
        'Marker','o','MarkerSize',5,'MarkerFaceColor',r_colors(i,:),'MarkerEdgeColor','none');
end
legend(str_regions,'Location','eastoutside');
ax1.Title.String = sprintf('Region Potentiation (%s)',str_title);
ax1.YLabel.String = 'Offset';
ax1.XLabel.String = 'Slope';
colorbar(ax1);

% BarTab
delete(tab2.Children);
ax1 = axes('Parent',tab2);
for i =1:length(S)
    line('XData',S(i).slope,'YData',S(i).offset,'Linestyle','none','Parent',ax1,...
        'Marker','o','MarkerSize',5,'MarkerFaceColor',S(i).color,'MarkerEdgeColor','none');
end
legend({S(:).name}','Location','eastoutside');
ax1.Title.String = sprintf('Region Potentiation (Mask) (%s)',str_title);
ax1.YLabel.String = 'Offset';
ax1.XLabel.String = 'Slope';
colorbar(ax1);

% Storing Data
handles.MainFigure.UserData.Slope_Map = Slope_Map;
handles.MainFigure.UserData.Offset_Map = Offset_Map;
handles.MainFigure.UserData.Slope_Reg = Slope_Reg;
handles.MainFigure.UserData.Offset_Reg = Offset_Reg;
handles.MainFigure.UserData.str_title = str_title;
handles.MainFigure.UserData.str_regions = str_regions;
handles.MainFigure.UserData.S = S;

handles.TabGroup.SelectedTab = handles.PixelTab;
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

handles.TabGroup.SelectedTab = handles.PixelTab;
tab = handles.TabGroup.SelectedTab.Title;
pic_name = sprintf('%s_Vascular_Potentiation_%s_%s%s',FILES(CUR_FILE).recording,str_title,tab,GTraces.ImageSaveExtension);
saveas(handles.MainFigure,fullfile(save_dir,pic_name),GTraces.ImageSaveFormat);
fprintf('Image saved at %s.\n',fullfile(save_dir,pic_name));

handles.TabGroup.SelectedTab = handles.RegionTab;
tab = handles.TabGroup.SelectedTab.Title;
pic_name = sprintf('%s_Vascular_Potentiation_%s_%s%s',FILES(CUR_FILE).recording,str_title,tab,GTraces.ImageSaveExtension);
saveas(handles.MainFigure,fullfile(save_dir,pic_name),GTraces.ImageSaveFormat);
fprintf('Image saved at %s.\n',fullfile(save_dir,pic_name));

handles.TabGroup.SelectedTab = handles.BarTab;
tab = handles.TabGroup.SelectedTab.Title;
pic_name = sprintf('%s_Vascular_Potentiation_%s_%s%s',FILES(CUR_FILE).recording,str_title,tab,GTraces.ImageSaveExtension);
saveas(handles.MainFigure,fullfile(save_dir,pic_name),GTraces.ImageSaveFormat);
fprintf('Image saved at %s.\n',fullfile(save_dir,pic_name));

handles.TabGroup.SelectedTab = cur_tab;

end

function savestats_Callback(~,~,handles)

global FILES CUR_FILE DIR_STATS;
load('Preferences.mat','GTraces');

%Loading data
str_title = char(handles.MainFigure.UserData.str_title);
str_regions = handles.MainFigure.UserData.str_regions;
recording = FILES(CUR_FILE).recording;
% % Storing parameters
% Tag_Selection = handles.MainFigure.UserData.Tag_Selection;
% thresh_inf = handles.MainFigure.UserData.thresh_inf;
% thresh_sup = handles.MainFigure.UserData.thresh_sup;
% t_gauss_lfp = handles.MainFigure.UserData.t_gauss_lfp;
% t_gauss_cbv = handles.MainFigure.UserData.t_gauss_cbv;
% freqdom = handles.MainFigure.UserData.freqdom;
% Storing data
Slope_Map = handles.MainFigure.UserData.Slope_Map;
Offset_Map = handles.MainFigure.UserData.Offset_Map;
Slope_Reg = handles.MainFigure.UserData.Slope_Reg;
Offset_Reg = handles.MainFigure.UserData.Offset_Reg;
S = handles.MainFigure.UserData.S;

% Creating Stats Directory
data_dir = fullfile(DIR_STATS,'Vascular_Potentiation',FILES(CUR_FILE).recording);
if ~isdir(data_dir)
    mkdir(data_dir);
end

% Saving data
filename = sprintf('%s_Vascular_Potentiation_%s.mat',FILES(CUR_FILE).recording,str_title);
save(fullfile(data_dir,filename),'recording','str_title','str_regions',...
    'Slope_Map','Offset_Map','Slope_Reg','Offset_Reg','S','-v7.3');
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

function update_caxis(hObj,~,ax,c,im,value)
for i=1:length(ax)
    switch value
        case 1
            ax(i).CLim(1) = abs(str2double(hObj.String));
            switch im.UserData.index 
                case 1
                    im.AlphaData = im.UserData.Slope_Map>str2double(hObj.String);
                case 2
                    im.AlphaData = im.UserData.Slope_Map<str2double(hObj.String);
            end
        case 2
            ax(i).CLim(2) = abs(str2double(hObj.String));
    end
end
c.Limits = ax.CLim;
end