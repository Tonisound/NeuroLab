function buttonRescale_Callback(~,~,handles)
% 115 -- Rescale Button - Displays whole movie

global START_IM END_IM LAST_IM CUR_IM;
load('Preferences.mat','GDisp');

START_IM = 1;
END_IM = LAST_IM;
set(handles.CurrentImageDisplay,'String',sprintf('%d/%d',CUR_IM,END_IM));
% Adding Tag Name
handles.RightAxes.Title.String = sprintf('Tag WHOLE (%s - %s)',handles.TimeDisplay.UserData(1,:),handles.TimeDisplay.UserData(LAST_IM,:));
actualize_plot(handles);

end