function actualize_plot(handles)
% Actualize Center Panel Plot and Right Panel Traces

global CUR_IM IM START_IM END_IM;
load('Preferences.mat','GDisp');

handles.MainImage.CData = IM(:,:,CUR_IM);
handles.RightAxes.XLim = [START_IM END_IM];

% Actualize Cursor
handles.Cursor.XData = [CUR_IM, CUR_IM];
handles.Cursor.YData = handles.RightAxes.YLim;
drawnow;

end