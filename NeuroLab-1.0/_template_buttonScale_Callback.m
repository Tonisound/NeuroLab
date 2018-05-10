function template_buttonScale_Callback(hObj,~,ax)

%ax = findobj(handles.TopPanel,'Tag','Ax1');
lines = findobj(ax,'Tag','Trace_Spiko');
others = findobj(ax,'Tag','Trace_Region','-or','Tag','Trace_Pixel','-or','Tag','Trace_Box','-or','Tag','Trace_Mean');
visible = findobj(ax,'Visible','on');
others = visible(ismember(visible,others));

m = 0;
M = 0;
if isempty(others)
    for k=1:length(lines)
        m = min(m,min(lines(k).YData));
        M = max(M,max(lines(k).YData));
    end
else
    for k=1:length(others)
        m = min(m,min(others(k).YData));
        M = max(M,max(others(k).YData));
    end
end

switch hObj.Value
    case 0,
        for i=1:length(lines)
            scale = lines(i).UserData.scale;
            lines(i).YData = (lines(i).YData)/scale;
            lines(i).UserData.scale = 1;
        end
    case 1,
        for i=1:length(lines)
            max_l = max(lines(i).YData);
            scale = M/max_l;
            lines(i).YData = lines(i).YData*scale;
            lines(i).UserData.scale = scale;
        end
end

end