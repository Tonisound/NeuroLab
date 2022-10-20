function click_PatchFcn(hObj,evnt,handles)
% Called when user clicks on Patch

%disp(hObj.UserData.UserData.Name);
seltype = get(handles.MainFigure,'SelectionType');

if strcmp(seltype,'normal')
    % left-click
    handles.MainFigure.Pointer = 'hand';
    hObj.Tag = 'Movable_Box';
    hObj.UserData.Tag = 'Movable_Trace_Box';
    
    % Direct click
    if ~isempty(evnt) 
        hObj.UserData.UserData.Selected = 1-hObj.UserData.UserData.Selected;
        actualize_line_aspect(hObj.UserData);
    end
    
    set(handles.MainFigure,'WindowButtonMotionFcn', {@centerPanel_motionFcn,handles});
    set(handles.MainFigure,'WindowButtonUpFcn',{@centerPanel_unclickFcn,handles});

elseif strcmp(seltype,'extend')
    % middle-click
    box_color = uisetcolor(hObj.MarkerFaceColor);
    hObj.MarkerFaceColor = box_color;
    hObj.UserData.Color = box_color;
    handles.MainFigure.Pointer = 'arrow';

elseif strcmp(seltype,'alt')
    % right-click
    delete(hObj.UserData);
    delete(hObj);
    restore_colors(handles);
    return;
end
% set(handles.MainFigure,'WindowButtonMotionFcn', {@centerPanel_motionFcn,handles});
% set(handles.MainFigure,'WindowButtonUpFcn',{@centerPanel_unclickFcn,handles});

end