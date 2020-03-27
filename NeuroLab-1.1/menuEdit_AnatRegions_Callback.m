function success = menuEdit_AnatRegions_Callback(folder_name,file_recording,handles,val)

global IM CUR_IM;
success = true;

% If nargin > 3 batch processing
% val indicates callback provenance (0 : batch mode - 1 : user mode)
if nargin == 3
    val=1;
end

data_config = load(fullfile(folder_name,'Config.mat'));
f = figure('Name','Anatomical Regions Edition',...
    'NumberTitle','off',...
    'Units','normalized',...
    'Tag','EditFigure');
colormap(f,'jet');
f.UserData.Colormap = f.Colormap;
colormap(f,'gray');
clrmenu(f);
f.UserData.data_config = data_config;
f.UserData.IM = IM;
f.UserData.success = false;

ax = copyobj(handles.CenterAxes,f);
ax.CLimMode = 'auto';
ax.Tag = 'AxEdit';
ax.TickLength = [0 0];
ax.XTickLabel = '';
ax.YTickLabel = '';
ax.XLabel.String ='';
ax.YLabel.String ='';
%axis(ax,'off');
ax.UserData.NeuroShop = [];
ax.UserData.data_atlas = [];

% Removing Pixel and Boxes
delete(findobj(ax,'Tag','Box','-or','Tag','Pixel'));

% Region Table
w_col = 60;
w_margin = 4;

mP = uipanel('Units','normalized',...
    'bordertype','etchedin',...
    'Tag','MainPanel',...
    'Parent',f);
tabgp = uitabgroup('Units','normalized',...
    'Position',[0 .05 1 .95],...
    'Parent',mP,...
    'Tag','TabGroup');
tab1 = uitab('Parent',tabgp,...
    'Units','normalized',...
    'Title','Regions',...
    'Tag','MainTab');
table_region = uitable('Units','normalized',...
    'ColumnFormat',{'char','char'},...
    'ColumnWidth',{w_col w_col},...
    'ColumnEditable',[false,false],...
    'ColumnName','',...
    'Data',[],...
    'RowName','',...
    'Tag','Region_table',...
    'RowStriping','on',...
    'Parent',tab1);
table_region.UserData.Selection = [];
table_region.UserData.patches = [];

tab2 = uitab('Parent',tabgp,...
    'Units','normalized',...
    'Title','Groups',...
    'Tag','SecondTab');
table_group = uitable('Units','normalized',...
    'ColumnFormat',{'char'},...
    'ColumnWidth',{w_col},...
    'ColumnEditable',false,...
    'ColumnName','',...
    'Data',[],...
    'RowName','',...
    'Tag','Group_table',...
    'RowStriping','on',...
    'Parent',tab2);
table_group.UserData.Selection = [];
table_group.UserData.groups = [];
%buttons
visibleButton = uicontrol('Style','pushbutton',... 
    'Units','normalized',...
    'String','Visible',...
    'TooltipString','Make selected regions visible',...
    'Tag','visibleButton',...
    'Parent',mP);
invisibleButton = uicontrol('Style','pushbutton',... 
    'Units','normalized',...
    'String','Invisible',...
    'TooltipString','Make selected regions invisible',...
    'Tag','invisibleButton',...
    'Parent',mP);

% Checkboxes
boxPref = uicontrol('Style','checkbox',...
    'Units','normalized',...
    'String','Keep prefix',...
    'Enable','off',...
    'TooltipString','Keep/remove largest prefix upon region importation',...
    'Value',0,...
    'Tag','boxPref',...
    'Parent',f);
boxSuf = uicontrol('Style','checkbox',...
    'Units','normalized',...
    'String','Keep suffix',...
    'Enable','off',...
    'TooltipString','Keep/remove largest suffix upon region importation',...
    'Value',0,...
    'Tag','boxSuf',...
    'Parent',f);
bg = uibuttongroup('Visible','on',...
    'Units','normalized',...
    'Position',[0 0 .2 1],...
    'Tag','radioMask');
% Create three radio buttons in the button group.
uicontrol(bg,'Style','radiobutton',...
    'Units','normalized',...
    'String','Patches',...
    'Position',[0 .5 1 .5],...
    'Tag','radioPatches',...
    'HandleVisibility','off');
uicontrol(bg,'Style','radiobutton',...
    'Units','normalized',...
    'String','Masks',...
    'Tag','radioMasks',...
    'Position',[0 0 1 .5],...
    'HandleVisibility','off');

boxAtlas = uicontrol('Style','checkbox',...
    'Units','normalized',...
    'String','Atlas Display',...
    'TooltipString','Display last registered atlas',...
    'Value',0,...
    'Tag','boxAtlas',...
    'Parent',f);
boxAtlas.Value = handles.AtlasBox.Value;
boxEdit = uicontrol('Style','checkbox',...
    'Units','normalized',...
    'String','Edit regions',...
    'TooltipString','Edit Region Table',...
    'Value',0,...
    'Tag','boxEdit',...
    'Parent',f);
boxEditGroup = uicontrol('Style','checkbox',...
    'Units','normalized',...
    'String','Edit groups',...
    'TooltipString','Edit Group Table',...
    'Value',0,...
    'Tag','boxEditGroup',...
    'Parent',f);
boxSticker = uicontrol('Style','checkbox',...
    'Units','normalized',...
    'String','Stickers',...
    'TooltipString','Show stickers to select/deselect regions',...
    'Value',1,...
    'Tag','boxSticker',...
    'Parent',f);

% Edition buttons
newButton = uicontrol('Style','pushbutton',... 
    'Units','normalized',...
    'String','New',...
    'Tag','newButton',...
    'Parent',f);
editButton = uicontrol('Style','pushbutton',...
    'Units','normalized',...
    'String','Edit',...
    'Tag','editButton',...
    'Parent',f);
edit_okButton = uicontrol('Style','pushbutton',...
    'Units','normalized',...
    'String','Ok',...
    'Tag','edit_okButton',...
    'Visible','off',...
    'Parent',f);
edit_cancelButton = uicontrol('Style','pushbutton',...
    'Units','normalized',...
    'String','Cancel',...
    'Tag','edit_cancelButton',...
    'Visible','off',...
    'Parent',f);
removeButton = uicontrol('Style','pushbutton',...
    'Units','normalized',...
    'String','Remove',...
    'Tag','removeButton',...
    'Parent',f);
duplicateButton = uicontrol('Style','pushbutton',...
    'Units','normalized',...
    'String','Duplicate',...
    'Tag','duplicateButton',...
    'Parent',f);
mergeButton = uicontrol('Style','pushbutton',...
    'Units','normalized',...
    'String','Merge',...
    'Tag','mergeButton',...
    'Parent',f);
addgroupButton = uicontrol('Style','pushbutton',... 
    'Units','normalized',...
    'String','Add Group',...
    'Tag','addgroupButton',...
    'Parent',f);
cleargroupButton = uicontrol('Style','pushbutton',...
    'Units','normalized',...
    'String','Clear Group',...
    'Tag','cleargroupButton',...
    'Parent',f);

% Import buttons
registerButton = uicontrol('Style','pushbutton',...
    'Units','normalized',...
    'String','Register Atlas',...
    'Tag','registerButton',...
    'Parent',f);
register_okButton = uicontrol('Style','pushbutton',...
    'Units','normalized',...
    'String','Ok',...
    'Tag','register_okButton',...
    'Visible','off',...
    'Parent',f);
register_cancelButton = uicontrol('Style','pushbutton',...
    'Units','normalized',...
    'String','Cancel',...
    'Tag','register_cancelButton',...
    'Visible','off',...
    'Parent',f);
importButton = uicontrol('Style','pushbutton',...
    'Units','normalized',...
    'String','Import',...
    'Tag','importButton',...
    'Parent',f);
exportButton = uicontrol('Style','pushbutton',...
    'Units','normalized',...
    'String','Export',...
    'Tag','exportButton',...
    'Parent',f);

% Time controls
l_mean = findobj(handles.RightAxes,'Tag','Trace_Mean');
l_cursor = findobj(handles.RightAxes,'Tag','Cursor');
ax_mean = axes('Parent',f,'YTick',[],'Tag','AxMean','FontSize',7,...
    'YTickLabel','','YLim',[min(l_mean.YData,[],'omitnan') max(l_mean.YData,[],'omitnan')]);
%set(ax_mean,'ButtonDownFcn',{@template_axes_clickFcn,ax_mean});
f.UserData.l_mean = copyobj(l_mean,ax_mean);
ax_mean.XLim = [min(l_mean.XData) max(l_mean.XData)];
% ax_mean.XTick = l_mean.XData(1):100:l_mean.XData(end);
% ax_mean.XTickLabel = cell2(l_mean.XData(1):100:l_mean.XData(end));
l_cursor = copyobj(l_cursor,ax_mean);
l_cursor.YData = ax_mean.YLim;
f.UserData.l_cursor = l_cursor;
l_cursor.Tag = 'T2';
l_cursor.Color = 'r';
l_cursor.HitTest = 'on';

t1 = uicontrol('Style','text',...
    'Units','normalized',...
    'String',sprintf('%d / %d',l_cursor.XData(1),f.UserData.data_config.LAST_IM),...
    'Tag','Text1',...
    'HorizontalAlignment','right',...
    'FontSize',8,...
    'Parent',f);
pu1 = uicontrol('Style','popupmenu',...
    'Units','normalized',...
    'String','current|source|normalized|dB',...
    'Tag','popup1',...
    'Parent',f);
set(pu1,'Callback',{@pu1_Callback,folder_name});

% OK/Cancel buttons
okButton = uicontrol('Style','pushbutton',...
    'Units','normalized',...
    'String','OK',...
    'Tag','okButton',...
    'Parent',f);
cancelButton = uicontrol('Style','pushbutton',...
    'Units','normalized',...
    'String','Cancel',...
    'Tag','cancelButton',...
    'Parent',f);

%Graphic position
ax.Position = [.2 .05 .6 .9];
f.Position = [.1 .3 .55 .5];
mP.Position = [.01 .05 .18 .75];
%table_region.Position = [.025 .05 .15 .75];
table_region.Position = [0 0 1 1];
table_group.Position = [0 0 1 1];
% Adjust Columns
mP.Units = 'pixels';
table_region.ColumnWidth ={mP.Position(3)/1.5-w_margin,mP.Position(3)/4-w_margin};
table_group.ColumnWidth ={mP.Position(3)-w_margin};
mP.Units = 'normalized';
%table_region.ColumnWidth = 1;

bg.Position = [.01 .89 .09 .06];
boxAtlas.Position = [.11 .89 .09 .03];
boxEdit.Position = [.01 .86 .09 .03];
boxEditGroup.Position = [.01 .83 .09 .03];
boxSticker.Position = [.11 .92 .09 .03];
boxPref.Position = [.11 .86 .09 .03];
boxSuf.Position = [.11 .83 .09 .03];
visibleButton.Position = [.035 0 .45 .07];
invisibleButton.Position = [.515 0 .45 .07];

newButton.Position = [.825 .9 .15 .05];
editButton.Position = [.825 .85 .15 .05];
edit_okButton.Position = [.825 .85 .075 .05];
edit_cancelButton.Position = [.9 .85 .075 .05];
duplicateButton.Position = [.825 .8 .15 .05];
mergeButton.Position = [.825 .75 .15 .05];
removeButton.Position = [.825 .7 .15 .05];
addgroupButton.Position = [.825 .625 .15 .05];
cleargroupButton.Position = [.825 .575 .15 .05];
registerButton.Position = [.825 .5 .15 .05];
register_okButton.Position = [.825 .5 .075 .05];
register_cancelButton.Position = [.9 .5 .075 .05];
importButton.Position = [.825 .45 .15 .05];
exportButton.Position = [.825 .4 .15 .05];
t1.Position = [.915 .3 .06 .04];
pu1.Position = [.825 .3 .09 .05];
ax_mean.Position = [.825 .2 .15 .1];
okButton.Position = [.825 .1 .15 .05];
cancelButton.Position = [.825 .05 .15 .05];

% Callback attribution
handles2 = guihandles(f);
bg.SelectionChangedFcn = {@radioMask_selection,handles2};
set(visibleButton,'Callback',{@visibleButton_callback,handles2});
set(invisibleButton,'Callback',{@invisibleButton_callback,handles2});

set(newButton,'Callback',{@newButton_callback,handles2});
set(editButton,'Callback',{@editButton_callback,handles2});
set(edit_okButton,'Callback',{@edit_ok_Button_callback,handles2});
set(edit_cancelButton,'Callback',{@edit_cancel_Button_callback,handles2});
set(duplicateButton,'Callback',{@duplicateButton_callback,handles2});
set(removeButton,'Callback',{@removeButton_callback,handles2});
set(mergeButton,'Callback',{@mergeButton_callback,handles2});
set(addgroupButton,'Callback',{@addgroupButton_callback,handles2});
set(cleargroupButton,'Callback',{@cleargroupButton_callback,handles2});

set(importButton,'Callback',{@importButton_Callback,file_recording,handles2});
set(exportButton,'Callback',{@exportButton_Callback,file_recording});
set(registerButton,'Callback',{@registerButton_Callback,handles2,folder_name,handles2.AxEdit,val});
set(register_okButton,'Callback',{@register_okButton_Callback,handles2,handles,folder_name,file_recording,handles2.AxEdit});
set(register_cancelButton,'Callback',{@register_cancel_Callback,handles2,handles2.AxEdit});

