function buttonSkip_Callback(~,~,handles)
% 114 -- Skip Button - Skips in Movie

global CUR_IM START_IM END_IM LAST_IM;

if END_IM<LAST_IM
    delta = END_IM - START_IM;
    START_IM = END_IM+1;
    CUR_IM = START_IM;
    END_IM = min(LAST_IM,END_IM+delta+1);
end

set(handles.CurrentImageDisplay,'String',sprintf('%d/%d',CUR_IM,END_IM));
set(handles.TimeDisplay,'String',handles.TimeDisplay.UserData(CUR_IM,:));
% Resetting ax Title
handles.RightAxes.Title.String = '';

actualize_plot(handles);

end