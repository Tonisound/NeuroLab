function f = edit_patches(handles)

%global DIR_SAVE FILES CUR_FILE 
global START_IM END_IM IM CUR_IM;

f = figure('Name','Edit Patches',...
    'Units','normalized',...
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
ax.Position = [.1 .1 .8 .85];

% OK & CANCEL Buttons
pu_region = uicontrol('Style','popup',...
    'Units','normalized',...
    'Position',[.1 .02 .3 .06],...
    'String','0',...
    'Tag','pu_region',...
    'Parent',f);
boxMask = uicontrol('Style','checkbox',...
    'Units','normalized',...
    'Position',[.02 .02 .04 .04],...
    'TooltipString','Mask Display',...
    'Tag','boxMask',...
    'Parent',f);
drawButton = uicontrol('Style','pushbutton',...
    'Units','normalized',...
    'Position',[.45 .02 .15 .06],...
    'String','Draw',...
    'Tag','drawButton',...
    'Parent',f);
applyButton = uicontrol('Style','pushbutton',...
    'Units','normalized',...
    'Position',[.6 .02 .15 .06],...
    'String','Apply',...
    'Tag','applyButton',...
    'Parent',f);
okButton = uicontrol('Style','pushbutton',...
    'Units','normalized',...
    'Position',[.75 .02 .15 .06],...
    'String','OK',...
    'Tag','okButton',...
    'Parent',f);


handles2 = guihandles(f);
set(pu_region,'Callback',{@pu_region_callback,handles2});
set(drawButton,'Callback',{@drawButton_callback,handles2});
set(applyButton,'Callback',{@applyButton_callback,handles2});
set(okButton,'Callback',{@okButton_callback,handles,handles2});
set(boxMask,'Callback',{@boxMask_Callback,handles2});


% Changing main image
main_im = mean(IM(:,:,START_IM:END_IM),3);
%ax.Title.String = sprintf('Image %d (time %s)',CUR_IM,handles.TimeDisplay.UserData(CUR_IM,:));
%main_im = IM(:,:,CUR_IM);
im = findobj(ax,'Tag','MainImage');
im.CData = main_im;

% Intialization
im.AlphaData = ones(size(main_im));
% Searching patches
patches = findobj(ax,'Tag','Region');
%patches = findobj(ax,'Tag','Region','-and','Visible','on');
str_popup = [];
for i = 1:length(patches)
    patches(i).Visible = 'on';
    patches(i).EdgeColor = patches(i).FaceColor;
    patches(i).FaceColor ='none';
    patches(i).LineWidth = 1;
    patches(i).MarkerSize =1;
    %patches(i).FaceAlpha = 0;
    str_popup = [str_popup;{patches(i).UserData.UserData.Name}];
    % changing Tag to handle patches
    patches(i).Tag = patches(i).UserData.UserData.Name;
end
pu_region.String = str_popup;
pu_region.UserData.patches = patches;

end

function pu_region_callback(hObj,~,handles)

patches = hObj.UserData.patches;
val = hObj.Value;

delete(findobj(handles.AxEdit,'Tag','Marker'));
delete(findobj(handles.AxEdit,'Tag','Line'));
handles.drawButton.UserData = [];

for i =1:length(patches)
    if i==val
        patches(i).Marker = 'square';
        patches(i).MarkerSize = 5;
        patches(i).MarkerFaceColor = 'k';
        patches(i).MarkerEdgeColor = [.5 .5 .5];
        patches(i).FaceColor = patches(i).EdgeColor;
    else
        patches(i).Marker = 'none';
        patches(i).MarkerSize = 1;
        patches(i).FaceColor = 'none';
    end
end


end

function drawButton_callback(hObj,~,handles)

delete(findobj(handles.AxEdit,'Tag','Marker'));
delete(findobj(handles.AxEdit,'Tag','Line'));

xdata = [];
ydata = [];
[x,y,button] = ginput(1);

while button==1
    % marker
    line(x,y,'Tag','Marker','Marker','o','MarkerSize',10,...
        'MarkerFaceColor','none','MarkerEdgeColor','w',...
        'Parent',handles.AxEdit);
    % line
    if ~isempty(xdata)
        line([x,xdata(end)],[y,ydata(end)],'Tag','Line',...
            'LineWidth',1,'Color','w','Parent',handles.AxEdit);
    end
    xdata = [xdata;x];
    ydata = [ydata;y];
    [x,y,button] = ginput(1);    
end

if length(xdata)>1
    line([xdata(1),xdata(end)],[ydata(1),ydata(end)],'Tag','Line',...
        'LineWidth',1,'Color','w','Parent',handles.AxEdit);
end

if ~isempty(xdata)
    hObj.UserData.xdata = xdata;
    hObj.UserData.ydata = ydata;
end

end

function applyButton_callback(~,~,handles)
% Apply changes in the Edit Figure

if ~isempty(handles.drawButton.UserData)
    xdata = handles.drawButton.UserData.xdata;
    ydata = handles.drawButton.UserData.ydata;
    
    str = char(handles.pu_region.String(handles.pu_region.Value,:));
    p = findobj(handles.EditFigure,'Tag',str);
    p.XData = xdata;
    p.YData = ydata;
    
    delete(findobj(handles.AxEdit,'Tag','Marker'));
    delete(findobj(handles.AxEdit,'Tag','Line'));
    handles.drawButton.UserData = [];
end

end

function okButton_callback(~,~,handles,handles2)
% Apply changes in the Main Figure

true_patches = findobj(handles.CenterAxes,'Tag','Region');
flag_change = false;

for i =1:length(true_patches)
    patch_name = true_patches(i).UserData.UserData.Name;
    new_patch = findobj(handles2.EditFigure,'Tag',patch_name);

    if length(true_patches(i).XData)~=length(new_patch.XData) || sum(true_patches(i).XData-round(new_patch.XData))~=0
        flag_change = true;
        % Update true patch
        true_patches(i).YData = round(new_patch.YData);
        true_patches(i).XData = round(new_patch.XData);
        % Update mask
        [x_mask,y_mask] = size(true_patches(i).UserData.UserData.Mask);
        new_mask = poly2mask(new_patch.XData,new_patch.YData,x_mask,y_mask);
        true_patches(i).UserData.UserData.Mask = double(new_mask);
    end
end

% Close figure and actualize traces
close(handles2.EditFigure);
if flag_change
    actualize_traces(handles);
end

end

function boxMask_Callback(src,~,handles)

hm = findobj(handles.AxEdit,'Type','Patch');
im = findobj(handles.AxEdit,'Tag','MainImage');

if src.Value 
    %draw mask 
    for i =1:length(hm)
        color = hm(i).EdgeColor;
        color_mask = cat(3, color(1)*ones(size(im.CData)),color(2)*ones(size(im.CData)),color(3)*ones(size(im.CData)));
        mask = hm(i).UserData.UserData.Mask;
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