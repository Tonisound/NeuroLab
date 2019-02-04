function f = edit_patches(handles)

%global DIR_SAVE FILES CUR_FILE 
global START_IM END_IM IM;

f = figure('Name','Anatomical Regions Edition',...
    'NumberTitle','off',...
    'Units','normalized',...
    'MenuBar','none',...
    'Tag','EditFigure');
colormap(f,'gray');
clrmenu(f);
%colormap(f,'jet');

ax = copyobj(handles.CenterAxes,f);
ax.Tag = 'AxEdit';
ax.TickLength = [0 0];
ax.XTickLabel = '';
ax.YTickLabel = '';
ax.XLabel.String ='';
ax.YLabel.String ='';
axis(ax,'off');

% Region Table
w_col = 60;
w_margin = 4;
table_region = uitable('Units','normalized',...
    'Position',[0 0 1 1],...
    'ColumnFormat',{'char'},...
    'ColumnWidth',{w_col},...
    'ColumnEditable',false,...
    'ColumnName','',...
    'Data',[],...
    'RowName','',...
    'Tag','Region_table',...
    'CellSelectionCallback',@uitable_select,...
    'RowStriping','on',...
    'Parent',f);
% Adjust Columns
table_region.Units = 'pixels';
table_region.ColumnWidth ={table_region.Position(3)-w_margin};
table_region.Units = 'normalized';
table_region.UserData.Selection = [];

% OK & CANCEL Buttons
boxMask = uicontrol('Style','checkbox',...
    'Units','normalized',...
    'String','Mask Display',...
    'Tag','boxMask',...
    'Parent',f);
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
table_region.Position = [.025 .05 .15 .9];

newButton.Position = [.825 .9 .15 .05];
drawButton.Position = [.825 .85 .15 .05];
applyButton.Position = [.825 .8 .15 .05];
removeButton.Position = [.825 .75 .15 .05];
boxMask.Position = [.825 .15 .15 .05];
okButton.Position = [.825 .1 .15 .05];
cancelButton.Position = [.825 .05 .15 .05];


handles2 = guihandles(f);
set(newButton,'Callback',{@newButton_callback,handles2});
set(drawButton,'Callback',{@drawButton_callback,handles2});
set(applyButton,'Callback',{@applyButton_callback,handles2});
set(removeButton,'Callback',{@removeButton_callback,handles2});
set(okButton,'Callback',{@okButton_callback,handles,handles2});
set(cancelButton,'Callback',{@cancelButton_callback,handles2});
set(boxMask,'Callback',{@boxMask_Callback,handles2});


% Changing main image
main_im = mean(IM(:,:,START_IM:END_IM),3);
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
    %patches(i).FaceAlpha = 0;
    patches(i).Visible = 'on';
    patches(i).EdgeColor = patches(i).FaceColor;
    patches(i).FaceColor ='none';
    patches(i).LineWidth = 1;
    patches(i).MarkerSize = 1;
    
    % changing Tag to handle patches
    patches(i).Tag = patches(i).UserData.UserData.Name;
    
    % changing patches UserData
    patches(i).Tag = patches(i).UserData.UserData.Name;
    name = patches(i).UserData.UserData.Name;
    mask = patches(i).UserData.UserData.Mask;
    patches(i).UserData = [];
    patches(i).UserData.Name = name;
    patches(i).UserData.Mask = mask;

end
table_region.Data = cellstr(str_popup);
table_region.UserData.patches = patches;

end

function newButton_callback(~,~,handles)

global IM;

answer = inputdlg('Enter Region Name','Region creation',[1 60]);
while contains(char(answer),handles.Region_table.Data)
    answer = inputdlg('Enter Region Name','Invalid name (Region already exists)',[1 60]);
end

if isempty(answer)
    return;
end

% Getting dots
drawButton_callback(handles.drawButton,[],handles);

% Patch creation
color = rand(1,3);
hq = patch('XData',handles.drawButton.UserData.xdata,...
    'YData',handles.drawButton.UserData.ydata,...
    'FaceColor','none',...
    'EdgeColor',color,...
    'Tag',char(answer),...
    'FaceAlpha',.5,...
    'LineWidth',1,...
    'Visible','on',...
    'Parent',handles.AxEdit);
