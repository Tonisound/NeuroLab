function click_PixelFcn(hObj,evnt,handles)
% Called when user clicks on Pixel

%disp(hObj.UserData.UserData.Name);
seltype = get(handles.MainFigure,'SelectionType');
load('Preferences.mat','GDisp');
coeff_increase = GDisp.coeff_increase;

if strcmp(seltype,'normal')
    handles.MainFigure.Pointer = 'hand';
    hObj.Tag = 'Movable_Pixel';
    hObj.UserData.Tag = 'Movable_Trace_Pixel';
    
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