function buttonBack_Callback(~,~,handles)
% 113 -- Back Button - Steps back in movie

global CUR_IM START_IM END_IM;

if START_IM>1
    delta = END_IM - START_IM;
    END_IM = START_IM-1;
    START_IM = max(1,START_IM-(delta+1));
    CUR_IM = START_IM;
end

set(handles.CurrentImageDisplay,'String',sprintf('%d/%d',CUR_IM,END_IM));
set(handles.TimeDisplay,'String',handles.TimeDisplay.UserData(CUR_IM,:));
% Resetting ax Title
handles.RightAxes.Title.String = '';

actualize_plot(handles);

end