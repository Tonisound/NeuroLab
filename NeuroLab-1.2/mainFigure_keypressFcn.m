function mainFigure_keypressFcn(hObj,evnt,handles)
% Main GUI Keyboard Control
% Called when user uses Keyboard for time selection

global CUR_IM START_IM END_IM;

%evnt.Key
switch evnt.Key
    case 'rightarrow'
        CUR_IM = min(CUR_IM+1,END_IM);
        set(handles.CurrentImageDisplay,'String',sprintf('%d/%d',CUR_IM,END_IM));
        set(handles.TimeDisplay,'String',handles.TimeDisplay.UserData(CUR_IM,:));
        actualize_plot(handles);
    case 'leftarrow'
        CUR_IM = max(CUR_IM-1,START_IM);
        set(handles.CurrentImageDisplay,'String',sprintf('%d/%d',CUR_IM,END_IM));
        set(handles.TimeDisplay,'String',handles.TimeDisplay.UserData(CUR_IM,:));
        actualize_plot(handles);
    case 'uparrow'
        buttonSkip_Callback([],[],handles);
    case 'downarrow'
        buttonBack_Callback([],[],handles);
    case 'subtract'
        buttonMinus_Callback([],[],handles);
    case 'add'
        buttonPlus_Callback([],[],handles);
    case 'multiply'
        buttonRescale_Callback([],[],handles);
    case 'space'
        val = handles.PlayToggle.Value;
        handles.PlayToggle.Value = abs(val-1);
        buttonPlay_Callback(handles.PlayToggle,[],handles);
    case 'o'
        menuEdit_prevTag_Callback([],[],handles);
    case 'p'
        menuEdit_nextTag_Callback([],[],handles);
end
    set(hObj,'WindowButtonUpFcn','');
end

  