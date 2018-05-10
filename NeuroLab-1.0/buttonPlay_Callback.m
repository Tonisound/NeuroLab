function buttonPlay_Callback(hObj,~,handles)
% 103 -- Play/Pause toggle button

global CUR_IM START_IM END_IM;
load('Preferences.mat','GTraces');

while get(hObj,'Value')==get(hObj,'Max')
    CUR_IM = CUR_IM+1;
    if CUR_IM>END_IM
        CUR_IM = START_IM;
    end
    set(handles.CurrentImageDisplay,'String',sprintf('%d/%d',CUR_IM,END_IM));
    set(handles.TimeDisplay,'String',handles.TimeDisplay.UserData(CUR_IM,:));

    actualize_plot(handles);
    pause(1/GTraces.videospeed);
end

end
