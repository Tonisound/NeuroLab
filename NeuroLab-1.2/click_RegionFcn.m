function click_RegionFcn(hObj,evnt,handles)

%disp(hObj);
%disp(hObj.UserData.Name);
l = hObj.UserData;
%disp(l.UserData.Name);

seltype = get(handles.MainFigure,'SelectionType');

if strcmp(seltype,'normal')
    % left-click
    % Direct click
    if ~isempty(evnt) 
        hObj.UserData.UserData.Selected = 1-hObj.UserData.UserData.Selected;
        actualize_line_aspect(hObj.UserData);
    end

elseif strcmp(seltype,'extend')
    % middle-click
    region_color = uisetcolor(hObj.MarkerFaceColor);
    hObj.FaceColor = region_color;
    hObj.UserData.Color = region_color;
    handles.MainFigure.Pointer = 'arrow';
    
elseif strcmp(seltype,'alt')
    % right-click
    choice = questdlg('Do you wish to discard current graphic object ?',...
        'User Confirmation','OK','Cancel','Cancel');
    if ~isempty(choice) && strcmp(choice,'OK')
        delete(hObj.UserData);
        delete(hObj);
    end
end

end