function menuView_Video_Callback(hObj,~,handles)

if strcmp(hObj.Checked,'on')
    hObj.Checked = 'off';
    handles.VideoFigure.Visible = 'off';
    %disp('hide video');
else
    hObj.Checked = 'on';
    handles.VideoFigure.Visible = 'on';
    %disp('show video');
end

end 