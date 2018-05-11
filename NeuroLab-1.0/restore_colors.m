function restore_colors(handles)
% Restore Colors for Dynamic Traces and Markers

load('Preferences.mat','GDisp');
A=flipud(findobj(handles.CenterAxes,'Tag','Pixel'));
B=flipud(findobj(handles.RightAxes,'Tag','Trace_Pixel'));

for i=1:length(A)
    set(A(i),'MarkerFaceColor',char2rgb(GDisp.colors{i}));
    set(B(i),'Color',char2rgb(GDisp.colors{i}));
end

A=findobj(handles.CenterAxes,'Tag','Box');
B=findobj(handles.RightAxes,'Tag','Trace_Box');

for i=1:length(A)
    set(A(i),'FaceColor',char2rgb(GDisp.colors{i}));
    set(B(i),'Color',char2rgb(GDisp.colors{i}));
end

end