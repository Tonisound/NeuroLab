function buttonAutoScale_Callback(~,~,handles)
% 403 -- Callback AutoScale Button

global IM;

set(findobj(handles.RightAxes,'Tag','Cursor'),'Visible','off');
axis(handles.RightAxes,'auto y');
set(findobj(handles.RightAxes,'Tag','Cursor'),'YData',ylim(handles.RightAxes),'Visible','on');

handles.CenterAxes.YLim  = [.5 size(IM,1)+.5];
handles.CenterAxes.XLim  = [.5 size(IM,2)+.5];
boxCLim_Callback(handles.CLimBox,[],handles);

end