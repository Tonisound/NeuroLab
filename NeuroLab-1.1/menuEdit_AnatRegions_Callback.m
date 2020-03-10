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
    'Position',[0 0 1 1],...
    'Parent',mP,...
    'Tag','TabGroup');
tab1 = uitab('Parent',tabgp,...
    'Units','normalized',...
    'Title','Regions',...
    'Tag','MainTab');
tab2 = uitab('Parent',tabgp,...
    'Units','normalized',...
    'Title','Groups',...
    'Tag','SecondTab');

table_region = uitable('Units','normalized',...
    'ColumnFormat',{'char'},...
    'ColumnWidth',{w_col},...
    'ColumnEditable',false,...
    'ColumnName','',...
    'Data',[],...
    'RowName','',...
    'Tag','Region_table',...
    'RowStriping','on',...
    'Parent',tab1);
table_region.CellEditCallback = {@uitable_edit};
table_region.UserData.Selection = [];

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
% radioMask = uicontrol('Style','radiobutton',...
%     'Units','normalized',...
%     'String','Patches|Masks',...
%     'TooltipString','Display masks or patches',...
%     'Value',1,...
%     'Tag','radioMask',...
%     'Parent',f);
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
    'String','Edit names',...
    'TooltipString','Enable Table Edition',...
    'Value',0,...
    'Tag','boxEdit',...
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
drawButton = uicontrol('Style','pushbutton',...
    'Units','normalized',...
    'String','Draw',...
    'Tag','drawButton',...
    'Parent',f);
applyButton = uicontrol('Style','pushbutton',...
    'Units','normalized',...
    'String','Apply',...
    'Tag','applyButton',...
    'Parent',f);
removeButton = uicontrol('Style','pushbutton',...
    'Units','normalized',...
    'String','Remove',...
    'Tag','removeButton',...
    'Parent',f);
mergeButton = uicontrol('Style','pushbutton',...
    'Units','normalized',...
    'String','Merge',...
    'Tag','mergeButton',...
    'Parent',f);

