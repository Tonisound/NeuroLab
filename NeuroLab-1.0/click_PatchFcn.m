function click_PatchFcn(hObj,~,handles)
% Called when user clicks on Patch

%disp(hObj);
disp(hObj.UserData.UserData.Name);
seltype = get(handles.MainFigure,'SelectionType');

if strcmp(seltype,'normal')
    handles.MainFigure.Pointer = 'hand';
    hObj.Tag = 'Movable_Box';
    hObj.UserData.Tag = 'Movable_Trace_Box';
    if hObj.EdgeColor == char2rgb('k')
        set(findobj(handles.CenterAxes,'Visible','on','-and','EdgeColor',char2rgb('w')),...
            'EdgeColor',char2rgb('k'),'LineWidth',1);
        hObj.EdgeColor = char2rgb('w');
        hObj.LineWidth = 2;
        hObj.Selected ='on';
        uistack(hObj.UserData.Trace,'top');
    else
        hObj.EdgeColor = char2rgb('k');
        hObj.LineWidth = 1;
        hObj.Selected ='off';
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