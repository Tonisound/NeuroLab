function click_PixelFcn(hObj,~,handles)
% Called when user clicks on Pixel

%disp(hObj);
disp(hObj.UserData.UserData.Name);
seltype = get(handles.MainFigure,'SelectionType');
load('Preferences.mat','GDisp');
coeff_increase = GDisp.coeff_increase;

if strcmp(seltype,'normal')
    handles.MainFigure.Pointer = 'hand';
    hObj.Tag = 'Movable_Pixel';
    hObj.UserData.Tag = 'Movable_Trace_Pixel';
    if hObj.MarkerEdgeColor == char2rgb('k')
        others = findobj(handles.CenterAxes,'Visible','on','-and','MarkerEdgeColor',char2rgb('w'));
        set(others,'MarkerEdgeColor',char2rgb('k'),'LineWidth',1);
        for i =1:length(others)
            others(i).UserData.LineWidth = others(i).UserData.LineWidth/coeff_increase;
        end
        
        hObj.MarkerEdgeColor = char2rgb('w');
        hObj.LineWidth = 2;
        uistack(hObj.UserData,'top');
        hObj.UserData.LineWidth=coeff_increase*hObj.UserData.LineWidth;
    else
        hObj.MarkerEdgeColor = char2rgb('k');
        hObj.LineWidth = 1;
        hObj.UserData.LineWidth=hObj.UserData.LineWidth/coeff_increase;
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