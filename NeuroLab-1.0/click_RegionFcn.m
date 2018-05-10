function click_RegionFcn(hObj,~,handles)

%disp(hObj);
%disp(hObj.UserData.Name);
l = hObj.UserData;
disp(l.UserData.Name);

seltype = get(handles.MainFigure,'SelectionType');

if strcmp(seltype,'normal')
    if hObj.EdgeColor == char2rgb('k')
        set(findobj(handles.CenterAxes,'Visible','on','-and','EdgeColor',char2rgb('w')),...
            'EdgeColor',char2rgb('k'),'LineWidth',1);
        hObj.EdgeColor = char2rgb('w');
        hObj.LineWidth = 2;
        hObj.Selected ='on';
    else
        hObj.EdgeColor = char2rgb('k');
        hObj.LineWidth = 1;
        hObj.Selected ='off';
    end
else
    delete(hObj.UserData);
    delete(hObj);
end

end