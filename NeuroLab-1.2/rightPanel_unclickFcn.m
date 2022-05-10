function rightPanel_unclickFcn(hObj,~,handles)
% Called when user manually releases cursor in RightAxes

global START_IM CUR_IM END_IM;

pt1 = get(handles.RightAxes,'UserData');
if ~isempty(pt1)
    pt = get(handles.RightAxes,'CurrentPoint');
    pt2 = [pt(1,1),pt(1,2)];
    if pt1(1,1)==pt2(1,1)
        CUR_IM = round(pt1(1,1));
        set(handles.CurrentImageDisplay,'String',sprintf('%d/%d',CUR_IM,END_IM));
        set(handles.TimeDisplay,'String',handles.TimeDisplay.UserData(CUR_IM,:));
    else
        START_IM = floor(min(pt1(1,1),max(min(pt2(1,1),END_IM),START_IM)));
        END_IM = ceil(max(pt1(1,1),max(min(pt2(1,1),END_IM),START_IM)));
        if START_IM>CUR_IM || END_IM<CUR_IM
            CUR_IM = START_IM;
        end
        set(handles.CurrentImageDisplay,'String',sprintf('%d/%d',CUR_IM,END_IM));
        set(handles.TimeDisplay,'String',handles.TimeDisplay.UserData(CUR_IM,:));
    end
    set(handles.RightAxes,'UserData',[]);
    set(handles.MainFigure,'WindowButtonMotionFcn', '');
    delete(findobj(handles.RightAxes,'Tag','T1','-or','Tag','T2','-or','Tag','T3'));
    actualize_plot(handles);
end
handles.Cursor.Visible = 'on';
set(hObj,'WindowButtonUp','');
end