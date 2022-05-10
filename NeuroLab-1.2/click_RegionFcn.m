function click_RegionFcn(hObj,evnt,handles)

%disp(hObj);
%disp(hObj.UserData.Name);
l = hObj.UserData;
%disp(l.UserData.Name);

seltype = get(handles.MainFigure,'SelectionType');

if strcmp(seltype,'normal')
    
    % Direct click
    if ~isempty(evnt) 
        hObj.UserData.UserData.Selected = 1-hObj.UserData.UserData.Selected;
        actualize_line_aspect(hObj.UserData);
    end

else
    choice = questdlg('Do you wish to discard current graphic object ?',...
        'User Confirmation','OK','Cancel','Cancel');
    if ~isempty(choice) && strcmp(choice,'OK')
        delete(hObj.UserData);
        delete(hObj);
    end
end

end