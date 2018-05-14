function menuView_Video_Callback(hObj,~,handles)

if strcmp(hObj.Checked,'on')
    %hide video
    hObj.Checked = 'off';
    handles.VideoFigure.Visible = 'off';

else
    %show video;
    hObj.Checked = 'on';
    handles.VideoFigure.Visible = 'on';
    
    %look for video reader and update UserData
end

end 