set(okButton,'Callback',{@okButton_callback,handles,handles2,val});
set(cancelButton,'Callback',{@cancelButton_callback,handles2});
set(boxAtlas,'Callback',{@boxAtlas_Callback,handles2.AxEdit});
set(boxEdit,'Callback',{@boxEdit_Callback,handles2.Region_table});
set(boxEditGroup,'Callback',{@boxEdit_Callback,handles2.Group_table});
set(boxSticker,'Callback',{@boxSticker_Callback,handles2});

% Interactive Control
table_region.CellSelectionCallback = {@uitable_select,handles2};
table_region.CellEditCallback = {@uitable_edit};

table_group.CellSelectionCallback = {@uitablegroup_select,handles2};
table_group.CellEditCallback = {@uitablegroup_edit};
set(l_cursor,'ButtonDownFcn',{@click_l_cursor});
set(ax,'ButtonDownFcn',{@axedit_clickFcn,handles2});
% set(ax,'ButtonDownFcn','disp(1)');

% Changing main image
% n_images = 100;
% main_im = mean(IM(:,:,START_IM:min(START_IM+n_images,END_IM)),3,'omitnan');
main_im = IM(:,:,CUR_IM);
im = findobj(ax,'Tag','MainImage');
im.CData = main_im;

% Intialization
im.AlphaData = ones(size(main_im));

% Building str_popup
patches = flipud(findobj(ax,'Tag','Region'));
str_popup = [];
for i = 1:length(patches)
    str_popup = [str_popup;{patches(i).UserData.UserData.Name}];
end

% Searching patches
for i = 1:length(patches)
    alpha = patches(i).FaceAlpha;
    %patches(i).FaceAlpha = 0;
    color = patches(i).FaceColor;
    patches(i).Visible = 'on';
    patches(i).EdgeColor = color;
    patches(i).FaceColor ='none';
    patches(i).LineWidth = 1;
    patches(i).MarkerSize = 1;
    
    % changing Tag to handle patches
    patches(i).Tag = patches(i).UserData.UserData.Name;
    
    % changing patches UserData
    patches(i).Tag = patches(i).UserData.UserData.Name;
    name = patches(i).UserData.UserData.Name;
    mask = patches(i).UserData.UserData.Mask;
    % adding mask
    cdata = repmat(permute(color,[3,1,2]),[size(mask,1),size(mask,2)]);
    im_mask = image('CData',cdata,...
        'Parent',ax,...
        'Tag','ImageMask',...
        'Hittest','off',...
        'AlphaData',alpha*mask,...
        'Visible','off');
    % adding boundary
    B = bwboundaries(mask);
    line_boundary=[];
    for j=1:length(B)
        boundary = B{j};
        l = line('XData',boundary(:,2),'YData',boundary(:,1),...
            'Color',color,...
            'Parent',ax,...
            'Tag','Boundary',...
            'Hittest','off',...
            'Visible','off');
        line_boundary=[line_boundary;l];
    end
    % adding sticker
    if boxSticker.Value
        sticker_status = 'on';
    else
        sticker_status = 'off';
    end
    sticker = text(mean(boundary(:,2)),mean(boundary(:,1)),name,...
        'FontSize',6,...
        'BackgroundColor',color,...
        'EdgeColor','k',...
        'Parent',ax,...
        'Tag','Sticker',...
        'Visible',sticker_status);
    sticker.UserData.Patch = patches(i);
    set(sticker,'ButtonDownFcn',{@click_sticker,patches(i),handles2});
    
    patches(i).UserData = [];
    patches(i).UserData.Name = name;
    patches(i).UserData.Mask = mask;
    patches(i).UserData.Selected = 0;
    patches(i).UserData.Color = color;
    patches(i).UserData.Alpha = alpha;
    patches(i).UserData.Line_Boundary = line_boundary;
    patches(i).UserData.ImMask = im_mask;
    patches(i).UserData.Sticker = sticker;
    
end

if ~isempty(str_popup)
    table_region.Data = [cellstr(str_popup),repmat({'1'},[length(str_popup),1])];
    table_region.UserData.patches = patches;
else
    table_region.Data = [];
    table_region.UserData.patches = [];
end

%waitfor(f);
success = true;

end

function newButton_callback(~,~,handles)

% getting region name
answer = inputdlg('Enter Region Name','Region creation',[1 60]);
if ~isempty(handles.Region_table.Data)
    while contains(char(answer),handles.Region_table.Data)
        answer = inputdlg('Enter Region Name','Invalid name (Region already exists)',[1 60]);
    end
end

if isempty(answer)
    return;
end

load('Preferences.mat','GColors');
alpha = GColors.patch_transparency;
patch_width = GColors.patch_width;
alpha_mask = GColors.mask_transparency;

% Getting dots
[xdata,ydata] = draw_patch(handles.AxEdit);
if length(xdata)<2
    delete(findobj(handles.AxEdit,'Tag','Marker'));
    delete(findobj(handles.AxEdit,'Tag','Line'));
    return;
end

% Patch creation
color = rand(1,3);
hq = patch('XData',xdata,...
    'YData',ydata,...
    'FaceColor','none',...
    'EdgeColor',color,...
    'Tag',char(answer),...
    'FaceAlpha',alpha,...
    'LineWidth',patch_width,...
    'Visible','on',...
    'Parent',handles.AxEdit);
delete(findobj(handles.AxEdit,'Tag','Marker'));
delete(findobj(handles.AxEdit,'Tag','Line'));

% mask creation
x_mask = handles.EditFigure.UserData.data_config.X;
y_mask = handles.EditFigure.UserData.data_config.Y;
new_mask = double(poly2mask(hq.XData,hq.YData,x_mask,y_mask));
% adding mask
cdata = repmat(permute(color,[3,1,2]),[size(new_mask,1),size(new_mask,2)]);
im_mask = image('CData',cdata,...
    'Parent',handles.AxEdit,...
    'Tag','ImageMask',...
    'Hittest','off',...
    'AlphaData',alpha_mask*new_mask,...
    'Visible','off');
% adding boundary
B = bwboundaries(new_mask);
line_boundary=[];
for j=1:length(B)
    boundary = B{j};
    l = line('XData',boundary(:,2),'YData',boundary(:,1),...
        'Color',color,...
        'Parent',handles.AxEdit,...
        'Tag','Boundary',...
        'Hittest','off',...
        'Visible','off');
    line_boundary=[line_boundary;l];
end
% adding sticker
if handles.boxSticker.Value
    sticker_status = 'on';
else
    sticker_status = 'off';
end
sticker = text(mean(boundary(:,2)),mean(boundary(:,1)),char(answer),...
    'FontSize',6,...
    'BackgroundColor',color,...
    'EdgeColor','k',...
    'Parent',handles.AxEdit,...
    'Tag','Sticker',...
    'Visible',sticker_status);
sticker.UserData.Patch = hq;
set(sticker,'ButtonDownFcn',{@click_sticker,hq,handles});

% Updating UserData
s.Name = char(answer);
s.Mask = new_mask;
s.Selected = 0;
s.Color = color;
s.Alpha = alpha;
s.Line_Boundary = line_boundary;
s.ImMask = im_mask;
s.Sticker = sticker;
hq.UserData = s;

%update table
handles.Region_table.UserData.patches = [handles.Region_table.UserData.patches;hq];
handles.Region_table.Data = [handles.Region_table.Data;[answer,{'1'}]];

end

function editButton_callback(hObj,~,handles)
% Editing selected patches

ax = handles.AxEdit;
marker_size = 5;
line_width = 1;
marker_type = 'o';
marker_color = 'r';

% enabling Region Edition
selection = handles.Region_table.UserData.Selection;
if isempty(selection)
    warning('Please select region to edit.');
    return;
elseif length(selection)>1
    warning('Can only edit one region at once. Please select one region.');
    return;
else
    % Converting region to line_marker
    p = handles.Region_table.UserData.patches(selection);
    p.Visible = 'off';
    for k =1:length(p.UserData.Line_Boundary)
        p.UserData.Line_Boundary(k).Visible = 'off';
    end
    p.UserData.ImMask.Visible = 'off';
    p.UserData.Sticker.Visible = 'off';
    % drawing lines
    %  xdata = p.UserData.Line_Boundary.XData;
    %  ydata = p.UserData.Line_Boundary.YData;
    xdata = [p.XData(:);p.XData(1)];
    ydata = [p.YData(:);p.YData(1)];
    
    % drawing marker line
    l_marker = line(xdata,ydata,'Tag','LineMarker','Marker',marker_type,'MarkerSize',marker_size,...
        'MarkerFaceColor',marker_color,'MarkerEdgeColor',marker_color,'Parent',ax,...
        'LineWidth',line_width,'LineStyle','-','Color',marker_color);
    set(l_marker,'ButtonDownFcn',{@click_l_marker});
    
    % storing data
    hObj.UserData.p = p;
    hObj.UserData.l_marker = l_marker;
end

% Setting all buttons to off
hObj.Visible ='off';
all_buttons = findobj(handles.EditFigure,'Style','pushbutton');
for i =1:length(all_buttons)
    all_buttons(i).Enable = 'off';
end
handles.edit_okButton.Visible ='on';
handles.edit_okButton.Enable ='on';
handles.edit_cancelButton.Visible ='on';
handles.edit_cancelButton.Enable ='on';

end

function edit_ok_Button_callback(~,~,handles)

load('Preferences.mat','GColors');
% alpha = GColors.patch_transparency;
% patch_width = GColors.patch_width;
alpha_mask = GColors.mask_transparency;

% Converting region to line_marker
p = handles.editButton.UserData.p;
l_marker = handles.editButton.UserData.l_marker;
% getting dots
xdata = l_marker.XData;
ydata = l_marker.YData;
color = p.UserData.Color;

% clearing UserData
delete(findobj(handles.AxEdit,'Tag','LineMarker'));
handles.editButton.UserData = [];

% Patch update
p.XData = xdata;
p.YData = ydata;
p.Visible = 'on';
% mask update
x_mask = handles.EditFigure.UserData.data_config.X;
y_mask = handles.EditFigure.UserData.data_config.Y;
new_mask = double(poly2mask(p.XData,p.YData,x_mask,y_mask));
cdata = repmat(permute(color,[3,1,2]),[size(new_mask,1),size(new_mask,2)]);
p.UserData.ImMask.CData = cdata;
p.UserData.ImMask.AlphaData = alpha_mask*new_mask;
p.UserData.ImMask.Visible = 'on';
p.UserData.Mask = new_mask;
% adding boundary
delete(p.UserData.Line_Boundary);
B = bwboundaries(new_mask);
line_boundary=[];
for j=1:length(B)
    boundary = B{j};
    l = line('XData',boundary(:,2),'YData',boundary(:,1),...
        'Color',color,...
        'Parent',handles.AxEdit,...
        'Tag','Boundary',...
        'Hittest','off',...
        'Visible','off');
    line_boundary=[line_boundary;l];
end
p.UserData.Line_Boundary = line_boundary;
% sticker update
if handles.boxSticker.Value
    sticker_status = 'on';
else
    sticker_status = 'off';
end
p.UserData.Sticker.Position(1) = mean(boundary(:,2));
p.UserData.Sticker.Position(2) = mean(boundary(:,1));
p.UserData.Sticker.Visible = sticker_status;

% Setting all buttons to on
handles.edit_okButton.Visible ='off';
handles.edit_cancelButton.Visible ='off';
all_buttons = findobj(handles.EditFigure,'Style','pushbutton');
for i =1:length(all_buttons)
    all_buttons(i).Enable = 'on';
end
handles.editButton.Visible ='on';

radioMask_selection([],[],handles);

end

function edit_cancel_Button_callback(~,~,handles)

% retrieving data
p = handles.editButton.UserData.p;

% deleting l_marker and clearing UserData
delete(findobj(handles.AxEdit,'Tag','LineMarker'));
handles.editButton.UserData = [];

% Turning them visible
p.Visible = 'on';
for k =1:length(p.UserData.Line_Boundary)
    p.UserData.Line_Boundary(k).Visible = 'on';
end
p.UserData.ImMask.Visible = 'on';
p.UserData.Sticker.Visible = 'on';

% Setting all buttons to on
handles.edit_okButton.Visible ='off';
handles.edit_cancelButton.Visible ='off';
all_buttons = findobj(handles.EditFigure,'Style','pushbutton');
for i =1:length(all_buttons)
    all_buttons(i).Enable = 'on';
end
handles.editButton.Visible ='on';

radioMask_selection([],[],handles);

end

function click_l_marker(hObj,evnt)

ax = hObj.Parent;
f = ax.Parent;

% getting mouse click
x = evnt.IntersectionPoint(1);
y = evnt.IntersectionPoint(2);
% finding closest marker
D = (hObj.XData(1:end-1)-x).^2 + (hObj.YData(1:end-1)-y).^2;
[val,index_closest] = min(D);
% x_closest = hObj.XData(index_closest);
% y_closest = hObj.YData(index_closest);
if val<.1
    clicked = 'marker';
else
    clicked = 'line';
end
% rounding x,y
x = round(x);
y = round(y);
pt = [x;y;0];

