function rightPanel_motionFcn(~,~,handles)
% Called when user manually zooms in RightAxes

pt = get(handles.RightAxes,'CurrentPoint');
pt1 = get(handles.RightAxes,'UserData');
c = findobj(handles.RightAxes,'Tag','T2');
d = findobj(handles.RightAxes,'Tag','T3');
if ~isempty(pt1)
    set(c,'XData',[pt(1,1) pt(1,1)]);
    set(d,'X',[pt1(1,1),pt1(1,1),pt(1,1),pt(1,1)]);
end
% Resetting ax Title
handles.RightAxes.Title.String = '';

end