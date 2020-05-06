function click_PatchFcn(hObj,evnt,handles)
% Called when user clicks on Patch

%disp(hObj.UserData.UserData.Name);
seltype = get(handles.MainFigure,'SelectionType');

if strcmp(seltype,'normal')
    handles.MainFigure.Pointer = 'hand';
    hObj.Tag = 'Movable_Box';
    hObj.UserData.Tag = 'Movable_Trace_Box';
    
    % Direct click
    if ~isempty(evnt) 
        hObj.UserData.UserData.Selected = 1-hObj.UserData.UserData.Selected;
        actualize_line_aspect(hObj.UserData);
    end
    
else
    delete(hObj.UserData);
    delete(hObj);
    restore_colors(handles);
    return;
end
set(handles.MainFigure,'WindowButtonMotionFcn', {@centerPanel_motionFcn,handles});
set(handles.MainFigure,'WindowButtonUpFcn',{@centerPanel_unclickFcn,handles});

end