switch evnt.Button
    case 1
        % Left click
        if strcmp(clicked,'marker')
            % move marker until release            
            f.Pointer = 'crosshair';
            set(f,'WindowButtonMotionFcn', {@marker_motionFcn,hObj,index_closest});
            set(f,'WindowButtonUpFcn', {@marker_unclickFcn});
            
        elseif strcmp(clicked,'line')
            % adding marker
            
            % finding closest marker
            index_v2 = index_closest;
            index_v1 = index_closest-1;
            if index_v1 == 0
                index_v1 = length(hObj.XData)-1;
            end
            index_v3 = index_closest+1;
            V2 = [hObj.XData(index_v2);hObj.YData(index_v2);0];
            V1 = [hObj.XData(index_v1);hObj.YData(index_v1);0];
            V3 = [hObj.XData(index_v3);hObj.YData(index_v3);0];
            
            % evaluate distance
            d12 = point_to_line(pt,V1,V2);
            d32 = point_to_line(pt,V3,V2);
            if d32<d12
                hObj.XData = [hObj.XData(1:index_closest),x,hObj.XData(index_closest+1:end)];
                hObj.YData = [hObj.YData(1:index_closest),y,hObj.YData(index_closest+1:end)];
            else
                hObj.XData = [hObj.XData(1:index_closest-1),x,hObj.XData(index_closest:end)];
                hObj.YData = [hObj.YData(1:index_closest-1),y,hObj.YData(index_closest:end)];
            end
        end
        
    case 3
        % Right click
        if strcmp(clicked,'marker')
            % delete marker
            hObj.XData(index_closest) = [];
            hObj.YData(index_closest) = [];
        end
end

end

function d = point_to_line(pt,v1,v2)
a = v1-v2;
b = pt-v2;
d = norm(cross(a,b))/norm(a);
end

function [xdata,ydata] = draw_patch(ax)
% Draw temporary patch (merkers and lines) on axes ax
% Returns xdata and ydata (marker coordinates)

marker_size = 5;
line_width = 1;
marker_type = 'o';
marker_color = 'r';

% % deleting Merkers if any
% delete(findobj(ax,'Tag','Marker'));
% delete(findobj(ax,'Tag','Line'));

xdata = [];
ydata = [];
[x,y,button] = ginput(1);
x = round(x);
y = round(y);

while button==1
    % marker
    line(x,y,'Tag','Marker','Marker',marker_type,'MarkerSize',marker_size,...
        'MarkerFaceColor',marker_color,'MarkerEdgeColor',marker_color,'Parent',ax)
    % line
    if ~isempty(xdata)
        line([x,xdata(end)],[y,ydata(end)],'Tag','Line',...
            'LineWidth',line_width,'Color',marker_color,'Parent',ax);
    end
    xdata = [xdata;x];
    ydata = [ydata;y];
    [x,y,button] = ginput(1);
end

if length(xdata)>1
    line([xdata(1),xdata(end)],[ydata(1),ydata(end)],'Tag','Line',...
        'LineWidth',line_width,'Color',marker_color,'Parent',ax);
end

% rounding values
xdata = round(xdata);
ydata = round(ydata);

end

function removeButton_callback(~,~,handles)
% Remove temporary or selected patch

selection = handles.Region_table.UserData.Selection;
if ~isempty(selection)
    % deleting Region
    for i=1:length(selection)
        index = selection(i);
        delete(handles.Region_table.UserData.patches(index).UserData.Line_Boundary);
        delete(handles.Region_table.UserData.patches(index).UserData.ImMask);
        delete(handles.Region_table.UserData.patches(index).UserData.Sticker);
    end
    delete(handles.Region_table.UserData.patches(selection));   
    handles.Region_table.UserData.patches(selection)=[];
    handles.Region_table.Data(selection,:)=[];
    
else
    warning('Select region to remove.');
    return;
end

end

function visibleButton_callback(~,~,handles)
% Turn selected patches visible

selection = handles.Region_table.UserData.Selection;
if ~isempty(selection)
    handles.Region_table.Data(selection,2) = repmat({'1'},[length(selection) 1]);   
else
    warning('Select region to turn visible.');
    return;
end

end

function invisibleButton_callback(~,~,handles)
% Turn selected patches invisible

selection = handles.Region_table.UserData.Selection;
if ~isempty(selection)
    handles.Region_table.Data(selection,2) = repmat({'0'},[length(selection) 1]);   
else
    warning('Select region to turn invisible.');
    return;
end

end

function duplicateButton_callback(~,~,handles)
% Duplicate selected patches

load('Preferences.mat','GColors');
alpha = GColors.patch_transparency;
patch_width = GColors.patch_width;
alpha_mask = GColors.mask_transparency;

selection = handles.Region_table.UserData.Selection;
all_hq = [];
all_names = [];
all_previousnames = [];
        
if ~isempty(selection)
    
    for i =1:length(selection)
        % duplicating region
        index = selection(i);
        p = handles.Region_table.UserData.patches(index);
        color = p.UserData.Color + rand(3,1)'/10;
        color = max(min(color,1),0);
        name = sprintf('Duplicate[%s]',p.UserData.Name);
        mask = p.UserData.Mask;
        xdata = p.XData;
        ydata = p.YData;
        
        % Patch creation
        hq = copyobj(p,handles.AxEdit);
        hq.Tag = name;
        hq.FaceColor = 'none';
        hq.EdgeColor = color;
        % Mask creation
        cdata = repmat(permute(color,[3,1,2]),[size(mask,1),size(mask,2)]);
        im_mask = copyobj(p.UserData.ImMask,handles.AxEdit);
        im_mask.CData = cdata;
        % adding boundary
        B = bwboundaries(mask);
        line_boundary=[];
        for j=1:length(B)
            boundary = B{j};
            l = line('XData',boundary(:,2),'YData',boundary(:,1),...
                'Color',color,...
                'Parent',handles.AxEdit,...
                'Tag','Boundary',...
                'Hittest','off',...
                'Visible','off');
            line_boundary=[line_boundary;l];
        end
        % adding sticker
        sticker = copyobj(p.UserData.Sticker,handles.AxEdit);
        sticker.BackgroundColor = color;
        sticker.String = name;
        sticker.UserData.Patch = hq;
        set(sticker,'ButtonDownFcn',{@click_sticker,hq,handles});
        
        % Updating UserData
        s.Name = name;
        s.Mask = mask;
        s.Selected = 0;
        s.Color = color;
        s.Alpha = alpha;
        s.Line_Boundary = line_boundary;
        s.ImMask = im_mask;
        s.Sticker = sticker;
        hq.UserData = s;
        
        % storing names and patches
        all_previousnames = [all_previousnames;{p.UserData.Name}];
        all_hq = [all_hq;hq];
        all_names = [all_names;{name}];
    end
    
%     % Update table
%     handles.Region_table.UserData.patches = [handles.Region_table.UserData.patches;all_hq];
%     handles.Region_table.Data = [handles.Region_table.Data;all_names];
%     radioMask_selection([],[],handles);
    
    % Update table (intertwinned)
    for j = 1:length(all_names)
        last_sel = find(strcmp(handles.Region_table.Data,all_previousnames(j))==1);
        handles.Region_table.UserData.patches = [handles.Region_table.UserData.patches(1:last_sel);all_hq(j);handles.Region_table.UserData.patches(last_sel+1:end)];
        handles.Region_table.Data = [handles.Region_table.Data(1:last_sel,:);[all_names(j),{'1'}];handles.Region_table.Data(last_sel+1:end,:)];
    end
    
else
    warning('Select region to duplicate.');
    return;
end

end

function mergeButton_callback(~,~,handles)
% Merge selected patches

selection = handles.Region_table.UserData.Selection;
load('Preferences.mat','GColors');
alpha = GColors.patch_transparency;
patch_width = GColors.patch_width;
alpha_mask = GColors.mask_transparency;

if ~isempty(selection) && length(selection)>1
    
    D = handles.Region_table.Data(selection);
    %Largest Prefix
    pattern = char(D(1));
    count=0;
    while (count <= length(pattern)) && (sum(contains(D,pattern(1:count)))== size(D,1))
        count = count+1;
    end
    prefix = pattern(1:count-1);
    
    if ~isempty(prefix)
        while strcmp(prefix(end),'-') || strcmp(prefix(end),'_')
            prefix = prefix(1:end-1);
        end        
    else