delete(findobj(handles.AxEdit,'Tag','Marker'));
delete(findobj(handles.AxEdit,'Tag','Line'));
handles.drawButton.UserData = [];


% mask creation
x_mask = size(IM,1);
y_mask = size(IM,2);
new_mask = double(poly2mask(hq.XData,hq.YData,x_mask,y_mask));

% Updating UserData
s.Name = char(answer);
s.Mask = new_mask;
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
marker_color = 'w';

delete(findobj(handles.AxEdit,'Tag','Marker'));
delete(findobj(handles.AxEdit,'Tag','Line'));

xdata = [];
ydata = [];
[x,y,button] = ginput(1);
x = round(x);
y = round(y);

while button==1
    % marker
    line(x,y,'Tag','Marker','Marker',marker_type,'MarkerSize',marker_size,...
        'MarkerFaceColor','none','MarkerEdgeColor',marker_color,'Parent',handles.AxEdit);
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

global IM;

if ~isempty(handles.drawButton.UserData)
    xdata = handles.drawButton.UserData.xdata;
    ydata = handles.drawButton.UserData.ydata;
    selection = handles.Region_table.UserData.Selection;
    
    if ~isempty(selection)
        str = char(handles.Region_table.Data(selection,:));
        p = findobj(handles.EditFigure,'Tag',str);
        p.XData = xdata;
        p.YData = ydata;
        
        % mask creation
        x_mask = size(IM,1);
        y_mask = size(IM,2);
        new_mask = double(poly2mask(p.XData,p.YData,x_mask,y_mask));
        p.UserData.Mask = new_mask;
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
    delete(findobj(handles.AxEdit,'Tag','Marker'));
    delete(findobj(handles.AxEdit,'Tag','Line'));
    handles.drawButton.UserData = [];
elseif ~isempty(selection)
    delete(handles.Region_table.UserData.patches(selection));   
    handles.Region_table.UserData.patches(selection)=[];
    handles.Region_table.Data(selection,:)=[];
else
    errordlg('Select region to remove.');
    return;
end

end

function cancelButton_callback(~,~,handles2)
    close(handles2.EditFigure);
end

function okButton_callback(~,~,handles,handles2)
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
    boxLabel_Callback(handles.LabelBox,[],handles);
    boxPatch_Callback(handles.PatchBox,[],handles);
    
    % Updating UserData
    s.Name = p.UserData.Name;
    s.Mask = p.UserData.Mask;
    s.Graphic = hq;
    hq.UserData = hl;
    hl.UserData = s;
end


% Close figure and actualize traces
close(handles2.EditFigure);
actualize_traces(handles);

end

function boxMask_Callback(src,~,handles)

hm = findobj(handles.AxEdit,'Type','Patch','-not','Tag','Box');
im = findobj(handles.AxEdit,'Tag','MainImage');

if src.Value 
    %draw mask 
    for i =1:length(hm)
        color = hm(i).EdgeColor;
        color_mask = cat(3, color(1)*ones(size(im.CData)),color(2)*ones(size(im.CData)),color(3)*ones(size(im.CData)));
        mask = hm(i).UserData.Mask;
        image('CData',color_mask,...
            'Parent',handles.AxEdit,...
            'Tag','Mask',...
            'Hittest','off',...
            'AlphaData',edge(mask,'canny'));
        hm(i).Visible = 'off';
    end
    
else
    %draw mask
    delete(findobj(handles.AxEdit,'Tag','Mask'));
    for i =1:length(hm)
        hm(i).Visible = 'on';
    end
end

end

function uitable_select(hObj,evnt)

if ~isempty(evnt.Indices)
    hObj.UserData.Selection = unique(evnt.Indices(1,1));
else
    hObj.UserData.Selection = [];
end

% Highlight patch
patches = hObj.UserData.patches;
for i =1:length(patches)
     patches(i).LineWidth = 1;
     patches(i).FaceColor = 'none';
end
if ~isempty(hObj.UserData.Selection)
    patches(hObj.UserData.Selection).LineWidth = 2;
    patches(hObj.UserData.Selection).FaceColor = patches(hObj.UserData.Selection).EdgeColor;
end

end