function actualize_plot(handles)
% Actualize Center Panel Plot and Right Panel Traces

global CUR_IM IM START_IM END_IM;
load('Preferences.mat','GDisp');

% Actualize Main image 
handles.MainImage.CData = IM(:,:,CUR_IM);
handles.RightAxes.XLim = [START_IM END_IM];

% Actualize Video
if ~isempty(handles.VideoAxes.UserData) && strcmp(handles.VideoFigure.Visible,'on')
    %v = handles.VideoAxes.UserData.VideoReader;
    %temp = datenum(handles.TimeDisplay.UserData(CUR_IM,:));
    %v.CurrentTime = (temp-floor(temp))*24*3600;
    %vidFrame = readFrame(v);
    %handles.VideoAxes.UserData.Image.CData = vidFrame;
    
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

% Actualize Cursor
handles.Cursor.XData = [CUR_IM, CUR_IM];
handles.Cursor.YData = handles.RightAxes.YLim;
drawnow;

end