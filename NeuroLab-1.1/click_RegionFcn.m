function click_RegionFcn(hObj,~,handles)

%disp(hObj);
%disp(hObj.UserData.Name);
l = hObj.UserData;
disp(l.UserData.Name);

seltype = get(handles.MainFigure,'SelectionType');
load('Preferences.mat','GDisp');
coeff_increase = GDisp.coeff_increase;

if strcmp(seltype,'normal')
    if hObj.EdgeColor == char2rgb('k')
        others = findobj(handles.CenterAxes,'Visible','on','-and','EdgeColor',char2rgb('w'));
        set(others,'EdgeColor',char2rgb('k'),'LineWidth',1);
        for i =1:length(others) 
            others(i).UserData.LineWidth = others(i).UserData.LineWidth/coeff_increase;
        end
        
        hObj.EdgeColor = char2rgb('w');
        hObj.LineWidth = 2;
        hObj.Selected ='on';
        hObj.UserData.LineWidth=coeff_increase*hObj.UserData.LineWidth;
    else
        hObj.EdgeColor = char2rgb('k');
        hObj.LineWidth = 1;
        hObj.Selected ='off';
        hObj.UserData.LineWidth=hObj.UserData.LineWidth/coeff_increase;
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