%         prefix = sprintf('Merged(%d)[',size(D,1));
%         for i=1:size(D,1)
%             prefix = strcat(prefix,char(D(i,:)),'-');
%         end
%         prefix = strcat(prefix(1:end-1),']');
        for i=1:size(D,1)
            prefix = strcat(prefix,char(D(i,:)),'-');
        end
        prefix=prefix(1:end-1);
    end
    prefix = sprintf('Merged[%s]',prefix);
    
    % Mask
    P = handles.Region_table.UserData.patches(selection);
    all_mask = [];
    all_colors = [];
    all_sticker_positions = [];
    for i=1:length(P)
        mask = P(i).UserData.Mask;
        all_mask = cat(3,all_mask,mask);
        all_colors = cat(3,all_colors,P(i).UserData.Color);
        all_sticker_positions = [all_sticker_positions;P(i).UserData.Sticker.Position(1) P(i).UserData.Sticker.Position(2)];
    end
    new_mask = double(sum(all_mask,3)>0);
    new_color = mean(all_colors,3);
    % Patch
    [y,x]= find(new_mask'==1);
    k = convhull(x,y);
    pxdata = x(k);
    pydata = y(k);
    
    % patch creation
    hq = patch('XData',pydata,...
        'YData',pxdata,...
        'FaceColor','none',...
        'EdgeColor',new_color,...
        'Tag',prefix,...
        'FaceAlpha',alpha,...
        'LineWidth',patch_width,...
        'Visible','on',...
        'Parent',handles.AxEdit);
    % adding mask
    cdata = repmat(permute(new_color,[3,1,2]),[size(new_mask,1),size(new_mask,2)]);
    im_mask = image('CData',cdata,...
        'Parent',handles.AxEdit,...
        'Tag','ImageMask',...
        'Hittest','off',...
        'AlphaData',alpha_mask*new_mask,...
        'Visible','off');
    % adding boundary
    B = bwboundaries(new_mask);
    line_boundary=[];
    for j=1:length(B)
        boundary = B{j};
        l = line('XData',boundary(:,2),'YData',boundary(:,1),...
            'Color',new_color,...
            'Parent',handles.AxEdit,...
            'Tag','Boundary',...
            'Hittest','off',...
            'Visible','off');
        line_boundary=[line_boundary;l];
    end
    % adding sticker
    if handles.boxSticker.Value
        sticker_status = 'on';
    else
        sticker_status = 'off';
    end
    sticker = text(mean(all_sticker_positions(:,1)),mean(all_sticker_positions(:,2)),prefix,...
        'FontSize',6,...
        'BackgroundColor',new_color,...
        'EdgeColor','k',...
        'Parent',handles.AxEdit,...
        'Tag','Sticker',...
        'Visible',sticker_status);
    sticker.UserData.Patch = hq;
    set(sticker,'ButtonDownFcn',{@click_sticker,hq,handles});
    
    % Updating UserData
    s.Name = prefix;
    s.Mask = new_mask;
    s.Selected = 0;
    s.Color = new_color;
    s.Alpha = alpha;
    s.Line_Boundary = line_boundary;
    s.ImMask = im_mask;
    s.Sticker = sticker;
    hq.UserData = s;
    
    % Update table
%     handles.Region_table.UserData.patches = [handles.Region_table.UserData.patches;hq];
%     handles.Region_table.Data = [handles.Region_table.Data;s.Name];
    last_sel = max(selection);
    handles.Region_table.UserData.patches = [handles.Region_table.UserData.patches(1:last_sel);hq;handles.Region_table.UserData.patches(last_sel+1:end)];
    handles.Region_table.Data = [handles.Region_table.Data(1:last_sel,:);[s.Name,{'1'}];handles.Region_table.Data(last_sel+1:end,:)];
else
    warning('Select at least two regions to merge');
end

end

function addgroupButton_callback(~,~,handles)
% Add group of regions from selected patches

selection = handles.Region_table.UserData.Selection;
if isempty(selection)
    warning('Please select regions to form group.');
    return;
end

% adding existing groups

% getting group name
answer = inputdlg('Enter Group Name','Group creation',[1 60]);
if ~isempty(handles.Group_table.Data)
    while contains(char(answer),handles.Group_table.Data)
        answer = inputdlg('Enter Group Name','Invalid name (Group already exists)',[1 60]);
    end
end

if isempty(answer)
    return;
end

group.Name = char(answer);
group.Patches = handles.Region_table.UserData.patches(selection);

%update table
handles.Group_table.UserData.groups = [handles.Group_table.UserData.groups;group];
handles.Group_table.Data = [handles.Group_table.Data;answer];

end

function cleargroupButton_callback(~,~,handles)
% Remove group of regions

selection = handles.Group_table.UserData.Selection;
if ~isempty(selection)
    % deleting Region
    handles.Group_table.UserData.groups(selection)=[];
    handles.Group_table.Data(selection,:)=[];
    
else
    warning('Select group to remove.');
    return;
end

end

function registerButton_Callback(hObj,~,handles,savedir,ax,val)
% Allow for atlas registration onto axis ax

% Trying to load existing Atlas 
if exist(fullfile(savedir,'Atlas.mat'),'file')
    data_atlas = load(fullfile(savedir,'Atlas.mat'));
    fprintf('File Atlas.mat loaded [%s].\n',fullfile(savedir,'Atlas.mat'));
else
    data_atlas = [];
    fprintf('No existing file Atlas.mat found [%s].\n',fullfile(savedir,'Atlas.mat'));
end
ax.UserData.data_atlas = data_atlas;

% Keeping track
hObj.UserData.cell_visible = handles.Region_table.Data(:,2);
hObj.UserData.boxsticker_value = handles.boxSticker.Value;
hObj.UserData.boxatlas_value = handles.boxAtlas.Value;

% Turning all regions and stickers invisible
handles.Region_table.Data(:,2) = repmat({'0'},[size(handles.Region_table.Data,1) 1]);
radioMask_selection([],[],handles);
handles.boxSticker.Value = 0;
boxSticker_Callback(handles.boxSticker,[],handles);
handles.boxAtlas.Value = 0;
boxAtlas_Callback(handles.boxAtlas,[],ax);

% Setting all buttons to off
handles.registerButton.Visible ='off';
all_buttons = findobj(handles.EditFigure,'Style','pushbutton',...
    '-not','Tag','visibleButton','-not','Tag','invisibleButton');
for i =1:length(all_buttons)
    all_buttons(i).Enable = 'off';
end
handles.register_okButton.Visible ='on';
handles.register_okButton.Enable ='on';
handles.register_cancelButton.Visible ='on';
handles.register_cancelButton.Enable ='on';

% Initialize ax.UserData.NeuroShop depending on ax.UserData.data_atlas
% Enable Interactive control on ax
set_interactive_Neuroshop(ax,val);

end

function register_okButton_Callback(~,~,handles,old_handles,savedir,file_recording,ax)
% Validate Altas registration

% Create Atlas based Mask
CreateMask(1,ax);

% Export NeuroShop masks
ExportMask(savedir,ax);

% updating FILES
% global FILES CUR_FILE;
% data_c = load(fullfile(DIR_SAVE,FILES(CUR_FILE).nlab,'Config.mat'),'File');
% FILES(CUR_FILE) = data_c.File;

% Converting masks in binary files
convert_neuroshop_masks(savedir,file_recording,old_handles);

% Updating Config.mat
data_c = load(fullfile(savedir,'Config.mat'),'File');
File = data_c.File;
File.atlas_type = ax.UserData.NeuroShop.AtlasType;
File.bregma_xy = ax.UserData.NeuroShop.BregmaXY;
File.bregma_z = ax.UserData.NeuroShop.BregmaZ;
save(fullfile(savedir,'Config.mat'),'File','-append');
fprintf('File Config.mat updated [%s].\n',fullfile(savedir,'Config.mat'));

% Updating Mask atlas in main GUI
line_x = ax.UserData.NeuroShop.line_x;
line_z = ax.UserData.NeuroShop.line_z;
delete(findobj(old_handles.CenterAxes,'Tag','AtlasMask'));
l = line('XData',line_x,'YData',line_z,'Tag','AtlasMask',...
    'LineWidth',1,'Color','w','Parent',old_handles.CenterAxes);
l.Color(4) = 1;
boxAtlas_Callback(old_handles.AtlasBox,[],old_handles.CenterAxes);

% Updating Current Atlas Edit GUI
atlasmask = findobj(ax,'Tag','AtlasMask');
atlasmask.XData = line_x;
atlasmask.YData = line_z;

% Turning things off
register_cancel_Callback([],[],handles,ax);

end

function register_cancel_Callback(~,~,handles,ax)
% Turning off AtLas registration

ax.UserData.NeuroShop = [];
ax.UserData.data_atlas = [];

% Removing Atlas Handles
delete(findobj(handles.EditFigure,'Tag','TemporaryAtlasMask'));
delete(findobj(handles.EditFigure,'Tag','AtlasHandle'));
ax.Title.String = '';
ax.XLabel.String = '';
ax.YLabel.String = '';

% Turning off interactive control
set (handles.EditFigure, 'WindowButtonDownFcn', '');
set (handles.EditFigure, 'WindowButtonMotionFcn', '');
set (handles.EditFigure, 'KeyPressFcn', '');
set(handles.EditFigure,'Pointer','arrow');

% Turning all regions and stickers visible
% handles.Region_table.Data(:,2) = repmat({'1'},[size(handles.Region_table.Data,1) 1]);
handles.Region_table.Data(:,2) = handles.registerButton.UserData.cell_visible;
radioMask_selection([],[],handles);
% handles.boxSticker.Value = 1;
handles.boxSticker.Value = handles.registerButton.UserData.boxsticker_value;
boxSticker_Callback(handles.boxSticker,[],handles);
% handles.boxAtlas.Value = 1;
handles.boxAtlas.Value = handles.registerButton.UserData.boxatlas_value;
boxAtlas_Callback(handles.boxAtlas,[],ax);

% Setting all buttons to on
handles.register_okButton.Visible ='off';
handles.register_cancelButton.Visible ='off';
all_buttons = findobj(handles.EditFigure,'Style','pushbutton');
for i =1:length(all_buttons)
    all_buttons(i).Enable = 'on';
end
handles.registerButton.Visible ='on';

end

function cancelButton_callback(~,~,handles2)
    close(handles2.EditFigure);
end

function okButton_callback(~,~,handles,handles2,val)
% Apply changes to the Main Figure
% handles: main figure 
% handles2: region edition figure 

global LAST_IM;

% Deleting old patches
old_patches = findobj(handles.CenterAxes,'Tag','Region');
for i=1:length(old_patches)
    delete(old_patches(i).UserData);
    delete(old_patches(i));
end

% Recreating new patches
patches = handles2.Region_table.UserData.patches;
for i =1:length(patches)
    p = patches(i);
    
    % patch creation
    hq = patch('XData',p.XData,...
        'YData',p.YData,...
        'FaceColor',p.EdgeColor,...
        'EdgeColor','k',...
        'Tag','Region',...
        'FaceAlpha',.5,...
        'LineWidth',.5,...
        'ButtonDownFcn',{@click_RegionFcn,handles},...
        'Visible','off',...
        'Parent',handles.CenterAxes);
        
    % line creation
    X = [(1:LAST_IM)';NaN];
    Y = NaN(size(X));
    l_width = 1;
    hl = line('XData',X(:),...
        'YData',Y(:),...
        'Color',p.EdgeColor,...
        'Tag','Trace_Region',...
        'HitTest','on',...
        'Visible','off',...
        'LineWidth',l_width,...
        'Parent',handles.RightAxes);
    set(hl,'ButtonDownFcn',{@click_lineFcn,handles});
    
    if handles.RightPanelPopup.Value ==3
        %set([hq;hl],'Visible','on');
        set(hl,'Visible','on');
    end
    % boxLabel_Callback(handles.LabelBox,[],handles);
    boxPatch_Callback(handles.PatchBox,[],handles);
    
    % Updating UserData
    s.Name = p.UserData.Name;
    s.Mask = p.UserData.Mask;
    s.Graphic = hq;
    hq.UserData = hl;
    hl.UserData = s;
end

% Close figure and actualize traces
handles2.EditFigure.UserData.success = true;
% if val ==1
%     close(handles2.EditFigure);
% end
close(handles2.EditFigure);
actualize_traces(handles);

end

function boxEdit_Callback(src,~,table)

if src.Value
    table.ColumnEditable = [true,false];
else
    table.ColumnEditable = [false,false];
end

end

function boxSticker_Callback(src,~,handles)

all_patches = handles.Region_table.UserData.patches;
for i =1:length(all_patches)
    
    p = all_patches(i);
    % checking status_visible
    if strcmp(char(handles.Region_table.Data(i,2)),'1')
        status_visible ='on';
    else
        status_visible ='off';
    end
    % checking boxSticker Value
    if src.Value
        p.UserData.Sticker.Visible = status_visible;

    else
        p.UserData.Sticker.Visible = 'off';
    end
end

% bringing on top
sticks = findobj(handles.AxEdit,'Tag','Sticker');
if src.Value
    uistack(sticks(i),'top');
end

end

function radioMask_selection(~,~,handles)

src = handles.radioMask;
all_patches = handles.Region_table.UserData.patches;

if strcmp(src.SelectedObject.String,'Patches')
    %Patch visible
    for i =1:length(all_patches)
        
        % getting status_visible
        if strcmp(char(handles.Region_table.Data(i,2)),'1')
            status_visible ='on';
        else
            status_visible ='off';
        end
        % all_patches(i).Visible = 'on';
        
        all_patches(i).Visible = status_visible;
        all_patches(i).UserData.Sticker.Visible = status_visible;
        color = all_patches(i).UserData.Color;
        % check selected
        if all_patches(i).UserData.Selected
            all_patches(i).FaceColor=color;
            all_patches(i).EdgeColor='k';
        else
            all_patches(i).FaceColor='none';
            all_patches(i).EdgeColor=color;
        end
        % turn off masks
        for j =1:length(all_patches(i).UserData.Line_Boundary)
            all_patches(i).UserData.Line_Boundary(j).Visible = 'off';
        end
        all_patches(i).UserData.ImMask.Visible = 'off';
    end

elseif strcmp(src.SelectedObject.String,'Masks')
    %Mask visible
    for i =1:length(all_patches)
        
        % checking status_visible
        if strcmp(char(handles.Region_table.Data(i,2)),'1')
            status_visible ='on';
        else
            status_visible ='off';
        end
        
        % turn off patches
        all_patches(i).Visible = 'off';
        all_patches(i).UserData.Sticker.Visible = status_visible;
        color = all_patches(i).UserData.Color;
        % check selected
        if all_patches(i).UserData.Selected      
            %all_patches(i).UserData.ImMask.Visible = 'on'
            all_patches(i).UserData.ImMask.Visible = status_visible;
            for j =1:length(all_patches(i).UserData.Line_Boundary)
                all_patches(i).UserData.Line_Boundary(j).Visible = 'off';
            end
        else
            all_patches(i).UserData.ImMask.Visible = 'off';
            for j =1:length(all_patches(i).UserData.Line_Boundary)
                % all_patches(i).UserData.Line_Boundary(j).Visible = 'on';
                all_patches(i).UserData.Line_Boundary(j).Visible = status_visible;
            end
        end
    end
end

% updating selection
selection = [];
for ii =1:length(all_patches)
    if all_patches(ii).UserData.Selected
        index = find(strcmp(handles.Region_table.Data(:,1),all_patches(ii).UserData.Name)==1);
        selection = [selection ;index(1)];
    end
end
handles.Region_table.UserData.Selection = selection;
% handles.Region_table.Data(selection)

end

function uitable_select(hObj,evnt,handles)

if ~isempty(evnt.Indices)
    %hObj.UserData.Selection = unique(evnt.Indices(1,1));
    hObj.UserData.Selection = unique(evnt.Indices(:,1));
else
    hObj.UserData.Selection = [];
end

% Deselect all patches
patches = hObj.UserData.patches;
for i =1:length(patches)
     patches(i).UserData.Selected = 0;
     patches(i).UserData.Sticker.EdgeColor = 'k';
end
% Select  patches
selection = hObj.UserData.Selection;
if ~isempty(selection)
    for j =1:length(selection)
        index = selection(j);
        patches(index).UserData.Selected = 1;
        patches(index).UserData.Sticker.EdgeColor = 'w';
    end
end

% update selection aspect
radioMask_selection([],[],handles);
handles.Group_table.UserData.Selection = [];

end

function uitable_edit(hObj,evnt)

patches = hObj.UserData.patches;
tdata = hObj.Data(:,1);
selection = evnt.Indices(:,1);
tdata(selection)=[];

if sum(strcmp(tdata,evnt.NewData))>0
    warning('Region name already exists.');
    hObj.Data(selection,1) = {evnt.PreviousData};
else
    patches(selection).UserData.Name = char(evnt.NewData);
end

end

function uitablegroup_select(hObj,evnt,handles)

if ~isempty(evnt.Indices)
    %hObj.UserData.Selection = unique(evnt.Indices(1,1));
    hObj.UserData.Selection = unique(evnt.Indices(:,1));
else
    hObj.UserData.Selection = [];
end

% Deselect all patches
patches = handles.Region_table.UserData.patches;
for i =1:length(patches)
     patches(i).UserData.Selected = 0;
     patches(i).UserData.Sticker.EdgeColor = 'k';
end

% Select  patches
selection = hObj.UserData.Selection;
all_patches = [];
if ~isempty(selection)
    for j =1:length(selection)
        index = selection(j);
        patches = hObj.UserData.groups(index).Patches;
        all_patches = [all_patches;patches];
    end
end
for i = 1:length(all_patches)
     all_patches(i).UserData.Selected = 1;
     all_patches(i).UserData.Sticker.EdgeColor = 'w';
end

% update selection aspect
radioMask_selection([],[],handles);
handles.Region_table.UserData.Selection = [];

end

function uitablegroup_edit(hObj,evnt)

tdata = hObj.Data;
selection = evnt.Indices(1);
tdata(selection)=[];

if sum(strcmp(tdata,evnt.NewData))>0
    warning('Group name already exists.');
    %hObj.Data(selection) = {char(evnt.PreviousData)};
    hObj.Data(selection) = {evnt.PreviousData};
else
    hObj.UserData.groups(selection).Name = char(evnt.NewData);
end

end

function click_l_cursor(hObj,~)

ax = hObj.Parent;
f = ax.Parent;
ax.UserData = 1;

f.Pointer = 'hand';
set(f,'WindowButtonMotionFcn', {@figure_motionFcn,ax});
set(f,'WindowButtonUpFcn', {@unclickFcn,ax});

end

function click_sticker(hObj,~,patch,handles)

if patch.UserData.Selected
    patch.UserData.Selected = 0;
    hObj.EdgeColor = 'k';
else
    patch.UserData.Selected = 1;
    hObj.EdgeColor = 'w';
end

% update selection aspect
radioMask_selection([],[],handles);

end

function figure_motionFcn(~,~,ax2)

pt_rp = ax2.CurrentPoint;
Xlim = ax2.XLim;
Ylim = ax2.YLim;
l_cursor = findobj(ax2,'Tag','T2');
text1 = findobj(ax2.Parent,'Tag','Text1');
im = findobj(ax2.Parent,'Tag','MainImage');

%Move Cursor
if(pt_rp(1,1)>Xlim(1) && pt_rp(1,1)<Xlim(2) && pt_rp(1,2)>Ylim(1) && pt_rp(1,2)<Ylim(2))
    l_cursor.XData = [round(pt_rp(1,1)) round(pt_rp(1,1))];
    im.CData = ax2.Parent.UserData.IM(:,:,round(pt_rp(1,1)));
    text1.String = sprintf('%d / %d',round(pt_rp(1,1)),round(ax2.XLim(2)));
end

end

function unclickFcn(f,~,ax)

set(f,'WindowButtonMotionFcn','');
set(f,'WindowButtonUpFcn', '');
ax.UserData = [];
f.Pointer = 'arrow';

end

function marker_motionFcn(hObj,evnt,line_marker,index_closest)

ax = line_marker.Parent;
pt_rp = ax.CurrentPoint;
Xlim = ax.XLim;
Ylim = ax.YLim;

%Move Cursor
if(pt_rp(1,1)>Xlim(1) && pt_rp(1,1)<Xlim(2) && pt_rp(1,2)>Ylim(1) && pt_rp(1,2)<Ylim(2))
    line_marker.XData(index_closest) = round(pt_rp(1,1));
    line_marker.YData(index_closest) = round(pt_rp(1,2));
end

end

function marker_unclickFcn(f,~)

set(f,'WindowButtonMotionFcn','');
set(f,'WindowButtonUpFcn', '');
f.Pointer = 'arrow';

end

function pu1_Callback(hObj,~,folder_name)

global IM;
temp = strtrim(hObj.String(hObj.Value,:));
f = hObj.Parent;
im = findobj(f,'Tag','MainImage');
l_cursor = findobj(f,'Tag','T2');
cur_im = l_cursor.XData(1);

switch temp
    case 'current'
        f.UserData.IM = IM;
        
    case 'source'
        fprintf('Loading Doppler_film ...\n');
        Dn = load(fullfile(folder_name,'Doppler.mat'),'Doppler_film');
        fprintf('===> Doppler_film loaded from %s.\n',fullfile(folder_name,'Doppler.mat'));
        f.UserData.IM = Dn.Doppler_film;
        
    case 'normalized'
        fprintf('Loading Doppler_normalized ...\n');
        Dn = load(fullfile(folder_name,'Doppler_normalized.mat'),'Doppler_normalized');
        fprintf('Doppler_normalized loaded : %s\n',fullfile(folder_name,'Doppler_normalized.mat'));
        f.UserData.IM = Dn.Doppler_normalized;
    
    case 'dB'
        fprintf('Loading Doppler_film ...\n');
        Dn = load(fullfile(folder_name,'Doppler.mat'),'Doppler_film');
        fprintf('===> dB Movie computed from %s [ref image: %d].\n',fullfile(folder_name,'Doppler.mat'),cur_im);
        f.UserData.IM = 20*log10(abs(Dn.Doppler_film)/max(max(abs(Dn.Doppler_film(:,:,cur_im)))));
        %f.UserData.IM = 20*log10(abs(IM)/max(max(abs(IM(:,:,cur_im)))));
end

im.CData = f.UserData.IM(:,:,cur_im);

end

function importButton_Callback(hObj,~,file_recording,handles)

global SEED_REGION;
f = hObj.Parent;
region_table = findobj(f,'Tag','Region_table');
ax = findobj(f,'Tag','AxEdit');
cb1 = findobj(f,'Tag','boxPref');
cb2 = findobj(f,'Tag','boxSuf');

load('Preferences.mat','GColors');
alpha = GColors.patch_transparency;
patch_width = GColors.patch_width;
alpha_mask = GColors.mask_transparency;

[files_regions,dir_regions] = uigetfile(fullfile(SEED_REGION,file_recording,'*.U8'),'Select Regions to Import','MultiSelect','on');

if dir_regions==0
    return;
end

files_regions = files_regions';
% Building regions structure
regions = struct('name',{},'mask',{},'patch_x',{},'patch_y',{});

% Sorting by name
pattern_list = {'ac';'s1bf';'lpta';'rs';'v2';'antcortex';'amidcortex';'pmidcortex';'postcortex';'neocortex';...
    'dg';'ca3';'ca2';'ca1';'fc';'subiculum';'dhpc';'vhpc';...
    'dthal';'vthal';'vpm';'po';'thalamus';'cpu';'gp';'hypothalrg'};
files_regions_sorted = [];
for i =1:length(pattern_list)
    pattern = strcat('_',pattern_list(i),'_');
    ind_sort = contains(lower(files_regions'),pattern);
    files_regions_sorted = [files_regions_sorted;files_regions(ind_sort)];
    files_regions(ind_sort)=[];
end
files_regions = [files_regions_sorted;files_regions];

% filling regions structure
for i=1:length(files_regions)
    filename = fullfile(dir_regions,char(files_regions(i)));
    fileID = fopen(filename,'r');
    raw = fread(fileID,8,'uint8')';
    X = raw(8);
    Y = raw(4);
    mask = fread(fileID,[X,Y],'uint8')';
    fclose(fileID);
    regions(i).name = char(files_regions(i));
    
    %regions(i).mask = mask';
    % Discrepant mask size
    X_ref = f.UserData.data_config.X;
    Y_ref = f.UserData.data_config.Y;
    pad_mask = padarray(mask',[abs(X-X_ref),abs(Y-Y_ref)],'post');
    newmask = pad_mask(1:X_ref,1:Y_ref);
    regions(i).mask = newmask;
    
    % Creating Patch
    [y,x]= find(mask'==1);
    try
        k = convhull(x,y);
        regions(i).patch_x = x(k);
        regions(i).patch_y = y(k);
    catch
        % Problem when points are colinear
        regions(i).patch_x = x;
        regions(i).patch_y = y ;
    end
end

%Largest Prefix
if ~cb1.Value
    pattern = char(regions(1).name);
    count=0;
    while (count <= length(pattern)) && (sum(contains({regions(:).name}',pattern(1:count)))== size({regions(:).name}',1))
        count = count+1;
    end
    prefix = pattern(1:count-1);
else
    prefix = '';
end
%Largest Suffix
if ~cb2.Value
    pattern = char(regions(1).name);
    count=0;
    while (count <= length(pattern)) && (sum(contains({regions(:).name}',pattern(end-count+1:end)))== size({regions(:).name}',1))
        count = count+1;
    end
    suffix = pattern(end-count+2:end);
else
    suffix = '';
end
for i=1:length(files_regions)
    root =  regions(i).name;
    regions(i).name = root(length(prefix)+1:end-length(suffix));
end

% Adding patches from regions structure
count = 0;
for i = 1:length(regions)
    % Color counter
    % color = rand(1,3);
    count = count+1;
    str = lower(char(regions(i).name));
    if contains(str,{'hpc';'ca1';'ca2';'ca3';'dg';'fc';'subic';'lent'})
        delta = 10;
    elseif contains(str,{'thal';'vpm';'po';'cpu-';'gp';'septal'})
        delta = 20;
    elseif contains(str,{'cortex';'rs';'ac';'s1';'lpta';'m12';'v1';'v2';'cg';'cx';'ptp'})
        delta = 0;
    else
        delta = 30;
    end
    ind_color = min(delta+count,length(f.UserData.Colormap));
    color = f.UserData.Colormap(ind_color,:);
    
    % Patch creation
    hq = patch('XData',regions(i).patch_x,...
        'YData',regions(i).patch_y,...
        'FaceColor','none',...
        'EdgeColor',color,...
        'Tag',char(regions(i).name),...
        'FaceAlpha',.5,...
        'LineWidth',1,...
        'Visible','on',...
        'Parent',ax);
    % adding mask
    cdata = repmat(permute(color,[3,1,2]),[size(regions(i).mask,1),size(regions(i).mask,2)]);
    im_mask = image('CData',cdata,...
        'Parent',ax,...
        'Tag','ImageMask',...
        'Hittest','off',...
        'AlphaData',alpha_mask*regions(i).mask,...
        'Visible','off');
    % adding boundary
    B = bwboundaries(regions(i).mask);
    line_boundary=[];
    for j=1:length(B)
        boundary = B{j};
        l = line('XData',boundary(:,2),'YData',boundary(:,1),...
            'Color',color,...
            'Parent',ax,...
            'Tag','Boundary',...
            'Hittest','off',...
            'Visible','off');
        line_boundary = [line_boundary;l];
    end
    % adding sticker
    if handles.boxSticker.Value
        sticker_status = 'on';
    else
        sticker_status = 'off';
    end
    sticker = text(mean(boundary(:,2)),mean(boundary(:,1)),char(regions(i).name),...
        'FontSize',6,...
        'BackgroundColor',color,...
        'EdgeColor','k',...
        'Parent',ax,...
        'Tag','Sticker',...
        'Visible',sticker_status);
    sticker.UserData.Patch = hq;
    set(sticker,'ButtonDownFcn',{@click_sticker,hq,handles});
    
    % Updating UserData
    s.Name = char(regions(i).name);
    s.Mask = regions(i).mask;
    s.Selected = 0;
    s.Color = color;
    s.Alpha = alpha;
    s.Line_Boundary = line_boundary;
    s.ImMask = im_mask;
    s.Sticker = sticker;
    hq.UserData = s;
    
    %update table
    region_table.UserData.patches = [region_table.UserData.patches;hq];
    region_table.Data = [region_table.Data;[{regions(i).name},{'1'}]];
end

end

function exportButton_Callback(hObj,~,file_recording)

global SEED_REGION;
f = hObj.Parent;
region_table = findobj(f,'Tag','Region_table');

if ~exist(fullfile(SEED_REGION,file_recording),'dir')
    %rmdir(fullfile(SEED_REGION,file_recording),'s');
    mkdir(fullfile(SEED_REGION,file_recording));
end

% Export Selection
[ind_export,v] = listdlg('Name','Region Exportation','PromptString','Select Regions to export',...
        'SelectionMode','multiple','ListString',region_table.Data(:,1),'InitialValue',[],'ListSize',[300 500]);

% return if selection empty
if v==0 || isempty(ind_export)
    return;
end

for i=1:length(ind_export)
    p = region_table.UserData.patches(ind_export(i));
    mask = p.UserData.Mask;
    X = size(p.UserData.Mask,2);
    Y = size(p.UserData.Mask,1);
    z=0;
    % Writing into file
    filename = strcat('NLab-reg_',p.UserData.Name,sprintf('_%d_%d.U8',X,Y));
    filename_full = fullfile(SEED_REGION,file_recording,filename);
    fileID = fopen(filename_full,'w');
    fwrite(fileID,z,'uint8');
    fwrite(fileID,z,'uint8');
    fwrite(fileID,z,'uint8');
    fwrite(fileID,X,'uint8');
    fwrite(fileID,z,'uint8');
    fwrite(fileID,z,'uint8');
    fwrite(fileID,z,'uint8');
    fwrite(fileID,Y,'uint8');
    fwrite(fileID,mask,'uint8');
    fclose(fileID);
    fprintf('NLab region successfully exported [%s].\n',filename);
end
%fprintf('NLab regions successfully exported [%s].\n',fullfile(SEED_REGION,file_recording));

end

function axedit_clickFcn(hObj,~,handles)
% Called when user clicks into AxEdit for sticker selection

f = hObj.Parent;

%load('Preferences.mat','GDisp','GTraces');
pt_cp = round(get(hObj,'CurrentPoint'));
Xlim = get(hObj,'XLim');
Ylim = get(hObj,'YLim');

% finding stickers positions
all_stickers = findobj(handles.AxEdit,'Tag','Sticker');
all_stickers_positions = [];
for i=1:length(all_stickers)
    all_stickers_positions = [all_stickers_positions ; all_stickers(i).Position];
end
all_stickers_positions = all_stickers_positions(:,1:2);

if pt_cp(1,1)>Xlim(1) && pt_cp(1,1)<Xlim(2) && pt_cp(1,2)>Ylim(1) && pt_cp(1,2)<Ylim(2)
    set(f,'Pointer','crosshair');            
    
    % User click in RightAxes for Box Selection
    x = [pt_cp(1,1),pt_cp(1,1),pt_cp(1,1),pt_cp(1,1)];
    y = [pt_cp(1,2),pt_cp(1,2),pt_cp(1,2),pt_cp(1,2)];
    %Patch
    patch('XData',x,'YData',y,...
        'FaceColor','none',...
        'EdgeColor','w',...
        'Tag','Movable_Box',...
        'FaceAlpha',.5,...
        'LineWidth',1,...
        'LineStyle',':',...
        'Parent',handles.AxEdit);
    
    set(f,'WindowButtonMotionFcn', {@f_motionFcn,handles,all_stickers,all_stickers_positions});
    set(f,'WindowButtonUpFcn',{@f_unclickFcn,handles,all_stickers,all_stickers_positions});
end

end

function f_motionFcn(hObj,~,handles,all_stickers,all_stickers_positions)        

pt2 = round(get(handles.AxEdit,'CurrentPoint'));
Xlim2 = get(handles.AxEdit,'XLim');
Ylim2 = get(handles.AxEdit,'YLim');

if(pt2(1,1)>Xlim2(1) && pt2(1,1)<Xlim2(2) && pt2(1,2)>Ylim2(1) && pt2(1,2)<Ylim2(2))
    if strcmp(get(hObj,'Pointer'),'arrow')
        set(hObj,'Pointer','crosshair');
    end
    
    if ~isempty(findobj(handles.AxEdit,'Tag','Movable_Box'))
        reg = findobj(handles.AxEdit,'Tag','Movable_Box');
        reg.XData(3) = pt2(1,1);
        reg.XData(4) = pt2(1,1);
        reg.YData(2) = pt2(1,2);
        reg.YData(3) = pt2(1,2);
    end
    
else
    set(hObj,'Pointer','arrow');
end

end

function f_unclickFcn(hObj,~,handles,all_stickers,all_stickers_positions)

reg = findobj(handles.AxEdit,'Tag','Movable_Box');
if handles.boxSticker.Value
    % finding selected sticker
    X = all_stickers_positions(:,1);
    Y = all_stickers_positions(:,2);
    X1 = reg.XData(2);
    X2 = reg.XData(3);
    Y1 = reg.YData(1);
    Y2 = reg.YData(2);
    ind_x = ((X-X1).*(X-X2))<=0;
    ind_y = ((Y-Y1).*(Y-Y2))<=0;
    %ind_xy = find(ind_x.*ind_y==1);
    selected_stickers = all_stickers(ind_x.*ind_y==1);
else
    selected_stickers = [];
end

% updating selection
for i=1:length(selected_stickers)
    p = selected_stickers(i).UserData.Patch;
    p.UserData.Selected = 1-p.UserData.Selected;
    if p.UserData.Selected == 1
        selected_stickers(i).EdgeColor = 'w';
    else
        selected_stickers(i).EdgeColor = 'k';
    end
end
% update layout
radioMask_selection([],[],handles);

% Delete Movable Box
set(hObj,'Pointer','arrow');
set(hObj,'WindowButtonMotionFcn','');
set(hObj,'WindowButtonUp','');
delete(reg);

end

%% NeuroShop functions

function success = set_interactive_Neuroshop(ax,val)
% Add graphical controls for Atlas registration based on Neuroshop code
% if ax.UserData.data_atlas not empty, uses existing parameters
% else initialize NeuroShop structure 
% Store registration in ax.UserData.NeuroShop

success = false;

% val indicates callback provenance (0 : batch mode - 1 : user mode)
if nargin < 2
    val=1;
end

% Initialization
setappdata(0,'UseNativeSystemDialogs',0);
set(0,'DefaultLineLineSmoothing','on')
set(0,'DefaultPatchLineSmoothing','on')
H = 750;

fig = ax.Parent;
%fig.UserData.success = false;
fig.UserData.val = val;

%test_temp  = false ;
if ~isempty(ax.UserData.data_atlas)
    d = ax.UserData.data_atlas;
    NeuroShop.AtlasType = d.AtlasType;
    NeuroShop.AtlasName = d.AtlasName;
    NeuroShop.AtlasOn = d.AtlasOn;
    NeuroShop.BregmaXY = d.BregmaXY;
    NeuroShop.BregmaZ = d.BregmaZ;
    NeuroShop.scaleX = d.scaleX;
    NeuroShop.scaleY = d.scaleY;
    NeuroShop.scaleZ = d.scaleZ;
    NeuroShop.theta = d.theta;
    NeuroShop.phi = d.phi;
    NeuroShop.xyfig = d.xyfig;
    NeuroShop.PatchCorner = d.PatchCorner;
else
    NeuroShop.AtlasType = 1;      % 1 = rat coronal ; 2 = rat sagital ; 3 =  souris coronal ; 4 = souris sagital
    NeuroShop.AtlasName = 'RatAtlasCor';
    NeuroShop.AtlasOn = 1;
end
% Initialize NeuroShop
NeuroShop.JustMoved = 0;
NeuroShop.fig = fig;
NeuroShop.CustomROIs.Nb = 0;
NeuroShop.MaskType = 0;
NeuroShop.MaskErodeSize = 0;  % mm
NeuroShop.MaskDiskNx = 15;
NeuroShop.MaskDiskNz = 10;
NeuroShop.MaskDiskWidth = 14; % mm
NeuroShop.MaskDiskDepth = 10; % mm

% Passing ax to NeuroShop
NeuroShop.ax = ax;
NeuroShop.hmsg = text(100,H/3,'[Loading Atlas data ...]',...
    'Units','Pixels','FontSize',16,'Color',[0.6 0.6 0.6],...
    'BackgroundColor','w','Parent',NeuroShop.ax);
drawnow;

% Storing NeuroShop in ax.UserData
ax.UserData.NeuroShop = NeuroShop;

% default Atlas loading
%fprintf('Loading Atlas data...');
fig.Pointer = 'watch';
drawnow;
NeuroShop_LoadAtlas_Image(NeuroShop.AtlasType,ax);
%fprintf(' done.\n');
fig.Pointer = 'arrow';

% Image loading
% NeuroShop_LoadImage([],[],ax);

%NeuroShop = UpdateView(NeuroShop,ax);
UpdateView(ax);

% Wait for figure closing
% waitfor(fig);
% NeuroShop.fig.UserData.success = true;
success = true;

end

function NeuroShop_LoadAtlas_Image(type,ax)

%global NeuroShop;
% Retrieving NeuroShop from ax.UserData
NeuroShop = ax.UserData.NeuroShop;

% Loading Atlas
switch type
    case 1
        %load('./Atlas/Rat/AtlasCor.mat');
        load('AtlasCor.mat');
        NeuroShop.AtlasName='RatAtlasCor';
        NeuroShop.Atlas=AtlasCor;
        for fig=1:length(NeuroShop.Atlas.Fig)
            for k=1:length(NeuroShop.Atlas.Fig{fig}.Plot.Id)
                NeuroShop.Atlas.Fig{fig}.Plot.Id{k}.xy=NeuroShop.Atlas.Fig{fig}.Plot.Id{k}.x;
            end
        end
        NeuroShop.Atlas.XY=NeuroShop.Atlas.X;
        NeuroShop.Atlas.V=NeuroShop.Atlas.Y;
    case 2
        %load('./Atlas/Rat/AtlasSag.mat');
        load('AtlasSag.mat');
        NeuroShop.AtlasName='RatAtlasSag';
        NeuroShop.Atlas=AtlasSag;
        for fig=1:length(NeuroShop.Atlas.Fig);for k=1:length(NeuroShop.Atlas.Fig{fig}.Plot.Id);NeuroShop.Atlas.Fig{fig}.Plot.Id{k}.xy=NeuroShop.Atlas.Fig{fig}.Plot.Id{k}.y;end;end
        NeuroShop.Atlas.XY=NeuroShop.Atlas.Y;
        NeuroShop.Atlas.V=NeuroShop.Atlas.X;
    case 3
        %load('./Atlas/Mouse/MouseAtlasCor.mat');
        load('MouseAtlasCor.mat');
        NeuroShop.AtlasName='MouseAtlasCor';
        NeuroShop.Atlas=AtlasCor;
        for fig=1:length(NeuroShop.Atlas.Fig);for k=1:length(NeuroShop.Atlas.Fig{fig}.Plot.Id);NeuroShop.Atlas.Fig{fig}.Plot.Id{k}.xy=NeuroShop.Atlas.Fig{fig}.Plot.Id{k}.x;end;end
        NeuroShop.Atlas.XY=NeuroShop.Atlas.X;
        NeuroShop.Atlas.V=NeuroShop.Atlas.Y;
    case 4
        %load('./Atlas/Mouse/MouseAtlasSag.mat');
        load('MouseAtlasSag.mat');
        NeuroShop.AtlasName='MouseAtlasSag';
        NeuroShop.Atlas=AtlasSag;
        for fig=1:length(NeuroShop.Atlas.Fig);for k=1:length(NeuroShop.Atlas.Fig{fig}.Plot.Id);NeuroShop.Atlas.Fig{fig}.Plot.Id{k}.xy=NeuroShop.Atlas.Fig{fig}.Plot.Id{k}.y;end;end
        NeuroShop.Atlas.XY=NeuroShop.Atlas.Y;
        NeuroShop.Atlas.V=NeuroShop.Atlas.X;
    case 5
        %load('./Atlas/Mouse/MouseAtlasCorAllen.mat');
        load('MouseAtlasCorAllen.mat');
        NeuroShop.AtlasName='MouseAtlasCorAllen';
        NeuroShop.Atlas=AtlasCor;
        for fig=1:length(NeuroShop.Atlas.Fig);for k=1:length(NeuroShop.Atlas.Fig{fig}.Plot.Id);NeuroShop.Atlas.Fig{fig}.Plot.Id{k}.xy=NeuroShop.Atlas.Fig{fig}.Plot.Id{k}.x;end;end
        NeuroShop.Atlas.XY=NeuroShop.Atlas.X;
        NeuroShop.Atlas.V=NeuroShop.Atlas.Y;
    case 6
        NeuroShop.AtlasOn = ~NeuroShop.AtlasOn;
        type = NeuroShop.AtlasType;
end

NeuroShop.AtlasType=type;
% if ~isempty(obj)
%     NeuroShop = UpdateView(NeuroShop,ax);
% end

% Loading Image
im = findobj(ax.Parent,'Tag','MainImage');
NeuroShop.Data.DopplerView = im.CData;
if ~isfield(NeuroShop.Data,'dr')
    NeuroShop.Data.dr=0.08;
    NeuroShop.Data.drz=0.1;
end
NeuroShop.MaskVisibility=0;

% Storing NeuroShop in ax.UserData
ax.UserData.NeuroShop = NeuroShop;

end

function UpdateView(ax)

%global NeuroShop
% Retrieving NeuroShop from ax.UserData
NeuroShop = ax.UserData.NeuroShop;

set(0,'DefaultLineLineSmoothing','on')
set(0,'DefaultPatchLineSmoothing','on')
Doppler = NeuroShop.Data.DopplerView;

s = size(Doppler);
Mz1 = size(Doppler,1);
My1 = size(Doppler,2);
H = 1.2*Mz1;
L = 1.2*(My1);
lcolors = lines(32);
atlascolor = [1 1 1];

if ~isfield(NeuroShop,'BregmaXY')
    NeuroShop.BregmaXY=round(My1/2);
end
if ~isfield(NeuroShop,'BregmaZ')
    NeuroShop.BregmaZ=10;
end

if ~isfield(NeuroShop,'scaleX')
    NeuroShop.scaleX=1;
end
if ~isfield(NeuroShop,'scaleY')
    NeuroShop.scaleY=1;
end
if ~isfield(NeuroShop,'scaleZ')
    NeuroShop.scaleZ=1;
end

% accelerate drawing
if ~isfield(NeuroShop.Atlas.Fig{1},'XY')
    for fig=1:length(NeuroShop.Atlas.Fig)
        NeuroShop.Atlas.Fig{fig}.XY=[];
        NeuroShop.Atlas.Fig{fig}.Z=[];
        for k=2:length(NeuroShop.Atlas.Fig{fig}.Plot.Id)
            NeuroShop.Atlas.Fig{fig}.XY=[NeuroShop.Atlas.Fig{fig}.XY -NeuroShop.Atlas.Fig{fig}.Plot.Id{k}.xy*1e3 NaN];
            NeuroShop.Atlas.Fig{fig}.Z=[NeuroShop.Atlas.Fig{fig}.Z NeuroShop.Atlas.Fig{fig}.Plot.Id{k}.z*1e3 NaN];
        end
    end
    
%     if isfield(NeuroShop,'xyfig')
%         NeuroShop = rmfield(NeuroShop,'xyfig');
%     end
end

if ~isfield(NeuroShop,'theta')
    NeuroShop.theta=0;
    NeuroShop.phi=0;
end

if ~isfield(NeuroShop,'xyfig')
    [a,b]=min(abs(NeuroShop.Atlas.V));
    NeuroShop.xyfig=b;
    %NeuroShop = CreateRegionMask(NeuroShop);
end

if ~isfield(NeuroShop,'AP_bregma')
    NeuroShop.AP_bregma = 3.00 - ((NeuroShop.xyfig-11)/80)*9.96;
end

if ~isfield(NeuroShop,'AtlasVisible')
    NeuroShop.AtlasVisible = 1;
end

% set(NeuroShop.hmsg,'String','');
delete(NeuroShop.hmsg);

Z = (((1:size(Doppler,1))-1)-NeuroShop.BregmaZ)*NeuroShop.Data.drz;
X = (((1:size(Doppler,2))-1)-NeuroShop.BregmaXY)*NeuroShop.Data.dr;
S.X = X;
S.Z = Z;
S.Doppler = Doppler;

if NeuroShop.MaskVisibility==0

    % Deleting existing objects
    delete(findobj(NeuroShop.fig,'Tag','TemporaryAtlasMask'));
    delete(findobj(NeuroShop.fig,'Tag','AtlasHandle'));
    
    if(NeuroShop.AtlasOn)
        [line_x,line_z]=rot_scaled(NeuroShop.Atlas.Fig{NeuroShop.xyfig}.XY*NeuroShop.scaleX,...
            NeuroShop.Atlas.Fig{NeuroShop.xyfig}.Z*NeuroShop.scaleZ,NeuroShop.theta,S);
        line('XData',line_x,'YData',line_z,'LineWidth',1,'Color',atlascolor,...
            'Tag','TemporaryAtlasMask','Parent',ax);
    
        mz = 2*NeuroShop.scaleZ;
        mx = 2*NeuroShop.scaleX;
        NeuroShop.PatchCorner{1}=[mz mx];
        % hold on;
        
        % Storing NeuroShop in ax.UserData
        ax.UserData.NeuroShop = NeuroShop;

        [x,z]=rot_scaled([-mx mx],[0 0],NeuroShop.theta,S);
        line('XData',x,'YData',z,'LineStyle','--','LineWidth',2,'Color',[1 1 1],'Parent',ax,'Tag','AtlasHandle');
        [x,z]=rot_scaled([-mx mx],[mz mz],NeuroShop.theta,S);
        line('XData',x,'YData',z,'LineStyle','--','LineWidth',1,'Color',[1 1 1],'Parent',ax,'Tag','AtlasHandle');
        [x,z]=rot_scaled([mx mx],[0 mz],NeuroShop.theta,S);
        line('XData',x,'YData',z,'LineStyle','--','LineWidth',1,'Color',[1 1 1],'Parent',ax,'Tag','AtlasHandle');
        [x,z]=rot_scaled([-mx -mx],[0 mz],NeuroShop.theta,S);
        line('XData',x,'YData',z,'LineStyle','--','LineWidth',1,'Color',[1 1 1],'Parent',ax,'Tag','AtlasHandle');
        [x,z]=rot_scaled([-mx-0.5 -mx+0.5],[mz-1 mz+1],NeuroShop.theta,S);
        line('XData',x,'YData',z,'LineWidth',2,'Color',[1 1 1],'Parent',ax,'Tag','AtlasHandle');
        % Interactive Control
        [x,z]=rot_scaled([2 2 -2 -2]*0.1,[2 -2 -2 2]*0.1,NeuroShop.theta,S);
        patch(x,z,'w','ButtonDownFcn',{@ClickPatchBregma,ax},'Parent',ax,'Tag','AtlasHandle');
        [x,z]=rot_scaled([2 2 -2 -2]*0.1,mz+[2 -2 -2 2]*0.1,NeuroShop.theta,S);
        patch(x,z,'w','ButtonDownFcn',{@ClickPatchMove,ax},'Parent',ax,'Tag','AtlasHandle');
        [x,z]=rot_scaled([2 2 -2 -2]*0.1+NeuroShop.Atlas.V(NeuroShop.xyfig)/4,[2 -2 -2 2]*0.1+Z(1),0,S);
        patch(x,z,'w','ButtonDownFcn',{@ClickPatchViewPaxinos,ax},'Parent',ax,'Tag','AtlasHandle');
        [x,z]=rot_scaled(mx+[2 2 -2 -2]*0.1,mz+[2 -2 -2 2]*0.1,NeuroShop.theta,S);
        patch(x,z,'w','ButtonDownFcn',{@ClickPatchCorner,ax},'Parent',ax,'Tag','AtlasHandle');
        [x,z]=rot_scaled(-mx+[2 2 -2 -2]*0.1,mz+[2 -2 -2 2]*0.1,NeuroShop.theta,S);
        patch(x,z,'w','ButtonDownFcn',{@ClickPatchCornerRotate,ax},'Parent',ax,'Tag','AtlasHandle');
        % Making Visible/invisible
        all_temp = findobj(NeuroShop.fig,'Tag','TemporaryAtlasMask');
        all_handles = findobj(NeuroShop.fig,'Tag','AtlasHandle');
        if NeuroShop.AtlasVisible ==0
            all_temp.Visible = 'off';
            for i=1:length(all_handles)
                all_handles(i).Visible ='off';
            end
        else
            all_temp.Visible = 'on';
            for i=1:length(all_handles)
                all_handles(i).Visible ='on';
            end
        end
                
        ax.XLabel.String = 'mm';
        ax.XLabel.FontSize = 16;
        ax.YLabel.String = 'mm';
        ax.XLabel.FontSize = 16;
        
        set(NeuroShop.fig,'KeyPressFcn',{@SlideChange,ax});
    end
else
    % Drawing Mask
    Mask = NeuroShop.Data.Mask(1:4:end,1:4:end,:);
    hold(ax,'on');
    im = imagesc('YData',1:size(Mask,1),'XData',1:size(Mask,2),'CData',squeeze(Mask(:,:,NeuroShop.MaskType)),...
        'Parent',ax,'Tag','MaskImage','AlphaData',double(squeeze(Mask(:,:,NeuroShop.MaskType)))>0);
    pause(1);
    delete(im);
    %colormap default;
    %axis image;
end

if rem(NeuroShop.AtlasType,2)==1
    % title(['Figure ' num2str(NeuroShop.xyfig)] ,'FontSize',16)
    ax.Title.String = sprintf('[Atlas Coronal] Plate %d - Bregma = %.2f mm',NeuroShop.xyfig,NeuroShop.AP_bregma);
    ax.Title.FontSize = 16;

else
    if NeuroShop.AtlasType == 2
        pageSagittal=[180:-1:162 162:180];
    else
        pageSagittal=[132:-1:101 101:132];
    end
    % title(['Figure ' num2str(pageSagittal(NeuroShop.xyfig))] ,'FontSize',16)
    ax.Title.String = ['Figure ' num2str(pageSagittal(NeuroShop.xyfig))];
    ax.Title.FontSize = 16;  
end

%axis([X(1) X(end) Z(1) Z(end)])
drawnow;

end

function [u,v] = rot_scaled(x,y,angle,S)

X = S.X;
Z = S.Z;
Doppler = S.Doppler;

Mrot=[cos(angle) -sin(angle); sin(angle) cos(angle)];
if ~isempty(x)
    uv=Mrot'*[x;y];
    u=uv(1,:);
    v=uv(2,:);   
    u = ((u-X(1))/(X(end)-X(1)))*size(Doppler,2);
    v = ((v-Z(1))/(Z(end)-Z(1)))*size(Doppler,1);      
else
    u=[];v=[];
end

end

function SlideChange(~,src,ax)
%global NeuroShop

% Retrieving NeuroShop from ax.UserData
NeuroShop = ax.UserData.NeuroShop;

switch src.Key
    case 'b'
        NeuroShop.AtlasVisible = 1-NeuroShop.AtlasVisible;
    case 'leftarrow'
        NeuroShop.BregmaXY=NeuroShop.BregmaXY-0.5;
    case 'rightarrow'
        NeuroShop.BregmaXY=NeuroShop.BregmaXY+0.5;
    case 'uparrow'
        NeuroShop.BregmaZ=NeuroShop.BregmaZ-0.5;
    case 'downarrow'
        NeuroShop.BregmaZ=NeuroShop.BregmaZ+0.5;
    case 'z'
        NeuroShop.xyfig = NeuroShop.xyfig+1;
        NeuroShop.AP_bregma = 3.00 - ((NeuroShop.xyfig-11)/80)*9.96;
    case 'x'
        NeuroShop.xyfig=NeuroShop.xyfig-1;
        NeuroShop.AP_bregma = 3.00 - ((NeuroShop.xyfig-11)/80)*9.96;
    case 'c'
        NeuroShop.theta=NeuroShop.theta-0.005;
    case 'v'
        NeuroShop.theta=NeuroShop.theta+0.005;
    case 'n'
        NeuroShop.scaleX=NeuroShop.scaleX-0.005;
        NeuroShop.scaleY=NeuroShop.scaleY-0.005;
        NeuroShop.scaleZ=NeuroShop.scaleZ-0.005;
    case 'm'
        NeuroShop.scaleX=NeuroShop.scaleX+0.005;
        NeuroShop.scaleY=NeuroShop.scaleY+0.005;
        NeuroShop.scaleZ=NeuroShop.scaleZ+0.005;
end

% Storing NeuroShop in ax.UserData
ax.UserData.NeuroShop = NeuroShop;

UpdateView(ax);

end

% @ClickPatchBregma
function ClickPatchBregma(~,~,ax)

%global NeuroShop
% Retrieving NeuroShop from ax.UserData
NeuroShop = ax.UserData.NeuroShop;
fig = ax.Parent;

if NeuroShop.JustMoved==1
    NeuroShop.JustMoved=0;
else
    set(fig,'Pointer','cross');
    set (fig, 'WindowButtonUpFcn', {@stopUpdateBregma,ax});
    set (fig, 'WindowButtonMotionFcn', {@mouseMoveBregma,ax});
    NeuroShop.JustMoved=1;
end

% Storing NeuroShop in ax.UserData
ax.UserData.NeuroShop = NeuroShop;

end

function mouseMoveBregma(~,~,ax)

%global NeuroShop
% Retrieving NeuroShop from ax.UserData
NeuroShop = ax.UserData.NeuroShop;
Doppler = NeuroShop.Data.DopplerView;
Z = (((1:size(Doppler,1))-1)-NeuroShop.BregmaZ)*NeuroShop.Data.drz;
X = (((1:size(Doppler,2))-1)-NeuroShop.BregmaXY)*NeuroShop.Data.dr;

A=get(NeuroShop.ax, 'CurrentPoint');
u=A(1,1);
v=A(1,2);

% Rescaling coordinates
u = X(1)+(X(end)-X(1))*(u/size(Doppler,2));
v = Z(1)+(Z(end)-Z(1))*(v/size(Doppler,1));

NeuroShop.BregmaZ = NeuroShop.BregmaZ+v/NeuroShop.Data.dr;
NeuroShop.BregmaXY = NeuroShop.BregmaXY+u/NeuroShop.Data.dr;

% Storing NeuroShop in ax.UserData
ax.UserData.NeuroShop = NeuroShop;

UpdateView(ax);

end

function stopUpdateBregma(~,~,ax)

fig = ax.Parent;
ax.UserData.NeuroShop.JustMoved=0;

%set (gcf, 'WindowButtonMotionFcn', @DisplayRegionInfo);
set (fig, 'WindowButtonMotionFcn', '');
%set (fig, 'WindowButtonDownFcn', '');
set (fig, 'WindowButtonUpFcn', '');
set(fig,'Pointer','arrow');
%CreateRegionMask();

end

% @ClickPatchMove
function ClickPatchMove(~,~,ax)

disp('patch move');

%global NeuroShop
% Retrieving NeuroShop from ax.UserData
NeuroShop = ax.UserData.NeuroShop;
fig = ax.Parent;

if NeuroShop.JustMoved==1
    NeuroShop.JustMoved=0;
else
    set(fig,'Pointer','cross');
    set (fig, 'WindowButtonUpFcn', {@stopUpdateMove,ax});
    set (fig, 'WindowButtonMotionFcn', {@mouseMoveMove,ax});
    NeuroShop.JustMoved=1;
end

% Storing NeuroShop in ax.UserData
ax.UserData.NeuroShop = NeuroShop;

end

function mouseMoveMove(~,~,ax)

%global NeuroShop
% Retrieving NeuroShop from ax.UserData
NeuroShop = ax.UserData.NeuroShop;
Doppler = NeuroShop.Data.DopplerView;
Z = (((1:size(Doppler,1))-1)-NeuroShop.BregmaZ)*NeuroShop.Data.drz;
X = (((1:size(Doppler,2))-1)-NeuroShop.BregmaXY)*NeuroShop.Data.dr;

mzx=NeuroShop.PatchCorner{1};
mz=mzx(1);
A=get(NeuroShop.ax,'CurrentPoint');
u=A(1,1);
v=A(1,2);

% Rescaling coordinates
u = X(1)+(X(end)-X(1))*(u/size(Doppler,2));
v = Z(1)+(Z(end)-Z(1))*(v/size(Doppler,1));

NeuroShop.BregmaZ=NeuroShop.BregmaZ+(v-mz)/NeuroShop.Data.dr;
NeuroShop.BregmaXY=NeuroShop.BregmaXY+u/NeuroShop.Data.dr;

% Storing NeuroShop in ax.UserData
ax.UserData.NeuroShop = NeuroShop;

UpdateView(ax);
    
end

function stopUpdateMove(~,~,ax)

fig = ax.Parent;
ax.UserData.NeuroShop.JustMoved=0;
%set (gcf, 'WindowButtonMotionFcn', @DisplayRegionInfo);
set (fig, 'WindowButtonMotionFcn', '');
%set (fig, 'WindowButtonDownFcn', '');
set (fig, 'WindowButtonUpFcn', '');
set(fig,'Pointer','arrow');
%CreateRegionMask();

end

% @ClickPatchViewPaxinos
function ClickPatchViewPaxinos(~,~,ax)

%global NeuroShop
% Retrieving NeuroShop from ax.UserData
NeuroShop = ax.UserData.NeuroShop;
fig = ax.Parent;

if NeuroShop.JustMoved==1
    NeuroShop.JustMoved=0;
else
    set(fig,'Pointer','right');
    set (fig, 'WindowButtonUpFcn', {@stopUpdatePaxinos,ax});
    set (fig, 'WindowButtonMotionFcn', {@mouseMovePaxinos,ax});
    NeuroShop.JustMoved=1;
end

% Storing NeuroShop in ax.UserData
ax.UserData.NeuroShop = NeuroShop;

end

function mouseMovePaxinos(~,~,ax)

%global NeuroShop
% Retrieving NeuroShop from ax.UserData
NeuroShop = ax.UserData.NeuroShop;
Doppler = NeuroShop.Data.DopplerView;
Z = (((1:size(Doppler,1))-1)-NeuroShop.BregmaZ)*NeuroShop.Data.drz;
X = (((1:size(Doppler,2))-1)-NeuroShop.BregmaXY)*NeuroShop.Data.dr;

A=get(NeuroShop.ax, 'CurrentPoint');
u=A(1,1);
v=A(1,2);

% Rescaling coordinates
u = X(1)+(X(end)-X(1))*(u/size(Doppler,2));
v = Z(1)+(Z(end)-Z(1))*(v/size(Doppler,1));

[a,b]=min(abs(NeuroShop.Atlas.V/4-u));
NeuroShop.xyfig=b;
NeuroShop.AP_bregma = 3.00 - ((NeuroShop.xyfig-11)/80)*9.96;

% Storing NeuroShop in ax.UserData
ax.UserData.NeuroShop = NeuroShop;

UpdateView(ax);

end

function stopUpdatePaxinos(~,~,ax)

fig = ax.Parent;
ax.UserData.NeuroShop.JustMoved=0;
%set (gcf, 'WindowButtonMotionFcn', @DisplayRegionInfo);
set (fig, 'WindowButtonMotionFcn', '');
%set (fig, 'WindowButtonDownFcn', '');
set (fig, 'WindowButtonUpFcn', '');
set(fig,'Pointer','arrow');
%CreateRegionMask();

end

% @ClickPatchCorner
function ClickPatchCorner(~,~,ax)

disp('patch corner');

%global NeuroShop
% Retrieving NeuroShop from ax.UserData
NeuroShop = ax.UserData.NeuroShop;
fig = ax.Parent;

if NeuroShop.JustMoved==1
    NeuroShop.JustMoved=0;
else
    set(fig,'Pointer','cross');
    set (fig, 'WindowButtonUpFcn', {@stopUpdateCorner,ax});
    set (fig, 'WindowButtonMotionFcn', {@mouseMoveCorner,ax});
    NeuroShop.JustMoved=1;
end

% Storing NeuroShop in ax.UserData
ax.UserData.NeuroShop = NeuroShop;

end

function mouseMoveCorner(~,~,ax)

%global NeuroShop
% Retrieving NeuroShop from ax.UserData
NeuroShop = ax.UserData.NeuroShop;
Doppler = NeuroShop.Data.DopplerView;
Z = (((1:size(Doppler,1))-1)-NeuroShop.BregmaZ)*NeuroShop.Data.drz;
X = (((1:size(Doppler,2))-1)-NeuroShop.BregmaXY)*NeuroShop.Data.dr;

A=get(NeuroShop.ax,'CurrentPoint');
u=A(1,1);
v=A(1,2);

% Rescaling coordinates
u = X(1)+(X(end)-X(1))*(u/size(Doppler,2));
v = Z(1)+(Z(end)-Z(1))*(v/size(Doppler,1));

scale1=NeuroShop.scaleZ*(v/NeuroShop.PatchCorner{1}(1));
scale2=NeuroShop.scaleY*(u/NeuroShop.PatchCorner{1}(2));
scale=1-min(1-scale1,1-scale2);
NeuroShop.scaleX=scale2;
NeuroShop.scaleY=scale2;
NeuroShop.scaleZ=scale1;

% Storing NeuroShop in ax.UserData
ax.UserData.NeuroShop = NeuroShop;

UpdateView(ax);
drawnow ; 

end

function stopUpdateCorner(~,~,ax)

fig = ax.Parent;
ax.UserData.NeuroShop.JustMoved=0;
%set (gcf, 'WindowButtonMotionFcn', @DisplayRegionInfo);
set (fig, 'WindowButtonMotionFcn', '');
%set (fig, 'WindowButtonDownFcn', '');
set (fig, 'WindowButtonUpFcn', '');
set(fig,'Pointer','arrow');
%CreateRegionMask();

end

% @ClickPatchCornerRotate
function ClickPatchCornerRotate(~,~,ax)

disp('patch move');

%global NeuroShop
% Retrieving NeuroShop from ax.UserData
NeuroShop = ax.UserData.NeuroShop;
fig = ax.Parent;

if NeuroShop.JustMoved==1
    NeuroShop.JustMoved=0;
else  
    set(fig,'Pointer','cross');
    set (fig, 'WindowButtonUpFcn', {@stopUpdateRotate,ax});
    set (fig, 'WindowButtonMotionFcn', {@mouseMoveRotate,ax});
    NeuroShop.JustMoved=1;
end

% Storing NeuroShop in ax.UserData
ax.UserData.NeuroShop = NeuroShop;

end

function mouseMoveRotate(~,~,ax)

%global NeuroShop
% Retrieving NeuroShop from ax.UserData
NeuroShop = ax.UserData.NeuroShop;
Doppler = NeuroShop.Data.DopplerView;
Z = (((1:size(Doppler,1))-1)-NeuroShop.BregmaZ)*NeuroShop.Data.drz;
X = (((1:size(Doppler,2))-1)-NeuroShop.BregmaXY)*NeuroShop.Data.dr;

A=get(NeuroShop.ax, 'CurrentPoint');
u=A(1,1);
v=A(1,2);

% Rescaling coordinates
u = X(1)+(X(end)-X(1))*(u/size(Doppler,2));
v = Z(1)+(Z(end)-Z(1))*(v/size(Doppler,1));

NeuroShop.theta=-atan((NeuroShop.PatchCorner{1}(1)-v)./(NeuroShop.PatchCorner{1}(2)-u));

% Storing NeuroShop in ax.UserData
ax.UserData.NeuroShop = NeuroShop;

UpdateView(ax);
drawnow;

end

function stopUpdateRotate(~,~,ax)

fig = ax.Parent;
ax.UserData.NeuroShop.JustMoved=0;
%set (gcf, 'WindowButtonMotionFcn', @DisplayRegionInfo);
set (fig, 'WindowButtonMotionFcn', '');
%set (fig, 'WindowButtonDownFcn', '');
set (fig, 'WindowButtonUpFcn', '');
set(fig,'Pointer','arrow');
%CreateRegionMask();

end

function [u,v]=rot(x,y,angle)
Mrot=[cos(angle) -sin(angle); sin(angle) cos(angle)];
if ~isempty(x)
uv=Mrot'*[x;y];
u=uv(1,:);
v=uv(2,:);
else
    u=[];v=[];
end
end

function CreateMask(MaskType,ax)

%global NeuroShop;
% Retrieving NeuroShop from ax.UserData
NeuroShop = ax.UserData.NeuroShop;
% S.Doppler = NeuroShop.Data.DopplerView;
% S.Z = (((1:size(S.Doppler,1))-1)-NeuroShop.BregmaZ)*NeuroShop.Data.drz;
% S.X = (((1:size(S.Doppler,2))-1)-NeuroShop.BregmaXY)*NeuroShop.Data.dr;

% ROIs based mask
[m,n]=size(NeuroShop.Data.DopplerView);
Mask=zeros(4*m,4*n);
N=length(NeuroShop.Atlas.Fig{NeuroShop.xyfig}.Plot.Id);
for k=2:N
    [x,z]=rot(NeuroShop.Atlas.Fig{NeuroShop.xyfig}.Plot.Id{k}.xy*NeuroShop.scaleX*1e3,...
        NeuroShop.Atlas.Fig{NeuroShop.xyfig}.Plot.Id{k}.z*NeuroShop.scaleZ*1e3,NeuroShop.theta);
%     [x,z]=rot_scaled(NeuroShop.Atlas.Fig{NeuroShop.xyfig}.Plot.Id{k}.xy*NeuroShop.scaleX*1e3,...
%         NeuroShop.Atlas.Fig{NeuroShop.xyfig}.Plot.Id{k}.z*NeuroShop.scaleZ*1e3,NeuroShop.theta,S);
    xk=x/(NeuroShop.Data.dr/4)+NeuroShop.BregmaXY*4;
    zk=z/(NeuroShop.Data.drz/4)+NeuroShop.BregmaZ*4;
    Pk=poly2mask(xk,zk,4*m,4*n);
    l=k;
    Mask(find(Pk))=l;
end

Mask2=zeros(4*m,4*n);
N=length(NeuroShop.Atlas.Fig{NeuroShop.xyfig}.Plot.Id);
se = ones(round(NeuroShop.MaskErodeSize/NeuroShop.Data.dr*4),round(NeuroShop.MaskErodeSize/NeuroShop.Data.drz*4));
for k=2:N
    Pk=(Mask==k);
    Pk=imclose(Pk,ones(9,9));
    if ~isempty(se)
        Pk = imerode(Pk,se);
    end
    Mask2(find(Pk))=k;
end

% Correct bug Sagittal Atlas (Rat)
if strcmp(NeuroShop.AtlasName,'RatAtlasSag')
    Mask2 = fliplr(Mask2);
end
NeuroShop.Data.Mask(:,:,1)=Mask2;

% Unsupervised mask
Mask=zeros(4*m,4*n);
MaskDiskPitchZ=NeuroShop.MaskDiskDepth/(NeuroShop.MaskDiskNz-1);
MaskDiskPitchX=NeuroShop.MaskDiskWidth/(NeuroShop.MaskDiskNx-1);
MaskDiskDiameter=min(MaskDiskPitchX,MaskDiskPitchZ)*0.9;

[Z,X]=ndgrid((0:MaskDiskPitchZ:NeuroShop.MaskDiskDepth)*NeuroShop.scaleZ,(-NeuroShop.MaskDiskWidth/2:MaskDiskPitchX:NeuroShop.MaskDiskWidth/2)*NeuroShop.scaleX);
[u,v]=rot(X(:)',Z(:)',NeuroShop.theta);X=reshape(u',size(X));Z=reshape(v',size(Z));
% [u,v]=rot_scaled(X(:)',Z(:)',NeuroShop.theta,S);X=reshape(u',size(X));Z=reshape(v',size(Z));
[Zm,Xm]=ndgrid(0:4*m-1,0:4*n-1);
Zm=(Zm-NeuroShop.BregmaZ*4)*NeuroShop.Data.drz/4;
Xm=(Xm-NeuroShop.BregmaXY*4)*NeuroShop.Data.dr/4;

k=1;
for i=1:size(X,1)
    for j=1:size(X,2)
        k=k+1;
        M=(sqrt( (Xm-X(i,j)).^2+(Zm-Z(i,j)).^2 )<=MaskDiskDiameter/2*NeuroShop.scaleX);
        Mask(find(M))=k;
    end
end

NeuroShop.Data.Mask(:,:,2)=Mask;

% Customs ROIs (roipoly)
[m,n]=size(NeuroShop.Data.DopplerView);
Mask=zeros(4*m,4*n);
N=NeuroShop.CustomROIs.Nb;
for k=1:N
    [x,z]=rot(NeuroShop.CustomROIs.Ids{k}.xy*NeuroShop.scaleX,NeuroShop.CustomROIs.Ids{k}.z*NeuroShop.scaleZ,NeuroShop.theta);
    % [x,z]=rot_scaled(NeuroShop.CustomROIs.Ids{k}.xy*NeuroShop.scaleX,NeuroShop.CustomROIs.Ids{k}.z*NeuroShop.scaleZ,NeuroShop.theta,S);
    xk=x/(NeuroShop.Data.dr/4)+NeuroShop.BregmaXY*4;
    zk=z/(NeuroShop.Data.drz/4)+NeuroShop.BregmaZ*4;
    Pk=poly2mask(xk,zk,4*m,4*n);
    l=k;
    Mask(find(Pk))=l;
end

Mask2=zeros(4*m,4*n);
N=NeuroShop.CustomROIs.Nb;
se = ones(round(NeuroShop.MaskErodeSize/NeuroShop.Data.dr*4),round(NeuroShop.MaskErodeSize/NeuroShop.Data.drz*4));
for k=1:N
    Pk=(Mask==k);
    Pk=imclose(Pk,ones(9,9));
    if ~isempty(se)
        Pk = imerode(Pk,se);
    end
    Mask2(find(Pk))=k;
end
NeuroShop.Data.Mask(:,:,3)=Mask2;

if MaskType==0
    NeuroShop.MaskVisibility=0;
else
    NeuroShop.MaskVisibility=1;
end

NeuroShop.MaskType=MaskType;

% Storing NeuroShop in ax.UserData
ax.UserData.NeuroShop = NeuroShop;

UpdateView(ax);
drawnow;

end

function ExportMask(savedir,ax)
% Saves Mask information in Atlas.mat

% global NeuroShop 
% Retrieving NeuroShop from ax.UserData
NeuroShop = ax.UserData.NeuroShop;
fig = ax.Parent;

Mask = NeuroShop.Data.Mask(1:4:end,1:4:end,:);
AtlasType = NeuroShop.AtlasType;
AtlasOn = NeuroShop.AtlasOn;
AtlasName = NeuroShop.AtlasName;
scaleX = NeuroShop.scaleX;
scaleY = NeuroShop.scaleY;
scaleZ = NeuroShop.scaleZ;
FigName = NeuroShop.xyfig;
xyfig = NeuroShop.xyfig;
PatchCorner = NeuroShop.PatchCorner;
BregmaXY = NeuroShop.BregmaXY;
BregmaZ = NeuroShop.BregmaZ;
theta = NeuroShop.theta;
phi = NeuroShop.phi;
AP_bregma = NeuroShop.AP_bregma;

temp_atlas = findobj(fig,'Tag','TemporaryAtlasMask');
line_x = temp_atlas.XData;
line_z = temp_atlas.YData;
NeuroShop.line_x = line_x;
NeuroShop.line_z = line_z;

% Saving Atlas.mat
if exist(fullfile(savedir,'Atlas.mat'),'file')
    delete(fullfile(savedir,'Atlas.mat'));
    fprintf('File Atlas.mat updated.\n==> [%s].\n',fullfile(savedir,'Atlas.mat'));
else
    fprintf('File Atlas.mat created via Neuroshop.\n==> [%s].\n',fullfile(savedir,'Atlas.mat'));
end
save(fullfile(savedir,'Atlas.mat'),'Mask','AtlasType','AtlasOn','AtlasName',...
    'scaleX','scaleY','scaleZ','xyfig','FigName','PatchCorner','AP_bregma',...
    'BregmaXY','BregmaZ','theta','phi','line_x','line_z');

% Storing NeuroShop in ax.UserData
ax.UserData.NeuroShop = NeuroShop;

end