function menuView_Video_Callback(hObj,~,handles)

%disp('menu view')

if strcmp(hObj.Checked,'on')
    %hide video
    hObj.Checked = 'off';
    handles.VideoFigure.Visible = 'off';

else
    %show video;
    hObj.Checked = 'on';
    handles.VideoFigure.Visible = 'on';
    
end

end 