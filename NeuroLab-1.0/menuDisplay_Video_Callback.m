function menuDisplay_Video_Callback(hObj,~,handles)

%disp('menu view')
global CUR_IM;

if strcmp(hObj.Checked,'on')
    %hide video
    hObj.Checked = 'off';
    handles.VideoFigure.Visible = 'off';

else
    %show video;
    hObj.Checked = 'on';
    handles.VideoFigure.Visible = 'on';
    
    %update frame
    v = handles.VideoAxes.UserData.VideoReader;
    temp = datenum(handles.TimeDisplay.UserData(CUR_IM,:));
    v.CurrentTime = (temp-floor(temp))*24*3600;
    vidFrame = readFrame(v);
    handles.VideoAxes.UserData.Image.CData = vidFrame;
    
end

end 