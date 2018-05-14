function actualize_plot(handles)
% Actualize Center Panel Plot and Right Panel Traces

global CUR_IM IM START_IM END_IM;
load('Preferences.mat','GDisp');

% Actualize Main image 
handles.MainImage.CData = IM(:,:,CUR_IM);
handles.RightAxes.XLim = [START_IM END_IM];

% Actualize Video
if ~isempty(handles.VideoAxes.UserData) && strcmp(handles.VideoFigure.Visible,'on')
    v = handles.VideoAxes.UserData.VideoReader;
    temp = datenum(handles.TimeDisplay.UserData(CUR_IM,:));
    v.CurrentTime = (temp-floor(temp))*24*3600;
    vidFrame = readFrame(v);
    handles.VideoAxes.UserData.Image.CData = vidFrame;
end

% Actualize Cursor
handles.Cursor.XData = [CUR_IM, CUR_IM];
handles.Cursor.YData = handles.RightAxes.YLim;
drawnow;

end