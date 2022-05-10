function buttonMinus_Callback(~,~,handles)
% 111 - Called when user zooms out

global START_IM CUR_IM END_IM LAST_IM;

delta = END_IM - START_IM;
END_IM = min(LAST_IM,END_IM+delta);

set(handles.CurrentImageDisplay,'String',sprintf('%d/%d',CUR_IM,END_IM));
set(handles.TimeDisplay,'String',handles.TimeDisplay.UserData(CUR_IM,:));
% Resetting ax Title
handles.RightAxes.Title.String = '';

actualize_plot(handles);

end