% Import buttons
registerButton = uicontrol('Style','pushbutton',...
    'Units','normalized',...
    'String','Register Atlas',...
    'Enable','off',...
    'Tag','registerButton',...
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
% Adjust Columns
mP.Units = 'pixels';
table_region.ColumnWidth ={mP.Position(3)-w_margin};
mP.Units = 'normalized';
%table_region.ColumnWidth = 1;
bg.Position = [.01 .89 .09 .06];
boxAtlas.Position = [.11 .89 .09 .03];
boxEdit.Position = [.01 .86 .09 .03];
boxSticker.Position = [.11 .92 .09 .03];
boxPref.Position = [.11 .86 .09 .03];
boxSuf.Position = [.11 .83 .09 .03];
newButton.Position = [.825 .9 .15 .05];
drawButton.Position = [.825 .85 .15 .05];
applyButton.Position = [.825 .8 .15 .05];
removeButton.Position = [.825 .75 .15 .05];
mergeButton.Position = [.825 .7 .15 .05];
registerButton.Position = [.825 .55 .15 .05];
importButton.Position = [.825 .5 .15 .05];
exportButton.Position = [.825 .45 .15 .05];
t1.Position = [.915 .3 .06 .04];
pu1.Position = [.825 .3 .09 .05];
ax_mean.Position = [.825 .2 .15 .1];
okButton.Position = [.825 .1 .15 .05];
cancelButton.Position = [.825 .05 .15 .05];

% Callback attribution
handles2 = guihandles(f);
table_region.CellSelectionCallback = {@uitable_select,handles2};
bg.SelectionChangedFcn = {@radioMask_selection,handles2};
set(newButton,'Callback',{@newButton_callback,handles2});
set(drawButton,'Callback',{@drawButton_callback,handles2});
set(applyButton,'Callback',{@applyButton_callback,handles2});
set(removeButton,'Callback',{@removeButton_callback,handles2});
set(mergeButton,'Callback',{@mergeButton_callback,handles2});
set(okButton,'Callback',{@okButton_callback,handles,handles2,val});
set(cancelButton,'Callback',{@cancelButton_callback,handles2});
set(boxAtlas,'Callback',{@boxAtlas_Callback,handles2.AxEdit});
set(boxEdit,'Callback',{@boxEdit_Callback,handles2});
set(boxSticker,'Callback',{@boxSticker_Callback,handles2});
set(importButton,'Callback',{@importButton_Callback,file_recording,handles2});
set(exportButton,'Callback',{@exportButton_Callback,file_recording});

% Interactive Control
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
    table_region.Data = cellstr(str_popup);
    table_region.UserData.patches = patches;
else
    table_region.Data = [];
    table_region.UserData.patches = [];
end

waitfor(f);
success = true;

end

function newButton_callback(~,~,handles)

answer = inputdlg('Enter Region Name','Region creation',[1 60]);
if ~isempty(handles.Region_table.Data)
    while contains(char(answer),handles.Region_table.Data)
        answer = inputdlg('Enter Region Name','Invalid name (Region already exists)',[1 60]);
    end
end

if isempty(answer)
    return;
end

% Getting dots
drawButton_callback(handles.drawButton,[],handles);

% Patch creation
load('Preferences.mat','GColors');
color = rand(1,3);
alpha = GColors.patch_transparency;
patch_width = GColors.patch_width;
alpha_mask = GColors.mask_transparency;

hq = patch('XData',handles.drawButton.UserData.xdata,...
    'YData',handles.drawButton.UserData.ydata,...
    'FaceColor','none',...
    'EdgeColor',color,...
    'Tag',char(answer),...
    'FaceAlpha',alpha,...
    'LineWidth',patch_width,...
    'Visible','on',...
    'Parent',handles.AxEdit);
delete(findobj(handles.AxEdit,'Tag','Marker'));
delete(findobj(handles.AxEdit,'Tag','Line'));
handles.drawButton.UserData = [];

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
handles.Region_table.Data = [handles.Region_table.Data;answer];

end

function drawButton_callback(hObj,~,handles)
% Draw new temporary patch

marker_size = 5;
line_width = 1;
marker_type = 'o';
marker_color = 'r';

delete(findobj(handles.AxEdit,'Tag','Marker'));
delete(findobj(handles.AxEdit,'Tag','Line'));

xdata = [];
ydata = [];
handles.EditFigure.CurrentAxes = handles.AxEdit;
[x,y,button] = ginput(1);
x = round(x);
y = round(y);

while button==1
    % marker
    line(x,y,'Tag','Marker','Marker',marker_type,'MarkerSize',marker_size,...
        'MarkerFaceColor',marker_color,'MarkerEdgeColor',marker_color,'Parent',handles.AxEdit)
    % line
    if ~isempty(xdata)
        line([x,xdata(end)],[y,ydata(end)],'Tag','Line',...
            'LineWidth',line_width,'Color',marker_color,'Parent',handles.AxEdit);
    end
    xdata = [xdata;x];
    ydata = [ydata;y];
    [x,y,button] = ginput(1);
end

if length(xdata)>1
    line([xdata(1),xdata(end)],[ydata(1),ydata(end)],'Tag','Line',...
        'LineWidth',line_width,'Color',marker_color,'Parent',handles.AxEdit);
end

if ~isempty(xdata)
    hObj.UserData.xdata = xdata;
    hObj.UserData.ydata = ydata;
end

end

function applyButton_callback(~,~,handles)
% Apply changes in the Edit Figure

load('Preferences.mat','GColors');
global IM;

if ~isempty(handles.drawButton.UserData)
    xdata = handles.drawButton.UserData.xdata;
    ydata = handles.drawButton.UserData.ydata;
    selection = handles.Region_table.UserData.Selection;
    
    if ~isempty(selection)
        % apply only to first region
        selection = selection(1);
        str = char(handles.Region_table.Data(selection,:));
        p = findobj(handles.EditFigure,'Tag',str);
        p.XData = xdata;
        p.YData = ydata;
        
        % mask update
        x_mask = size(IM,1);
        y_mask = size(IM,2);
        new_mask = double(poly2mask(p.XData,p.YData,x_mask,y_mask));
        p.UserData.Mask = new_mask;
        
        % update mask image
        alpha_mask = GColors.mask_transparency;
        p.UserData.ImMask.AlphaData = alpha_mask*new_mask;

        % update boundary
        delete(p.UserData.Line_Boundary);
        B = bwboundaries(new_mask);
        line_boundary = [];
        for j=1:length(B)
            boundary = B{j};
            l = line('XData',boundary(:,2),'YData',boundary(:,1),...
                'Color',p.FaceColor,...
                'Parent',handles.AxEdit,...
                'Tag','Boundary',...
                'Hittest','off',...
                'Visible','off');
            line_boundary = [line_boundary;l];
        end
        p.UserData.Line_Boundary = line_boundary;
        
        % update sticker
        p.UserData.Sticker.Position(1) = mean(boundary(:,2));
        p.UserData.Sticker.Position(2) = mean(boundary(:,1));
    else
        errordlg('Select region to update.');
        return;
    end
    
    delete(findobj(handles.AxEdit,'Tag','Marker'));
    delete(findobj(handles.AxEdit,'Tag','Line'));
    handles.drawButton.UserData = [];
end

end

function removeButton_callback(~,~,handles)
% Remove temporary or selected patch

selection = handles.Region_table.UserData.Selection;

if ~isempty(handles.drawButton.UserData)
    % deleting after Draw button
    delete(findobj(handles.AxEdit,'Tag','Marker'));
    delete(findobj(handles.AxEdit,'Tag','Line'));
    handles.drawButton.UserData = [];
elseif ~isempty(selection)
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
    errordlg('Select region to remove.');
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
        prefix = sprintf('MergedRegion(%d)[',size(D,1));
        for i=1:size(D,1)
            prefix = strcat(prefix,char(D(i,:)),'-');
        end
        prefix = strcat(prefix(1:end-1),']');
    end
    
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
    
    %update table
    handles.Region_table.UserData.patches = [handles.Region_table.UserData.patches;hq];
    handles.Region_table.Data = [handles.Region_table.Data;s.Name];
end

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

function boxEdit_Callback(src,~,handles)

table = handles.Region_table;
if src.Value
    table.ColumnEditable = true;
else
    table.ColumnEditable = false;
end

end

function boxSticker_Callback(src,~,handles)

sticks = findobj(handles.AxEdit,'Tag','Sticker');
for i =1:length(sticks)
    if src.Value
        sticks(i).Visible = 'on';
    else
        sticks(i).Visible = 'off';
    end
    % bringing on top
    uistack(sticks(i),'top');
end 

end

function radioMask_selection(~,~,handles)

src = handles.radioMask;
all_patches = findobj(handles.AxEdit,'Type','Patch','-not','Tag','Movable_Box');
%all_boundaries = findobj(handles.AxEdit,'Tag','Boundary');
%all_imagemasks = findobj(handles.AxEdit,'Tag','ImageMask');

if strcmp(src.SelectedObject.String,'Patches')
    %Patch visible
    for i =1:length(all_patches)
        all_patches(i).Visible = 'on';
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
    %Patch visible
    for i =1:length(all_patches)
         % turn off patches
        all_patches(i).Visible = 'off';
        color = all_patches(i).UserData.Color;
        % check selected
        if all_patches(i).UserData.Selected      
            all_patches(i).UserData.ImMask.Visible = 'on';
            for j =1:length(all_patches(i).UserData.Line_Boundary)
                all_patches(i).UserData.Line_Boundary(j).Visible = 'off';
            end
        else
            all_patches(i).UserData.ImMask.Visible = 'off';
            for j =1:length(all_patches(i).UserData.Line_Boundary)
                all_patches(i).UserData.Line_Boundary(j).Visible = 'on';
            end
        end
    end
end

% updating selection
selection = [];
for ii =1:length(all_patches)
    if all_patches(ii).UserData.Selected
        index = find(strcmp(handles.Region_table.Data,all_patches(ii).UserData.Name)==1);
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

end

function uitable_edit(hObj,evnt)

patches = hObj.UserData.patches;
selection = evnt.Indices(1);

if ~strcmp(patches(selection).UserData.Name,evnt.PreviousData)
    warning('Problem updating region name (Selection/Name Mismatch).');
else
    patches(selection).UserData.Name = char(evnt.NewData);
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
    region_table.Data = [region_table.Data;{regions(i).name}];
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
        'SelectionMode','multiple','ListString',region_table.Data,'InitialValue',[],'ListSize',[300 500]);

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

% finding selected sticker
reg = findobj(handles.AxEdit,'Tag','Movable_Box');
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

% updating selection
for i=1:length(selected_stickers)
    p = selected_stickers(i).UserData.Patch;
    p.UserData.Selected = 1-p.UserData.Selected;
end
% update layout
radioMask_selection([],[],handles);

% Delete Movable Box
set(hObj,'Pointer','arrow');
set(hObj,'WindowButtonMotionFcn','');
set(hObj,'WindowButtonUp','');
delete(reg);

end
