function buttonPlus_Callback(~,~,handles)
% 112 - Called when user zooms in

global CUR_IM START_IM END_IM ;

if abs(CUR_IM-START_IM)<abs(END_IM-CUR_IM)
    END_IM = ceil((START_IM+END_IM)/2);
else
    START_IM = round((START_IM+END_IM)/2);
end

set(handles.CurrentImageDisplay,'String',sprintf('%d/%d',CUR_IM,END_IM));
set(handles.TimeDisplay,'String',handles.TimeDisplay.UserData(CUR_IM,:));
% Resetting ax Title
handles.RightAxes.Title.String = '';

actualize_plot(handles);

end