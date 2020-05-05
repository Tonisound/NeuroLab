function click_RegionFcn(hObj,~,handles)

%disp(hObj);
%disp(hObj.UserData.Name);
load('Preferences.mat','GColors');
l = hObj.UserData;
disp(l.UserData.Name);

seltype = get(handles.MainFigure,'SelectionType');
load('Preferences.mat','GDisp');
coeff_increase = GDisp.coeff_increase;

if strcmp(seltype,'normal')
    if strcmp(hObj.EdgeColor,'none') %hObj.EdgeColor == char2rgb('k')
        others = findobj(handles.CenterAxes,'Visible','on','-and','EdgeColor',char2rgb('w'));
        %set(others,'EdgeColor',char2rgb('k'),'LineWidth',1);
        set(others,'EdgeColor','none','LineWidth',1);
        for i =1:length(others) 
            others(i).UserData.LineWidth = others(i).UserData.LineWidth/coeff_increase;
        end
        
        hObj.EdgeColor = char2rgb('w');
        hObj.LineWidth = 2*GColors.patch_width;
        hObj.FaceAlpha = GColors.patch_transparency;
        hObj.Selected ='on';
        hObj.LineWidth = 2*GColors.patch_width;
        hObj.UserData.LineWidth=coeff_increase*hObj.UserData.LineWidth;
    else
        %hObj.EdgeColor = char2rgb('k');
        hObj.EdgeColor = GColors.patch_color;
        hObj.FaceAlpha = GColors.patch_transparency;
        hObj.Selected ='off';
        hObj.LineWidth = 1;
        hObj.UserData.LineWidth=1;
        hObj.LineWidth = GColors.patch_width;
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