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
    all_frames = handles.VideoAxes.UserData.all_frames;
    handles.VideoAxes.UserData.Image.CData = all_frames(:,:,CUR_IM);
    
    % update text
    %t_str = datestr(data_video.t_ref(CUR_IM),'HH:MM:SS.FFF');
    %handles.VideoAxes.UserData.Text.String = sprintf('Absolute Time: %s',t_str);
    t_str1 = datestr(handles.VideoAxes.UserData.t_ref(CUR_IM)/(24*3600),'HH:MM:SS.FFF');
    t_str2 = datestr(handles.VideoAxes.UserData.t_video(CUR_IM)/(24*3600),'HH:MM:SS.FFF');
    handles.VideoAxes.UserData.Text.String(1) = {sprintf('LFP Time: %s',t_str1)};
    handles.VideoAxes.UserData.Text.String(2) = {sprintf('Video Time: %s',t_str2)};
end

end 